//
//  ITTransfersViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITSidebarItemDatasource.h"
#import "ITTimerListener.h"

@class ITTransferCell;
@class ITTorrent;

@interface ITTransfersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ITSidebarItemDatasource, ITTimerListener>

@property (strong, nonatomic) NSMutableArray *displayedTorrents;
@property (strong, nonatomic) ITSidebarItem *sidebarItem;
@property (strong, nonatomic) UITableView *tableView;

- (void)registerNotifications;
- (void)torrentHistoryLoaded:(NSNotification*)notification;
- (void)newTorrentAdded:(NSNotification*)notification;
- (void)torrentUpdated:(NSNotification*)notification;
- (void)torrentRemoved:(NSNotification*)notification;
- (void)fillInCell:(ITTransferCell*)cell withTorrent:(ITTorrent*)torrent;
- (void)updateCellForIndexPath:(NSIndexPath*)indexPath;
- (void)progressControlTapped:(id)sender;
@end
