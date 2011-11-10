//
//  ITInspectorBaseViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITTorrent;

@interface ITInspectorBaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (assign /* better with weak */, nonatomic) ITTorrent *torrent;
@property (readonly, nonatomic, getter = isTorrentEmpty) BOOL torrentEmpty;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil torrent:(ITTorrent*)torrent;
- (id)initWithTorrent:(ITTorrent*)torrent;

- (void)registerNotifications;
- (void)torrentRemoved:(NSNotification*)notification;
- (void)torrentChanged:(NSNotification*)notification;

@end
