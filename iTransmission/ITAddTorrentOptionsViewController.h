//
//  ITAddTorrentOptionsViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITTorrent;

@interface ITAddTorrentOptionsViewController : UIViewController

@property (nonatomic, strong) ITTorrent *torrent;

- (id)initWithPrebuiltTorrent:(ITTorrent*)torrent;

- (void)cancel:(id)sender;
- (void)done:(id)sender;

@end
