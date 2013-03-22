# SVSegmentedControl

SVSegmentedControl is a customizable `UIControl` class that mimics `UISegmentedControl` but that looks like an `UISwitch`.

![SVSegmentedControl](http://f.cl.ly/items/213N0a1k2U2O0F3y053z/svsegmentedcontrol3.png)

## Installation

### From CocoaPods

Add `pod 'SVSegmentedControl'` to your Podfile or `pod 'SVSegmentedControl', :head` if you're feeling adventurous.

### Manually

_**Important note if your project doesn't use ARC**: you must add the `-fobjc-arc` compiler flag to `SVSegmentedControl.m` and `SVSegmentedThumb.m` in Target Settings > Build Phases > Compile Sources._

* Drag the `SVSegmentedControl/SVSegmentedControl ` folder into your project. 
* Add the **QuartzCore** framework to your project.

## Usage

(see sample Xcode project in `/Demo`)

In its simplest form, this is how you create an SVSegmentedControl instance:

```objective-c
segmentedControl = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Section 1", @"Section 2", nil]];
segmentedControl.changeHandler = ^(NSUInteger newIndex) {
    // respond to index change
};

[self.view addSubview:segmentedControl];
```

You can position it using either its `frame` or `center` property:

## Customization

SVSegmentedControl can be customized with the following properties:

```objective-c
@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *sectionImages;

@property (nonatomic, readwrite) BOOL animateToInitialSelection; // default is NO
@property (nonatomic, readwrite) BOOL crossFadeLabelsOnDrag; // default is NO

@property (nonatomic, readwrite) BOOL mustSlideToChange; // default is NO - To make the control difficult to accidentally change, force the user to slide it
@property (nonatomic, readwrite) CGFloat minimumOverlapToChange; // default is 0.66 - Only snap to a new segment if the thumb overlaps it by this fraction
@property (nonatomic, readwrite) UIEdgeInsets touchTargetMargins; // default is UIEdgeInsetsMake(0, 0, 0, 0) - Enlarge touch target of control

@property (nonatomic, strong) UIColor *backgroundTintColor; // default is [UIColor colorWithWhite:0.1 alpha:1]
@property (nonatomic, retain) UIImage *backgroundImage; // default is nil

@property (nonatomic, readwrite) CGFloat height; // default is 32.0
@property (nonatomic, readwrite) UIEdgeInsets thumbEdgeInset; // default is UIEdgeInsetsMake(2, 2, 3, 2)
@property (nonatomic, readwrite) UIEdgeInsets titleEdgeInsets; // default is UIEdgeInsetsMake(0, 10, 0, 10)
@property (nonatomic, readwrite) CGFloat cornerRadius; // default is 4.0

@property (nonatomic, retain) UIFont *font; // default is [UIFont boldSystemFontOfSize:15]
@property (nonatomic, retain) UIColor *textColor; // default is [UIColor grayColor];
@property (nonatomic, strong) UIColor *innerShadowColor; // default is [UIColor colorWithWhite:0 alpha:0.8]
@property (nonatomic, retain) UIColor *textShadowColor;  // default is [UIColor blackColor]
@property (nonatomic, readwrite) CGSize textShadowOffset;  // default is CGSizeMake(0, -1)
```

Its thumb (`SVSegmentedThumb`) can be customized as well: 

```objective-c
@property (nonatomic, retain) UIImage *backgroundImage; // default is nil;
@property (nonatomic, retain) UIImage *highlightedBackgroundImage; // default is nil;

@property (nonatomic, retain) UIColor *tintColor; // default is [UIColor grayColor]
@property (nonatomic, assign) UIColor *textColor; // default is [UIColor whiteColor]
@property (nonatomic, assign) UIColor *textShadowColor; // default is [UIColor blackColor]
@property (nonatomic, readwrite) CGSize textShadowOffset; // default is CGSizeMake(0, -1)
@property (nonatomic, readwrite) BOOL shouldCastShadow; // default is YES (NO when backgroundImage is set)
@property (nonatomic, assign) CGFloat gradientIntensity; // default is 0.15
```

To customize the thumb's appearance, you'll have to set the properties through SVSegmentedControl's `thumb` property. For instance, setting the thumb's `tintColor` is done with:

```objective-c
segmentedControl.thumb.tintColor = someColor;
```

## Responding to value changes

You can respond to value changes using a block handler:

```objective-c
segmentedControl.changeHandler = ^(NSUInteger newIndex) {
    // respond to index change
};
```

If you haven't fallen in love with blocks yet, you can still use the classic UIControl method:

```objective-c
[mySegmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
```

Providing an action method ending with a semicolon, the sender object is therefore made accessible:

```objective-c
- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
	NSLog(@"segmentedControl did select index %i", segmentedControl.selectedIndex);
}
```

## Credits

SVSegmentedControl is brought to you by [Sam Vermette](http://samvermette.com) and [contributors to the project](https://github.com/samvermette/SVSegmentedControl/contributors). If you have feature suggestions or bug reports, feel free to help out by sending pull requests or by [creating new issues](https://github.com/samvermette/SVSegmentedControl/issues/new). If you're using SVSegmentedControl in your project, attribution would be nice. 