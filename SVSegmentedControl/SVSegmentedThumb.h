//
//  SVSegmentedThumb.h
//  SVSegmentedControl
//
//  Created by Sam Vermette on 25.05.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SVSegmentedThumb : UIView {
	UILabel *label;
	UILabel *secondLabel;
	BOOL selected;
}

@property (nonatomic, retain) UIColor *tintColor; // default is [UIColor grayColor]
@property (nonatomic, retain) UIColor *textColor; // default is [UIColor whiteColor]
@property (nonatomic, retain) UIColor *shadowColor; // default is [UIColor blackColor]
@property (nonatomic, readwrite) CGSize shadowOffset; // default is CGSizeMake(0, -1)

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *secondTitle;
@property (nonatomic, readwrite) CGFloat titleAlpha;
@property (nonatomic, readwrite) CGFloat secondTitleAlpha;
@property (nonatomic, retain) UIFont *font;

- (void)activate;
- (void)deactivate;

@end
