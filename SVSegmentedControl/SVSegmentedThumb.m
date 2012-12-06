//
// SVSegmentedThumb.m
// SVSegmentedControl
//
// Created by Sam Vermette on 25.05.11.
// Copyright 2011 Sam Vermette. All rights reserved.
//
// https://github.com/samvermette/SVSegmentedControl
//

#import "SVSegmentedThumb.h"
#import <QuartzCore/QuartzCore.h>
#import "SVSegmentedControl.h"

@interface SVSegmentedThumb ()

@property (nonatomic, readwrite) BOOL selected;
@property (nonatomic, readonly) SVSegmentedControl *segmentedControl;
@property (nonatomic, strong) UIImageView *thumbBackgroundImageView;
@property (nonatomic, readonly) UIFont *font;

@property (strong, nonatomic, readonly) UILabel *firstLabel;
@property (strong, nonatomic, readonly) UILabel *secondLabel; // when crossFadeLabelsOnDrag == YES
@property (strong, nonatomic, readonly) UIImageView *firstImageView;
@property (strong, nonatomic, readonly) UIImageView *secondImageView; // when crossFadeLabelsOnDrag == YES

@property (nonatomic, readonly) BOOL isAtLastIndex;
@property (nonatomic, readonly) BOOL isAtFirstIndex;

- (void)activate;
- (void)deactivate;

@end


@implementation SVSegmentedThumb

@synthesize segmentedControl, backgroundImage, highlightedBackgroundImage, font, tintColor, textColor, textShadowColor, textShadowOffset, shouldCastShadow, selected;
@synthesize firstLabel = _firstLabel;
@synthesize secondLabel = _secondLabel;
@synthesize firstImageView = _firstImageView;
@synthesize secondImageView = _secondImageView;
@synthesize thumbBackgroundImageView = _thumbBackgroundImageView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
	
    if (self) {
		self.userInteractionEnabled = NO;
        self.clipsToBounds = YES;
		self.backgroundColor = [UIColor clearColor];
		self.textColor = [UIColor whiteColor];
		self.textShadowColor = [UIColor blackColor];
		self.textShadowOffset = CGSizeMake(0, -1);
		self.tintColor = [UIColor grayColor];
        self.shouldCastShadow = YES;
        self.backgroundColor = [UIColor clearColor];
    }
	
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect bounds = self.bounds;
    return CGRectContainsPoint(CGRectMake(bounds.origin.x - self.segmentedControl.touchTargetMargins.left,
                                          bounds.origin.y - self.segmentedControl.touchTargetMargins.top,
                                          bounds.size.width + self.segmentedControl.touchTargetMargins.left + self.segmentedControl.touchTargetMargins.right,
                                          bounds.size.height + self.segmentedControl.touchTargetMargins.bottom + self.segmentedControl.touchTargetMargins.top), point);
}

- (UILabel*)label {
    
    if(_firstLabel == nil) {
        _firstLabel = [[UILabel alloc] initWithFrame:self.bounds];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		_firstLabel.textAlignment = UITextAlignmentLeft;
#else
        _firstLabel.textAlignment = NSTextAlignmentLeft;
#endif
		_firstLabel.font = self.font;
		_firstLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_firstLabel];
    }
    
    return _firstLabel;
}

- (UILabel*)secondLabel {
    
    if(_secondLabel == nil) {
		_secondLabel = [[UILabel alloc] initWithFrame:self.bounds];
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		_secondLabel.textAlignment = UITextAlignmentLeft;
#else
        _secondLabel.textAlignment = NSTextAlignmentLeft;
#endif
		_secondLabel.font = self.font;
		_secondLabel.backgroundColor = [UIColor clearColor];
		[self addSubview:_secondLabel];
    }
    
    return _secondLabel;
}

- (UIImageView *)imageView {
    if(!_firstImageView) {
        _firstImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _firstImageView.layer.shadowOpacity = 1;
        _firstImageView.layer.shadowRadius = 0;
        [self addSubview:_firstImageView];
    }
    return _firstImageView;
}

- (UIImageView *)secondImageView {
    if(!_secondImageView) {
        _secondImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _secondImageView.layer.shadowOpacity = 1;
        _secondImageView.layer.shadowRadius = 0;
        [self addSubview:_secondImageView];
    }
    return _secondImageView;
}

- (UIImageView *)thumbBackgroundImageView {
    if(!_thumbBackgroundImageView) {
        _thumbBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5+self.segmentedControl.thumbEdgeInset.left,
                                                                                  self.segmentedControl.thumbEdgeInset.top,
                                                                                  self.bounds.size.width-10-self.segmentedControl.thumbEdgeInset.left-self.segmentedControl.thumbEdgeInset.right,
                                                                                  self.backgroundImage.size.height)];
        _thumbBackgroundImageView.backgroundColor = [UIColor clearColor];
        [self insertSubview:_thumbBackgroundImageView atIndex:0];
        
        self.clipsToBounds = NO;
        self.segmentedControl.clipsToBounds = NO;
    }
    return _thumbBackgroundImageView;
}

- (SVSegmentedControl *)segmentedControl {
    return (SVSegmentedControl*)self.superview;
}

- (UIFont *)font {
    return self.label.font;
}


- (void)drawRect:(CGRect)rect {
    CGRect thumbRect = CGRectMake(self.segmentedControl.thumbEdgeInset.left,
                                  self.segmentedControl.thumbEdgeInset.top,
                                  rect.size.width-self.segmentedControl.thumbEdgeInset.left-self.segmentedControl.thumbEdgeInset.right,
                                  rect.size.height-self.segmentedControl.thumbEdgeInset.top-self.segmentedControl.thumbEdgeInset.bottom+1); // 1 is for segmented bottom gloss
    
    thumbRect = CGRectInset(thumbRect, 5, 0); // 5 is for thumb shadow
    
    if(self.backgroundImage && !self.selected) {
        self.thumbBackgroundImageView.image = self.backgroundImage;
    }
    else if(self.highlightedBackgroundImage && self.selected) {
        self.thumbBackgroundImageView.image = self.highlightedBackgroundImage;
    }
    else {
        
        CGFloat cornerRadius = self.segmentedControl.cornerRadius;
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGPathRef strokePath= [UIBezierPath bezierPathWithRoundedRect:thumbRect cornerRadius:cornerRadius-1.5].CGPath;
        
        if(self.shouldCastShadow) {
            CGContextAddRect(context, rect);
            CGContextSaveGState(context);
            CGContextAddPath(context, strokePath);
            CGContextEOClip(context);
            
            if(!self.selected) { // dont let thumb drop shadow get outside of segmented control
                if(self.isAtFirstIndex) {
                    CGRect maskRect = thumbRect;
                    maskRect.size.width+=5;
                    maskRect.size.height = rect.size.height+1;
                    CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:maskRect cornerRadius:cornerRadius].CGPath);
                    CGContextClip(context);
                }
                else if(self.isAtLastIndex) {
                    CGRect maskRect = thumbRect;
                    maskRect.size.width+=5;
                    maskRect.origin.x-=5;
                    maskRect.size.height = rect.size.height+1;
                    CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:maskRect cornerRadius:cornerRadius].CGPath);
                    CGContextClip(context);
                }
            }
            
            CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 3, [UIColor colorWithWhite:0 alpha:0.6].CGColor);
            [[UIColor blackColor] set];
            CGContextAddPath(context, strokePath);
            CGContextFillPath(context);
            
            CGContextSetShadowWithColor(context, CGSizeZero, 0, NULL);
            CGContextRestoreGState(context);
        }
                
        // FILL GRADIENT
        CGRect fillRect = thumbRect;
        CGPathRef fillPath = [UIBezierPath bezierPathWithRoundedRect:fillRect cornerRadius:cornerRadius-1.5].CGPath;
        CGContextAddPath(context, fillPath);
        CGContextSaveGState(context);
        CGContextClip(context);
        
        CGFloat fillComponents[4] = {0.5, CGColorGetAlpha(self.tintColor.CGColor),   0.35, CGColorGetAlpha(self.tintColor.CGColor)};
        
        if(self.selected) {
            fillComponents[0]-=0.1;
            fillComponents[2]-=0.1;
        }

        CGGradientRef fillGradient = CGGradientCreateWithColorComponents(colorSpace, fillComponents, NULL, 2);	
        CGContextDrawLinearGradient(context, fillGradient, CGPointMake(0,0), CGPointMake(0,CGRectGetHeight(rect)), 0);
        CGGradientRelease(fillGradient);
        
        CGColorSpaceRelease(colorSpace);
        
        [self.tintColor set];
        UIRectFillUsingBlendMode(thumbRect, kCGBlendModeOverlay);
        
        
        // STROKE GRADIENT
        CGContextRestoreGState(context);
        CGContextAddPath(context, strokePath);
        CGContextAddPath(context, [UIBezierPath bezierPathWithRoundedRect:CGRectInset(thumbRect, 1, 1) cornerRadius:cornerRadius-2.5].CGPath);
        CGContextEOClip(context);
        
        CGFloat strokeComponents[4] = {1, 0.1,    1, 0.05};
        
        if(self.selected) {
            strokeComponents[0]-=0.1;
            strokeComponents[2]-=0.1;
        }
        
        CGGradientRef strokeGradient = CGGradientCreateWithColorComponents(colorSpace, strokeComponents, NULL, 2);
        CGContextDrawLinearGradient(context, strokeGradient, CGPointMake(0,0), CGPointMake(0,CGRectGetHeight(rect)), 0);
        CGGradientRelease(strokeGradient);
    }
}


#pragma mark -
#pragma mark Setters

- (void)setTitle:(NSString*)title image:(UIImage*)image {
    [UIView setAnimationsEnabled:NO];
    
    self.label.text = title;
    self.imageView.image = image;
    [self arrangeLabel:self.label imageView:self.imageView];
    
    [UIView setAnimationsEnabled:YES];
}

- (void)setSecondTitle:(NSString*)title image:(UIImage*)image {
    [UIView setAnimationsEnabled:NO];
    
    self.secondLabel.text = title;
    self.secondImageView.image = image;
    [self arrangeLabel:self.secondLabel imageView:self.secondImageView];

    [UIView setAnimationsEnabled:YES];
}

- (void)arrangeLabel:(UILabel*)label imageView:(UIImageView*)imageView {
    CGSize titleSize = [label.text sizeWithFont:self.font];
    CGFloat titleWidth = titleSize.width;
    CGFloat imageWidth = 0;
    
    if(imageView.image) {
        imageWidth = imageView.image.size.width+5;
        titleWidth += imageWidth;
    }
    
    CGFloat titlePosX = round((self.bounds.size.width-titleWidth)/2);
    
    if(imageView.image)
        imageView.frame = CGRectMake(titlePosX,
                                     round((self.segmentedControl.bounds.size.height-imageView.image.size.height)/2),
                                     imageView.image.size.width,
                                     imageView.image.size.height);
    
    CGFloat posY = ceil((self.segmentedControl.bounds.size.height-titleSize.height)/2)+self.segmentedControl.titleEdgeInsets.top-self.segmentedControl.titleEdgeInsets.bottom;
    
    self.label.frame = CGRectMake(titlePosX+imageWidth,
                                  posY,
                                  titleWidth,
                                  titleSize.height);
}

- (void)setBackgroundImage:(UIImage *)newImage {
    
    if(backgroundImage)
        backgroundImage = nil;
    
    if(newImage) {
        backgroundImage = newImage;
        self.shouldCastShadow = NO;
    } else {
        self.shouldCastShadow = YES;
    }
}

- (void)setTintColor:(UIColor *)newColor {
    
    if(tintColor)
        tintColor = nil;
	
	if(newColor)
		tintColor = newColor;

	[self setNeedsDisplay];
}

- (void)setFont:(UIFont *)newFont {
    self.label.font = newFont;
    self.secondLabel.font = newFont;
}

- (void)setTextColor:(UIColor *)newColor {
    textColor = newColor;
	self.label.textColor = newColor;
    self.secondLabel.textColor = newColor;
}

- (void)setTextShadowColor:(UIColor *)newColor {
    textShadowColor = newColor;
	self.label.shadowColor = newColor;
    self.secondLabel.shadowColor = newColor;
    self.imageView.layer.shadowColor = newColor.CGColor;
    self.secondImageView.layer.shadowColor = newColor.CGColor;
}

- (void)setTextShadowOffset:(CGSize)newOffset {
    textShadowOffset = newOffset;
	self.label.shadowOffset = newOffset;
    self.secondLabel.shadowOffset = newOffset;
    self.imageView.layer.shadowOffset = newOffset;
    self.secondImageView.layer.shadowOffset = newOffset;
}


#pragma mark -

- (void)setFrame:(CGRect)newFrame {
	[super setFrame:newFrame];
        
    CGFloat posY = ceil((self.segmentedControl.height-self.font.pointSize+self.font.descender)/2)+self.segmentedControl.titleEdgeInsets.top-self.segmentedControl.titleEdgeInsets.bottom+2;
	int pointSize = self.font.pointSize;
	
	if(pointSize%2 != 0)
		posY--;
    
	self.label.frame = self.secondLabel.frame = CGRectMake(0, posY, newFrame.size.width, self.font.pointSize);
}

- (void)setSelected:(BOOL)s {
	
	selected = s;
	
	if(selected && !self.segmentedControl.crossFadeLabelsOnDrag && !self.highlightedBackgroundImage)
		self.alpha = 0.8;
	else
		self.alpha = 1;
	
	[self setNeedsDisplay];
}

- (void)activate {
	[self setSelected:NO];
    
    if(!self.segmentedControl.crossFadeLabelsOnDrag) {
        self.label.alpha = 1;
        self.imageView.alpha = 1;
    }
}

- (void)deactivate {
	[self setSelected:YES];
    
    if(!self.segmentedControl.crossFadeLabelsOnDrag) {
        self.label.alpha = 0;
        self.imageView.alpha = 0;
    }
}

- (BOOL)isAtFirstIndex {
    return (CGRectGetMinX(self.frame) < CGRectGetMinX(self.segmentedControl.bounds));
}

- (BOOL)isAtLastIndex {
    return (CGRectGetMaxX(self.frame) > CGRectGetMaxX(self.segmentedControl.bounds));
}

@end
