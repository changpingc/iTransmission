//
//  ITExperimentalViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITExperimentalViewController.h"
#import "ITSidebarItem.h"
#import "ITColoredProgressView.h"
#import "ITShadowView.h"

@implementation ITExperimentalViewController
@synthesize sidebarItem = _sidebarItem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.sidebarItem = [[ITSidebarItem alloc] init];
        self.sidebarItem.title = @"Experiment";
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
    self.view = [[UIView alloc] init];
    
    ITColoredProgressView *pv = [[ITColoredProgressView alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 200.0f, 18.0f)];
    
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 50.0f, 200.0f, 10.0f)];
    ITShadowView *sv = [[ITShadowView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 10.0f)];
    [v addSubview:sv];
    [self.view addSubview:v];
    [self.view addSubview:pv];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
