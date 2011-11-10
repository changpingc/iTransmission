//
//  ITInfoViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITInfoViewController.h"
#import "ITSidebarItem.h"
#import <libtransmission/version.h>
#import <event2/event-config.h>
#import <curl/curlver.h>
#import <openssl/opensslv.h>

@implementation ITInfoViewController

@synthesize pageName = _pageName;
@synthesize activityIndicator = _activityIndicator;
@synthesize sidebarItem = _sidebarItem;

- (id)initWithPageName:(NSString*)p
{
    if ((self = [super init])) {
        self.pageName = p;
        self.sidebarItem = [[ITSidebarItem alloc] init];
        self.sidebarItem.title = @"About";
        self.sidebarItem.icon = [UIImage imageNamed:@"about-icon.png"];
    }
    return self;
}

#pragma mark - View lifecycle

- (void)loadView
{
    UIWebView *view = [[UIWebView alloc] init];
    view.delegate = self;
    self.view = view;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
    self.activityIndicator = [[UIActivityIndicatorView alloc]
                               initWithFrame:frame];
    [self.activityIndicator sizeToFit];
    [self.activityIndicator setHidesWhenStopped:YES];
    self.activityIndicator.autoresizingMask =
    (UIViewAutoresizingFlexibleLeftMargin |
     UIViewAutoresizingFlexibleRightMargin |
     UIViewAutoresizingFlexibleTopMargin |
     UIViewAutoresizingFlexibleBottomMargin);
    
    UIBarButtonItem *loadingView = [[UIBarButtonItem alloc] 
                                    initWithCustomView:self.activityIndicator];
    loadingView.target = self;
    self.navigationItem.rightBarButtonItem = loadingView;
    
    NSString *pagePath = [[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Info"] stringByAppendingPathComponent:self.pageName] stringByAppendingPathExtension:@"html"];
    
    self.pageName = nil;
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:pagePath] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5.0f];
    [(UIWebView*)self.view loadRequest:request];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    if (![[[request URL] scheme] isEqualToString:@"file"]) {
        [[UIApplication sharedApplication] openURL:[request URL]];
        return NO;
    }
    
    if ([[[[request URL] absoluteString] lastPathComponent] isEqualToString:@"about.html"]) {
        
    }
    
    [self.activityIndicator startAnimating];
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.title = title;
    
    if ([[[[webView.request URL] absoluteString] lastPathComponent] isEqualToString:@"about.html"]) {
        NSString *viTrans = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('itransmission_version').innerHTML = '%@'", viTrans]];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('libtransmission_version').innerHTML = '%s'", LONG_VERSION_STRING]];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('libevent_version').innerHTML = '%s'", _EVENT_VERSION]];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('libcurl_version').innerHTML = '%s'", LIBCURL_VERSION]];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.getElementById('openssl_version').innerHTML = '%s'", OPENSSL_VERSION_TEXT]];

    }
    [self.activityIndicator stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    LogMessageCompat(@"%@", [error description]);
    [self.activityIndicator stopAnimating];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
@end
