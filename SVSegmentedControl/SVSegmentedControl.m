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
@synthesize font, textColor, shadowColor, shadowOffset, segmentPadding, height, crossFadeLabelsOnDrag;

#pragma mark -
#pragma mark Life Cycle

- (void)dealloc {
	
	[titlesArray release];
	
	self.delegate = nil;
	self.selectedSegmentChangedHandler = nil;
	self.font = nil;
	self.textColor = nil;
	self.shadowColor = nil;
	
    [super dealloc];
}

- (id)initWithSectionTitles:(NSArray*)array {
	
	titlesArray = [array retain];
	
	self = [super initWithFrame:CGRectZero];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = YES;
	self.userInteractionEnabled = YES;
	
	self.font = [UIFont boldSystemFontOfSize:15];
	self.textColor = [UIColor grayColor];
	self.shadowColor = [UIColor blackColor];
	self.shadowOffset = CGSizeMake(0, -1);
	
	self.segmentPadding = 10.0;
	self.height = 32.0;
	
	self.selectedIndex = 0;
	
	thumb = [[SVSegmentedThumb alloc] initWithFrame:CGRectZero];

	return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
	
	if(!newSuperview || newSuperview == nil)
		return;

	int c = [titlesArray count];
	int i = 0;
	
	segmentWidth = 0;
	
	for(NSString *titleString in titlesArray) {
		
		CGFloat stringWidth = [titleString sizeWithFont:self.font].width+((self.segmentPadding+2)*2);
		
		if(stringWidth > segmentWidth)
			segmentWidth = stringWidth;
		i++;
	}
	
	segmentWidth = ceil((segmentWidth*2)/2); // make it an even number so we can position with center
	
	self.bounds = CGRectMake(0, 0, segmentWidth*c, self.height);
	
	i = 0;
    
	for(NSString *titleString in titlesArray) {
		thumbRects[i] = CGRectMake(segmentWidth*i, 0, segmentWidth, CGRectGetHeight(self.bounds)-1);
		i++;
	} 
	
	self.thumb.frame = CGRectInset(thumbRects[0], 2, 2);
	self.thumb.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:thumb.bounds cornerRadius:2].CGPath;
	self.thumb.title = [titlesArray objectAtIndex:0];
	
	self.thumb.font = self.font;
	
	[self insertSubview:self.thumb atIndex:0];
	[thumb release];
	
	self.selectedIndex = selectedIndex;
}


- (void)drawRect:(CGRect)rect {

	CGContextRef context = UIGraphicsGetCurrentContext();
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

	CGContextSetShadowWithColor(context, self.shadowOffset, 0, self.shadowColor.CGColor);
	[self.textColor set];
	
	CGFloat posY = ceil((CGRectGetHeight(rect)-self.font.pointSize+self.font.descender)/2);
	int pointSize = self.font.pointSize;
	
	if(pointSize%2 != 0)
		posY--;
	
	int i = 0;
	
	for(NSString *titleString in titlesArray) {
		[titleString drawInRect:CGRectMake((segmentWidth*i), posY, segmentWidth, self.font.pointSize) withFont:self.font lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
		i++;
	}
	
	CGContextRestoreGState(context);
	
	[SVSegmentedControlBG drawInRect:rect];
}

#pragma mark -
#pragma mark Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CGPoint cPos = [[touches anyObject] locationInView:self.thumb];
	activated = NO;
	
	snapToIndex = floor(self.thumb.center.x/segmentWidth);
	
	if(CGRectContainsPoint(self.thumb.bounds, cPos)) {
		tracking = YES;

		if (!self.crossFadeLabelsOnDrag)
			[self.thumb deactivate];
	
		dragOffset = (self.thumb.frame.size.width/2)-cPos.x;
		return;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(!tracking)
		return;
	
	CGPoint cPos = [[touches anyObject] locationInView:self];
	CGFloat newPos = cPos.x+dragOffset;
	CGFloat newMaxX = newPos+(CGRectGetWidth(self.thumb.frame)/2);
	CGFloat newMinX = newPos-(CGRectGetWidth(self.thumb.frame)/2);
	
	CGFloat buffer = 2.0;		// to prevent the thumb from moving slightly too far
	CGFloat pMaxX = CGRectGetMaxX(self.bounds) - buffer;
	CGFloat pMinX = CGRectGetMinX(self.bounds) + buffer;
	
	if(newMaxX > pMaxX || newMinX < pMinX) {
		snapToIndex = floor(self.thumb.center.x/segmentWidth);
		[self snap:NO];

		if (self.crossFadeLabelsOnDrag)
			[self updateTitles];
		return;
	}
	
	else if(tracking) {
		self.thumb.center = CGPointMake(cPos.x+dragOffset, self.thumb.center.y);
		moved = YES;

		if (self.crossFadeLabelsOnDrag)
			[self updateTitles];
	}
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	
	CGPoint cPos = [[touches anyObject] locationInView:self];
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
	
	else
		[self activate];
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	
	if(tracking)
		[self snap:NO];
}

#pragma mark -

- (void)snap:(BOOL)animated {

	if (!self.crossFadeLabelsOnDrag)
		[self.thumb deactivate];

	int index;
	
	if(snapToIndex != -1)
		index = snapToIndex;
	else
		index = floor(self.thumb.center.x/segmentWidth);
	
	self.thumb.title = [titlesArray objectAtIndex:index];

	if(animated)
		[self moveThumbToIndex:index animate:YES];
	else
		self.thumb.frame = CGRectInset(thumbRects[index], 2, 2);
	
	snapToIndex = 0;
}

- (void)updateTitles {
	int hoverIndex = floor(self.thumb.center.x/segmentWidth);
	
	BOOL secondTitleOnLeft = ((self.thumb.center.x / segmentWidth) - hoverIndex) < 0.5;
	
	if (secondTitleOnLeft && hoverIndex > 0)
	{
		self.thumb.titleAlpha = 0.5 + ((self.thumb.center.x / segmentWidth) - hoverIndex);
		self.thumb.secondTitle = [titlesArray objectAtIndex:hoverIndex - 1];
		self.thumb.secondTitleAlpha = 0.5 - ((self.thumb.center.x / segmentWidth) - hoverIndex);
	}
	else if (hoverIndex + 1 < titlesArray.count)
	{
		self.thumb.titleAlpha = 0.5 + (1 - ((self.thumb.center.x / segmentWidth) - hoverIndex));
		self.thumb.secondTitle = [titlesArray objectAtIndex:hoverIndex + 1];
		self.thumb.secondTitleAlpha = ((self.thumb.center.x / segmentWidth) - hoverIndex) - 0.5;
	}
	else
	{
		self.thumb.secondTitle = nil;
		self.thumb.titleAlpha = 1.0;
	}

	self.thumb.title = [titlesArray objectAtIndex:hoverIndex];
}

- (void)activate {
	
	tracking = moved = NO;
	
	self.selectedIndex = floor(self.thumb.center.x/segmentWidth);
	self.thumb.title = [titlesArray objectAtIndex:self.selectedIndex];

	if ([(id)self.delegate respondsToSelector:@selector(segmentedControl:didSelectIndex:)])
		[self.delegate segmentedControl:self didSelectIndex:selectedIndex];
	
	if (self.selectedSegmentChangedHandler)
		self.selectedSegmentChangedHandler(self);

	[UIView animateWithDuration:0.1 
						  delay:0 
						options:UIViewAnimationOptionAllowUserInteraction 
					 animations:^{
						 activated = YES;

						 if (!self.crossFadeLabelsOnDrag)
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

	if(animate) {
		if (!self.crossFadeLabelsOnDrag)
			[self.thumb deactivate];
		
		[UIView animateWithDuration:0.2 
							  delay:0 
							options:UIViewAnimationOptionCurveEaseOut 
						 animations:^{
							 self.thumb.frame = CGRectInset(thumbRects[segmentIndex], 2, 2);

							 if (self.crossFadeLabelsOnDrag)
								 [self updateTitles];
						 }
						 completion:^(BOOL finished){
							 [self activate];
						 }];
	}
	
	else {
		self.thumb.frame = CGRectInset(thumbRects[segmentIndex], 2, 2);
		[self activate];
	}
}

- (void)setSelectedIndex:(NSUInteger)newIndex {
	
	selectedIndex = newIndex;
	self.thumb.frame = CGRectInset(thumbRects[newIndex], 2, 2);
	self.thumb.title = [titlesArray objectAtIndex:newIndex];
}


@end
