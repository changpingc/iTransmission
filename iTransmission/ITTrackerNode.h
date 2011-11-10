//
//  ITTrackerNode.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libtransmission/transmission.h>

@class ITTorrent;

@interface ITTrackerNode : NSObject
@property (nonatomic, assign) tr_tracker_stat stat;
@property (nonatomic, assign) ITTorrent *torrent;

- (id) initWithTrackerStat:(tr_tracker_stat *)stat torrent:(ITTorrent *) torrent;

- (NSString *) host;
- (NSString *) fullAnnounceAddress;

- (NSInteger) tier;

- (NSUInteger) identifier;
- (NSInteger) totalSeeders;
- (NSInteger) totalLeechers;
- (NSInteger) totalDownloaded;

- (NSString *) lastAnnounceStatusString;
- (NSString *) nextAnnounceStatusString;
- (NSString *) lastScrapeStatusString;

@end