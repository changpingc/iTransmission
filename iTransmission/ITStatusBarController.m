//
//  ITStatusBarController.m
//  iTransmission
//
//  Created by Mike Chen on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITStatusBarController.h"
#import "NSArray+iTransmissionUtility.h"
#import "ITController.h"
#import "ITStatistics.h"
#import "ITStatusBar.h"
#import "NSStringAdditions.h"

@implementation ITStatusBarController

@synthesize statusBar = _statusBar;
@synthesize containerView = _containerView;
@synthesize contentViewController = _contentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (void)setContentViewController:(UIViewController *)contentViewController
{
    _contentViewController = contentViewController;
    [self fillContentView];
}

- (NSArray*)childViewControllers
{
    return [NSArray arrayWithObject:self.contentViewController];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newStatisticsArrived:) name:kITNewStatisticsAvailableNotification object:nil];
    
    [self fillContentView];
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers
{
    return YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)fillContentView
{
    if (self.containerView == nil) return;
    if ([[self.containerView.subviews firstObjectOrNil] isEqual:self.contentViewController.view]) return;
    else {
        for (UIView *view in self.containerView.subviews) 
            [view removeFromSuperview];
        [self.containerView addSubview:self.contentViewController.view];
        [self.contentViewController.view setFrame:self.containerView.bounds];
    }
}

- (void)newStatisticsArrived:(NSNotification *)notif
{
    ITStatistics *statistics = [[notif userInfo] objectForKey:@"statistics"];
    self.statusBar.uploadSpeedLabel.text = [NSString stringForSpeed:statistics.uploadRate];
    self.statusBar.downloadSpeedLabel.text = [NSString stringForSpeed:statistics.downloadRate];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return [self.contentViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return [self.contentViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return [self.contentViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (self.contentViewController) 
        return [self.contentViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation];
    else return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
