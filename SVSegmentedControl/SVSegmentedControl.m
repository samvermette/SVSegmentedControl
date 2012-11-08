//
// SWSegmentedControl.m
// SWSegmentedControl
//
// Created by Sam Vermette on 26.10.10.
// Copyright 2010 Sam Vermette. All rights reserved.
//
// https://github.com/samvermette/SVSegmentedControl

#import <QuartzCore/QuartzCore.h>
#import "SVSegmentedControl.h"

#define SVSegmentedControlBG [[UIImage imageNamed:@"SVSegmentedControl.bundle/inner-shadow"] stretchableImageWithLeftCapWidth:4 topCapHeight:5]


@interface SVSegmentedThumb ()

@property (nonatomic, assign) SVSegmentedControl *segmentedControl;
@property (nonatomic, assign) UIFont *font;

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UILabel *secondLabel;

- (void)activate;
- (void)deactivate;

@end



@interface SVSegmentedControl()

- (void)activate;
- (void)snap:(BOOL)animated;
- (void)updateTitles;
- (void)toggle;
- (void)setupAccessibility;

@property (nonatomic, strong) NSMutableArray *titlesArray;
@property (nonatomic, strong) NSMutableArray *thumbRects;
@property (nonatomic, strong) NSMutableArray *accessibilityElements;

@property (nonatomic, readwrite) NSUInteger snapToIndex;
@property (nonatomic, readwrite) BOOL trackingThumb;
@property (nonatomic, readwrite) BOOL moved;
@property (nonatomic, readwrite) BOOL activated;

@property (nonatomic, readwrite) CGFloat halfSize;
@property (nonatomic, readwrite) CGFloat dragOffset;
@property (nonatomic, readwrite) CGFloat segmentWidth;
@property (nonatomic, readwrite) CGFloat thumbHeight;

@end


@implementation SVSegmentedControl

@synthesize selectedSegmentChangedHandler, changeHandler, selectedIndex, animateToInitialSelection, accessibilityElements;
@synthesize cornerRadius, tintColor, backgroundImage, font, textColor, textShadowColor, textShadowOffset, segmentPadding, titleEdgeInsets, height, crossFadeLabelsOnDrag;
@synthesize titlesArray, thumb, thumbRects, snapToIndex, trackingThumb, moved, activated, halfSize, dragOffset, segmentWidth, thumbHeight;

// deprecated
@synthesize delegate, thumbEdgeInset, shadowColor, shadowOffset;

#pragma mark -
#pragma mark Life Cycle

- (id)initWithSectionTitles:(NSArray*)array {
    
	if (self = [super initWithFrame:CGRectZero]) {
        self.titlesArray = [NSMutableArray arrayWithArray:array];
        self.thumbRects = [NSMutableArray arrayWithCapacity:[array count]];
        self.accessibilityElements = [NSMutableArray arrayWithCapacity:self.titlesArray.count];
        
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor grayColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.animateToInitialSelection = NO;
        
        self.font = [UIFont boldSystemFontOfSize:15];
        self.textColor = [UIColor grayColor];
        self.textShadowColor = [UIColor blackColor];
        self.textShadowOffset = CGSizeMake(0, -1);
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.thumbEdgeInset = UIEdgeInsetsMake(2, 2, 3, 2);
        self.height = 32.0;
        self.cornerRadius = 4.0;
        
        self.selectedIndex = 0;
        self.thumb.segmentedControl = self;
    }
    
	return self;
}

- (SVSegmentedThumb *)thumb {
    
    if(thumb == nil)
        thumb = [[SVSegmentedThumb alloc] initWithFrame:CGRectZero];
    
    return thumb;
}


#pragma mark - Drawing code


- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();

    if(self.backgroundImage)
        [self.backgroundImage drawInRect:rect];
    
    else {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        
        // bottom gloss
        CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:1 alpha:0.1].CGColor);
        CGPathRef bottomGlossRect = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, rect.size.width, rect.size.height) cornerRadius:self.cornerRadius].CGPath;
        CGContextAddPath(context, bottomGlossRect);
        CGContextFillPath(context);
        
        CGRect insetRect = CGRectMake(0, 0, rect.size.width, rect.size.height-1);
        CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:self.cornerRadius].CGPath;
        CGContextAddPath(context, roundedRect);
        CGContextClip(context);
        
        // background tint
        CGFloat components[4] = {0.10, CGColorGetAlpha(self.tintColor.CGColor),  0.12, CGColorGetAlpha(self.tintColor.CGColor)};
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);	
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,CGRectGetHeight(rect)-1), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        [self.tintColor set];
        UIRectFillUsingBlendMode(rect, kCGBlendModeOverlay);
        
        
        UIColor *innerShadowColor = [UIColor colorWithWhite:0 alpha:0.8];
        NSArray *paths = [NSArray arrayWithObject:[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:self.cornerRadius]];
        UIImage *mask = [self maskWithPaths:paths bounds:CGRectInset(insetRect, -10, -10)];
        UIImage *invertedImage = [self invertedImageWithMask:mask color:innerShadowColor];
        
        CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 2, innerShadowColor.CGColor);
        [invertedImage drawAtPoint:CGPointMake(-10, -10)];

    }
    
	CGContextSetShadowWithColor(context, self.textShadowOffset, 0, self.textShadowColor.CGColor);
	[self.textColor set];
	
	CGFloat posY = ceil((CGRectGetHeight(rect)-self.font.pointSize+self.font.descender)/2)+self.titleEdgeInsets.top-self.titleEdgeInsets.bottom;
	int pointSize = self.font.pointSize;
	
	if(pointSize%2 != 0)
		posY--;
	
	int i = 0;
	
	for(NSString *titleString in self.titlesArray) {
        CGRect labelRect = CGRectMake((self.segmentWidth*i), posY, self.segmentWidth, self.font.pointSize);
        //CGContextFillRect(context, labelRect);
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		[titleString drawInRect:labelRect withFont:self.font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
#else
		[titleString drawInRect:labelRect withFont:self.font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
#endif
		i++;
	}
}

#pragma mark - Accessibility

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.segmentWidth = round(bounds.size.width/self.titlesArray.count);
    [self setupAccessibility];
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    [self setupAccessibility];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    int c = [self.titlesArray count];
	int i = 0;
	
    if(CGRectIsEmpty(self.frame)) {
        self.segmentWidth = 0;
        
        for(NSString *titleString in self.titlesArray) {
            CGFloat stringWidth = [titleString sizeWithFont:self.font].width+(self.titleEdgeInsets.left+self.titleEdgeInsets.right+self.thumbEdgeInset.left+self.thumbEdgeInset.right);
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
        }
        
        self.segmentWidth = ceil(self.segmentWidth/2.0)*2; // make it an even number so we can position with center
        self.bounds = CGRectMake(0, 0, self.segmentWidth*c, self.height);
    }
    else {
        self.segmentWidth = round(self.frame.size.width/self.titlesArray.count);
        self.height = self.frame.size.height;
    }
    
    self.thumbHeight = self.thumb.backgroundImage ? self.thumb.backgroundImage.size.height : self.height-(self.thumbEdgeInset.top+self.thumbEdgeInset.bottom);
    
    i = 0;
    
	for(NSString *titleString in self.titlesArray) {
        CGRect thumbRect = CGRectMake(self.segmentWidth*i, 0, self.segmentWidth, self.bounds.size.height);
        thumbRect.size.width+=10;
        thumbRect.size.height-=1; // for segmented bottom gloss
        
        if(i == 0 || i == self.titlesArray.count-1)
            thumbRect.origin.x-=5;
        
        [self.thumbRects addObject:[NSValue valueWithCGRect:thumbRect]];
		i++;
	}
	
	self.thumb.frame = [[self.thumbRects objectAtIndex:0] CGRectValue];
	self.thumb.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.thumb.bounds cornerRadius:2].CGPath;
	self.thumb.label.text = [self.titlesArray objectAtIndex:0];
	self.thumb.font = self.font;
	
	[self insertSubview:self.thumb atIndex:0];
    
    BOOL animateInitial = self.animateToInitialSelection;
    
    if(self.selectedIndex == 0)
        animateInitial = NO;
	
    [self moveThumbToIndex:selectedIndex animate:animateInitial];
}

- (void)setupAccessibility {
    [self.accessibilityElements removeAllObjects];
    
    NSUInteger i = 0;
    for (NSString *title in self.titlesArray) {
        UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        element.isAccessibilityElement = YES;
        element.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%@ tab",), title];
        element.accessibilityHint = [NSString stringWithFormat:NSLocalizedString(@"Tab %d of %d",), i + 1, self.titlesArray.count];
        
        [self.accessibilityElements addObject:element];
        i++;
    }
}

- (NSInteger)accessibilityElementCount {
    return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    UIAccessibilityElement *element = [self.accessibilityElements objectAtIndex:index];
    
    CGFloat posY = ceil((CGRectGetHeight(self.bounds)-self.font.pointSize+self.font.descender)/2)+self.titleEdgeInsets.top-self.titleEdgeInsets.bottom;
    element.accessibilityFrame = [self.window convertRect:CGRectMake((self.segmentWidth*index), posY, self.segmentWidth, self.font.pointSize) fromView:self];
    
    element.accessibilityTraits = UIAccessibilityTraitNone;
    if (index == self.selectedIndex)
        element.accessibilityTraits = element.accessibilityTraits | UIAccessibilityTraitSelected;
    else if (!self.enabled)
        element.accessibilityTraits = element.accessibilityTraits | UIAccessibilityTraitNotEnabled;
    
    return element;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    NSString *title = [[[element accessibilityLabel] componentsSeparatedByString:@" "] objectAtIndex:0];
    return [self.titlesArray indexOfObject:title];
}

#pragma mark -
#pragma mark Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self.thumb];
	self.activated = NO;
	
	self.snapToIndex = floor(self.thumb.center.x/self.segmentWidth);
	
	if(CGRectContainsPoint(self.thumb.bounds, cPos)) {
		self.trackingThumb = YES;
        [self.thumb deactivate];
		self.dragOffset = (self.thumb.frame.size.width/2)-cPos.x;
	}
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self];
	CGFloat newPos = cPos.x+self.dragOffset;
	CGFloat newMaxX = newPos+(CGRectGetWidth(self.thumb.frame)/2);
	CGFloat newMinX = newPos-(CGRectGetWidth(self.thumb.frame)/2);
	
	CGFloat buffer = 0.0; // to prevent the thumb from moving slightly too far
	CGFloat pMaxX = CGRectGetMaxX(self.bounds) - buffer+5;
	CGFloat pMinX = CGRectGetMinX(self.bounds) + buffer-5;
	
	if((newMaxX > pMaxX || newMinX < pMinX) && self.trackingThumb) {
		self.snapToIndex = floor(self.thumb.center.x/self.segmentWidth);
        
        if(newMaxX-pMaxX > 10 || pMinX-newMinX > 10)
            self.moved = YES;
        
		[self snap:NO];
        
		if (self.crossFadeLabelsOnDrag)
			[self updateTitles];
	}
	
	else if(self.trackingThumb) {
		self.thumb.center = CGPointMake(cPos.x+self.dragOffset, self.thumb.center.y);
		self.moved = YES;
        
		if (self.crossFadeLabelsOnDrag)
			[self updateTitles];
	}
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self];
    CGFloat posX = cPos.x-5;

	CGFloat pMaxX = CGRectGetMaxX(self.bounds);
	CGFloat pMinX = CGRectGetMinX(self.bounds); // 5 is for thumb shadow
	
	if(!self.moved && self.trackingThumb && [self.titlesArray count] == 2)
		[self toggle];
	
	else if(!self.activated && posX > pMinX && posX < pMaxX) {
		self.snapToIndex = floor(cPos.x/self.segmentWidth);
		[self snap:YES];
	} 
	
	else {        
        if(posX < pMinX)
            posX = pMinX;
        
        if(posX >= pMaxX)
            posX = pMaxX-1;
        
        self.snapToIndex = floor(posX/self.segmentWidth);
        [self snap:YES];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    
    if(self.trackingThumb)
		[self snap:NO];
}

#pragma mark -

- (void)snap:(BOOL)animated {

	[self.thumb deactivate];
    
    if(self.crossFadeLabelsOnDrag)
        self.thumb.secondLabel.alpha = 0;

	int index;
	
	if(self.snapToIndex != -1)
		index = self.snapToIndex;
	else
		index = floor(self.thumb.center.x/self.segmentWidth);
	
	self.thumb.label.text = [self.titlesArray objectAtIndex:index];
    
    if(self.changeHandler && self.snapToIndex != self.selectedIndex && !self.isTracking)
		self.changeHandler(self.snapToIndex);

	if(animated)
		[self moveThumbToIndex:index animate:YES];
	else
		self.thumb.frame = [[self.thumbRects objectAtIndex:index] CGRectValue];
}

- (void)updateTitles {
	int hoverIndex = floor(self.thumb.center.x/self.segmentWidth);
	
	BOOL secondTitleOnLeft = ((self.thumb.center.x / self.segmentWidth) - hoverIndex) < 0.5;
	
	if (secondTitleOnLeft && hoverIndex > 0) {
		self.thumb.label.alpha = 0.5 + ((self.thumb.center.x / self.segmentWidth) - hoverIndex);
		self.thumb.secondLabel.text = [self.titlesArray objectAtIndex:hoverIndex - 1];
		self.thumb.secondLabel.alpha = 0.5 - ((self.thumb.center.x / self.segmentWidth) - hoverIndex);
	}
	
    else if (hoverIndex + 1 < self.titlesArray.count) {
		self.thumb.label.alpha = 0.5 + (1 - ((self.thumb.center.x / self.segmentWidth) - hoverIndex));
		self.thumb.secondLabel.text = [self.titlesArray objectAtIndex:hoverIndex + 1];
		self.thumb.secondLabel.alpha = ((self.thumb.center.x / self.segmentWidth) - hoverIndex) - 0.5;
	}
	
    else {
		self.thumb.secondLabel.text = nil;
		self.thumb.label.alpha = 1.0;
	}

	self.thumb.label.text = [self.titlesArray objectAtIndex:hoverIndex];
}

- (void)activate {
	
	self.trackingThumb = self.moved = NO;
	
	self.thumb.label.text = [self.titlesArray objectAtIndex:self.selectedIndex];
    
    void (^oldChangeHandler)(id sender) = [self valueForKey:@"selectedSegmentChangedHandler"];
    	
	if(oldChangeHandler)
		oldChangeHandler(self);
    
    if([self valueForKey:@"delegate"]) {
        id controlDelegate = [self valueForKey:@"delegate"];
        
        if([controlDelegate respondsToSelector:@selector(segmentedControl:didSelectIndex:)])
            [controlDelegate segmentedControl:self didSelectIndex:selectedIndex];
    }

	[UIView animateWithDuration:0.1 
						  delay:0 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{
						 self.activated = YES;
						 [self.thumb activate];
					 }
					 completion:NULL];
}


- (void)toggle {
	
	if(self.snapToIndex == 0)
		self.snapToIndex = 1;
	else
		self.snapToIndex = 0;
	
	[self snap:YES];
}

- (void)moveThumbToIndex:(NSUInteger)segmentIndex animate:(BOOL)animate {

    self.selectedIndex = segmentIndex;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
	if(animate) {
        
        [self.thumb deactivate];
		
		[UIView animateWithDuration:0.2 
							  delay:0 
							options:UIViewAnimationOptionCurveEaseOut 
						 animations:^{
							 self.thumb.frame = [[self.thumbRects objectAtIndex:segmentIndex] CGRectValue];

							 if(self.crossFadeLabelsOnDrag)
								 [self updateTitles];
						 }
						 completion:^(BOOL finished){
                             if (finished) {
                                 [self activate];
                             }
						 }];
	}
	
	else {
		self.thumb.frame = [[self.thumbRects objectAtIndex:segmentIndex] CGRectValue];
		[self activate];
	}
}

#pragma mark -

- (void)setBackgroundImage:(UIImage *)newImage {
    
    if(backgroundImage)
        backgroundImage = nil;
    
    if(newImage) {
        backgroundImage = newImage;
        self.height = backgroundImage.size.height;
    }
}

#pragma mark - Support for deprecated methods

- (void)setSegmentPadding:(CGFloat)newPadding {
    self.titleEdgeInsets = UIEdgeInsetsMake(0, newPadding, 0, newPadding);
}

- (void)setShadowOffset:(CGSize)newOffset {
    self.textShadowOffset = newOffset;
}

- (void)setShadowColor:(UIColor *)newColor {
    self.textShadowColor = newColor;
}

#pragma mark - Inner Glow Methods

// http://stackoverflow.com/a/8482103/87158

- (UIImage *)maskWithPaths:(NSArray *)paths bounds:(CGRect)bounds
{
    // Get the scale for good results on Retina screens.
    CGFloat scale = [UIScreen mainScreen].scale;
    CGSize scaledSize = CGSizeMake(bounds.size.width * scale, bounds.size.height * scale);
    
    // Create the bitmap with just an alpha channel.
    // When created, it has value 0 at every pixel.
    CGContextRef gc = CGBitmapContextCreate(NULL, scaledSize.width, scaledSize.height, 8, scaledSize.width, NULL, kCGImageAlphaOnly);
    
    // Adjust the current transform matrix for the screen scale.
    CGContextScaleCTM(gc, scale, scale);
    // Adjust the CTM in case the bounds origin isn't zero.
    CGContextTranslateCTM(gc, -bounds.origin.x, -bounds.origin.y);
    
    // whiteColor has all components 1, including alpha.
    CGContextSetFillColorWithColor(gc, [UIColor whiteColor].CGColor);
    
    // Fill each path into the mask.
    for (UIBezierPath *path in paths) {
        CGContextBeginPath(gc);
        CGContextAddPath(gc, path.CGPath);
        CGContextFillPath(gc);
    }
    
    // Turn the bitmap context into a UIImage.
    CGImageRef cgImage = CGBitmapContextCreateImage(gc);
    CGContextRelease(gc);
    UIImage *image = [UIImage imageWithCGImage:cgImage scale:scale orientation:UIImageOrientationDownMirrored];
    CGImageRelease(cgImage);
    return image;
}

- (UIImage *)invertedImageWithMask:(UIImage *)mask color:(UIColor *)color
{
    CGRect rect = { CGPointZero, mask.size };
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, mask.scale); {
        // Fill the entire image with color.
        [color setFill];
        UIRectFill(rect);
        // Now erase the masked part.
        CGContextClipToMask(UIGraphicsGetCurrentContext(), rect, mask.CGImage);
        CGContextClearRect(UIGraphicsGetCurrentContext(), rect);
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)drawInnerGlowWithPaths:(NSArray *)paths bounds:(CGRect)bounds color:(UIColor *)color offset:(CGSize)offset blur:(CGFloat)blur
{
    UIImage *mask = [self maskWithPaths:paths bounds:bounds];
    UIImage *invertedImage = [self invertedImageWithMask:mask color:color];
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    // Save the graphics state so I can restore the clip and
    // shadow attributes after drawing.
    CGContextSaveGState(gc); {
        CGContextClipToMask(gc, bounds, mask.CGImage);
        CGContextSetShadowWithColor(gc, offset, blur, color.CGColor);
        [invertedImage drawInRect:bounds];
    } CGContextRestoreGState(gc);
}

@end
