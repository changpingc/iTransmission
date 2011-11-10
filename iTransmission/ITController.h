//
//  ITController.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libtransmission/transmission.h>
#import "ITTimerListener.h"

#define kITNewTorrentAddedNotification @"kITNewTorrentAdded"
#define kITTorrentStateChangedNotification @"kITTorrentStateChanged"
#define kITTorrentChangedNotification @"kITTorrentChanged"
#define kITTorrentAboutToBeRemovedNotification @"kITTorrentAboutToBeRemoved"
#define kITTorrentRemovedNotification @"kITTorrentRemoved"
#define kITNewStatisticsAvailableNotification @"kITNewStatisticsAvailable"
#define kITTorrentHistoryLoadedNotification @"kITTorrentHistoryLoaded"
#define kITTorrentHistorySavedNotification @"kITTorrentHistorySaved"
#define kITTorrentAddingIsAbortingNotification @"kITTorrentAddingIsAborting"
#define kITAttemptToAddDuplicateTorrentNotification @"kITAttemptToAddDuplicateTorrent"
#define kITAttemptToAddInvalidTorrentNotification @"kITAttemptToAddInvalidTorrent"

typedef enum
{
    ITAddTypeManual,
    ITAddTypeAuto,
    ITAddTypeURL,
    ITAddTypeCreated,
} ITAddType;

@class ITPrefsController;
@class ITTorrent;
@class ITStatistics;

@interface ITController : NSObject<ITTimerListener>

@property (nonatomic, assign, getter = isLoggingEnabled) BOOL loggingEnabled;
@property (nonatomic, strong) ITPrefsController* prefsController;
@property (nonatomic, assign) BOOL pauseOnLaunch;
@property (nonatomic, strong) NSMutableArray *torrents;
@property (nonatomic, strong) NSMutableArray *unconfirmedTorrents;
@property (nonatomic, assign) tr_session *handle;

+ (id)sharedController;
- (id)init;

- (NSString*)transfersPlistPath;
- (NSString*)configPath;
- (NSString*)downloadPath;
- (NSString*)incompletePath;
- (void)logUsedPaths;

- (void)fixPathPreferencesForSandbox;
- (void)createPathsIfNeeded;

- (void)rpcCallback: (tr_rpc_callback_type) type forTorrentStruct: (struct tr_torrent *) torrentStruct;
- (void)rpcAddTorrentStruct: (NSValue *) torrentStructPtr;
- (void)rpcRemoveTorrent: (ITTorrent *) torrent;
- (void)rpcRemoveTorrentDeleteData: (ITTorrent *) torrent;
- (void)rpcStartedStoppedTorrent: (ITTorrent *) torrent;
- (void)rpcChangedTorrent: (ITTorrent *) torrent;
- (void)rpcMovedTorrent: (ITTorrent *) torrent;
- (void)rpcUpdateQueue;

- (void)updateStatistics;   

- (void)_delayedRemovalOfTorrents:(NSArray*)torrents;

- (void)loadTorrentHistory;
- (void)updateTorrentHistory;

- (void)sleepAllTransfers;
- (void)wakeupAllTransfers;
- (void)startAllTransfers;
- (void)stopAllTransfers;

- (void)shutdown;

- (BOOL)openFiles:(NSArray *)filenames addType:(ITAddType)type;
- (void)openFilesWithDict:(NSDictionary *)dictionary;
- (void)confirmRemoveTorrents: (NSArray *) torrents deleteData: (BOOL) deleteData;

- (void)pumpLogMessages;

@end
