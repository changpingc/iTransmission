//
//  ITSidebarController.m
//  iTransmission
//
//  Created by Mike Chen on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITSidebarController.h"
#import "ITSidebar.h"
#import "NSArray+iTransmissionUtility.h"
#import "ITNavigationController.h"
#import "ITSidebarItem.h"
#import "ITSidebarContainerView.h"
#import "ITSidebarControllerView.h"
#import "ITDebug.h"
#import "ITSidebarItemCell.h"
#import "ITTouchRecognizer.h"

@implementation ITSidebarController

@synthesize sidebar = _sidebar;
@synthesize viewControllers = _viewControllers;
@synthesize currentViewController = _currentViewController;
@synthesize containerView = _containerView;
@synthesize state = _state;
@synthesize swipeLeftRecognizer = _swipeLeftRecognizer;
@synthesize sidebarItems = _sidebarItems;
@synthesize swipeRightRecognizer = _swipeRightRecognizer;
@synthesize containerTouchRecognizer = _containerTouchRecognizer;

- (id)init
{
    self = [super init];
    if (self) {
        _state = ITSidebarHidden;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    if (self.currentViewController) {
        if (![viewControllers containsObject:self.currentViewController]) {
            self.currentViewController = [viewControllers objectAtIndex:0];
        }
        else {
        }
    }
    
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[self.viewControllers count]];
    
    for (UIViewController *viewController in viewControllers) {
        if ([viewController isKindOfClass:[ITNavigationController class]]) {
            [(ITNavigationController*)viewController setSidebarController:self];
        }
        if ([viewController conformsToProtocol:@protocol(ITSidebarItemDatasource)]) {
            [items addObject:[(UINavigationController<ITSidebarItemDatasource>*)viewController sidebarItem]];
        }
        else {
            ITSidebarItem *item = [[ITSidebarItem alloc] init];
            item.title = viewController.title;
            [items addObject:item];
        }
    }
    self.sidebarItems = [NSArray arrayWithArray:items];
}

- (void)fillContentView
{
    if (self.containerView == nil) return;
    UIView *exisingView = [self.containerView.subviews firstObjectOrNil];
    if (exisingView == nil) {
        self.currentViewController.view.frame = self.containerView.bounds;
        [self.containerView addSubview:self.currentViewController.view];
    }
    else if (exisingView == self.currentViewController.view) {
    }
    else {
        self.currentViewController.view.frame = self.containerView.bounds;
        [exisingView removeFromSuperview];
        [self.containerView addSubview:self.currentViewController.view];
//        [self performSelector:@selector(_delayedViewTransition:) withObject:exisingView afterDelay:0.0f];
    }
}

- (void)_delayedViewTransition:(UIView*)oldView
{
    [UIView transitionFromView:oldView toView:self.currentViewController.view duration:0.5f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone completion:NULL];
}

- (void)setCurrentViewController:(UIViewController *)currentViewController
{
    if (self.currentViewController == currentViewController) return;
//    [_currentViewController viewWillDisappear:NO];
//    [_currentViewController viewDidDisappear:NO];
    _currentViewController = currentViewController;
    [self fillContentView];
//    [self.currentViewController viewWillDisappear:NO];
//    [self.currentViewController viewDidDisappear:NO];
    [self.sidebar.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[self.viewControllers indexOfObject:self.currentViewController] inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

- (void)toggleStateAnimated:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return;
    if (self.state == ITSidebarShown || self.state == ITSidebarSlidingRight) {
        [self slideContainerViewToLeftAnimated:animated];
    }
    else {
        [self slideContainerViewToRightAnimated:animated];
    }
}

- (void)slideContainerViewToLeftAnimated:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return;
    if (self.state == ITSidebarShown || self.state == ITSidebarSlidingRight) {
        if (animated) {
            [UIView beginAnimations:@"ITSidebarController.slideContainerViewToLeftAnimated" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:kITSidebarSlidingAnimationDuration];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        }
        [self.containerView setCenter:CGPointMake(self.containerView.center.x - self.sidebar.bounds.size.width, self.containerView.center.y)];
        self.containerView.horizontalShift = 0;
        
        if (animated) {
            [UIView commitAnimations];
            _state = ITSidebarSlidingLeft;
        }
        else {
            _state = ITSidebarHidden;
        }
        [self.containerView removeGestureRecognizer:self.containerTouchRecognizer];
    }
}

- (void)slideContainerViewToRightAnimated:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return;
    if (self.state == ITSidebarHidden || self.state == ITSidebarSlidingLeft) {
        if (animated) {
            [UIView beginAnimations:@"ITSidebarController.slideContainerViewToRightAnimated" context:nil];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:kITSidebarSlidingAnimationDuration];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        }
        [self.containerView setCenter:CGPointMake(self.containerView.center.x + self.sidebar.bounds.size.width, self.containerView.center.y)];
        self.containerView.horizontalShift = self.sidebar.bounds.size.width;
        if (animated) {
            [UIView commitAnimations];
            _state = ITSidebarSlidingRight;
        }
        else {
            _state = ITSidebarShown;
        }
        [self.containerView addGestureRecognizer:self.containerTouchRecognizer];
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([finished boolValue] == YES) {
        switch (self.state) {
            case ITSidebarSlidingLeft:
                _state = ITSidebarHidden;
                break;
            case ITSidebarSlidingRight:
                _state = ITSidebarShown;
            default:
                break;
        }
    }
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[ITSidebarControllerView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.backgroundColor = [UIColor blueColor];
    self.view.clipsToBounds = YES;
    
    _sidebar = [ITSidebar sidebarFromNib];
    self.sidebar.frame = CGRectMake(0.0f, 0.0f, _sidebar.bounds.size.width, self.view.bounds.size.height);
    self.sidebar.tableView.delegate = self;
    self.sidebar.tableView.dataSource = self;
    [self.view addSubview:self.sidebar];
    
    _containerView = [[ITSidebarContainerView alloc] initWithFrame:self.view.bounds];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.containerView setFrame:CGRectMake(self.sidebar.bounds.size.width, 0.0f, self.view.bounds.size.width - self.sidebar.bounds.size.width, self.view.bounds.size.height)];
    }
    self.containerView.backgroundColor = [UIColor whiteColor];

    [self.view addSubview:self.containerView];
    
    [(ITSidebarControllerView*)self.view setContainerView:self.containerView];
    [(ITSidebarControllerView*)self.view setSidebarView:self.sidebar];
}

- (void)viewDidLoad
{
    [self.view setNeedsLayout];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.swipeLeftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
        self.swipeLeftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        self.swipeLeftRecognizer.numberOfTouchesRequired = 3;
        [self.view addGestureRecognizer:self.swipeLeftRecognizer];
        
        self.swipeRightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
        self.swipeRightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        self.swipeRightRecognizer.numberOfTouchesRequired = 3;
        [self.view addGestureRecognizer:self.swipeRightRecognizer];
        
        self.containerTouchRecognizer = [[ITTouchRecognizer alloc] initWithTarget:self action:@selector(containerViewTouched)];
    }
    
    if (self.currentViewController == nil) {
        self.currentViewController = [self.viewControllers objectAtIndex:0];
    }
    [self fillContentView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return ([self.currentViewController shouldAutorotateToInterfaceOrientation:interfaceOrientation]);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* kITSidebarItemCellIdentifier = @"ITSidebarItemCell";
    ITSidebarItemCell *cell = (ITSidebarItemCell*)[tableView dequeueReusableCellWithIdentifier:kITSidebarItemCellIdentifier];
    if (cell == nil) {
        cell = [[ITSidebarItemCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kITSidebarItemCellIdentifier];
    }
    ITSidebarItem *item = [self.sidebarItems objectAtIndex:indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 0) 
        cell.firstCell = YES;
    cell.textLabel.text = item.title;
    cell.imageView.image = item.icon;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [self.viewControllers count];
            break;
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self slideContainerViewToLeftAnimated:YES];
    NSInteger row = indexPath.row;
    UIViewController *viewController = [self.viewControllers objectAtIndex:row];
    [self setCurrentViewController:viewController];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    return [self.currentViewController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return [self.currentViewController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    return [self.currentViewController willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)swipedLeft
{
    [self slideContainerViewToLeftAnimated:YES];
}
- (void)swipedRight
{
    [self slideContainerViewToRightAnimated:YES];
}

- (void)containerViewTouched
{
    [self slideContainerViewToLeftAnimated:YES];
}

@end
