//
//  ITTransfersViewController.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITTransfersViewController.h"
#import "ITSidebarItem.h"
#import "ITTransferCell.h"
#import "ITColoredProgressView.h"
#import "ITShadowedTableView.h"
#import "ITController.h"
#import "ITTorrent.h"
#import "ITRoundProgressView.h"
#import "ITShadowView.h"
#import "ITInspectorCollectionViewController.h"
#import "ITAppDelegate.h"
#import "UIColor+Style.h"

@implementation ITTransfersViewController
@synthesize sidebarItem = _sidebarItem;
@synthesize tableView = _tableView;
@synthesize displayedTorrents = _displayedTorrents;

- (id)init 
{
    if ((self = [super init])) {
        self.title = @"Transfers";
        self.sidebarItem = [[ITSidebarItem alloc] init];
        self.sidebarItem.title = @"Transfers";
        self.sidebarItem.icon = [UIImage imageNamed:@"transfers-icon.png"];
        self.displayedTorrents = [NSMutableArray array];
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

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"texture_white_small.png"]];
    backgroundView.contentMode = UIViewContentModeRedraw;
    backgroundView.frame = self.view.bounds;
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:backgroundView];
    self.tableView.backgroundView.contentMode = UIViewContentModeRedraw;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
        
    [self.tableView registerNib:[UINib nibWithNibName:@"ITTransferCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[ITTransferCell identifier]];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[ITAppDelegate sharedDelegate] registerForTimerEvent:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[ITAppDelegate sharedDelegate] unregisterForTimerEvent:self];
}

- (void)timerFiredAfterDelay:(NSTimeInterval)timeInternalSinceLastCall
{
//    NSArray *indexPathes = [self.tableView indexPathsForVisibleRows];
//    for (NSIndexPath *indexPath in indexPathes) {
//        [self performSelector:@selector(updateCellForIndexPath:) withObject:indexPath afterDelay:0.0f];
//    }
}

- (void)updateCellForIndexPath:(NSIndexPath *)indexPath
{
    ITTransferCell *cell = (ITTransferCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    if (cell) {
        ITTorrent *torrent = [self.displayedTorrents objectAtIndex:indexPath.row];
        [self fillInCell:cell withTorrent:torrent];
    }
}
         
- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentHistoryLoaded:) name:kITTorrentHistoryLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentRemoved:) name:kITTorrentRemovedNotification object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentRemoved:) name:kITTorrentAboutToBeRemovedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTorrentAdded:) name:kITNewTorrentAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentUpdated:) name:kITTorrentUpdatedNotification object:nil];
}

- (void)torrentHistoryLoaded:(NSNotification *)notification
{
    NSArray *loadedTorrents = [[notification userInfo] objectForKey:@"torrents"];
    [self.displayedTorrents addObjectsFromArray:loadedTorrents];
    [self.tableView reloadData];
}

- (void)torrentUpdated:(NSNotification *)notification
{
    if ([self.view isHidden] == NO) {
        ITTorrent *torrent = [[notification userInfo] objectForKey:@"torrent"];
        if ([self.displayedTorrents containsObject:torrent]) {
            [self updateCellForIndexPath:[NSIndexPath indexPathForRow:[self.displayedTorrents indexOfObject:torrent] inSection:0]];
        }
    }
}

- (void)torrentRemoved:(NSNotification *)notification
{
    ITTorrent *torrent = [[notification userInfo] objectForKey:@"torrent"];
    NSInteger index = [self.displayedTorrents indexOfObject:torrent];
    if (index != NSNotFound) {
        [self.tableView beginUpdates];
        [self.displayedTorrents removeObject:torrent];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (void)newTorrentAdded:(NSNotification *)notification
{
    ITTorrent *torrent = [[notification userInfo] objectForKey:@"torrent"];
    NSAssert(torrent, @"Received notification that has nil torrent\n", @"");
    NSInteger index = [self.displayedTorrents indexOfObject:torrent];

    if (index == NSNotFound) {
        [self.tableView beginUpdates];
        [self.displayedTorrents addObject:torrent];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:([self.displayedTorrents count] - 1) inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
        [self.tableView endUpdates];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ITTransferCell defaultHeight];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger ret = [self.displayedTorrents count];
    return ret;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ITTransferCell *cell = (ITTransferCell*)[tableView dequeueReusableCellWithIdentifier:[ITTransferCell identifier]];
    assert(cell);
    
    ITTorrent *torrent = [self.displayedTorrents objectAtIndex:indexPath.row];
    [self fillInCell:cell withTorrent:torrent];
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ITInspectorCollectionViewController *inspectors = [[ITInspectorCollectionViewController alloc] initWithTorrent:[self.displayedTorrents objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:inspectors animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ITTorrent *torrent = [self.displayedTorrents objectAtIndex:indexPath.row];
        [[ITController sharedController] confirmRemoveTorrents:[NSArray arrayWithObject:torrent] deleteData:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)fillInCell:(ITTransferCell*)cell withTorrent:(ITTorrent*)torrent
{
    cell.titleLabel.text = torrent.name;
    cell.sizeLabel.text = [torrent progressString];
    cell.descriptionLabel.text = [torrent statusString];
    [cell.roundProgressView setProgress:[torrent progress]];
    if ([[cell.roundProgressView allTargets] containsObject:self] == NO) {
        [cell.roundProgressView addTarget:self action:@selector(progressControlTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
//    if ([torrent isActive]) {
//        if ([torrent isChecking]) 
//            cell.roundProgressView.progressColor = [UIColor controlYellowColor];
//        else if ([torrent isSeeding])
//            cell.roundProgressView.progressColor = [UIColor controlGreenColor];
//        else 
//            cell.roundProgressView.progressColor = [UIColor controlBlueColor];
//    }
//    else 
//        cell.roundProgressView.progressColor = [UIColor controlGreyColor];
}

- (void)progressControlTapped:(id)sender
{
    ITTransferCell *cell = nil;
    UIView *superView = [sender superview];
    while (TRUE) {
        if (superView == nil || [superView isKindOfClass:NSClassFromString(@"UITableViewCell")]) 
            break;
        else {
            superView = [superView superview];
        }
    }
    if (superView) {
        cell = (ITTransferCell*)superView;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (indexPath) {
            ITTorrent *torrent = [self.displayedTorrents objectAtIndex:indexPath.row];
            assert(torrent);
            if ([torrent isActive]) {
                [torrent sleep];
            }
            else {
                [torrent startIfAllowed];
            }
        }
    }
    else {
        LogMessageCompat(@"No cell matched for sender 0x%X\n", (u_int32_t)sender);
    }
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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObject:self];
}

@end
