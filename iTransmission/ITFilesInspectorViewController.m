//
//  ITFilesInspectorViewController.m
//  iTransmission
//
//  Created by Mike Chen on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITFilesInspectorViewController.h"
#import "ITTorrent.h"
#import "ITFileInspectorCell.h"
#import "ITFileListNode.h"
#import "ITRoundProgressView.h"
#import "UIAlertView+Lazy.h"
#import "NSStates.h"

@implementation ITFilesInspectorViewController
@synthesize interactionController;

- (id)initWithTorrent:(ITTorrent*)torrent
{
    self = [super initWithNibName:nil bundle:nil torrent:torrent];
    if (self) {
        self.title = @"Files";
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
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;

    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if ([self.tableView respondsToSelector:@selector(registerNib:forCellReuseIdentifier:)]) {
        [self.tableView registerNib:[UINib nibWithNibName:@"ITFileInspectorCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ITFileInspectorCell"];
    }
}

- (void)registerNotifications
{
    [super registerNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(torrentUpdated:) name:kITTorrentUpdatedNotification object:nil];
}

- (void)torrentUpdated:(NSNotification *)notification
{
    ITTorrent *updatedTorrent = [[notification userInfo] objectForKey:@"torrent"];
    if ([updatedTorrent isEqual:self.torrent]) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.torrent flatFileList] count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if ([self.torrent canChangeDownloadCheckForFiles:[[[self.torrent flatFileList] objectAtIndex:indexPath.row] indexes]]) {
        [(ITFileInspectorCell*)cell checkmarkControl].backgroundColor = [UIColor whiteColor];
    }
    else {
        [(ITFileInspectorCell*)cell checkmarkControl].backgroundColor = [UIColor colorWithWhite:0.8f alpha:1.0f];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.torrent fileProgress:[[self.torrent flatFileList] objectAtIndex:indexPath.row]] == 1.00f) {
        return indexPath;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ITFileInspectorCell *cell = (ITFileInspectorCell*)[tableView dequeueReusableCellWithIdentifier:@"ITFileInspectorCell"];
    if (! [self.tableView respondsToSelector:@selector(registerNib:forCellReuseIdentifier:)]) {
        cell = (ITFileInspectorCell*)[[[NSBundle mainBundle] loadNibNamed:@"ITFileInspectorCell" owner:nil options:nil] objectAtIndex:0];
    }
    assert(cell);
    
    if ([[cell.checkmarkControl allTargets] containsObject:self] == NO) {
        [cell.checkmarkControl addTarget:self action:@selector(checkmarkControlTapped:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.nameLabel.text = [[[self.torrent flatFileList] objectAtIndex:indexPath.row] name];
    
    if ([self.torrent checkForFiles:[[[self.torrent flatFileList] objectAtIndex:indexPath.row] indexes]]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.progressView.progress = [self.torrent fileProgress:[[self.torrent flatFileList] objectAtIndex:indexPath.row]];
    
    return cell;
}

- (void)checkmarkControlTapped:(id)sender
{
    ITFileInspectorCell *cell = nil;
    UIView *superView = [sender superview];
    while (TRUE) {
        if (superView == nil || [superView isKindOfClass:NSClassFromString(@"UITableViewCell")]) 
            break;
        else {
            superView = [superView superview];
        }
    }
    if (superView) {
        cell = (ITFileInspectorCell*)superView;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [self.torrent setFileCheckState:NSOffState forIndexes:[[[self.torrent flatFileList] objectAtIndex:indexPath.row] indexes]];
        }
        else {
            [self.torrent setFileCheckState:NSOnState forIndexes:[[[self.torrent flatFileList] objectAtIndex:indexPath.row] indexes]];
        }
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    else {
        LogMessageCompat(@"No cell matched for sender 0x%X\n", (u_int32_t)sender);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ITFileListNode *node = [[self.torrent flatFileList] objectAtIndex:indexPath.row];
    if ([self.torrent fileProgress:node] == 1.00f) {
        
        NSString *fileLocation = [self.torrent fileLocation:node];
        NSURL *URL = [NSURL fileURLWithPath:fileLocation];
        
        self.interactionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        self.interactionController.delegate = self;

        if ([interactionController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES] == NO) {
            [UIAlertView showMessageWithDismissButton:[NSString stringWithFormat:@"No application can open \"%@\"!\n", node.name]];
            self.interactionController = nil;
        }
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    self.interactionController = nil;
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{
    self.interactionController = nil;
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
