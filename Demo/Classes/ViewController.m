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
	navSC.delegate = self;

	[self.view addSubview:navSC];
	[navSC release];
	
	navSC.center = CGPointMake(160, 70);
	
	
	// 2nd CONTROL
	
	SVSegmentedControl *redSC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"About", @"Help", @"Credits", nil]];
	redSC.delegate = self;
	
	redSC.thumb.tintColor = [UIColor colorWithRed:0.6 green:0.2 blue:0.2 alpha:1];
	
	[self.view addSubview:redSC];
	[redSC release];
	
	redSC.center = CGPointMake(160, 170);
	
	
	// 3rd CONTROL
	
	SVSegmentedControl *grayRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Section 1", @"Section 2", nil]];
	grayRC.selectedSegmentChangedHandler = ^(id sender) {
		SVSegmentedControl *grayRC = (SVSegmentedControl *)sender;
		NSLog(@"segmentedControl %i did select index %i (captured via block)", grayRC.tag, grayRC.selectedIndex);
	};
	grayRC.fadeLabelsBetweenSegments = YES;
	grayRC.font = [UIFont boldSystemFontOfSize:19];
	grayRC.segmentPadding = 14;
	grayRC.height = 46;
	
	grayRC.thumb.tintColor = [UIColor colorWithRed:0 green:0.5 blue:0.1 alpha:1];
	
	[self.view addSubview:grayRC];
	[grayRC release];
	
	grayRC.center = CGPointMake(160, 270);
	
	
	// 4th CONTROL
	
	SVSegmentedControl *yellowRC = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"One", @"Two", @"Three", nil]];
	yellowRC.selectedSegmentChangedHandler = ^(id sender) {
		SVSegmentedControl *yellowRC = (SVSegmentedControl *)sender;
		NSLog(@"segmentedControl %i did select index %i (captured via block)", yellowRC.tag, yellowRC.selectedIndex);
	};
	yellowRC.fadeLabelsBetweenSegments = YES;
	yellowRC.font = [UIFont fontWithName:@"Marker Felt" size:20];
	yellowRC.segmentPadding = 14;
	yellowRC.height = 40;
	
	yellowRC.thumb.tintColor = [UIColor colorWithRed:0.999 green:0.889 blue:0.312 alpha:1.000];
	yellowRC.thumb.textColor = [UIColor blackColor];
	yellowRC.thumb.shadowColor = [UIColor colorWithWhite:1 alpha:0.5];
	yellowRC.thumb.shadowOffset = CGSizeMake(0, 1);
	
	[self.view addSubview:yellowRC];
	[yellowRC release];
	
	yellowRC.center = CGPointMake(160, 370);
	
	
	
	navSC.tag = 1;
	redSC.tag = 2;
	grayRC.tag = 3;
	yellowRC.tag = 4;
}


#pragma mark -
#pragma mark SPSegmentedControl

- (void)segmentedControl:(SVSegmentedControl*)segmentedControl didSelectIndex:(NSUInteger)index {
	
	NSLog(@"segmentedControl %i did select index %i (captured via delegate method)", segmentedControl.tag, index);
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


- (void)dealloc {
    [super dealloc];
}

@end
