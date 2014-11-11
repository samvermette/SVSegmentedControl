//
//  ViewController.m
//  SVSegmentedControl
//
//  Created by Sam Vermette on 24.05.11.
//  Copyright 2011 Sam Vermette. All rights reserved.
//

#import "ViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// 1st CONTROL
	
	SVSegmentedControl *navSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Section 1", @"Section 2", nil]];
    navSC.changeHandler = ^(NSUInteger newIndex) {
        NSLog(@"segmentedControl did select index %@ (via block handler)", @(newIndex));
    };
    
	[self.view addSubview:navSC];
	
	navSC.center = CGPointMake(160, 70);
	
	
	// 2nd CONTROL
	SVSegmentedControl *redSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"About", @"Help", @"Credits", nil]];
    [redSC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
	redSC.crossFadeLabelsOnDrag = YES;
	redSC.thumb.tintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1];
    [redSC setSelectedSegmentIndex:1 animated:NO];
	
	[self.view addSubview:redSC];
	
	redSC.center = CGPointMake(160, 150);
	
	
	// 3rd CONTROL
	SVSegmentedControl *grayRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Section 1", @"Section 2", nil]];
    [grayRC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
	grayRC.font = [UIFont boldSystemFontOfSize:19];
	grayRC.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
	grayRC.height = 46;
	grayRC.thumb.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
	grayRC.mustSlideToChange = YES;
    
	[self.view addSubview:grayRC];
	
	grayRC.center = CGPointMake(160, 230);
	
	
	// 4th CONTROL
	SVSegmentedControl *yellowRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"One", @"Two", @"Three", nil]];
    [yellowRC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
	yellowRC.crossFadeLabelsOnDrag = YES;
	yellowRC.font = [UIFont fontWithName:@"Marker Felt" size:20];
	yellowRC.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
	yellowRC.height = 40;
    [yellowRC setSelectedSegmentIndex:2 animated:NO];
	yellowRC.thumb.tintColor = [UIColor colorWithRed:0.999 green:0.889 blue:0.312 alpha:1.000];
	yellowRC.thumb.textColor = [UIColor blackColor];
	yellowRC.thumb.textShadowColor = [UIColor colorWithWhite:1 alpha:0.5];
	yellowRC.thumb.textShadowOffset = CGSizeMake(0, 1);
	
	[self.view addSubview:yellowRC];
	
	yellowRC.center = CGPointMake(160, 310);
	
	
	// 4th CONTROL
	SVSegmentedControl *imageRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Some", @"Section", @"Images", nil]];
    [imageRC setSectionImages:@[[UIImage imageNamed:@"1"], [UIImage imageNamed:@"2"], [UIImage imageNamed:@"3"], [UIImage imageNamed:@"3"]]];
    [imageRC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
	imageRC.crossFadeLabelsOnDrag = YES;
	imageRC.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
	imageRC.height = 40;
    [imageRC setSelectedSegmentIndex:0 animated:NO];
	imageRC.thumb.tintColor = [UIColor colorWithRed:0.100 green:0.400 blue:0.800 alpha:1.000];
	imageRC.thumb.textColor = [UIColor whiteColor];
	imageRC.thumb.textColor = [UIColor whiteColor];
	imageRC.thumb.textShadowColor = [UIColor colorWithWhite:0 alpha:0.5];
	imageRC.thumb.textShadowOffset = CGSizeMake(0, 1);
	
	[self.view addSubview:imageRC];
	
	imageRC.center = CGPointMake(160, 390);
	
	
	// 5th CONTROL
	SVSegmentedControl *iOS7FlatRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Can", @"Look", @"Flat", nil] stylePreset:SVSegmentedControlStylePresetFlat];
    [iOS7FlatRC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
	iOS7FlatRC.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
	iOS7FlatRC.height = 40;
    [iOS7FlatRC setSelectedSegmentIndex:1 animated:NO];
	iOS7FlatRC.thumb.tintColor = [UIColor colorWithRed:1.000 green:0.300 blue:0.100 alpha:1.000];
	iOS7FlatRC.thumb.textColor = [UIColor whiteColor];
	iOS7FlatRC.thumb.textColor = [UIColor whiteColor];
	
	[self.view addSubview:iOS7FlatRC];
	
	iOS7FlatRC.center = CGPointMake(160, 470);
}


#pragma mark - UIControlEventValueChanged

- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
	NSLog(@"segmentedControl %@ did select index %@ (via UIControl method)", @(segmentedControl.tag), @(segmentedControl.selectedSegmentIndex));
}


@end
