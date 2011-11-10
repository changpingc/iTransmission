//
//  ITController.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITController.h"
#import "ITPrefsController.h"
#import <libtransmission/bencode.h>
#import <libtransmission/utils.h>
#import "ITPrefsController.h"
#import "ITTorrent.h"
#import "ITTorrentGroup.h"
#import "ITStatistics.h"
#import "ITApplication.h"
#import "ITAppDelegate.h"
#import "ITLogger.h"

static void altSpeedToggledCallback(tr_session * handle UNUSED, bool active, bool byUser, void * controller)
{
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys: [[NSNumber alloc] initWithBool: active], @"Active",
                           [[NSNumber alloc] initWithBool: byUser], @"ByUser", nil];
    [(__bridge ITController *)controller performSelectorOnMainThread: @selector(altSpeedToggledCallbackIsLimited:)
                                                 withObject: dict waitUntilDone: NO];
}

static tr_rpc_callback_status rpcCallback(tr_session * handle UNUSED, tr_rpc_callback_type type, struct tr_torrent * torrentStruct,
                                          void * controller)
{
    [(__bridge ITController *)controller rpcCallback: type forTorrentStruct: torrentStruct];
    return TR_RPC_NOREMOVE; //we'll do the remove manually
}

// Can we do the same on ios? e.g. callback on lock? */
/*
static void sleepCallback(void * controller, io_service_t y, natural_t messageType, void * messageArgument)
{
    [(__bridge ITController *)controller sleepCallback: messageType argument: messageArgument];
}
 */

@implementation ITController

@synthesize prefsController = _prefsController;
@synthesize torrents = _torrents;
@synthesize handle = _handle;
@synthesize pauseOnLaunch = _pauseOnLaunch;
@synthesize unconfirmedTorrents = _unconfirmedTorrents;
@synthesize loggingEnabled = _loggingEnabled;

+ (id)sharedController
{
    return [(ITAppDelegate*)[[UIApplication sharedApplication] delegate] controller];
}

- (NSString*)transfersPlistPath
{
    return [[ITApplication defaultDocumentsPath] stringByAppendingPathComponent:@"transfers.plist"];
}

- (NSString*)configPath
{
    return [[ITApplication defaultDocumentsPath] stringByAppendingPathComponent:@"config"];

}
- (NSString*)downloadPath
{
    return [[ITApplication defaultDocumentsPath] stringByAppendingPathComponent:@"download"];
}

- (NSString*)incompletePath
{
    return [[ITApplication defaultDocumentsPath] stringByAppendingPathComponent:@"incomplete"];
}

- (void)createPathsIfNeeded
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    LogMessageCompat(@"Using document directory: %@\n", [ITApplication defaultDocumentsPath]);
    [fileManager createDirectoryAtPath:[ITApplication defaultDocumentsPath] withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:[self configPath] withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:[self downloadPath] withIntermediateDirectories:YES attributes:nil error:nil];
    [fileManager createDirectoryAtPath:[self incompletePath] withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)logUsedPaths
{
    LogMessageCompat(@"Documents: %@\n", [ITApplication defaultDocumentsPath]);
    LogMessageCompat(@"Download: %@\n", [self downloadPath]);
    LogMessageCompat(@"Incomplete: %@\n", [self incompletePath]);
    LogMessageCompat(@"Config: %@\n", [self configPath]);
    LogMessageCompat(@"Transfer.plist: %@\n", [self transfersPlistPath]);
}

- (id)init
{
    if (self = [super init]) {
        [self setLoggingEnabled:YES];
        [[ITAppDelegate sharedDelegate] registerForTimerEvent:self];
        
        [self createPathsIfNeeded];
        [self logUsedPaths];
        
        NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults registerDefaults: [NSDictionary dictionaryWithContentsOfFile:
                                                                  [[NSBundle mainBundle] pathForResource: @"Defaults" ofType: @"plist"]]];
        
        tr_benc settings;
        tr_bencInitDict(&settings, 41);
        tr_sessionGetDefaultSettings(&settings);
        
        if ([ITApplication isRunningInSandbox]) {
//            [self fixPathPreferencesForSandbox];
        }
        
        /* We don't care alternative speed limits but we leave them there if users prefer to use*/
        const BOOL usesSpeedLimitSched = [userDefaults boolForKey: @"SpeedLimitAuto"];
        if (!usesSpeedLimitSched)
            tr_bencDictAddBool(&settings, TR_PREFS_KEY_ALT_SPEED_ENABLED, [userDefaults boolForKey: @"SpeedLimit"]);
        
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_UP_KBps, [userDefaults integerForKey: @"SpeedLimitUploadLimit"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_DOWN_KBps, [userDefaults integerForKey: @"SpeedLimitDownloadLimit"]);
        
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_ENABLED, [userDefaults boolForKey: @"SpeedLimitAuto"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_BEGIN, [ITPrefsController dateToTimeSum:
                                                                         [userDefaults objectForKey: @"SpeedLimitAutoOnDate"]]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_END, [ITPrefsController dateToTimeSum:
                                                                       [userDefaults objectForKey: @"SpeedLimitAutoOffDate"]]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_ALT_SPEED_TIME_DAY, [userDefaults integerForKey: @"SpeedLimitAutoDay"]);
        
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_DSPEED_KBps, [userDefaults integerForKey: @"DownloadLimit"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_DSPEED_ENABLED, [userDefaults boolForKey: @"CheckDownload"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_USPEED_KBps, [userDefaults integerForKey: @"UploadLimit"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_USPEED_ENABLED, [userDefaults boolForKey: @"CheckUpload"]);
        
        //hidden prefs
        if ([userDefaults objectForKey: @"BindAddressIPv4"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_BIND_ADDRESS_IPV4, [[userDefaults stringForKey: @"BindAddressIPv4"] UTF8String]);
        if ([userDefaults objectForKey: @"BindAddressIPv6"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_BIND_ADDRESS_IPV6, [[userDefaults stringForKey: @"BindAddressIPv6"] UTF8String]);
        
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_BLOCKLIST_ENABLED, [userDefaults boolForKey: @"BlocklistEnabled"]);
        if ([userDefaults objectForKey: @"BlocklistURL"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_BLOCKLIST_URL, [[userDefaults stringForKey: @"BlocklistURL"] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_DHT_ENABLED, [userDefaults boolForKey: @"DHTGlobal"]);
        if ([[userDefaults stringForKey:@"DownloadFolder"] isAbsolutePath]) 
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_DOWNLOAD_DIR, [[[userDefaults stringForKey: @"DownloadFolder"] stringByExpandingTildeInPath] UTF8String]);
        else 
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_DOWNLOAD_DIR, [[self downloadPath] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_DOWNLOAD_QUEUE_ENABLED, [userDefaults boolForKey: @"Queue"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_DOWNLOAD_QUEUE_SIZE, [userDefaults integerForKey: @"QueueDownloadNumber"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_IDLE_LIMIT, [userDefaults integerForKey: @"IdleLimitMinutes"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_IDLE_LIMIT_ENABLED, [userDefaults boolForKey: @"IdleLimitCheck"]);
        if ([[userDefaults stringForKey:@"IncompleteDownloadFolder"] isAbsolutePath]) 
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_INCOMPLETE_DIR, [[[userDefaults stringForKey: @"IncompleteDownloadFolder"]
                                                                    stringByExpandingTildeInPath] UTF8String]);
        else
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_INCOMPLETE_DIR, [[self downloadPath] UTF8String]);

        tr_bencDictAddBool(&settings, TR_PREFS_KEY_INCOMPLETE_DIR_ENABLED, [userDefaults boolForKey: @"UseIncompleteDownloadFolder"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_LPD_ENABLED, [userDefaults boolForKey: @"LocalPeerDiscoveryGlobal"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_MSGLEVEL, TR_MSG_DBG);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_LIMIT_GLOBAL, [userDefaults integerForKey: @"PeersTotal"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_LIMIT_TORRENT, [userDefaults integerForKey: @"PeersTorrent"]);
        
        const BOOL randomPort = [userDefaults boolForKey: @"RandomPort"];
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_PEER_PORT_RANDOM_ON_START, randomPort);
        if (!randomPort)
            tr_bencDictAddInt(&settings, TR_PREFS_KEY_PEER_PORT, [userDefaults integerForKey: @"BindPort"]);
        
        //hidden pref
        if ([userDefaults objectForKey: @"PeerSocketTOS"])
            tr_bencDictAddStr(&settings, TR_PREFS_KEY_PEER_SOCKET_TOS, [[userDefaults stringForKey: @"PeerSocketTOS"] UTF8String]);
        
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_PEX_ENABLED, [userDefaults boolForKey: @"PEXGlobal"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_PORT_FORWARDING, [userDefaults boolForKey: @"NatTraversal"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_QUEUE_STALLED_ENABLED, [userDefaults boolForKey: @"CheckStalled"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_QUEUE_STALLED_MINUTES, [userDefaults integerForKey: @"StalledMinutes"]);
        tr_bencDictAddReal(&settings, TR_PREFS_KEY_RATIO, [userDefaults floatForKey: @"RatioLimit"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RATIO_ENABLED, [userDefaults boolForKey: @"RatioCheck"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RENAME_PARTIAL_FILES, [userDefaults boolForKey: @"RenamePartialFiles"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_AUTH_REQUIRED,  [userDefaults boolForKey: @"RPCAuthorize"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_ENABLED,  [userDefaults boolForKey: @"RPC"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_RPC_PORT, [userDefaults integerForKey: @"RPCPort"]);
        tr_bencDictAddStr(&settings, TR_PREFS_KEY_RPC_USERNAME,  [[userDefaults stringForKey: @"RPCUsername"] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_RPC_WHITELIST_ENABLED,  [userDefaults boolForKey: @"RPCUseWhitelist"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_SEED_QUEUE_ENABLED, [userDefaults boolForKey: @"QueueSeed"]);
        tr_bencDictAddInt(&settings, TR_PREFS_KEY_SEED_QUEUE_SIZE, [userDefaults integerForKey: @"QueueSeedNumber"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_START, [userDefaults boolForKey: @"AutoStartDownload"]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_SCRIPT_TORRENT_DONE_ENABLED, [userDefaults boolForKey: @"DoneScriptEnabled"]);
        tr_bencDictAddStr(&settings, TR_PREFS_KEY_SCRIPT_TORRENT_DONE_FILENAME, [[userDefaults stringForKey: @"DoneScriptPath"] UTF8String]);
        tr_bencDictAddBool(&settings, TR_PREFS_KEY_UTP_ENABLED, [userDefaults boolForKey: @"UTPGlobal"]);
        
        tr_formatter_size_init(1000,
                               [NSLocalizedString(@"KB", "File size - kilobytes") UTF8String],
                               [NSLocalizedString(@"MB", "File size - megabytes") UTF8String],
                               [NSLocalizedString(@"GB", "File size - gigabytes") UTF8String],
                               [NSLocalizedString(@"TB", "File size - terabytes") UTF8String]);
        
        tr_formatter_speed_init(1000,
                                [NSLocalizedString(@"KB/s", "Transfer speed (kilobytes per second)") UTF8String],
                                [NSLocalizedString(@"MB/s", "Transfer speed (megabytes per second)") UTF8String],
                                [NSLocalizedString(@"GB/s", "Transfer speed (gigabytes per second)") UTF8String],
                                [NSLocalizedString(@"TB/s", "Transfer speed (terabytes per second)") UTF8String]); //why not?
        
        tr_formatter_mem_init(1024, [NSLocalizedString(@"KB", "Memory size - kilobytes") UTF8String],
                              [NSLocalizedString(@"MB", "Memory size - megabytes") UTF8String],
                              [NSLocalizedString(@"GB", "Memory size - gigabytes") UTF8String],
                              [NSLocalizedString(@"TB", "Memory size - terabytes") UTF8String]);
        
        self.pauseOnLaunch = [userDefaults boolForKey:@"PauseOnLaunch"];
        
        const char * configDir = [[self configPath] UTF8String];
        self.handle = tr_sessionInit("ios", configDir, YES, &settings);
        tr_bencFree(&settings);
        
        self.torrents = [[NSMutableArray alloc] init];
        self.unconfirmedTorrents = [[NSMutableArray alloc] init];
        self.prefsController = [[ITPrefsController alloc] initWithHandle:self.handle];
        
        tr_sessionSetAltSpeedFunc(self.handle, altSpeedToggledCallback, (__bridge void*)self);
        if (usesSpeedLimitSched)
            [userDefaults setBool:tr_sessionUsesAltSpeed(self.handle) forKey: @"SpeedLimit"];
        
        tr_sessionSetRPCCallback(self.handle, rpcCallback, (__bridge void*)self);
        
        [self loadTorrentHistory];
    }
    return self;
}

- (void)fixPathPreferencesForSandbox
{
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"DownloadFolder"] hasPrefix:[ITApplication applicationPath]] == FALSE) {
        [[NSUserDefaults standardUserDefaults] setObject:[self downloadPath] forKey:@"DownloadFolder"];
    }
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"IncompleteDownloadFolder"] hasPrefix:[ITApplication applicationPath]] == FALSE) {
        [[NSUserDefaults standardUserDefaults] setObject:[self downloadPath] forKey:@"IncompleteDownloadFolder"];
    }
}

- (void)shutdown
{
    [[ITAppDelegate sharedDelegate] unregisterForTimerEvent:self];
    tr_sessionClose(self.handle);
}

- (void)timerFiredAfterDelay:(NSTimeInterval)timeInternalSinceLastCall
{
    [self updateStatistics];
        
    if ([self isLoggingEnabled]) {
        [self pumpLogMessages];
    }
}

- (void)pumpLogMessages
{
    static NSString *libtransmissionDomain = @"libtransmission";
    const tr_msg_list * l;
    
    /*
     TR_MSG_ERR = 1,
     TR_MSG_INF = 2,
     TR_MSG_DBG = 3
     */
    
    tr_msg_list * list = tr_getQueuedMessages( );

    for( l=list; l!=NULL; l=l->next ) {
        LogMessage(libtransmissionDomain, l->level, @"%s %s (%s:%d)", l->name, l->message, l->file, l->line );
    }
    
    tr_freeMessageList( list );
}

- (void)updateStatistics
{
    ITStatistics *s = [[ITStatistics alloc] init];
    CGFloat dlRate = 0.0, ulRate = 0.0;
    BOOL completed = NO;
    for (ITTorrent * torrent in self.torrents)
    {
        [torrent update];
        
        //pull the upload and download speeds - most consistent by using current stats
        dlRate += [torrent downloadRate];
        ulRate += [torrent uploadRate];
        
        completed |= [torrent isFinishedSeeding];
    }
    s.downloadRate = dlRate;
    s.uploadRate = ulRate;
    s.completed = completed;
    
    tr_session_stats stats;
    tr_sessionGetCumulativeStats(self.handle, &stats);
    s.cumulativeDownload = stats.downloadedBytes;
    s.cumulativeUpload = stats.uploadedBytes;
    s.cumulativeRatio = stats.ratio;
    
    tr_sessionGetStats(self.handle, &stats);
    s.sessionRatio = stats.ratio;
    s.sessionDownload = stats.downloadedBytes;
    s.sessionUpload = stats.uploadedBytes;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITNewStatisticsAvailableNotification object:nil userInfo:[NSDictionary dictionaryWithObject:s forKey:@"statistics"]];
}

- (void)loadTorrentHistory
{
    NSArray * history = [NSArray arrayWithContentsOfFile:[self transfersPlistPath]];
    NSMutableArray *loadedTorrents = [NSMutableArray arrayWithCapacity:[history count]];
    
    if (history)
    {
        NSMutableArray * waitToStartTorrents = [NSMutableArray arrayWithCapacity: (([history count] > 0 && !self.pauseOnLaunch) ? [history count]-1 : 0)]; //theoretical max without doing a lot of work
        
        for (NSDictionary * historyItem in history)
        {
            ITTorrent* torrent;
            if ((torrent = [[ITTorrent alloc] initWithHistory: historyItem lib: self.handle forcePause: self.pauseOnLaunch]))
            {
                [self.torrents addObject: torrent];
                [loadedTorrents addObject: torrent];
                
                NSNumber * waitToStart;
                if (!self.pauseOnLaunch && (waitToStart = [historyItem objectForKey: @"WaitToStart"]) && [waitToStart boolValue])
                    [waitToStartTorrents addObject: torrent];
                }
        }
        
        //now that all are loaded, let's set those in the queue to waiting
        for (ITTorrent * torrent in waitToStartTorrents)
            [torrent startTransfer];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kITTorrentHistoryLoadedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:loadedTorrents forKey:@"torrents"]];
}

- (void)updateTorrentHistory
{
    NSMutableArray * history = [NSMutableArray arrayWithCapacity:[self.torrents count]];
    
    for (ITTorrent * torrent in self.torrents)
        [history addObject: [torrent history]];
    
    [history writeToFile:[self transfersPlistPath] atomically: YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kITTorrentHistorySavedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:self.torrents forKey:@"torrents"]];
}

- (void)sleepAllTransfers
{
    [self.torrents makeObjectsPerformSelector:@selector(sleep)];
}

- (void)wakeupAllTransfers
{
    [self.torrents makeObjectsPerformSelector:@selector(wakeUp)];
}

- (void)startAllTransfers
{
    [self.torrents makeObjectsPerformSelector:@selector(startTransfer)];
}

- (void)stopAllTransfers
{
    [self.torrents makeObjectsPerformSelector:@selector(stopTransfer)];
}

- (void) confirmRemoveTorrents: (NSArray *) torrents deleteData: (BOOL) deleteData
{
    /*
    NSMutableArray * selectedValues = [NSMutableArray arrayWithArray: [fTableView selectedValues]];
    [selectedValues removeObjectsInArray: torrents];
    */
     
    //don't want any of these starting then stopping
    for (ITTorrent *torrent in torrents)
        if ([torrent waitingToStart])
            [torrent stopTransfer];
    
    [self.torrents removeObjectsInArray: torrents];
    
    for (ITTorrent *torrent in torrents) {
        [torrent closeRemoveTorrent: deleteData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kITTorrentAboutToBeRemovedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:torrent forKey:@"torrent"]];
    }
    
    [self performSelector:@selector(_delayedRemovalOfTorrents:) withObject:torrents afterDelay:0.2f];
}

- (void)_delayedRemovalOfTorrents:(NSArray*)torrents
{
    [self.torrents removeObjectsInArray:torrents];
}

- (void) rpcCallback: (tr_rpc_callback_type) type forTorrentStruct: (struct tr_torrent *) torrentStruct
{    
    //get the torrent
    ITTorrent * torrent = nil;
    if (torrentStruct != NULL && (type != TR_RPC_TORRENT_ADDED && type != TR_RPC_SESSION_CHANGED && type != TR_RPC_SESSION_CLOSE))
    {
        for (torrent in self.torrents)
            if (torrentStruct == [torrent torrentStruct])
            {
                break;
            }
        
        if (!torrent)
        {            
            LogMessageCompat(@"No torrent found matching the given torrent struct from the RPC callback!");
            return;
        }
    }
    
    switch (type)
    {
        case TR_RPC_TORRENT_ADDED:
            [self performSelectorOnMainThread: @selector(rpcAddTorrentStruct:) withObject:
             [NSValue valueWithPointer: torrentStruct] waitUntilDone: NO];
            break;
            
        case TR_RPC_TORRENT_STARTED:
        case TR_RPC_TORRENT_STOPPED:
            [self performSelectorOnMainThread: @selector(rpcStartedStoppedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
            
        case TR_RPC_TORRENT_REMOVING:
            [self performSelectorOnMainThread: @selector(rpcRemoveTorrent:) withObject: torrent waitUntilDone: NO];
            break;
            
        case TR_RPC_TORRENT_TRASHING:
            [self performSelectorOnMainThread: @selector(rpcRemoveTorrentDeleteData:) withObject: torrent waitUntilDone: NO];
            break;
            
        case TR_RPC_TORRENT_CHANGED:
            [self performSelectorOnMainThread: @selector(rpcChangedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
            
        case TR_RPC_TORRENT_MOVED:
            [self performSelectorOnMainThread: @selector(rpcMovedTorrent:) withObject: torrent waitUntilDone: NO];
            break;
            
        case TR_RPC_SESSION_QUEUE_POSITIONS_CHANGED:
            [self performSelectorOnMainThread: @selector(rpcUpdateQueue) withObject: nil waitUntilDone: NO];
            break;
            
        case TR_RPC_SESSION_CHANGED:
            [self.prefsController performSelectorOnMainThread: @selector(rpcUpdatePrefs) withObject: nil waitUntilDone: NO];
            break;
            
        case TR_RPC_SESSION_CLOSE:
            LogMessageCompat(@"TR_RPC_SESSION_CLOSE ignored!!!\n");
            break;
        default:
            NSAssert1(NO, @"Unknown RPC command received: %d", type);
    }
}

- (void) rpcAddTorrentStruct: (NSValue *) torrentStructPtr
{
    tr_torrent * torrentStruct = (tr_torrent *)[torrentStructPtr pointerValue];
    
    NSString * location = nil;
    if (tr_torrentGetDownloadDir(torrentStruct) != NULL)
        location = [NSString stringWithUTF8String: tr_torrentGetDownloadDir(torrentStruct)];
    
    ITTorrent * torrent = [[ITTorrent alloc] initWithTorrentStruct: torrentStruct location: location lib: self.handle];
    
    //change the location if the group calls for it (this has to wait until after the torrent is created)
    /*
    if ([[GroupsController groups] usesCustomDownloadLocationForIndex: [torrent groupValue]])
    {
        location = [[GroupsController groups] customDownloadLocationForIndex: [torrent groupValue]];
        [torrent changeDownloadFolderBeforeUsing: location];
    }
     */
    
    [self.torrents addObject: torrent];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITNewTorrentAddedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:torrent forKey:@"torrent"]];
}

- (void) rpcRemoveTorrent: (ITTorrent *) torrent
{
    [self confirmRemoveTorrents: [NSArray arrayWithObject: torrent] deleteData: NO];
}

- (void) rpcRemoveTorrentDeleteData: (ITTorrent *) torrent
{
    [self confirmRemoveTorrents: [NSArray arrayWithObject: torrent] deleteData: YES];
}

- (void) rpcStartedStoppedTorrent: (ITTorrent *) torrent
{
    [torrent update];
    
    [self updateTorrentHistory];
    [[NSNotificationCenter defaultCenter] postNotificationName:kITTorrentStateChangedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:torrent forKey:@"torrent"]];
}

- (void) rpcChangedTorrent: (ITTorrent *) torrent
{
    [torrent update];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITTorrentChangedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:torrent forKey:@"torrent"]];
}

- (void) rpcMovedTorrent: (ITTorrent *) torrent
{
    [torrent update];
}

- (void) rpcUpdateQueue
{
    /*
    for (ITTorrent * torrent in self.torrents)
        [torrent update];
    
    NSArray * selectedValues = [fTableView selectedValues];
    
    NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey: @"queuePosition" ascending: YES];
    NSArray * descriptors = [NSArray arrayWithObject: descriptor];
    [descriptor release];
    
    [fTorrents sortUsingDescriptors: descriptors];
    
    [self fullUpdateUI];
    
    [fTableView selectValues: selectedValues];
     */
}

- (void)openFilesWithDict:(NSDictionary *)dictionary
{
    [self openFiles: [dictionary objectForKey: @"Filenames"] addType: [[dictionary objectForKey: @"AddType"] intValue]];
}

- (BOOL)openFiles:(NSArray *)filenames addType:(ITAddType)type
{
    BOOL deleteTorrentFile, canToggleDelete = YES;
    BOOL retval = YES;
    switch (type)
    {
        case ITAddTypeCreated:
            deleteTorrentFile = NO;
            canToggleDelete = NO;
            break;
        case ITAddTypeURL:
            deleteTorrentFile = YES;
            break;
        default:
            deleteTorrentFile = NO;
    }
    
    for (NSString * torrentPath in filenames)
    {
        //ensure torrent doesn't already exist
        tr_ctor * ctor = tr_ctorNew(self.handle);
        tr_ctorSetMetainfoFromFile(ctor, [torrentPath UTF8String]);
        
        tr_info info;
        const tr_parse_result result = tr_torrentParse(ctor, &info);
        tr_ctorFree(ctor);
        
        if (result != TR_PARSE_OK)
        {
            if (result == TR_PARSE_DUPLICATE)
                [[NSNotificationCenter defaultCenter] postNotificationName:kITAttemptToAddDuplicateTorrentNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithUTF8String:info.name], @"ExistingTorrentName", torrentPath, @"TorrentPath", [NSNumber numberWithInteger:type], @"AddType", nil]];
            else if (result == TR_PARSE_ERR)
            {
                if (type != ITAddTypeAuto) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kITAttemptToAddInvalidTorrentNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:torrentPath, @"TorrentPath", [NSNumber numberWithInteger:type], @"AddType", nil]];
                }
            }
            else
                NSAssert2(NO, @"Unknown error code (%d) when attempting to open \"%@\"", result, torrentPath);
            
            tr_metainfoFree(&info);
            retval = NO;
            continue;
        }
        
        //determine download location
        NSString * location;
        /*
        else if ([[NSUserDefaults standardUserDefaults] boolForKey: @"DownloadLocationConstant"])
            location = [[fDefaults stringForKey: @"DownloadFolder"] stringByExpandingTildeInPath];
        else if (type != ADD_URL)
            location = [torrentPath stringByDeletingLastPathComponent];
        else
            location = nil;
         */
        location = [[[NSUserDefaults standardUserDefaults] stringForKey: @"DownloadFolder"] stringByExpandingTildeInPath];

        //determine to show the options window
        const BOOL showWindow = type == [[NSUserDefaults standardUserDefaults] boolForKey: @"DownloadAsk"] && ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive && false);
        tr_metainfoFree(&info);
        
        ITTorrent * torrent;
        if (!(torrent = [[ITTorrent alloc] initWithPath: torrentPath location: location
                                      deleteTorrentFile: showWindow ? NO : deleteTorrentFile lib:self.handle])) {
            retval = NO;
            continue;
        }
        //change the location if the group calls for it (this has to wait until after the torrent is created)
        /*
        if (!lockDestination && [[GroupsController groups] usesCustomDownloadLocationForIndex: [torrent groupValue]])
        {
            location = [[GroupsController groups] customDownloadLocationForIndex: [torrent groupValue]];
            [torrent changeDownloadFolderBeforeUsing: location];
        }
         */
        
        //verify the data right away if it was newly created
        if (type == ITAddTypeCreated)
            [torrent resetCache];
        
        //show the add window or add directly
        if (showWindow || !location)
        {
            /*
            AddWindowController * addController = [[AddWindowController alloc] initWithTorrent: torrent destination: location
                                                                               lockDestination: lockDestination controller: self torrentFile: torrentPath
                                                                                 deleteTorrent: deleteTorrentFile canToggleDelete: canToggleDelete];
            [addController showWindow: self];
            */
        }
        else
        {
            if ([[NSUserDefaults standardUserDefaults] boolForKey: @"AutoStartDownload"])
                [torrent startTransfer];
            
            [torrent update];
            [self.torrents addObject: torrent];
            [[NSNotificationCenter defaultCenter] postNotificationName:kITNewTorrentAddedNotification object:nil userInfo:[NSDictionary dictionaryWithObject:torrent forKey:@"torrent"]];
            [self updateTorrentHistory];
        }
    }
    return retval;
}

@end