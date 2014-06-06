//
// SWSegmentedControl.h
// SWSegmentedControl
//
// Created by Sam Vermette on 26.10.10.
// Copyright 2010 Sam Vermette. All rights reserved.
//
// https://github.com/samvermette/SVSegmentedControl
//

#import <UIKit/UIKit.h>
#import "SVSegmentedThumb.h"
#import <AvailabilityMacros.h>

/**
 *  Default initial styles to enable or disable multiple visual attributes at once.
 */
typedef NS_ENUM(NSInteger, SVSegmentedControlStylePreset)
{
    /**
     *  The default style used when nothing is set.  Shadows and gradient are intact.
     */
    SVSegmentedControlStylePresetDefault,
    /**
     *  A flat style to match iOS 7+ style layouts.  All shadows and gradient disabled.
     */
    SVSegmentedControlStylePresetFlat,
};

@protocol SVSegmentedControlDelegate;

/**
 *  SVSegmentedControl is a customizable UIControl class that mimics UISegmentedControl but that looks like an UISwitch.
 *  In its simplest form, this is how you create an SVSegmentedControl instance:
 *  @code
 segmentedControl = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Section 1", @"Section 2", nil]];
 segmentedControl.changeHandler = ^(NSUInteger newIndex) {
     // respond to index change
 };
 
 [self.view addSubview:segmentedControl];
 *  @endcode
 *  You can position it using either its frame or center property:
 */
@interface SVSegmentedControl : UIControl

/**
 *  A block called whenever there is a change to the switch.
 *  If you haven't fallen in love with blocks yet, you can still use the classic UIControl method: 
 *  @code
[mySegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
 *  @endcode
 *
 *  Providing an action method ending with a semicolon, the sender object is therefore made accessible:
 *  @code
- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
    NSLog(@"segmentedControl did select index %i", segmentedControl.selectedIndex);
}
 *  @endcode
 */
@property (nonatomic, copy) void (^changeHandler)(NSUInteger newIndex); // you can also use addTarget:action:forControlEvents:

/**
 *  The titles for each section of the switch.  These are laid out in the order specicied in the array.
 */
@property (nonatomic, copy) NSArray *sectionTitles;

/**
 *  Images placed to the left of section titles.  Images are assigned to titles with corresponding indices.
 *  If not enough images are provided, the remaining section(s) will be displayed normally. 
 *  If too many images are provided, the remaining images are not displayed.
 */
@property (nonatomic, copy) NSArray *sectionImages;

/**
 *  The thumb that moves to the selected section.  Access this property to change its appearance.
 */
@property (nonatomic, strong, readonly) SVSegmentedThumb *thumb;

/**
 *  The currently selected index of the switch.  The default value is 0.
 */
@property (nonatomic, readonly) NSUInteger selectedSegmentIndex; // default is 0

/**
 *  Whether or not to animated the change to initial selection. The default value is NO.
 *  @remarks This doesn't seem to be used anywhere.
 */
@property (nonatomic, readwrite) BOOL animateToInitialSelection; // default is NO

/**
 *  Whether or not to change the title on the thumb, or slide the thumb over the titles.
 *  If set to NO (the default) the thumb moves while the old and new titles stay lined up with the titles
 *  in the background, sliding on and off the thumb.
 *  If set to YES, as the thumb moves, the title stays in place and fades between the two sections.
 */
@property (nonatomic, readwrite) BOOL crossFadeLabelsOnDrag; // default is NO

/**
 *  Whether the switch must be changed with a pan gesture to make the control difficult to accidentally change.
 *  The default is NO.
 */
@property (nonatomic, readwrite) BOOL mustSlideToChange; // default is NO - To make the control difficult to accidentally change, force the user to slide it

/**
 *  The fractional amount by which the thumb must overlap a destination segment to cause a snap to that segment.
 *  The default value is 0.66.
 */
@property (nonatomic, readwrite) CGFloat minimumOverlapToChange; // default is 0.66 - Only snap to a new segment if the thumb overlaps it by this fraction

/**
 *  Margins to add to the touchable area of the control.
 *  The default is UIEdgeInsetsMake(0, 0, 0, 0).
 */
@property (nonatomic, readwrite) UIEdgeInsets touchTargetMargins; // default is UIEdgeInsetsMake(0, 0, 0, 0) - Enlarge touch target of control

/**
 *  The color used in the background of the switch.
 *  The default is [UIColor colorWithWhite:0.1 alpha:1].
 */
@property (nonatomic, strong) UIColor *backgroundTintColor; // default is [UIColor colorWithWhite:0.1 alpha:1]

/**
 *  The image used in the background of the switch.
 *  The default is nil.
 */
@property (nonatomic, strong) UIImage *backgroundImage; // default is nil

/**
 *  The height of the control.  The default is 32.0.
 */
@property (nonatomic, readwrite) CGFloat height; // default is 32.0

/**
 *  The insets of the thumb from the boundries of the segment and the control.
 *  The default is UIEdgeInsetsMake(2, 2, 3, 2).
 */
@property (nonatomic, readwrite) UIEdgeInsets thumbEdgeInset; // default is UIEdgeInsetsMake(2, 2, 3, 2)

/**
 *  The insets from the edge of the control to the edges of the segment titles.
 *  The default is UIEdgeInsetsMake(0, 10, 0, 10).
 */
@property (nonatomic, readwrite) UIEdgeInsets titleEdgeInsets; // default is UIEdgeInsetsMake(0, 10, 0, 10)

/**
 *  The corner radius of the control.  The default is 4.0.
 */
@property (nonatomic, readwrite) CGFloat cornerRadius; // default is 4.0

/**
 *  The font used for the titles.  The default is [UIFont boldSystemFontOfSize:15].
 */
@property (nonatomic, strong) UIFont *font; // default is [UIFont boldSystemFontOfSize:15]

/**
 *  The color of the text in the segments that are not selected.  The default is [UIColor grayColor].
 */
@property (nonatomic, strong) UIColor *textColor; // default is [UIColor grayColor];

/**
 *  The color of the shadow for the text in the segments that are not selected.  The default is [UIColor blackColor].
 */
@property (nonatomic, strong) UIColor *textShadowColor;  // default is [UIColor blackColor]

/**
 *  The offset of the shadow from the text in the segments that are not selected.  The default is CGSizeMake(0, -1).
 */
@property (nonatomic, readwrite) CGSize textShadowOffset;  // default is CGSizeMake(0, -1)

/**
 *  The color of the shadow inside the control along the edges.  The default is [UIColor colorWithWhite:0 alpha:0.8].
 */
@property (nonatomic, strong) UIColor *innerShadowColor; // default is [UIColor colorWithWhite:0 alpha:0.8]

/**
 *  The preset style.  Setting this will change all documented shadow colors, the thumb gradient, 
 *  and remove the bottom gloss.  The default value is SVSegmentedControlStylePresetDefault.
 */
@property (nonatomic, readwrite) SVSegmentedControlStylePreset stylePreset;

/**
 *  Make a new segmented control with the specified section titles.
 *  Initialized with SVSegmentedControlStylePresetDefault.
 *
 *  @param titlesArray an array of section titles for the new control
 *
 *  @return a new segemented control with the specified titles
 */
- (SVSegmentedControl*)initWithSectionTitles:(NSArray*)titlesArray;

/**
 *  Make a new segmented control with the specified section titles and style.
 *
 *
 *  @param titlesArray an array of section titles for the new control
 *  @param style       the initial styling preset for the control
 *
 *  @return a new segmented control with the specified titles and style preset
 */
- (SVSegmentedControl*)initWithSectionTitles:(NSArray*)titlesArray stylePreset:(SVSegmentedControlStylePreset)stylePreset;

/**
 *  Selects a specified index in the control.  Either animates or jumps straight to the new state.
 *
 *  @param index    the new index to select
 *  @param animated whether to animate the change in selection
 */
- (void)setSelectedSegmentIndex:(NSUInteger)index animated:(BOOL)animated;

// deprecated
@property (nonatomic, strong) UIColor *tintColor __attribute__((deprecated("review your color (it doesn't get darkened automatically anymore) and assign it 'backgroundTintColor' instead")));
@property (nonatomic, readwrite) NSUInteger selectedIndex __attribute__((deprecated("use 'setSelectedSegmentIndex:animated:' instead")));
- (void)setSelectedIndex:(NSUInteger)index animated:(BOOL)animated __attribute__((deprecated("use 'setSelectedSegmentIndex:animated:' instead")));
- (void)moveThumbToIndex:(NSUInteger)segmentIndex animate:(BOOL)animate __attribute__((deprecated("use 'setSelectedSegmentIndex:animated:' instead")));

@end


@protocol SVSegmentedControlDelegate

- (void)segmentedControl:(SVSegmentedControl*)segmentedControl didSelectIndex:(NSUInteger)index;

@end
