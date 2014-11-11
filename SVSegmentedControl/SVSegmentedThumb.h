//
// SVSegmentedThumb.h
// SVSegmentedControl
//
// Created by Sam Vermette on 25.05.11.
// Copyright 2011 Sam Vermette. All rights reserved.
//
// https://github.com/samvermette/SVSegmentedControl
//

#import <UIKit/UIKit.h>

@class SVSegmentedControl;

@interface SVSegmentedThumb : UIView

/**
 *  The image to use in the background of the thumb.  The default is nil.
 *  Setting this property, sets the valye of shouldCastShadow to NO.
 */
@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR; // default is nil;

/**
 *  The image used in the background when highlighted.  The default is nil.
 */
@property (nonatomic, strong) UIImage *highlightedBackgroundImage UI_APPEARANCE_SELECTOR; // default is nil;

/**
 *  The color of the thumb used as a base for the gradient.  The default is [UIColor grayColor].
 */
@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR; // default is [UIColor grayColor]

/**
 *  The color the title text in the thumb.  The default is [UIColor whiteColor].
 */
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR; // default is [UIColor whiteColor]

/**
 *  The color of the shadow for the title text in the thumb.  The default is [UIColor blackColor].
 */
@property (nonatomic, strong) UIColor *textShadowColor UI_APPEARANCE_SELECTOR; // default is [UIColor blackColor]

/**
 *  The offset of the shadow from the title text in the thumb.  The default is CGSizeMake(0, -1).
 */
@property (nonatomic, readwrite) CGSize textShadowOffset UI_APPEARANCE_SELECTOR; // default is CGSizeMake(0, -1)

/**
 *  Whether or not the thumb should cast a shadow on the rest of the control.  The default is YES.
 *  This value is set to NO if the backgroundImage property is set to something other than nil.
 */
@property (nonatomic, readwrite) BOOL shouldCastShadow UI_APPEARANCE_SELECTOR; // default is YES (NO when backgroundImage is set)

/**
 *  How much darker to make the second color in the gradient. Valid values range from 0 (no gradient) 
 *  to 1 (gradient from tintColor to black).  The default is 0.15.
 */
@property (nonatomic, assign) CGFloat gradientIntensity UI_APPEARANCE_SELECTOR; // default is 0.15

@end
