//
//  ITInspectorCollectionViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITInspectorCollectionViewController.h"
#import "ITTorrent.h"
#import "SVSegmentedControl.h"
#import "UIColor+Style.h"
#import "ITInspectorCollectionTabBar.h"
#import "ITInspectorCollectionView.h"
#import "ITInfoInspectorViewController.h"
#import "ITActivityInspectorViewController.h"
#import "ITFilesInspectorViewController.h"
#import "ITPeersInspectorViewController.h"

@implementation ITInspectorCollectionViewController

@synthesize childViewControllers = _childViewControllers;
@synthesize currentInspector = _currentInspector;

- (id)initWithTorrent:(ITTorrent*)torrent
{
    self = [super initWithNibName:nil bundle:nil torrent:torrent];
    if (self) {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView
{
    self.view = [[ITInspectorCollectionView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    SVSegmentedControl *segmentedControl = [[SVSegmentedControl alloc] initWithSectionTitles:[NSArray arrayWithObjects:@"Info", @"Activity", @"Files", @"Peers", nil]];
    segmentedControl.height = 32.0f;
    segmentedControl.crossFadeLabelsOnDrag = YES;
	segmentedControl.thumb.tintColor = [UIColor controlBlueColor];
    [segmentedControl addTarget:self action:@selector(segmentControlSwitched:) forControlEvents:UIControlEventTouchUpInside];
    
    ITInspectorCollectionTabBar *tabBar = [[ITInspectorCollectionTabBar alloc] initWithFrame:CGRectZero];
    tabBar.backgroundColor = [UIColor colorWithWhite:0.30f alpha:1.0f];
    
    [tabBar setSegmentedControl:segmentedControl];
    [tabBar addSubview:segmentedControl];
    [(ITInspectorCollectionView*)self.view setTabBar:tabBar];
    [self.view addSubview:tabBar];
    
    ITInfoInspectorViewController *infoInspector = [[ITInfoInspectorViewController alloc] initWithTorrent:self.torrent];
    ITActivityInspectorViewController *activityInspector = [[ITActivityInspectorViewController alloc] initWithTorrent:self.torrent];
    ITFilesInspectorViewController *filesInspector = [[ITFilesInspectorViewController alloc] initWithTorrent:self.torrent];
    ITPeersInspectorViewController *peersInspector = [[ITPeersInspectorViewController alloc] initWithTorrent:self.torrent];
    self.childViewControllers = [NSArray arrayWithObjects:infoInspector, activityInspector, filesInspector, peersInspector, nil];
    
    [self setCurrentInspector:infoInspector];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)setCurrentInspector:(ITInspectorBaseViewController*)inspector
{
    _currentInspector = inspector;
    [[[(ITInspectorCollectionView*)self.view tabBar] segmentedControl] setSelectedIndex:[self.childViewControllers indexOfObject:inspector]];
    for (UIView *subView in [[(ITInspectorCollectionView*)self.view contentView] subviews]) {
        [subView removeFromSuperview];
    }
    [[(ITInspectorCollectionView*)self.view contentView] addSubview:self.currentInspector.view];
    self.currentInspector.view.frame = [(ITInspectorCollectionView*)self.view contentView].bounds;
    [self setTitle:self.currentInspector.title];
}

- (void)segmentControlSwitched:(id)sender
{
    NSInteger index = [[[(ITInspectorCollectionView*)self.view tabBar] segmentedControl] selectedIndex];
    [self setCurrentInspector:[self.childViewControllers objectAtIndex:index]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

@end
