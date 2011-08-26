//
//  SWSegmentedControl.m
//  SWSegmentedControl
//
//  Created by Sam Vermette on 26.10.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SVSegmentedControl.h"
#import "SVSegmentedThumb.h"

#define SVSegmentedControlBG [[UIImage imageNamed:@"SVSegmentedControl.bundle/inner-shadow"] stretchableImageWithLeftCapWidth:4 topCapHeight:5]


@interface SVSegmentedControl()

- (void)activate;
- (void)snap:(BOOL)animated;
- (void)updateTitles;
- (void)toggle;

@end


@implementation SVSegmentedControl

@synthesize delegate, selectedSegmentChangedHandler, selectedIndex, thumb;
@synthesize backgroundImage, font, textColor, shadowColor, shadowOffset, segmentPadding, titleEdgeInsets, height, crossFadeLabelsOnDrag;

#pragma mark -
#pragma mark Life Cycle

- (void)dealloc {
	
	[titlesArray release];
	
    self.selectedSegmentChangedHandler = nil;
    
    // avoid deprecated warnings
    [self setValue:nil forKey:@"delegate"];

	self.font = nil;
	self.textColor = nil;
	self.shadowColor = nil;
    self.backgroundImage = nil;
	
    [super dealloc];
}


- (id)initWithSectionTitles:(NSArray*)array {
    
	if (self = [super initWithFrame:CGRectZero]) {
        titlesArray = [array mutableCopy];
        
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.userInteractionEnabled = YES;
        self.clipsToBounds = NO;
        
        self.font = [UIFont boldSystemFontOfSize:15];
        self.textColor = [UIColor grayColor];
        self.shadowColor = [UIColor blackColor];
        self.shadowOffset = CGSizeMake(0, -1);
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        self.height = 32.0;
        
        self.selectedIndex = 0;
        
        thumb = [[SVSegmentedThumb alloc] initWithFrame:CGRectZero];
    }
	return self;
}


- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	if(!newSuperview || newSuperview == nil)
		return;

	int c = [titlesArray count];
	int i = 0;
	
	segmentWidth = 0;
	
	for(NSString *titleString in titlesArray) {
		
		CGFloat stringWidth = [titleString sizeWithFont:self.font].width+(self.titleEdgeInsets.left+self.titleEdgeInsets.right+4);
		
		if(stringWidth > segmentWidth)
			segmentWidth = stringWidth;
        
		i++;
	}
	
	segmentWidth = ceil((segmentWidth*2)/2); // make it an even number so we can position with center
	
	self.bounds = CGRectMake(0, 0, segmentWidth*c, self.height);
	
	i = 0;
    
    thumbHeight = self.thumb.backgroundImage ? self.thumb.backgroundImage.size.height : self.height-5;
    
	for(NSString *titleString in titlesArray) {
		thumbRects[i] = CGRectMake(segmentWidth*i+2, 2, segmentWidth-4, thumbHeight);
		i++;
	} 
	
	self.thumb.frame = thumbRects[0];
	self.thumb.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:thumb.bounds cornerRadius:2].CGPath;
	self.thumb.title = [titlesArray objectAtIndex:0];
    self.thumb.segmentedControl = self;
	
	self.thumb.font = self.font;
	
	[self insertSubview:self.thumb atIndex:0];
	[thumb release];
	
    [self moveThumbToIndex:selectedIndex animate:NO];
}


- (void)drawRect:(CGRect)rect {

    CGContextRef context = UIGraphicsGetCurrentContext();

    if(self.backgroundImage)
        [self.backgroundImage drawInRect:rect];
    
    else {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

        CGContextSaveGState(context);
        
        CGPathRef roundedRect = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4].CGPath;
        CGContextAddPath(context, roundedRect);
        CGContextClip(context);
            
        // BACKGROUND GRADIENT
        
        CGFloat components[4] = {    
            0, 0.55,
            0, 0.4
        };
        
        CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, NULL, 2);	
        CGContextDrawLinearGradient(context, gradient, CGPointMake(0,0), CGPointMake(0,CGRectGetHeight(rect)-1), 0);
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        [[[UIImage imageNamed:@"SVSegmentedControl.bundle/inner-shadow"] stretchableImageWithLeftCapWidth:4 topCapHeight:5] drawInRect:rect];
    }
    
	CGContextSetShadowWithColor(context, self.shadowOffset, 0, self.shadowColor.CGColor);
    
	[self.textColor set];
	
	CGFloat posY = ceil((CGRectGetHeight(rect)-self.font.pointSize+self.font.descender)/2)+self.titleEdgeInsets.top-self.titleEdgeInsets.bottom;
	int pointSize = self.font.pointSize;
	
	if(pointSize%2 != 0)
		posY--;
	
	int i = 0;
	
	for(NSString *titleString in titlesArray) {
		[titleString drawInRect:CGRectMake((segmentWidth*i), posY, segmentWidth, self.font.pointSize) withFont:self.font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		i++;
	}
}

#pragma mark -
#pragma mark Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super beginTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self.thumb];
	activated = NO;
	
	snapToIndex = floor(self.thumb.center.x/segmentWidth);
	
	if(CGRectContainsPoint(self.thumb.bounds, cPos)) {
		tracking = YES;
        [self.thumb deactivate];
		dragOffset = (self.thumb.frame.size.width/2)-cPos.x;
	}
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super continueTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self];
	CGFloat newPos = cPos.x+dragOffset;
	CGFloat newMaxX = newPos+(CGRectGetWidth(self.thumb.frame)/2);
	CGFloat newMinX = newPos-(CGRectGetWidth(self.thumb.frame)/2);
	
	CGFloat buffer = 2.0; // to prevent the thumb from moving slightly too far
	CGFloat pMaxX = CGRectGetMaxX(self.bounds) - buffer;
	CGFloat pMinX = CGRectGetMinX(self.bounds) + buffer;
	
	if(newMaxX > pMaxX || newMinX < pMinX) {
		snapToIndex = floor(self.thumb.center.x/segmentWidth);
		[self snap:NO];
        
		if (self.crossFadeLabelsOnDrag)
			[self updateTitles];
	}
	
	else if(tracking) {
		self.thumb.center = CGPointMake(cPos.x+dragOffset, self.thumb.center.y);
		moved = YES;
        
		if (self.crossFadeLabelsOnDrag)
			[self updateTitles];
	}
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [super endTrackingWithTouch:touch withEvent:event];
    
    CGPoint cPos = [touch locationInView:self];
	CGFloat pMaxX = CGRectGetMaxX(self.bounds);
	CGFloat pMinX = CGRectGetMinX(self.bounds);
	
	if(!moved && tracking && [titlesArray count] == 2)
		[self toggle];
	
	else if(!moved && !tracking && [titlesArray count] == 2)
		[self toggle];
	
	else if(!activated && cPos.x > pMinX && cPos.x < pMaxX) {
		snapToIndex = floor(cPos.x/segmentWidth);
		[self snap:YES];
	} 
	
	else {
        CGFloat posX = cPos.x;
        
        if(posX < pMinX)
            posX = pMinX;
        
        if(posX > pMaxX)
            posX = pMaxX-1;
        
        snapToIndex = floor(posX/segmentWidth);
        [self snap:YES];
    }
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
    [super cancelTrackingWithEvent:event];
    
    if(tracking)
		[self snap:NO];
}

#pragma mark -

- (void)snap:(BOOL)animated {

	[self.thumb deactivate];
    
    if(self.crossFadeLabelsOnDrag)
        self.thumb.secondTitleAlpha = 0;

	int index;
	
	if(snapToIndex != -1)
		index = snapToIndex;
	else
		index = floor(self.thumb.center.x/segmentWidth);
	
	self.thumb.title = [titlesArray objectAtIndex:index];

	if(animated)
		[self moveThumbToIndex:index animate:YES];
	else
		self.thumb.frame = thumbRects[index];
	
	snapToIndex = 0;
}

- (void)updateTitles {
	int hoverIndex = floor(self.thumb.center.x/segmentWidth);
	
	BOOL secondTitleOnLeft = ((self.thumb.center.x / segmentWidth) - hoverIndex) < 0.5;
	
	if (secondTitleOnLeft && hoverIndex > 0) {
		self.thumb.titleAlpha = 0.5 + ((self.thumb.center.x / segmentWidth) - hoverIndex);
		self.thumb.secondTitle = [titlesArray objectAtIndex:hoverIndex - 1];
		self.thumb.secondTitleAlpha = 0.5 - ((self.thumb.center.x / segmentWidth) - hoverIndex);
	}
	
    else if (hoverIndex + 1 < titlesArray.count) {
		self.thumb.titleAlpha = 0.5 + (1 - ((self.thumb.center.x / segmentWidth) - hoverIndex));
		self.thumb.secondTitle = [titlesArray objectAtIndex:hoverIndex + 1];
		self.thumb.secondTitleAlpha = ((self.thumb.center.x / segmentWidth) - hoverIndex) - 0.5;
	}
	
    else {
		self.thumb.secondTitle = nil;
		self.thumb.titleAlpha = 1.0;
	}

	self.thumb.title = [titlesArray objectAtIndex:hoverIndex];
}

- (void)activate {
	
	tracking = moved = NO;
	
	self.thumb.title = [titlesArray objectAtIndex:self.selectedIndex];
    	
	if(self.selectedSegmentChangedHandler)
		self.selectedSegmentChangedHandler(self);
    
    if([self valueForKey:@"delegate"]) {
        id controlDelegate = [self valueForKey:@"delegate"];
        
        if([controlDelegate respondsToSelector:@selector(segmentedControl:didSelectIndex:)])
            [controlDelegate segmentedControl:self didSelectIndex:selectedIndex];
    }

	[UIView animateWithDuration:0.1 
						  delay:0 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{
						 activated = YES;
						 [self.thumb activate];
					 }
					 completion:NULL];
}


- (void)toggle {
	
	if(snapToIndex == 0)
		snapToIndex = 1;
	else
		snapToIndex = 0;
	
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
							 self.thumb.frame = thumbRects[segmentIndex];

							 if(self.crossFadeLabelsOnDrag)
								 [self updateTitles];
						 }
						 completion:^(BOOL finished){
							 [self activate];
						 }];
	}
	
	else {
		self.thumb.frame = thumbRects[segmentIndex];
		[self activate];
	}
}

#pragma mark -

- (void)setBackgroundImage:(UIImage *)newImage {
    
    if(backgroundImage)
        [backgroundImage release], backgroundImage = nil;
    
    if(newImage) {
        backgroundImage = [newImage retain];
        self.height = backgroundImage.size.height;
    }
}

- (void)setSegmentPadding:(CGFloat)newPadding {
    // deprecated; this method is provided for backward compatibility
    // use titleEdgeInsets instead
    
    self.titleEdgeInsets = UIEdgeInsetsMake(0, newPadding, 0, newPadding);
}



@end
