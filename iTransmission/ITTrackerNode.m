//
//  ITTrackerNode.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITTrackerNode.h"
#import "ITTorrent.h"
#import "NSStringAdditions.h"

@implementation ITTrackerNode
@synthesize torrent = _torrent;
@synthesize stat = _stat;

- (id) initWithTrackerStat: (tr_tracker_stat *) stat torrent: (ITTorrent *) torrent
{
    if ((self = [super init]))
    {
        self.stat = *stat;
        self.torrent = torrent;
    }
    
    return self;
}

- (NSString *) description
{
    return [@"Tracker: " stringByAppendingString: [self fullAnnounceAddress]];
}

- (id) copyWithZone: (NSZone *) zone
{
    return self;
}

- (NSString *) host
{
    return [NSString stringWithUTF8String: self.stat.host];
}

- (NSString *) fullAnnounceAddress
{
    return [NSString stringWithUTF8String: self.stat.announce];
}

- (NSInteger) tier
{
    return self.stat.tier;
}

- (NSUInteger) identifier
{
    return self.stat.id;
}

- (NSInteger) totalSeeders
{
    return self.stat.seederCount;
}

- (NSInteger) totalLeechers
{
    return self.stat.leecherCount;
}

- (NSInteger) totalDownloaded
{
    return self.stat.downloadCount;
}

- (NSString *) lastAnnounceStatusString
{
    NSString * dateString;
    if (self.stat.hasAnnounced)
    {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle: NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        
        [dateFormatter setDoesRelativeDateFormatting: YES];
        
        dateString = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: self.stat.lastAnnounceTime]];
    }
    else
        dateString = NSLocalizedString(@"N/A", "Tracker last announce");
    
    NSString * baseString;
    if (self.stat.hasAnnounced && self.stat.lastAnnounceTimedOut)
        baseString = [NSLocalizedString(@"Announce timed out", "Tracker last announce") stringByAppendingFormat: @": %@", dateString];
    else if (self.stat.hasAnnounced && !self.stat.lastAnnounceSucceeded)
    {
        baseString = NSLocalizedString(@"Announce error", "Tracker last announce");
        
        NSString * errorString = [NSString stringWithUTF8String: self.stat.lastAnnounceResult];
        if ([errorString isEqualToString: @""])
            baseString = [baseString stringByAppendingFormat: @": %@", dateString];
        else
            baseString = [baseString stringByAppendingFormat: @": %@ - %@", errorString, dateString];
    }
    else
    {
        baseString = [NSLocalizedString(@"Last Announce", "Tracker last announce") stringByAppendingFormat: @": %@", dateString];
        if (self.stat.hasAnnounced && self.stat.lastAnnounceSucceeded && self.stat.lastAnnouncePeerCount > 0)
        {
            NSString * peerString;
            if (self.stat.lastAnnouncePeerCount == 1)
                peerString = NSLocalizedString(@"got 1 peer", "Tracker last announce");
            else
                peerString = [NSString stringWithFormat: NSLocalizedString(@"got %d peers", "Tracker last announce"),
                              self.stat.lastAnnouncePeerCount];
            baseString = [baseString stringByAppendingFormat: @" (%@)", peerString];
        }
    }
    
    return baseString;
}

- (NSString *) nextAnnounceStatusString
{
    switch (self.stat.announceState)
    {
        case TR_TRACKER_ACTIVE:
            return [NSLocalizedString(@"Announce in progress", "Tracker next announce") stringByAppendingEllipsis];
            
        case TR_TRACKER_WAITING:
            return [NSString stringWithFormat: NSLocalizedString(@"Next announce in %@", "Tracker next announce"),
                    [NSString timeString: self.stat.nextAnnounceTime - [[NSDate date] timeIntervalSince1970] showSeconds: YES]];
            
        case TR_TRACKER_QUEUED:
            return [NSLocalizedString(@"Announce is queued", "Tracker next announce") stringByAppendingEllipsis];
            
        case TR_TRACKER_INACTIVE:
            return self.stat.isBackup ? NSLocalizedString(@"Tracker will be used as a backup", "Tracker next announce")
            : NSLocalizedString(@"Announce not scheduled", "Tracker next announce");
            
        default:
            NSAssert1(NO, @"unknown announce state: %d", self.stat.announceState);
            return nil;
    }
}

- (NSString *) lastScrapeStatusString
{
    NSString * dateString;
    if (self.stat.hasScraped)
    {
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle: NSDateFormatterFullStyle];
        [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
        
        [dateFormatter setDoesRelativeDateFormatting: YES];
        
        dateString = [dateFormatter stringFromDate: [NSDate dateWithTimeIntervalSince1970: self.stat.lastScrapeTime]];
    }
    else
        dateString = NSLocalizedString(@"N/A", "Tracker last scrape");
    
    NSString * baseString;
    if (self.stat.hasScraped && self.stat.lastScrapeTimedOut)
        baseString = [NSLocalizedString(@"Scrape timed out", "Tracker last scrape") stringByAppendingFormat: @": %@", dateString];
    else if (self.stat.hasScraped && !self.stat.lastScrapeSucceeded)
    {
        baseString = NSLocalizedString(@"Scrape error", "Tracker last scrape");
        
        NSString * errorString = [NSString stringWithUTF8String: self.stat.lastScrapeResult];
        if ([errorString isEqualToString: @""])
            baseString = [baseString stringByAppendingFormat: @": %@", dateString];
        else
            baseString = [baseString stringByAppendingFormat: @": %@ - %@", errorString, dateString];
    }
    else
        baseString = [NSLocalizedString(@"Last Scrape", "Tracker last scrape") stringByAppendingFormat: @": %@", dateString];
    
    return baseString;
}

@end
