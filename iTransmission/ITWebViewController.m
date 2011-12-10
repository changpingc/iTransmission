//
//  ITWebViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITWebViewController.h"
#import "ITSidebarItem.h"
#import "ITNavigationController.h"

@implementation ITWebViewController
@synthesize sidebarItem = _sidebarItem;

- (id)init
{
    if ((self = [super initWithAddress:@"http://www.google.com"])) {
        self.sidebarItem = [[ITSidebarItem alloc] init];
        self.sidebarItem.title = @"Browser";
//        self.sidebarItem.icon = [UIImage imageNamed:@"browser-icon.png"];
        self.navigationController.toolbarHidden = NO;
//        self.navigationController.toolbar.barStyle = UIBarStyleBlack;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([self.navigationController respondsToSelector:@selector(setUseDefaultTheme:)])
        [(ITNavigationController*)self.navigationController setUseDefaultTheme:YES];
//    [[self.navigationController navigationBar] setBarStyle:UIBarStyleDefault];
//    [[self.navigationController navigationBar] setTintColor:nil];
//    if ([[self.navigationController navigationBar] respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
//        [[self.navigationController navigationBar] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
