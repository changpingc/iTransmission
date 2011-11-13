//
//  ITNavigationController.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITNavigationController.h"
#import "ITSidebarController.h"
#import "ITSidebarItem.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Style.h"

// Tint: 0.25, 0.375, 0.7

@implementation ITNavigationController

@synthesize sidebarController = _sidebarController;
@synthesize sidebarItem = _sidebarItem;
@synthesize rootViewController = _rootViewController;

- (UIBarButtonItem*)sidebarButtonItem
{
//    UIBarButtonItem *sidebarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"33-cabinet.png"] style:UIBarButtonItemStylePlain target:self action:@selector(sidebarButtonItemClicked:)];
    UIBarButtonItem *sidebarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(sidebarButtonItemClicked:)];

    return sidebarButtonItem;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if ((self = [super initWithRootViewController:rootViewController])) {
//        self.navigationBar.barStyle = UIBarStyleBlack;
        self.delegate = self;
        self.rootViewController = rootViewController;
        self.navigationBar.tintColor = [UIColor barBlueColor];
        UIImage *barBackground = [UIImage imageNamed:@"bar-bg.png"];
        if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            [self.navigationBar setBackgroundImage:barBackground forBarMetrics:UIBarMetricsDefault];
        }
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)sidebarButtonItemClicked:(id)sender
{
    [self.sidebarController toggleStateAnimated:YES];
}

- (void)setSidebarController:(ITSidebarController *)sidebarController
{
    _sidebarController = sidebarController;
    if (self.sidebarController) {
        if ([self.rootViewController conformsToProtocol:@protocol(ITSidebarItemDatasource)])
            self.sidebarItem = [(UIViewController<ITSidebarItemDatasource>*)self.rootViewController sidebarItem];
        else {
            self.sidebarItem = [[ITSidebarItem alloc] init];
            self.sidebarItem.title = [self rootViewController].title;
        }
    }
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if (self.sidebarController) {
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//            viewController.navigationItem.leftBarButtonItem = [self sidebarButtonItem];
//    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if (self.sidebarController) {
//        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//            viewController.navigationItem.leftBarButtonItem = [self sidebarButtonItem];
//    }
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

@end