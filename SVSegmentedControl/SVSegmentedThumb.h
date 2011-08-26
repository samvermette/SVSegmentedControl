//
//  SVSegmentedThumb.h
//  SVSegmentedControl
//
//  Created by Sam Vermette on 25.05.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SVSegmentedControl;

@interface SVSegmentedThumb : UIView {
	UILabel *label;
	UILabel *secondLabel;
	BOOL selected;
}

@property (nonatomic, assign) SVSegmentedControl *segmentedControl;

@property (nonatomic, retain) UIImage *backgroundImage; // default is nil;
@property (nonatomic, retain) UIImage *highlightedBackgroundImage; // default is nil;

@property (nonatomic, retain) UIColor *tintColor; // default is [UIColor grayColor]
@property (nonatomic, retain) UIColor *textColor; // default is [UIColor whiteColor]
@property (nonatomic, retain) UIColor *shadowColor; // default is [UIColor blackColor]
@property (nonatomic, readwrite) CGSize shadowOffset; // default is CGSizeMake(0, -1)
@property (nonatomic, readwrite) BOOL castsShadow; // default is YES

// these properties are for internal use only
// only the segmentedControl is to set them
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *secondTitle;
@property (nonatomic, readwrite) CGFloat titleAlpha;
@property (nonatomic, readwrite) CGFloat secondTitleAlpha;
@property (nonatomic, retain) UIFont *font;

- (void)activate;
- (void)deactivate;

@end
