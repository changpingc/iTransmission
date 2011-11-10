//
//  ITTorrentGroup.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITTorrentGroup.h"
#import "ITTorrent.h"
#import <libtransmission/transmission.h>
#import <libtransmission/utils.h>

@implementation ITTorrentGroup
@synthesize group = _group;
@synthesize torrents = _torrents;
- (id) initWithGroup: (NSInteger) group
{
    if ((self = [super init]))
    {
        self.group = group;
        self.torrents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (CGFloat) ratio
{
    uint64_t uploaded = 0, downloaded = 0;
    for (ITTorrent * torrent in self.torrents)
    {
        uploaded += [torrent uploadedTotal];
        downloaded += [torrent downloadedTotal];
    }
    
    return tr_getRatio(uploaded, downloaded);
}

- (CGFloat) uploadRate
{
    CGFloat rate = 0.0;
    for (ITTorrent * torrent in self.torrents)
        rate += [torrent uploadRate];
    
    return rate;
}

- (CGFloat) downloadRate
{
    CGFloat rate = 0.0;
    for (ITTorrent * torrent in self.torrents)
        rate += [torrent downloadRate];
    
    return rate;
}

@end
