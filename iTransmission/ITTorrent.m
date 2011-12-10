//
//  ITTorrent.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITTorrent.h"
#import <libtransmission/utils.h>
#import "NSStringAdditions.h"
#import "ITTrackerNode.h"
#import "ITFileListNode.h"
#import "ITNetworkSwitcher.h"
#import "NSStates.h"

#define ETA_IDLE_DISPLAY_SEC (2*60)

static void startQueueCallback(tr_torrent * torrent, void * torrentData)
{
    [(__bridge ITTorrent *)torrentData performSelectorOnMainThread: @selector(startQueue) withObject: nil waitUntilDone: NO];
}

static void completenessChangeCallback(tr_torrent * torrent, tr_completeness status, bool wasRunning, void * torrentData)
{    
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt: status], @"Status",
                           [NSNumber numberWithBool: wasRunning], @"WasRunning", nil];
    [(__bridge ITTorrent *)torrentData performSelectorOnMainThread: @selector(completenessChange:) withObject: dict waitUntilDone: NO];
}

static void ratioLimitHitCallback(tr_torrent * torrent, void * torrentData)
{
    [(__bridge ITTorrent *)torrentData performSelectorOnMainThread: @selector(ratioLimitHit) withObject: nil waitUntilDone: NO];
}

static void idleLimitHitCallback(tr_torrent * torrent, void * torrentData)
{
    [(__bridge ITTorrent *)torrentData performSelectorOnMainThread: @selector(idleLimitHit) withObject: nil waitUntilDone: NO];
}

static void metadataCallback(tr_torrent * torrent, void * torrentData)
{
    [(__bridge ITTorrent *)torrentData performSelectorOnMainThread: @selector(metadataRetrieved) withObject: nil waitUntilDone: NO];
}

static int trashDataFile(const char * filename)
{
    if (filename != NULL)
        [ITTorrent trashFile: [NSString stringWithUTF8String: filename]];
    
    return 0;
}

@interface ITTorrent (Private)

- (id) initWithPath: (NSString *) path hash: (NSString *) hashString torrentStruct: (tr_torrent *) torrentStruct
      magnetAddress: (NSString *) magnetAddress lib: (tr_session *) lib
         groupValue: (NSNumber *) groupValue
     downloadFolder: (NSString *) downloadFolder
legacyIncompleteFolder: (NSString *) incompleteFolder;

- (void) createFileList;
- (void) insertPath: (NSMutableArray *) components forParent: (ITFileListNode *) parent fileSize: (uint64_t) size
              index: (NSInteger) index flatList: (NSMutableArray *) flatFileList;
- (void) sortFileList: (NSMutableArray *) fileNodes;

- (void) startQueue;
- (void) completenessChange: (NSDictionary *) statusInfo;
- (void) ratioLimitHit;
- (void) idleLimitHit;
- (void) metadataRetrieved;

- (BOOL) shouldShowEta;
- (NSString *) etaString;

@end

@implementation ITTorrent

@synthesize handle = _handle;
@synthesize info = _info;
@synthesize stat = _stat;
@synthesize hashString = _hashString;
@synthesize fileStat = _fileStat;
@synthesize previousFinishedIndexes = _previousFinishedIndexes;
@synthesize previousFinishedIndexesDate = _previousFinishedIndexesDate;
@synthesize groupValue = _groupValue;
@synthesize resumeOnWake = _resumeOnWake;
@synthesize userDefaults = _userDefaults;
@synthesize icon = _icon;
@synthesize fileList = _fileList;
@synthesize flatFileList = _flatFileList;
@synthesize lastUpdateDate = _lastUpdateDate;

- (id) initWithPath: (NSString *) path location: (NSString *) location deleteTorrentFile: (BOOL) torrentDelete
                lib: (tr_session *) lib
{
    self = [self initWithPath: path hash: nil torrentStruct: NULL magnetAddress: nil lib: lib
                   groupValue: nil
               downloadFolder: location
       legacyIncompleteFolder: nil];
    
    if (self)
    {
        if (torrentDelete && ![[self torrentLocation] isEqualToString: path])
            [ITTorrent trashFile: path];
    }
    return self;
}

- (id) initWithTorrentStruct: (tr_torrent *) torrentStruct location: (NSString *) location lib: (tr_session *) lib
{
    self = [self initWithPath: nil hash: nil torrentStruct: torrentStruct magnetAddress: nil lib: lib
                   groupValue: nil
               downloadFolder: location
       legacyIncompleteFolder: nil];
    
    return self;
}

- (id) initWithMagnetAddress: (NSString *) address location: (NSString *) location lib: (tr_session *) lib
{
    self = [self initWithPath: nil hash: nil torrentStruct: nil magnetAddress: address
                          lib: lib groupValue: nil
               downloadFolder: location legacyIncompleteFolder: nil];
    
    return self;
}

- (id) initWithHistory: (NSDictionary *) history lib: (tr_session *) lib forcePause: (BOOL) pause
{
    self = [self initWithPath: [history objectForKey: @"InternalTorrentPath"]
                         hash: [history objectForKey: @"TorrentHash"]
                torrentStruct: NULL
                magnetAddress: nil
                          lib: lib
                   groupValue: [history objectForKey: @"GroupValue"]
               downloadFolder: [history objectForKey: @"DownloadFolder"] //upgrading from versions < 1.80
       legacyIncompleteFolder: [[history objectForKey: @"UseIncompleteFolder"] boolValue] //upgrading from versions < 1.80
            ? [history objectForKey: @"IncompleteFolder"] : nil];
    
    if (self)
    {
        //start transfer
        NSNumber * active;
        if (!pause && (active = [history objectForKey: @"Active"]) && [active boolValue])
        {
            self.stat = (struct tr_stat*)tr_torrentStat(self.handle);
            [self startTransferNoQueue];
        }
        NSNumber * ratioLimit;
        if ((ratioLimit = [history objectForKey: @"RatioLimit"]))
            [self setRatioLimit: [ratioLimit floatValue]];
    }
    return self;
}

- (NSDictionary *) history
{
    NSMutableDictionary * history = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [self torrentLocation], @"InternalTorrentPath",
                                     [self hashString], @"TorrentHash",
                                     [NSNumber numberWithBool: [self isActive]], @"Active",
                                     [NSNumber numberWithBool: [self waitingToStart]], @"WaitToStart",
                                     [NSNumber numberWithInt: self.groupValue], @"GroupValue", nil];
    
    return history;
}

- (NSString *) description
{
    return [@"Torrent: " stringByAppendingString: [self name]];
}

- (id) copyWithZone: (NSZone *) zone
{
    return self;
}

- (void) closeRemoveTorrent: (BOOL) trashFiles
{
    tr_torrentRemove(self.handle, trashFiles, trashDataFile);
}

- (void) changeDownloadFolderBeforeUsing: (NSString *) folder
{
    tr_torrentSetDownloadDir(self.handle, [folder UTF8String]);
}

- (NSString *) currentDirectory
{
    return [NSString stringWithUTF8String: tr_torrentGetCurrentDir(self.handle)];
}

- (void) getAvailability: (int8_t *) tab size: (NSInteger) size
{
    tr_torrentAvailability(self.handle, tab, size);
}

- (void) getAmountFinished: (float *) tab size: (NSInteger) size
{
    tr_torrentAmountFinished(self.handle, tab, size);
}

- (NSIndexSet *) previousFinishedPieces
{
    //if the torrent hasn't been seen in a bit, and therefore hasn't been refreshed, return nil
    if (self.previousFinishedIndexesDate && [self.previousFinishedIndexesDate timeIntervalSinceNow] > -2.0)
        return self.previousFinishedIndexes;
    else
        return nil;
}

- (void) setPreviousFinishedPieces: (NSIndexSet *) indexes
{
    self.previousFinishedIndexes = indexes;
    self.previousFinishedIndexesDate = indexes != nil ? [[NSDate alloc] init] : nil;
}

- (void) update
{
    NSDate *now = [NSDate date];
    self.stat = (tr_stat*)tr_torrentStat(self.handle);
    self.lastUpdateDate = now;
    [[NSNotificationCenter defaultCenter] postNotificationName:kITTorrentUpdatedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:self forKey:@"torrent"]];
}

- (void) startTransferIgnoringQueue: (BOOL) ignoreQueue
{
    if ([self alertForRemainingDiskSpace])
    {
        ignoreQueue ? tr_torrentStartNow(self.handle) : tr_torrentStart(self.handle);
        [self update];
        
        //capture, specifically, stop-seeding settings changing to unlimited
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateOptions" object: nil];
    }
}

- (void) startTransferNoQueue
{
    [self startTransferIgnoringQueue: YES];
}

- (void) startTransfer
{
    
    [self startTransferIgnoringQueue: NO];
}

- (void) stopTransfer
{
    [self performSelectorInBackground:@selector(_stopInBackground) withObject:nil];
    [self update];
}

- (void)_stopInBackground
{
    tr_torrentStop(self.handle);
    [self performSelectorOnMainThread:@selector(update) withObject:nil waitUntilDone:NO];
}

- (void) sleep
{
    if ((self.resumeOnWake = [self isActive]))
        [self performSelectorInBackground:@selector(_stopInBackground) withObject:nil];
}

- (void) wakeUp
{
    if (self.resumeOnWake)
    {
        tr_ninf( self.info->name, "restarting because of wakeUp" );
        tr_torrentStart(self.handle);
    }
}

- (NSInteger) queuePosition
{
    return self.stat->queuePosition;
}

- (void) setQueuePosition: (NSUInteger) index
{
    tr_torrentSetQueuePosition(self.handle, index);
}

- (void) manualAnnounce
{
    tr_torrentManualUpdate(self.handle);
}

- (BOOL) canManualAnnounce
{
    return tr_torrentCanManualUpdate(self.handle);
}

- (void) resetCache
{
    tr_torrentVerify(self.handle);
    [self update];
}

- (BOOL) isMagnet
{
    return !tr_torrentHasMetadata(self.handle);
}

- (NSString *) magnetLink
{
    return [NSString stringWithUTF8String: tr_torrentGetMagnetLink(self.handle)];
}

- (CGFloat) ratio
{
    return self.stat->ratio;
}

- (tr_ratiolimit) ratioSetting
{
    return tr_torrentGetRatioMode(self.handle);
}

- (void) setRatioSetting: (tr_ratiolimit) setting
{
    tr_torrentSetRatioMode(self.handle, setting);
}

- (CGFloat) ratioLimit
{
    return tr_torrentGetRatioLimit(self.handle);
}

- (void) setRatioLimit: (CGFloat) limit
{
    NSAssert(limit >= 0, @"Ratio cannot be negative");
    tr_torrentSetRatioLimit(self.handle, limit);
}

- (CGFloat) progressStopRatio
{
    return self.stat->seedRatioPercentDone;
}

- (tr_idlelimit) idleSetting
{
    return tr_torrentGetIdleMode(self.handle);
}

- (void) setIdleSetting: (tr_idlelimit) setting
{
    tr_torrentSetIdleMode(self.handle, setting);
}

- (NSUInteger) idleLimitMinutes
{
    return tr_torrentGetIdleLimit(self.handle);
}

- (void) setIdleLimitMinutes: (NSUInteger) limit
{
    NSAssert(limit > 0, @"Idle limit must be greater than zero");
    tr_torrentSetIdleLimit(self.handle, limit);
}

- (BOOL) usesSpeedLimit: (BOOL) upload
{
    return tr_torrentUsesSpeedLimit(self.handle, upload ? TR_UP : TR_DOWN);
}

- (void) setUseSpeedLimit: (BOOL) use upload: (BOOL) upload
{
    tr_torrentUseSpeedLimit(self.handle, upload ? TR_UP : TR_DOWN, use);
}

- (NSInteger) speedLimit: (BOOL) upload
{
    return tr_torrentGetSpeedLimit_KBps(self.handle, upload ? TR_UP : TR_DOWN);
}

- (void) setSpeedLimit: (NSInteger) limit upload: (BOOL) upload
{
    tr_torrentSetSpeedLimit_KBps(self.handle, upload ? TR_UP : TR_DOWN, limit);
}

- (BOOL) usesGlobalSpeedLimit
{
    return tr_torrentUsesSessionLimits(self.handle);
}

- (void) setUseGlobalSpeedLimit: (BOOL) use
{
    tr_torrentUseSessionLimits(self.handle, use);
}

- (void) setMaxPeerConnect: (uint16_t) count
{
    NSAssert(count > 0, @"max peer count must be greater than 0");
    
    tr_torrentSetPeerLimit(self.handle, count);
}

- (uint16_t) maxPeerConnect
{
    return tr_torrentGetPeerLimit(self.handle);
}
- (BOOL) waitingToStart
{
    return self.stat->activity == TR_STATUS_DOWNLOAD_WAIT || self.stat->activity == TR_STATUS_SEED_WAIT;
}

- (tr_priority_t) priority
{
    return tr_torrentGetPriority(self.handle);
}

- (void) setPriority: (tr_priority_t) priority
{
    return tr_torrentSetPriority(self.handle, priority);
}

+ (void) trashFile: (NSString *) path
{
    NSError * error;
    if (![[NSFileManager defaultManager] removeItemAtPath: path error: &error])
        LogMessageCompat(@"Could not trash %@: %@", path, [error localizedDescription]);    
}

- (void) moveTorrentDataFileTo: (NSString *) folder
{
    NSString * oldFolder = [self currentDirectory];
    if ([oldFolder isEqualToString: folder])
        return;
    
    //check if moving inside itself
    NSArray * oldComponents = [oldFolder pathComponents],
    * newComponents = [folder pathComponents];
    const NSInteger oldCount = [oldComponents count];
    
    if (oldCount < [newComponents count] && [[newComponents objectAtIndex: oldCount] isEqualToString: [self name]]
        && [folder hasPrefix: oldFolder])
    {
        LogMessageCompat(@"A folder cannot be moved to inside itself.\n");
        return;
    }
    
    volatile int status;
    tr_torrentSetLocation(self.handle, [folder UTF8String], YES, NULL, &status);
    
    while (status == TR_LOC_MOVING) //block while moving (for now)
        [NSThread sleepForTimeInterval: 0.05];
    
    if (status == TR_LOC_DONE)
        [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateStats" object: nil];
    else
    {
        LogMessageCompat(@"Failed to move files.\n");
    }
}

- (void) copyTorrentFileTo: (NSString *) path
{
    [[NSFileManager defaultManager] copyItemAtPath: [self torrentLocation] toPath: path error: NULL];
}

- (BOOL) alertForRemainingDiskSpace
{
    if ([self allDownloaded] || ![self.userDefaults boolForKey: @"WarningRemainingSpace"])
        return YES;
    
    NSString * downloadFolder = [self currentDirectory];
    NSDictionary * systemAttributes;
    if ((systemAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath: downloadFolder error: NULL]))
    {
        const uint64_t remainingSpace = [[systemAttributes objectForKey: NSFileSystemFreeSize] unsignedLongLongValue];
        
        //if the remaining space is greater than the size left, then there is enough space regardless of preallocation
        if (remainingSpace < [self sizeLeft] && remainingSpace < tr_torrentGetBytesLeftToAllocate(self.handle))
        {
            //            NSString * volumeName = [[[NSFileManager defaultManager] componentsToDisplayForPath: downloadFolder] objectAtIndex: 0];
            //            
            //            NSAlert * alert = [[NSAlert alloc] init];
            //            [alert setMessageText: [NSString stringWithFormat:
            //                                    NSLocalizedString(@"Not enough remaining disk space to download \"%@\" completely.",
            //                                                      "Torrent disk space alert -> title"), [self name]]];
            //            [alert setInformativeText: [NSString stringWithFormat: NSLocalizedString(@"The transfer will be paused."
            //                                                                                     " Clear up space on %@ or deselect files in the torrent inspector to continue.",
            //                                                                                     "Torrent disk space alert -> message"), volumeName]];
            //            [alert addButtonWithTitle: NSLocalizedString(@"OK", "Torrent disk space alert -> button")];
            //            [alert addButtonWithTitle: NSLocalizedString(@"Download Anyway", "Torrent disk space alert -> button")];
            //            
            //            [alert setShowsSuppressionButton: YES];
            //            [[alert suppressionButton] setTitle: NSLocalizedString(@"Do not check disk space again",
            //                                                                   "Torrent disk space alert -> button")];
            //            
            //            const NSInteger result = [alert runModal];
            //            if ([[alert suppressionButton] state] == NSOnState)
            //                [self.userDefaults setBool: NO forKey: @"WarningRemainingSpace"];
            //            [alert release];
            //            
            //            return result != NSAlertFirstButtonReturn;
            LogMessageCompat(@"Insufficient data storage.");
            return NO;
        }
    }
    return YES;
}

- (NSString *) name
{
    return self.info->name != NULL ? [NSString stringWithUTF8String: self.info->name] : self.hashString;
}

- (BOOL) isFolder
{
    return self.info->isMultifile;
}

- (uint64_t) size
{
    return self.info->totalSize;
}

- (uint64_t) sizeLeft
{
    return self.stat->leftUntilDone;
}

- (NSMutableArray *) allTrackerStats
{
    int count;
    tr_tracker_stat * stats = tr_torrentTrackers(self.handle, &count);
    
    NSMutableArray * trackers = [NSMutableArray arrayWithCapacity: (count > 0 ? count + (stats[count-1].tier + 1) : 0)];
    
    int prevTier = -1;
    for (int i=0; i < count; ++i)
    {
        if (stats[i].tier != prevTier)
        {
            [trackers addObject: [NSDictionary dictionaryWithObjectsAndKeys: [NSNumber numberWithInteger: stats[i].tier + 1], @"Tier",
                                  [self name], @"Name", nil]];
            prevTier = stats[i].tier;
        }
        
        ITTrackerNode * tracker = [[ITTrackerNode alloc] initWithTrackerStat: &stats[i] torrent: self];
        [trackers addObject: tracker];
    }
    
    tr_torrentTrackersFree(stats, count);
    return trackers;
}

- (NSArray *) allTrackersFlat
{
    NSMutableArray * allTrackers = [NSMutableArray arrayWithCapacity: self.info->trackerCount];
    
    for (NSInteger i=0; i < self.info->trackerCount; i++)
        [allTrackers addObject: [NSString stringWithUTF8String: self.info->trackers[i].announce]];
    
    return allTrackers;
}

- (BOOL) addTrackerToNewTier: (NSString *) tracker
{
    tracker = [tracker stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([tracker rangeOfString: @"://"].location == NSNotFound)
        tracker = [@"http://" stringByAppendingString: tracker];
    
    //recreate the tracker structure
    const int oldTrackerCount = self.info->trackerCount;
    tr_tracker_info * trackerStructs = tr_new(tr_tracker_info, oldTrackerCount+1);
    for (NSUInteger i=0; i < oldTrackerCount; ++i)
        trackerStructs[i] = self.info->trackers[i];
    
    trackerStructs[oldTrackerCount].announce = (char *)[tracker UTF8String];
    trackerStructs[oldTrackerCount].tier = trackerStructs[oldTrackerCount-1].tier + 1;
    trackerStructs[oldTrackerCount].id = oldTrackerCount;
    
    const BOOL success = tr_torrentSetAnnounceList(self.handle, trackerStructs, oldTrackerCount+1);
    tr_free(trackerStructs);
    
    return success;
}

- (void) removeTrackers: (NSSet *) trackers
{
    //recreate the tracker structure
    tr_tracker_info * trackerStructs = tr_new(tr_tracker_info, self.info->trackerCount);
    
    NSUInteger newCount = 0;
    for (NSUInteger i = 0; i < self.info->trackerCount; i++)
    {
        if (![trackers containsObject: [NSString stringWithUTF8String: self.info->trackers[i].announce]])
            trackerStructs[newCount++] = self.info->trackers[i];
    }
    
    const BOOL success = tr_torrentSetAnnounceList(self.handle, trackerStructs, newCount);
    NSAssert(success, @"Removing tracker addresses failed");
    
    tr_free(trackerStructs);
}

- (NSString *) comment
{
    return self.info->comment ? [NSString stringWithUTF8String: self.info->comment] : @"";
}

- (NSString *) creator
{
    return self.info->creator ? [NSString stringWithUTF8String: self.info->creator] : @"";
}

- (NSDate *) dateCreated
{
    NSInteger date = self.info->dateCreated;
    return date > 0 ? [NSDate dateWithTimeIntervalSince1970: date] : nil;
}

- (NSInteger) pieceSize
{
    return self.info->pieceSize;
}

- (NSInteger) pieceCount
{
    return self.info->pieceCount;
}

- (BOOL) privateTorrent
{
    return self.info->isPrivate;
}

- (NSString *) torrentLocation
{
    return self.info->torrent ? [NSString stringWithUTF8String: self.info->torrent] : @"";
}

- (NSString *) dataLocation
{
    if ([self isMagnet])
        return nil;
    
    if ([self isFolder])
    {
        NSString * dataLocation = [[self currentDirectory] stringByAppendingPathComponent: [self name]];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: dataLocation])
            return nil;
        
        return dataLocation;
    }
    else
    {
        char * location = tr_torrentFindFile(self.handle, 0);
        if (location == NULL)
            return nil;
        
        NSString * dataLocation = [NSString stringWithUTF8String: location];
        free(location);
        
        return dataLocation;
    }
}

- (NSString *) fileLocation: (ITFileListNode *) node
{
    if ([node isFolder])
    {
        NSString * basePath = [[node path] stringByAppendingPathComponent: [node name]];
        NSString * dataLocation = [[self currentDirectory] stringByAppendingPathComponent: basePath];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath: dataLocation])
            return nil;
        
        return dataLocation;
    }
    else
    {
        char * location = tr_torrentFindFile(self.handle, [[node indexes] firstIndex]);
        if (location == NULL)
            return nil;
        
        NSString * dataLocation = [NSString stringWithUTF8String: location];
        free(location);
        
        return dataLocation;
    }
}

- (CGFloat) progress
{
    return self.stat->percentComplete;
}

- (CGFloat) progressDone
{
    return self.stat->percentDone;
}

- (CGFloat) progressLeft
{
    if ([self size] == 0) //magnet links
        return 0.0;
    
    return (CGFloat)[self sizeLeft] / [self size];
}

- (CGFloat) checkingProgress
{
    return self.stat->recheckProgress;
}

- (CGFloat) availableDesired
{
    return (CGFloat)self.stat->desiredAvailable / [self sizeLeft];
}

- (BOOL) isActive
{
    return self.stat->activity != TR_STATUS_STOPPED && self.stat->activity != TR_STATUS_DOWNLOAD_WAIT && self.stat->activity != TR_STATUS_SEED_WAIT;
}

- (BOOL) isSeeding
{
    return self.stat->activity == TR_STATUS_SEED;
}

- (BOOL) isChecking
{
    return self.stat->activity == TR_STATUS_CHECK || self.stat->activity == TR_STATUS_CHECK_WAIT;
}

- (BOOL) isCheckingWaiting
{
    return self.stat->activity == TR_STATUS_CHECK_WAIT;
}

- (BOOL) allDownloaded
{
    return [self sizeLeft] == 0 && ![self isMagnet];
}

- (BOOL) isComplete
{
    return [self progress] >= 1.0;
}

- (BOOL) isFinishedSeeding
{
    return self.stat->finished;
}

- (BOOL) isError
{
    return self.stat->error == TR_STAT_LOCAL_ERROR;
}

- (BOOL) isAnyErrorOrWarning
{
    return self.stat->error != TR_STAT_OK;
}

- (NSString *) errorMessage
{
    if (![self isAnyErrorOrWarning])
        return @"";
    
    NSString * error;
    if (!(error = [NSString stringWithUTF8String: self.stat->errorString])
        && !(error = [NSString stringWithCString: self.stat->errorString encoding: NSISOLatin1StringEncoding]))
        error = [NSString stringWithFormat: @"(%@)", NSLocalizedString(@"unreadable error", "Torrent -> error string unreadable")];
    
    //libtransmission uses "Set Location", Mac client uses "Move data file to..." - very hacky!
    error = [error stringByReplacingOccurrencesOfString: @"Set Location" withString: [@"Move Data File To" stringByAppendingEllipsis]];
    
    return error;
}

- (NSArray *) peers
{
    int totalPeers;
    tr_peer_stat * peers = tr_torrentPeers(self.handle, &totalPeers);
    
    NSMutableArray * peerDicts = [NSMutableArray arrayWithCapacity: totalPeers];
    
    for (int i = 0; i < totalPeers; i++)
    {
        tr_peer_stat * peer = &peers[i];
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity: 12];
        
        [dict setObject: [self name] forKey: @"Name"];
        [dict setObject: [NSNumber numberWithInt: peer->from] forKey: @"From"];
        [dict setObject: [NSString stringWithUTF8String: peer->addr] forKey: @"IP"];
        [dict setObject: [NSNumber numberWithInt: peer->port] forKey: @"Port"];
        [dict setObject: [NSNumber numberWithFloat: peer->progress] forKey: @"Progress"];
        [dict setObject: [NSNumber numberWithBool: peer->isSeed] forKey: @"Seed"];
        [dict setObject: [NSNumber numberWithBool: peer->isEncrypted] forKey: @"Encryption"];
        [dict setObject: [NSNumber numberWithBool: peer->isUTP] forKey: @"uTP"];
        [dict setObject: [NSString stringWithUTF8String: peer->client] forKey: @"Client"];
        [dict setObject: [NSString stringWithUTF8String: peer->flagStr] forKey: @"Flags"];
        
        if (peer->isUploadingTo)
            [dict setObject: [NSNumber numberWithDouble: peer->rateToPeer_KBps] forKey: @"UL To Rate"];
        if (peer->isDownloadingFrom)
            [dict setObject: [NSNumber numberWithDouble: peer->rateToClient_KBps] forKey: @"DL From Rate"];
        
        [peerDicts addObject: dict];
    }
    
    tr_torrentPeersFree(peers, totalPeers);
    
    return peerDicts;
}

- (NSUInteger) webSeedCount
{
    return self.info->webseedCount;
}

- (NSArray *) webSeeds
{
    NSMutableArray * webSeeds = [NSMutableArray arrayWithCapacity: self.info->webseedCount];
    
    double * dlSpeeds = tr_torrentWebSpeeds_KBps(self.handle);
    
    for (NSInteger i = 0; i < self.info->webseedCount; i++)
    {
        NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity: 3];
        
        [dict setObject: [self name] forKey: @"Name"];
        [dict setObject: [NSString stringWithUTF8String: self.info->webseeds[i]] forKey: @"Address"];
        
        if (dlSpeeds[i] != -1.0)
            [dict setObject: [NSNumber numberWithDouble: dlSpeeds[i]] forKey: @"DL From Rate"];
        
        [webSeeds addObject: dict];
    }
    
    tr_free(dlSpeeds);
    
    return webSeeds;
}

- (NSString *) progressString
{
    if ([self isMagnet])
    {
        NSString * progressString = self.stat->metadataPercentComplete > 0.0
        ? [NSString stringWithFormat: NSLocalizedString(@"%@ of torrent metadata retrieved",
                                                        "Torrent -> progress string"), [NSString percentString: self.stat->metadataPercentComplete longDecimals: YES]]
        : NSLocalizedString(@"torrent metadata needed", "Torrent -> progress string");
        
        return [NSString stringWithFormat: @"%@ - %@", NSLocalizedString(@"Magnetized transfer", "Torrent -> progress string"),
                progressString];
    }
    
    NSString * string;
    
    if (![self allDownloaded])
    {
        CGFloat progress;
        if ([self isFolder] && [self.userDefaults boolForKey: @"DisplayStatusProgressSelected"])
        {
            string = [NSString stringForFilePartialSize: [self haveTotal] fullSize: [self totalSizeSelected]];
            progress = [self progressDone];
        }
        else
        {
            string = [NSString stringForFilePartialSize: [self haveTotal] fullSize: [self size]];
            progress = [self progress];
        }
        
        string = [string stringByAppendingFormat: @" (%@)", [NSString percentString: progress longDecimals: YES]];
    }
    else
    {
        NSString * downloadString;
        if (![self isComplete]) //only multifile possible
        {
            if ([self.userDefaults boolForKey: @"DisplayStatusProgressSelected"])
                downloadString = [NSString stringWithFormat: NSLocalizedString(@"%@ selected", "Torrent -> progress string"),
                                  [NSString stringForFileSize: [self haveTotal]]];
            else
            {
                downloadString = [NSString stringForFilePartialSize: [self haveTotal] fullSize: [self size]];
                downloadString = [downloadString stringByAppendingFormat: @" (%@)",
                                  [NSString percentString: [self progress] longDecimals: YES]];
            }
        }
        else
            downloadString = [NSString stringForFileSize: [self size]];
        
        NSString * uploadString = [NSString stringWithFormat: NSLocalizedString(@"uploaded %@ (Ratio: %@)",
                                                                                "Torrent -> progress string"), [NSString stringForFileSize: [self uploadedTotal]],
                                   [NSString stringForRatio: [self ratio]]];
        
        string = [downloadString stringByAppendingFormat: @", %@", uploadString];
    }
    
    //add time when downloading or seed limit set
    if ([self shouldShowEta])
        string = [string stringByAppendingFormat: @" - %@", [self etaString]];
    
    return string;
}

- (NSString *) statusString
{
    NSString * string;
    
    if ([self isAnyErrorOrWarning])
    {
//        switch (self.stat->error)
//        {
//            case TR_STAT_LOCAL_ERROR: string = NSLocalizedString(@"Error", "Torrent -> status string"); break;
//            case TR_STAT_TRACKER_ERROR: string = NSLocalizedString(@"Tracker returned error", "Torrent -> status string"); break;
//            case TR_STAT_TRACKER_WARNING: string = NSLocalizedString(@"Tracker returned warning", "Torrent -> status string"); break;
//            default: NSAssert(NO, @"unknown error state");
//        }
        
        string = [NSString string];
        
        NSString * errorString = [self errorMessage];
        if (errorString && ![errorString isEqualToString: @""])
            string = [string stringByAppendingFormat: @": %@", errorString];
    }
    else
    {
        switch (self.stat->activity)
        {
            case TR_STATUS_STOPPED:
                if ([self isFinishedSeeding])
                    string = NSLocalizedString(@"Seeding complete", "Torrent -> status string");
                else
                    string = NSLocalizedString(@"Paused", "Torrent -> status string");
                break;
                
            case TR_STATUS_DOWNLOAD_WAIT:
                string = [NSLocalizedString(@"Waiting to download", "Torrent -> status string") stringByAppendingEllipsis];
                break;
                
            case TR_STATUS_SEED_WAIT:
                string = [NSLocalizedString(@"Waiting to seed", "Torrent -> status string") stringByAppendingEllipsis];
                break;
                
            case TR_STATUS_CHECK_WAIT:
                string = [NSLocalizedString(@"Waiting to check existing data", "Torrent -> status string") stringByAppendingEllipsis];
                break;
                
            case TR_STATUS_CHECK:
                string = [NSString stringWithFormat: @"%@ (%@)",
                          NSLocalizedString(@"Checking existing data", "Torrent -> status string"),
                          [NSString percentString: [self checkingProgress] longDecimals: YES]];
                break;
                
            case TR_STATUS_DOWNLOAD:
                if ([self totalPeersConnected] != 1)
                    string = [NSString stringWithFormat: NSLocalizedString(@"Downloading from %d of %d peers",
                                                                           "Torrent -> status string"), [self peersSendingToUs], [self totalPeersConnected]];
                else
                    string = [NSString stringWithFormat: NSLocalizedString(@"Downloading from %d of 1 peer",
                                                                           "Torrent -> status string"), [self peersSendingToUs]];
                
                const NSInteger webSeedCount = self.stat->webseedsSendingToUs;
                if (webSeedCount > 0)
                {
                    NSString * webSeedString;
                    if (webSeedCount == 1)
                        webSeedString = NSLocalizedString(@"web seed", "Torrent -> status string");
                    else
                        webSeedString = [NSString stringWithFormat: NSLocalizedString(@"%d web seeds", "Torrent -> status string"),
                                         webSeedCount];
                    
                    string = [string stringByAppendingFormat: @" + %@", webSeedString];
                }
                
                break;
                
            case TR_STATUS_SEED:
                if ([self totalPeersConnected] != 1)
                    string = [NSString stringWithFormat: NSLocalizedString(@"Seeding to %d of %d peers", "Torrent -> status string"),
                              [self peersGettingFromUs], [self totalPeersConnected]];
                else
                    string = [NSString stringWithFormat: NSLocalizedString(@"Seeding to %d of 1 peer", "Torrent -> status string"),
                              [self peersGettingFromUs]];
        }
        
        if ([self isStalled])
            string = [NSLocalizedString(@"Stalled", "Torrent -> status string") stringByAppendingFormat: @", %@", string];
    }
    
    //append even if error
    if ([self isActive] && ![self isChecking])
    {
        if (self.stat->activity == TR_STATUS_DOWNLOAD)
            string = [string stringByAppendingFormat: @" - %@: %@, %@: %@",
                      NSLocalizedString(@"DL", "Torrent -> status string"), [NSString stringForSpeed: [self downloadRate]],
                      NSLocalizedString(@"UL", "Torrent -> status string"), [NSString stringForSpeed: [self uploadRate]]];
        else
            string = [string stringByAppendingFormat: @" - %@: %@",
                      NSLocalizedString(@"UL", "Torrent -> status string"), [NSString stringForSpeed: [self uploadRate]]];
    }
    
    return string;
}

- (NSString *) shortStatusString
{
    NSString * string;
    
    switch (self.stat->activity)
    {
        case TR_STATUS_STOPPED:
            if ([self isFinishedSeeding])
                string = NSLocalizedString(@"Seeding complete", "Torrent -> status string");
            else
                string = NSLocalizedString(@"Paused", "Torrent -> status string");
            break;
            
        case TR_STATUS_DOWNLOAD_WAIT:
            string = [NSLocalizedString(@"Waiting to download", "Torrent -> status string") stringByAppendingEllipsis];
            break;
            
        case TR_STATUS_SEED_WAIT:
            string = [NSLocalizedString(@"Waiting to seed", "Torrent -> status string") stringByAppendingEllipsis];
            break;
            
        case TR_STATUS_CHECK_WAIT:
            string = [NSLocalizedString(@"Waiting to check existing data", "Torrent -> status string") stringByAppendingEllipsis];
            break;
            
        case TR_STATUS_CHECK:
            string = [NSString stringWithFormat: @"%@ (%@)",
                      NSLocalizedString(@"Checking existing data", "Torrent -> status string"),
                      [NSString percentString: [self checkingProgress] longDecimals: YES]];
            break;
            
        case TR_STATUS_DOWNLOAD:
            string = [NSString stringWithFormat: @"%@: %@, %@: %@",
                      NSLocalizedString(@"DL", "Torrent -> status string"), [NSString stringForSpeed: [self downloadRate]],
                      NSLocalizedString(@"UL", "Torrent -> status string"), [NSString stringForSpeed: [self uploadRate]]];
            break;
            
        case TR_STATUS_SEED:
            string = [NSString stringWithFormat: @"%@: %@, %@: %@",
                      NSLocalizedString(@"Ratio", "Torrent -> status string"), [NSString stringForRatio: [self ratio]],
                      NSLocalizedString(@"UL", "Torrent -> status string"), [NSString stringForSpeed: [self uploadRate]]];
    }
    
    return string;
}

- (NSString *) remainingTimeString
{
    if ([self shouldShowEta])
        return [self etaString];
    else
        return [self shortStatusString];
}

- (NSString *) stateString
{
    switch (self.stat->activity)
    {
        case TR_STATUS_STOPPED:
        case TR_STATUS_DOWNLOAD_WAIT:
        case TR_STATUS_SEED_WAIT:
        {
            NSString * string = NSLocalizedString(@"Paused", "Torrent -> status string");
            
            NSString * extra = nil;
            if ([self waitingToStart])
            {
                extra = self.stat->activity == TR_STATUS_DOWNLOAD_WAIT 
                ? NSLocalizedString(@"Waiting to download", "Torrent -> status string")
                : NSLocalizedString(@"Waiting to seed", "Torrent -> status string");
            }
            else if ([self isFinishedSeeding])
                extra = NSLocalizedString(@"Seeding complete", "Torrent -> status string");
            else;
            
            return extra ? [string stringByAppendingFormat: @" (%@)", extra] : string;
        }
            
        case TR_STATUS_CHECK_WAIT:
            return [NSLocalizedString(@"Waiting to check existing data", "Torrent -> status string") stringByAppendingEllipsis];
            
        case TR_STATUS_CHECK:
            return [NSString stringWithFormat: @"%@ (%@)",
                    NSLocalizedString(@"Checking existing data", "Torrent -> status string"),
                    [NSString percentString: [self checkingProgress] longDecimals: YES]];
            
        case TR_STATUS_DOWNLOAD:
            return NSLocalizedString(@"Downloading", "Torrent -> status string");
            
        case TR_STATUS_SEED:
            return NSLocalizedString(@"Seeding", "Torrent -> status string");
    }
}

- (NSInteger) totalPeersConnected
{
    return self.stat->peersConnected;
}

- (NSInteger) totalPeersTracker
{
    return self.stat->peersFrom[TR_PEER_FROM_TRACKER];
}

- (NSInteger) totalPeersIncoming
{
    return self.stat->peersFrom[TR_PEER_FROM_INCOMING];
}

- (NSInteger) totalPeersCache
{
    return self.stat->peersFrom[TR_PEER_FROM_RESUME];
}

- (NSInteger) totalPeersPex
{
    return self.stat->peersFrom[TR_PEER_FROM_PEX];
}

- (NSInteger) totalPeersDHT
{
    return self.stat->peersFrom[TR_PEER_FROM_DHT];
}

- (NSInteger) totalPeersLocal
{
    return self.stat->peersFrom[TR_PEER_FROM_LPD];
}

- (NSInteger) totalPeersLTEP
{
    return self.stat->peersFrom[TR_PEER_FROM_LTEP];
}

- (NSInteger) peersSendingToUs
{
    return self.stat->peersSendingToUs;
}

- (NSInteger) peersGettingFromUs
{
    return self.stat->peersGettingFromUs;
}

- (CGFloat) downloadRate
{
    return self.stat->pieceDownloadSpeed_KBps;
}

- (CGFloat) uploadRate
{
    return self.stat->pieceUploadSpeed_KBps;
}

- (CGFloat) totalRate
{
    return [self downloadRate] + [self uploadRate];
}

- (uint64_t) haveVerified
{
    return self.stat->haveValid;
}

- (uint64_t) haveTotal
{
    return [self haveVerified] + self.stat->haveUnchecked;
}

- (uint64_t) totalSizeSelected
{
    return self.stat->sizeWhenDone;
}

- (uint64_t) downloadedTotal
{
    return self.stat->downloadedEver;
}

- (uint64_t) uploadedTotal
{
    return self.stat->uploadedEver;
}

- (uint64_t) failedHash
{
    return self.stat->corruptEver;
}

- (void) setGroupValue: (NSInteger) goupValue
{
    self.groupValue = goupValue;
}

/*
- (NSInteger) groupOrderValue
{
    return [[GroupsController groups] rowValueForIndex: self.groupValue];
}
*/

- (void) checkGroupValueForRemoval: (NSNotification *) notification
{
    if (self.groupValue != -1 && [[[notification userInfo] objectForKey: @"Index"] integerValue] == self.groupValue)
        self.groupValue = -1;
}

- (NSInteger) fileCount
{
    return self.info->fileCount;
}

- (void) updateFileStat
{
    if (self.fileStat)
        tr_torrentFilesFree(self.fileStat, [self fileCount]);
    
    self.fileStat = tr_torrentFiles(self.handle, NULL);
}

- (CGFloat) fileProgress: (ITFileListNode *) node
{
    if ([self fileCount] == 1 || [self isComplete])
        return [self progress];
    
    if (!self.fileStat)
        [self updateFileStat];
    
    NSIndexSet * indexSet = [node indexes];
    
    if ([indexSet count] == 1)
        return self.fileStat[[indexSet firstIndex]].progress;
    
    uint64_t have = 0;
    for (NSInteger index = [indexSet firstIndex]; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index])
        have += self.fileStat[index].bytesCompleted;
    
    NSAssert([node size], @"directory in torrent file has size 0");
    return (CGFloat)have / [node size];
}

- (BOOL) canChangeDownloadCheckForFile: (NSUInteger) index
{
    NSAssert2(index < [self fileCount], @"Index %d is greater than file count %d", index, [self fileCount]);
    
    if ([self fileCount] == 1 || [self isComplete])
        return NO;
    
    if (!self.fileStat)
        [self updateFileStat];
    
    return self.fileStat[index].progress < 1.0;
}

- (BOOL) canChangeDownloadCheckForFiles: (NSIndexSet *) indexSet
{
    if ([self fileCount] == 1 || [self isComplete])
        return NO;
    
    if (!self.fileStat)
        [self updateFileStat];
    
    for (NSUInteger index = [indexSet firstIndex]; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index])
        if (self.fileStat[index].progress < 1.0)
            return YES;
    return NO;
}

- (NSInteger) checkForFiles: (NSIndexSet *) indexSet
{
    BOOL onState = NO, offState = NO;
    for (NSUInteger index = [indexSet firstIndex]; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index])
    {
        if (!self.info->files[index].dnd || ![self canChangeDownloadCheckForFile: index])
            onState = YES;
        else
            offState = YES;
        
        if (onState && offState)
            return NSMixedState;
    }
    return onState ? NSOnState : NSOffState;
}

- (void) setFileCheckState: (NSInteger) state forIndexes: (NSIndexSet *) indexSet
{
    NSUInteger count = [indexSet count];
    tr_file_index_t * files = malloc(count * sizeof(tr_file_index_t));
    for (NSUInteger index = [indexSet firstIndex], i = 0; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index], i++)
        files[i] = index;
    
    tr_torrentSetFileDLs(self.handle, files, count, state != NSOffState);
    free(files);
    
    [self update];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TorrentFileCheckChange" object: self];
}

- (void) setFilePriority: (tr_priority_t) priority forIndexes: (NSIndexSet *) indexSet
{
    const NSUInteger count = [indexSet count];
    tr_file_index_t * files = tr_malloc(count * sizeof(tr_file_index_t));
    for (NSUInteger index = [indexSet firstIndex], i = 0; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index], i++)
        files[i] = index;
    
    tr_torrentSetFilePriorities(self.handle, files, count, priority);
    tr_free(files);
}

- (BOOL) hasFilePriority: (tr_priority_t) priority forIndexes: (NSIndexSet *) indexSet
{
    for (NSUInteger index = [indexSet firstIndex]; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index])
        if (priority == self.info->files[index].priority && [self canChangeDownloadCheckForFile: index])
            return YES;
    return NO;
}

- (NSSet *) filePrioritiesForIndexes: (NSIndexSet *) indexSet
{
    BOOL low = NO, normal = NO, high = NO;
    NSMutableSet * priorities = [NSMutableSet setWithCapacity: MIN([indexSet count], 3)];
    
    for (NSUInteger index = [indexSet firstIndex]; index != NSNotFound; index = [indexSet indexGreaterThanIndex: index])
    {
        if (![self canChangeDownloadCheckForFile: index])
            continue;
        
        const tr_priority_t priority = self.info->files[index].priority;
        switch (priority)
        {
            case TR_PRI_LOW:
                if (low)
                    continue;
                low = YES;
                break;
            case TR_PRI_NORMAL:
                if (normal)
                    continue;
                normal = YES;
                break;
            case TR_PRI_HIGH:
                if (high)
                    continue;
                high = YES;
                break;
            default:
                NSAssert2(NO, @"Unknown priority %d for file index %d", priority, index);
        }
        
        [priorities addObject: [NSNumber numberWithInteger: priority]];
        if (low && normal && high)
            break;
    }
    return priorities;
}

- (NSDate *) dateAdded
{
    const time_t date = self.stat->addedDate;
    return [NSDate dateWithTimeIntervalSince1970: date];
}

- (NSDate *) dateCompleted
{
    const time_t date = self.stat->doneDate;
    return date != 0 ? [NSDate dateWithTimeIntervalSince1970: date] : nil;
}

- (NSDate *) dateActivity
{
    const time_t date = self.stat->activityDate;
    return date != 0 ? [NSDate dateWithTimeIntervalSince1970: date] : nil;
}

- (NSDate *) dateActivityOrAdd
{
    NSDate * date = [self dateActivity];
    return date ? date : [self dateAdded];
}

- (NSInteger) secondsDownloading
{
    return self.stat->secondsDownloading;
}

- (NSInteger) secondsSeeding
{
    return self.stat->secondsSeeding;
}

- (NSInteger) stalledMinutes
{
    if (self.stat->idleSecs == -1)
        return -1;
    
    return self.stat->idleSecs / 60;
}

- (BOOL) isStalled
{
    return self.stat->isStalled;
}

- (NSInteger) stateSortKey
{
    if (![self isActive]) //paused
    {
        if ([self waitingToStart])
            return 1;
        else
            return 0;
    }
    else if ([self isSeeding]) //seeding
        return 10;
    else //downloading
        return 20;
}

- (NSString *) trackerSortKey
{
    int count;
    tr_tracker_stat * stats = tr_torrentTrackers(self.handle, &count);
    
    NSString * best = nil;
    
    for (int i=0; i < count; ++i)
    {
        NSString * tracker = [NSString stringWithUTF8String: stats[i].host];
        if (!best || [tracker localizedCaseInsensitiveCompare: best] == NSOrderedAscending)
            best = tracker;
    }
    
    tr_torrentTrackersFree(stats, count);
    return best;
}

- (tr_torrent *) torrentStruct
{
    return self.handle;
}

- (NSURL *) previewItemURL
{
    NSString * location = [self dataLocation];
    return location ? [NSURL fileURLWithPath: location] : nil;
}

- (void)startIfAllowed
{
    if ([[ITNetworkSwitcher sharedNetworkSwitcher] canStartTransfer])
        [self startTransfer];
}

@end

@implementation ITTorrent (Private)

- (id) initWithPath: (NSString *) path hash: (NSString *) hashString torrentStruct: (tr_torrent *) torrentStruct
      magnetAddress: (NSString *) magnetAddress lib: (tr_session *) lib
         groupValue: (NSNumber *) groupValue
     downloadFolder: (NSString *) downloadFolder
legacyIncompleteFolder: (NSString *) incompleteFolder
{
    if (!(self = [super init]))
        return nil;
    
    self.userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (torrentStruct)
        self.handle = torrentStruct;
    else
    {
        //set libtransmission settings for initialization
        tr_ctor * ctor = tr_ctorNew(lib);
        
        tr_ctorSetPaused(ctor, TR_FORCE, YES);
        if (downloadFolder)
            tr_ctorSetDownloadDir(ctor, TR_FORCE, [downloadFolder UTF8String]);
        if (incompleteFolder)
            tr_ctorSetIncompleteDir(ctor, [incompleteFolder UTF8String]);
        
        tr_parse_result result = TR_PARSE_ERR;
        if (path)
            result = tr_ctorSetMetainfoFromFile(ctor, [path UTF8String]);
        
        if (result != TR_PARSE_OK && magnetAddress)
            result = tr_ctorSetMetainfoFromMagnetLink(ctor, [magnetAddress UTF8String]);
        
        //backup - shouldn't be needed after upgrade to 1.70
        if (result != TR_PARSE_OK && hashString)
            result = tr_ctorSetMetainfoFromHash(ctor, [hashString UTF8String]);
        
        if (result == TR_PARSE_OK)
            self.handle = tr_torrentNew(ctor, NULL);
        
        tr_ctorFree(ctor);
        
        if (!self.handle)
        {
            return nil;
        }
    }
    
    self.info = (tr_info*)tr_torrentInfo(self.handle);
    
    tr_torrentSetQueueStartCallback(self.handle, startQueueCallback, (__bridge void*)self);
    tr_torrentSetCompletenessCallback(self.handle, completenessChangeCallback, (__bridge void*)self);
    tr_torrentSetRatioLimitHitCallback(self.handle, ratioLimitHitCallback, (__bridge void*)self);
    tr_torrentSetIdleLimitHitCallback(self.handle, idleLimitHitCallback, (__bridge void*)self);
    tr_torrentSetMetadataCallback(self.handle, metadataCallback, (__bridge void*)self);
    
    self.hashString = [[NSString alloc] initWithUTF8String: self.info->hashString];
    
    self.resumeOnWake = NO;
    
    //don't do after this point - it messes with auto-group functionality
    if (![self isMagnet])
        [self createFileList];
	
//    self.groupValue = groupValue ? [groupValue intValue] : [[GroupsController groups] groupIndexForTorrent: self]; 
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(checkGroupValueForRemoval:)
                                                 name: @"GroupValueRemoved" object: nil];
    
    self.lastUpdateDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    [self update];
    
    return self;
}

- (void) createFileList
{
    NSAssert(![self isMagnet], @"Cannot create a file list until the torrent is demagnetized");
    
    if ([self isFolder])
    {
        const NSInteger count = [self fileCount];
        NSMutableArray * fileList = [NSMutableArray arrayWithCapacity: count],
        * flatFileList = [NSMutableArray arrayWithCapacity: count];
        
        for (NSInteger i = 0; i < count; i++)
        {
            tr_file * file = &self.info->files[i];
            
            NSString * fullPath = [NSString stringWithUTF8String: file->name];
            NSArray * pathComponents = [fullPath pathComponents];
            NSAssert1([pathComponents count] >= 2, @"Not enough components in path %@", fullPath);
            
            NSString * path = [pathComponents objectAtIndex: 0];
            NSString * name = [pathComponents objectAtIndex: 1];
            
            if ([pathComponents count] > 2)
            {
                //determine if folder node already exists
                ITFileListNode * node;
                for (node in fileList)
                    if ([[node name] isEqualToString: name] && [node isFolder])
                        break;
                
                if (!node)
                {
                    node = [[ITFileListNode alloc] initWithFolderName: name path: path torrent: self];
                    [fileList addObject: node];
                }
                
                NSMutableArray * trimmedComponents = [NSMutableArray arrayWithArray: [pathComponents subarrayWithRange:
                                                                                      NSMakeRange(2, [pathComponents count]-2)]];
                
                [node insertIndex: i withSize: file->length];
                [self insertPath: trimmedComponents forParent: node fileSize: file->length index: i flatList: flatFileList];
            }
            else
            {
                ITFileListNode * node = [[ITFileListNode alloc] initWithFileName: name path: path size: file->length index: i torrent: self];
                [fileList addObject: node];
                [flatFileList addObject: node];
            }
        }
        
        [self sortFileList: fileList];
        [self sortFileList: flatFileList];
        
        self.fileList = [[NSArray alloc] initWithArray: fileList];
        self.flatFileList = [[NSArray alloc] initWithArray: flatFileList];
    }
    else
    {
        ITFileListNode * node = [[ITFileListNode alloc] initWithFileName: [self name] path: @"" size: [self size] index: 0 torrent: self];
        self.fileList = [NSArray arrayWithObject: node];
        self.flatFileList = self.fileList;
    }
}

- (void) insertPath: (NSMutableArray *) components forParent: (ITFileListNode *) parent fileSize: (uint64_t) size
              index: (NSInteger) index flatList: (NSMutableArray *) flatFileList
{
    NSString * name = [components objectAtIndex: 0];
    const BOOL isFolder = [components count] > 1;
    
    ITFileListNode * node = nil;
    if (isFolder)
    {
        for (node in [parent children])
            if ([[node name] isEqualToString: name] && [node isFolder])
                break;
    }
    
    //create new folder or file if it doesn't already exist
    if (!node)
    {
        NSString * path = [[parent path] stringByAppendingPathComponent: [parent name]];
        if (isFolder)
            node = [[ITFileListNode alloc] initWithFolderName: name path: path torrent: self];
        else
        {
            node = [[ITFileListNode alloc] initWithFileName: name path: path size: size index: index torrent: self];
            [flatFileList addObject: node];
        }
        
        [parent insertChild: node];
    }
    
    if (isFolder)
    {
        [node insertIndex: index withSize: size];
        
        [components removeObjectAtIndex: 0];
        [self insertPath: components forParent: node fileSize: size index: index flatList: flatFileList];
    }
}

- (void) sortFileList: (NSMutableArray *) fileNodes
{
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES
                                                                  selector: @selector(compareFinder:)];
    [fileNodes sortUsingDescriptors: [NSArray arrayWithObject: descriptor]];
    
    for (ITFileListNode * node in fileNodes)
        if ([node isFolder])
            [self sortFileList: [node children]];
}

- (void) startQueue
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateQueue" object: self];
}

//status has been retained
- (void) completenessChange: (NSDictionary *) statusInfo
{
    self.stat = (tr_stat*)tr_torrentStat(self.handle); //don't call update yet to avoid auto-stop
    
    switch ([[statusInfo objectForKey: @"Status"] intValue])
    {
        case TR_SEED:
        case TR_PARTIAL_SEED:
            //simpler to create a new dictionary than to use statusInfo - avoids retention chicanery
            [[NSNotificationCenter defaultCenter] postNotificationName: @"TorrentFinishedDownloading" object: self
                                                              userInfo: [NSDictionary dictionaryWithObject: [statusInfo objectForKey: @"WasRunning"] forKey: @"WasRunning"]];
            break;
            
        case TR_LEECH:
            [[NSNotificationCenter defaultCenter] postNotificationName: @"TorrentRestartedDownloading" object: self];
            break;
    }    
    [self update];
}

- (void) ratioLimitHit
{
    self.stat = (tr_stat*)tr_torrentStat(self.handle);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TorrentFinishedSeeding" object: self];
}

- (void) idleLimitHit
{
    self.stat = (tr_stat*)tr_torrentStat(self.handle);
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"TorrentFinishedSeeding" object: self];
}

- (void) metadataRetrieved
{
    self.stat = (tr_stat*)tr_torrentStat(self.handle);
    
    [self createFileList];
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"ResetInspector" object: self];
}

- (BOOL) shouldShowEta
{
    if (self.stat->activity == TR_STATUS_DOWNLOAD)
        return YES;
    else if ([self isSeeding])
    {
        //ratio: show if it's set at all
        if (tr_torrentGetSeedRatio(self.handle, NULL))
            return YES;
        
        //idle: show only if remaining time is less than cap
        if (self.stat->etaIdle != TR_ETA_NOT_AVAIL && self.stat->etaIdle < ETA_IDLE_DISPLAY_SEC)
            return YES;
    }
    
    return NO;
}

- (NSString *) etaString
{
    NSInteger eta;
    BOOL fromIdle;
    //don't check for both, since if there's a regular ETA, the torrent isn't idle so it's meaningless
    if (self.stat->eta != TR_ETA_NOT_AVAIL && self.stat->eta != TR_ETA_UNKNOWN)
    {
        eta = self.stat->eta;
        fromIdle = NO;
    }
    else if (self.stat->etaIdle != TR_ETA_NOT_AVAIL && self.stat->etaIdle < ETA_IDLE_DISPLAY_SEC)
    {
        eta = self.stat->etaIdle;
        fromIdle = YES;
    }
    else
        return NSLocalizedString(@"remaining time unknown", "Torrent -> eta string");
    
    NSString * idleString = [NSString stringWithFormat: NSLocalizedString(@"%@ remaining", "Torrent -> eta string"),
                             [NSString timeString: eta showSeconds: YES maxFields: 2]];
    if (fromIdle)
        idleString = [idleString stringByAppendingFormat: @" (%@)", NSLocalizedString(@"inactive", "Torrent -> eta string")];
    
    return idleString;
}

@end
