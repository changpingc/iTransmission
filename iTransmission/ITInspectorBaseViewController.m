//
//  ITInspectorBaseViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITInspectorBaseViewController.h"
#import "ITTorrent.h"
#import "ITController.h"

@implementation ITInspectorBaseViewController

@synthesize torrent = _torrent;
@synthesize tableView = _tableView;
@dynamic torrentEmpty;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil torrent:(ITTorrent *)torrent
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.torrent = torrent;
        [self registerNotifications];
    }
    return self;
}

- (id)initWithTorrent:(ITTorrent*)torrent
{
    self = [super init];
    if (self) {
        self.torrent = torrent;
        [self registerNotifications];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentRemoved:) name:kITTorrentRemovedNotification object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentRemoved:) name:kITTorrentAboutToBeRemovedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentChanged:) name:kITTorrentChangedNotification object:nil];
}

- (void)torrentRemoved:(NSNotification *)notification
{
    ITTorrent *removedTorrent = [[notification userInfo] objectForKey:@"torrent"];
    if ([removedTorrent isEqual:self.torrent]) {
        self.torrent = nil;
    }
}

- (void)torrentChanged:(NSNotification *)notification
{
    ITTorrent *changedTorrent = [[notification userInfo] objectForKey:@"torrent"];
    if ([changedTorrent isEqual:self.torrent]) {
        if (self.tableView != nil) {
            [self.tableView reloadData];
        }
        else {
            LogMessageCompat(@"ITInspectorBaseViewController: torrent changed but table view is nil? what to do? \n");
        }
    }
}

- (BOOL)isTorrentEmpty
{
    return (self.torrent == nil);
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    LogMessageCompat(@"ITInspectorBaseViewController received numberOfSectionsInTableView: call\n");
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    LogMessageCompat(@"ITInspectorBaseViewController received tableView:numberOfRowsInSection: call\n");
    return 0;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LogMessageCompat(@"ITInspectorBaseViewController received tableView:cellForRowAtIndexPath: call\n");
    return nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
