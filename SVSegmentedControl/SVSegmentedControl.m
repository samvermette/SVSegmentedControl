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


@interface SVSegmentedThumb ()

@property (nonatomic, assign) UIFont *font;

@property (nonatomic, readonly) UILabel *label;
@property (nonatomic, readonly) UILabel *secondLabel;
@property (nonatomic, readonly) UIImageView *imageView;
@property (nonatomic, readonly) UIImageView *secondImageView;

- (void)setTitle:(NSString*)title image:(UIImage*)image;
- (void)setSecondTitle:(NSString*)title image:(UIImage*)image;

- (void)activate;
- (void)deactivate;

@end



@interface SVSegmentedControl()

- (void)activate;
- (void)snap:(BOOL)animated;
- (void)crossFadeThumbContent;
- (void)toggle;
- (void)setupAccessibility;

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

@synthesize changeHandler, animateToInitialSelection, accessibilityElements;
@synthesize cornerRadius, tintColor, backgroundImage, font, textColor, textShadowColor, textShadowOffset, titleEdgeInsets, height, crossFadeLabelsOnDrag;
@synthesize sectionTitles, sectionImages, thumb, thumbRects, snapToIndex, trackingThumb, moved, activated, halfSize, dragOffset, segmentWidth, thumbHeight, thumbEdgeInset;
@synthesize mustSlideToChange, minimumOverlapToChange, touchTargetMargins;

@synthesize selectedIndex = _selectedIndex;

#pragma mark -
#pragma mark Life Cycle

- (id)initWithSectionTitles:(NSArray*)array {
    
	if (self = [super initWithFrame:CGRectZero]) {
        self.sectionTitles = array;
        self.thumbRects = [NSMutableArray arrayWithCapacity:[array count]];
        self.accessibilityElements = [NSMutableArray arrayWithCapacity:self.sectionTitles.count];
        
        self.backgroundColor = [UIColor clearColor];
        self.tintColor = [UIColor grayColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.animateToInitialSelection = NO;
        
        self.mustSlideToChange = NO;
        self.minimumOverlapToChange = 0.66;
        
        self.font = [UIFont boldSystemFontOfSize:15];
        self.textColor = [UIColor grayColor];
        self.textShadowColor = [UIColor blackColor];
        self.textShadowOffset = CGSizeMake(0, -1);
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.thumbEdgeInset = UIEdgeInsetsMake(2, 2, 3, 2);
        self.height = 32.0;
        self.cornerRadius = 4.0;
        
        self.selectedIndex = 0;
        
        [self setupAccessibility];
    }
    
	return self;
}

- (SVSegmentedThumb *)thumb {
    
    if(thumb == nil)
        thumb = [[SVSegmentedThumb alloc] initWithFrame:CGRectZero];
    
    return thumb;
}

- (void)updateSectionRects {
    
    int c = [self.sectionTitles count];
	int i = 0;
	
    if(CGRectIsEmpty(self.frame)) {
        self.segmentWidth = 0;
        
        for(NSString *titleString in self.sectionTitles) {
            CGFloat stringWidth = [titleString sizeWithFont:self.font].width+(self.titleEdgeInsets.left+self.titleEdgeInsets.right+self.thumbEdgeInset.left+self.thumbEdgeInset.right);
            
            if(self.sectionImages.count > i)
                stringWidth+=[(UIImage*)[self.sectionImages objectAtIndex:i] size].width+5;
            
            self.segmentWidth = MAX(stringWidth, self.segmentWidth);
            i++;
        }
        
        self.segmentWidth = ceil(self.segmentWidth/2.0)*2; // make it an even number so we can position with center
        self.bounds = CGRectMake(0, 0, self.segmentWidth*c, self.height);
    }
    else {
        self.segmentWidth = round(self.frame.size.width/self.sectionTitles.count);
        self.height = self.frame.size.height;
    }
    
    self.thumbHeight = self.thumb.backgroundImage ? self.thumb.backgroundImage.size.height : self.height-(self.thumbEdgeInset.top+self.thumbEdgeInset.bottom);
    
    i = 0;
    
	for(NSString *titleString in self.sectionTitles) {
        CGRect thumbRect = CGRectMake(self.segmentWidth*i, 0, self.segmentWidth, self.bounds.size.height);
        thumbRect.size.width+=10;
        thumbRect.size.height-=1; // for segmented bottom gloss
        
        if(i == 0 || i == self.sectionTitles.count-1)
            thumbRect.origin.x-=5;
        
        [self.thumbRects addObject:[NSValue valueWithCGRect:thumbRect]];
		i++;
	}
	
    self.thumb.frame = [[self.thumbRects objectAtIndex:self.selectedIndex] CGRectValue];
    self.thumb.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.thumb.bounds cornerRadius:2].CGPath;
    self.thumb.font = self.font;
    
    [self insertSubview:self.thumb atIndex:0];
    [self setThumbValuesForIndex:self.selectedIndex];
}

#pragma mark - Accessibility

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.segmentWidth = round(bounds.size.width/self.sectionTitles.count);
    [self setupAccessibility];
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    [self setupAccessibility];
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    
    if (newSuperview == nil)
        return; // control is being _removed_ from super view
    
    [self updateSectionRects];
}

- (void)setupAccessibility {
    [self.accessibilityElements removeAllObjects];
    
    NSUInteger i = 0;
    for (NSString *title in self.sectionTitles) {
        UIAccessibilityElement *element = [[UIAccessibilityElement alloc] initWithAccessibilityContainer:self];
        element.isAccessibilityElement = YES;
        element.accessibilityLabel = [NSString stringWithFormat:NSLocalizedString(@"%@ tab",), title];
        element.accessibilityHint = [NSString stringWithFormat:NSLocalizedString(@"Tab %d of %d",), i + 1, self.sectionTitles.count];
        
        [self.accessibilityElements addObject:element];
        i++;
    }
}

- (NSInteger)accessibilityElementCount {
    return self.accessibilityElements.count;
}

- (id)accessibilityElementAtIndex:(NSInteger)index {
    UIAccessibilityElement *element = [self.accessibilityElements objectAtIndex:index];
    
    CGFloat posY = ceil((CGRectGetHeight(self.bounds)-self.font.pointSize+self.font.descender)/2)+self.titleEdgeInsets.top-self.titleEdgeInsets.bottom-self.font.pointSize/2;
    element.accessibilityFrame = [self.window convertRect:CGRectMake((self.segmentWidth*index), posY, self.segmentWidth, self.font.pointSize*2) fromView:self];
    
    element.accessibilityTraits = UIAccessibilityTraitNone;
    if (index == self.selectedIndex)
        element.accessibilityTraits = element.accessibilityTraits | UIAccessibilityTraitSelected;
    else if (!self.enabled)
        element.accessibilityTraits = element.accessibilityTraits | UIAccessibilityTraitNotEnabled;
    
    return element;
}

- (NSInteger)indexOfAccessibilityElement:(id)element {
    NSString *title = [[[element accessibilityLabel] componentsSeparatedByString:@" "] objectAtIndex:0];
    return [self.sectionTitles indexOfObject:title];
}

#pragma mark - Tracking

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    return CGRectContainsPoint(CGRectMake(bounds.origin.x - self.touchTargetMargins.left, bounds.origin.y - self.touchTargetMargins.top,
                                          bounds.size.width + self.touchTargetMargins.left + self.touchTargetMargins.right,
                                          bounds.size.height + self.touchTargetMargins.bottom + self.touchTargetMargins.top), point);
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self.thumb];
	self.activated = NO;
	
	self.snapToIndex = MIN(floor(self.thumb.center.x/self.segmentWidth), self.sectionTitles.count-1);
	
	if([self.thumb pointInside:cPos withEvent:event]) {
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
		self.snapToIndex = MIN(floor(self.thumb.center.x/self.segmentWidth), self.sectionTitles.count-1);
        
        if(newMaxX-pMaxX > 10 || pMinX-newMinX > 10)
            self.moved = YES;
        
		[self snap:NO];
        
		if (self.crossFadeLabelsOnDrag)
			[self crossFadeThumbContent];
	}
	
	else if(self.trackingThumb) {
		self.thumb.center = CGPointMake(cPos.x+self.dragOffset, self.thumb.center.y);
		self.moved = YES;
        
		if (self.crossFadeLabelsOnDrag)
			[self crossFadeThumbContent];
	}
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self];
    CGFloat posX = cPos.x-5;
    
	CGFloat pMaxX = CGRectGetMaxX(self.bounds);
	CGFloat pMinX = CGRectGetMinX(self.bounds); // 5 is for thumb shadow
	
    if(!self.mustSlideToChange && !self.moved && self.trackingThumb && [self.sectionTitles count] == 2)
        [self toggle];
    else if(!self.activated && posX > pMinX && posX < pMaxX) {
        int potentialSnapToIndex = MIN(floor(cPos.x/self.segmentWidth), self.sectionTitles.count-1);
        
        if (self.mustSlideToChange) {
            CGRect potentialSegmentRect = CGRectMake(self.segmentWidth * potentialSnapToIndex, 0, self.segmentWidth, self.bounds.size.height);
            CGRect intersection = CGRectIntersection(potentialSegmentRect, self.thumb.frame);
            CGFloat overlap = intersection.size.width / self.segmentWidth;
            
            // Only snap to this segment if we are far enough within it
            if (overlap > self.minimumOverlapToChange)
                self.snapToIndex = potentialSnapToIndex;
        }
        else {
            self.snapToIndex = potentialSnapToIndex;
        }
        [self snap:YES];
    }
    else {
        if(posX < pMinX)
            posX = pMinX;
        
        if(posX >= pMaxX)
            posX = pMaxX-1;
        
        self.snapToIndex = MIN(floor(posX/self.segmentWidth), self.sectionTitles.count-1);
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
    
    if(self.crossFadeLabelsOnDrag) {
        self.thumb.secondLabel.alpha = 0;
        self.thumb.secondImageView.alpha = 0;
    }
    
	int index;
	
	if(self.snapToIndex != -1)
		index = self.snapToIndex;
	else
		index = MIN(floor(self.thumb.center.x/self.segmentWidth), self.sectionTitles.count-1);
	
    [self setThumbValuesForIndex:index];
    
    if(self.changeHandler && self.snapToIndex != self.selectedIndex && !self.isTracking)
		self.changeHandler(self.snapToIndex);
    
	if(animated)
		[self setSelectedIndex:index animated:YES];
	else
		self.thumb.frame = [[self.thumbRects objectAtIndex:index] CGRectValue];
}

- (void)crossFadeThumbContent {
    float segmentOverlap = ((int)(self.thumb.center.x * 10 / self.segmentWidth))/10.0f; // how far along are we dragging through the current segment
    int hoverIndex = floor(segmentOverlap); // the segment the touch is current hovering
    BOOL secondTitleOnLeft = (segmentOverlap - hoverIndex) < 0.5;
    
	if (secondTitleOnLeft && hoverIndex > 0) {
		self.thumb.label.alpha = self.thumb.imageView.alpha = 0.5 + (segmentOverlap - hoverIndex);
		self.thumb.secondLabel.alpha = self.thumb.secondImageView.alpha = 0.5 - (segmentOverlap - hoverIndex);
        [self setThumbSecondValuesForIndex:hoverIndex-1];
	}
    else if (hoverIndex + 1 < self.sectionTitles.count) {
		self.thumb.label.alpha = self.thumb.imageView.alpha = 0.5 + (1 - (segmentOverlap - hoverIndex));
		self.thumb.secondLabel.alpha = self.thumb.secondImageView.alpha = (segmentOverlap - hoverIndex) - 0.5;
        [self setThumbSecondValuesForIndex:hoverIndex+1];
	}
    else {
		self.thumb.secondLabel.alpha = self.thumb.secondImageView.alpha = 0.0;
		self.thumb.label.alpha = self.thumb.imageView.alpha = 1.0;
	}
    [self setThumbValuesForIndex:hoverIndex];
}

- (void)activate {
	
	self.trackingThumb = self.moved = NO;
	
    [self setThumbValuesForIndex:self.selectedIndex];
    
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

- (void)setSelectedIndex:(NSUInteger)index {
    [self setSelectedIndex:index animated:NO];
}

- (void)moveThumbToIndex:(NSUInteger)index animate:(BOOL)animate {
    [self setSelectedIndex:index animated:animate];
}

- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated {
    _selectedIndex = index;
    
    if(self.superview) {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        if(animated) {
            [self.thumb deactivate];
            [UIView animateWithDuration:0.2
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.thumb.frame = [[self.thumbRects objectAtIndex:index] CGRectValue];
                                 
                                 if(self.crossFadeLabelsOnDrag)
                                     [self crossFadeThumbContent];
                             }
                             completion:^(BOOL finished){
                                 if (finished) {
                                     [self activate];
                                 }
                             }];
        }
        
        else {
            self.thumb.frame = [[self.thumbRects objectAtIndex:index] CGRectValue];
            [self activate];
        }
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

- (UIImage*)imageForSectionIndex:(NSUInteger)index {
    if(self.sectionImages.count > index)
        return [self.sectionImages objectAtIndex:index];
    return nil;
}

- (void)setThumbValuesForIndex:(NSUInteger)index {
    [self.thumb setTitle:[self.sectionTitles objectAtIndex:index]
                   image:[self sectionImage:[self imageForSectionIndex:index] withTintColor:self.thumb.textColor]];
}

- (void)setThumbSecondValuesForIndex:(NSUInteger)index {
    [self.thumb setSecondTitle:[self.sectionTitles objectAtIndex:index]
                         image:[self sectionImage:[self imageForSectionIndex:index] withTintColor:self.thumb.textColor]];
}

#pragma mark - Drawing


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
		
	int i = 0;
	
	for(NSString *titleString in self.sectionTitles) {
        CGSize titleSize = [titleString sizeWithFont:self.font];
        CGFloat titleWidth = titleSize.width;
        CGFloat posY = ceil((CGRectGetHeight(rect)-titleSize.height)/2)+self.titleEdgeInsets.top-self.titleEdgeInsets.bottom;

        CGFloat imageWidth = 0;
        UIImage *image = nil;
        
        if(self.sectionImages.count > i) {
            image = [self.sectionImages objectAtIndex:i];
            imageWidth = image.size.width+5;
        }
        
        titleWidth+=imageWidth;
        CGFloat sectionOffset = round((self.segmentWidth-titleWidth)/2);
        CGFloat titlePosX = (self.segmentWidth*i)+sectionOffset;
        
        if(image)
            [[self sectionImage:image withTintColor:self.textColor] drawAtPoint:CGPointMake(titlePosX, round((rect.size.height-image.size.height)/2))];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		[titleString drawAtPoint:CGPointMake(titlePosX+imageWidth, posY) forWidth:self.segmentWidth withFont:self.font lineBreakMode:UILineBreakModeTailTruncation];
#else
        [titleString drawAtPoint:CGPointMake(titlePosX+imageWidth, posY) forWidth:self.segmentWidth withFont:self.font lineBreakMode:NSLineBreakByClipping];
#endif
		i++;
	}
}


#pragma mark - Image Methods Methods

- (UIImage *)sectionImage:(UIImage*)image withTintColor:(UIColor*)color {
    if(!image)
        return nil;
    
    CGRect rect = { CGPointZero, image.size };
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, image.scale); {
        [color set];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, rect.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, rect, [image CGImage]);
        CGContextFillRect(context, rect);
    }
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}


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
