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
        NSLog(@"segmentedControl did select index %i (via block handler)", newIndex);
    };
    
	[self.view addSubview:navSC];
	
	navSC.center = CGPointMake(160, 70);
	
	
	// 2nd CONTROL
	
	SVSegmentedControl *redSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"About", @"Help", @"Credits", nil]];
    [redSC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
	
	redSC.crossFadeLabelsOnDrag = YES;
	redSC.thumb.tintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1];
	redSC.selectedIndex = 1;
	
	[self.view addSubview:redSC];
	
	redSC.center = CGPointMake(160, 170);
	
	
	// 3rd CONTROL
	
	SVSegmentedControl *grayRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Section 1", @"Section 2", nil]];
    [grayRC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];

	grayRC.font = [UIFont boldSystemFontOfSize:19];
	grayRC.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
	grayRC.height = 46;
	
	grayRC.thumb.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
	grayRC.mustSlideToChange = YES;
    
	[self.view addSubview:grayRC];
	
	grayRC.center = CGPointMake(160, 270);
	
	
	// 4th CONTROL
	
	SVSegmentedControl *yellowRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"One", @"Two", @"Three", nil]];
    [yellowRC addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];

	yellowRC.crossFadeLabelsOnDrag = YES;
	yellowRC.font = [UIFont fontWithName:@"Marker Felt" size:20];
	yellowRC.titleEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 14);
	yellowRC.height = 40;
	yellowRC.selectedIndex = 2;
	
	yellowRC.thumb.tintColor = [UIColor colorWithRed:0.999 green:0.889 blue:0.312 alpha:1.000];
	yellowRC.thumb.textColor = [UIColor blackColor];
	yellowRC.thumb.textShadowColor = [UIColor colorWithWhite:1 alpha:0.5];
	yellowRC.thumb.textShadowOffset = CGSizeMake(0, 1);
	
	[self.view addSubview:yellowRC];
	
	yellowRC.center = CGPointMake(160, 370);
    
    // Light Backgrounds
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 400, 320, 160)];
    background.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1];
    [self.view addSubview:background];
    
    // Using Deprecated tintColor property
    SVSegmentedControl *tintSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Sec1", @"Sec2", nil]];
    tintSC.tintColor = [UIColor colorWithWhite:0.9 alpha:1];
    tintSC.thumb.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    tintSC.thumb.textColor = [UIColor blackColor];
    tintSC.thumb.textShadowColor = [UIColor whiteColor];
    tintSC.thumb.gradientIntensity = 0.075;
    tintSC.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    tintSC.textShadowColor = [UIColor whiteColor];
    tintSC.innerShadowColor = [UIColor colorWithWhite:0.4 alpha:0.8];
	tintSC.center = CGPointMake(90, 440);
	[self.view addSubview:tintSC];

    SVSegmentedControl *tintSC2 = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Sec1", @"Sec2", nil]];
    tintSC2.tintColor = [UIColor colorWithRed:0.647 green:1.000 blue:0.247 alpha:1.000];
    tintSC2.thumb.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    tintSC2.thumb.textColor = [UIColor blackColor];
    tintSC2.thumb.textShadowColor = [UIColor whiteColor];
    tintSC2.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    tintSC2.textShadowColor = [UIColor whiteColor];
	tintSC2.center = CGPointMake(90, 500);
    [self.view addSubview:tintSC2];
    
    // Using New backgroundTintColor property
    SVSegmentedControl *backgroundTintSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Sec1", @"Sec2", nil]];
    backgroundTintSC.backgroundTintColor = [UIColor colorWithWhite:0.9 alpha:1];
    backgroundTintSC.thumb.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    backgroundTintSC.thumb.textColor = [UIColor blackColor];
    backgroundTintSC.thumb.textShadowColor = [UIColor whiteColor];
    backgroundTintSC.thumb.gradientIntensity = 0.075;
    backgroundTintSC.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    backgroundTintSC.textShadowColor = [UIColor whiteColor];
    backgroundTintSC.innerShadowColor = [UIColor colorWithWhite:0.4 alpha:0.8];
	backgroundTintSC.center = CGPointMake(230, 440);
	[self.view addSubview:backgroundTintSC];
    
    SVSegmentedControl *backgroundTintSC2 = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Sec1", @"Sec2", nil]];
    backgroundTintSC2.backgroundTintColor = [UIColor colorWithRed:0.647 green:1.000 blue:0.247 alpha:1.000];
    backgroundTintSC2.thumb.tintColor = [UIColor colorWithWhite:0.9 alpha:1.0];
    backgroundTintSC2.thumb.textColor = [UIColor blackColor];
    backgroundTintSC2.thumb.textShadowColor = [UIColor whiteColor];
    backgroundTintSC2.textColor = [UIColor colorWithWhite:0.3 alpha:1];
    backgroundTintSC2.textShadowColor = [UIColor whiteColor];
	backgroundTintSC2.center = CGPointMake(230, 500);
    [self.view addSubview:backgroundTintSC2];
	
	navSC.tag = 1;
	redSC.tag = 2;
	grayRC.tag = 3;
	yellowRC.tag = 4;
}


#pragma mark -
#pragma mark SPSegmentedControl

- (void)segmentedControlChangedValue:(SVSegmentedControl*)segmentedControl {
	NSLog(@"segmentedControl %i did select index %i (via UIControl method)", segmentedControl.tag, segmentedControl.selectedIndex);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



@end
