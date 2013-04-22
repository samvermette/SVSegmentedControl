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

@property (nonatomic, strong) UIImage *backgroundImage UI_APPEARANCE_SELECTOR; // default is nil;
@property (nonatomic, strong) UIImage *highlightedBackgroundImage UI_APPEARANCE_SELECTOR; // default is nil;

@property (nonatomic, strong) UIColor *tintColor UI_APPEARANCE_SELECTOR; // default is [UIColor grayColor]
@property (nonatomic, strong) UIColor *textColor UI_APPEARANCE_SELECTOR; // default is [UIColor whiteColor]
@property (nonatomic, strong) UIColor *textShadowColor UI_APPEARANCE_SELECTOR; // default is [UIColor blackColor]
@property (nonatomic, readwrite) CGSize textShadowOffset UI_APPEARANCE_SELECTOR; // default is CGSizeMake(0, -1)
@property (nonatomic, readwrite) BOOL shouldCastShadow UI_APPEARANCE_SELECTOR; // default is YES (NO when backgroundImage is set)
@property (nonatomic, assign) CGFloat gradientIntensity UI_APPEARANCE_SELECTOR; // default is 0.15

@end
