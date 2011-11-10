//
//  ITTorrent.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libtransmission/transmission.h>

#define kITTorrentUpdatedNotification @"kITTorrentUpdatedNotification"

@class ITFileListNode;

@interface ITTorrent : NSObject

@property (assign, nonatomic) tr_torrent *handle;
@property (assign, nonatomic) tr_stat *stat;
@property (assign, nonatomic) tr_info *info;
@property (strong, nonatomic) UIImage *icon;
@property (strong, nonatomic) NSString *hashString;
@property (assign, nonatomic) tr_file_stat *fileStat;
@property (strong, nonatomic) NSIndexSet* previousFinishedIndexes;
@property (strong, nonatomic) NSDate *previousFinishedIndexesDate;
@property (assign, nonatomic) NSInteger groupValue;
@property (assign, nonatomic) BOOL resumeOnWake;
@property (strong, nonatomic) NSUserDefaults *userDefaults;
@property (strong, nonatomic) NSArray *flatFileList;
@property (strong, nonatomic) NSArray *fileList;
@property (strong, nonatomic) NSDate *lastUpdateDate;

- (id) initWithPath: (NSString *) path location: (NSString *) location deleteTorrentFile: (BOOL) torrentDelete
                lib: (tr_session *) lib;
- (id) initWithTorrentStruct: (tr_torrent *) torrentStruct location: (NSString *) location lib: (tr_session *) lib;
- (id) initWithMagnetAddress: (NSString *) address location: (NSString *) location lib: (tr_session *) lib;
- (id) initWithHistory: (NSDictionary *) history lib: (tr_session *) lib forcePause: (BOOL) pause;

- (NSDictionary *) history;

- (void) closeRemoveTorrent: (BOOL) trashFiles;

- (void) changeDownloadFolderBeforeUsing: (NSString *) folder;

- (NSString *) currentDirectory;

- (void) getAvailability: (int8_t *) tab size: (NSInteger) size;
- (void) getAmountFinished: (float *) tab size: (NSInteger) size;
- (NSIndexSet *) previousFinishedPieces;
- (void) setPreviousFinishedPieces: (NSIndexSet *) indexes;

- (void) update;

- (void) startTransferIgnoringQueue: (BOOL) ignoreQueue;
- (void) startTransferNoQueue;
- (void) startTransfer;
- (void) stopTransfer;
- (void) sleep;
- (void) wakeUp;

- (NSInteger) queuePosition;
- (void) setQueuePosition: (NSUInteger) index;

- (void) manualAnnounce;
- (BOOL) canManualAnnounce;

- (void) resetCache;

- (BOOL) isMagnet;
- (NSString *) magnetLink;

- (CGFloat) ratio;
- (tr_ratiolimit) ratioSetting;
- (void) setRatioSetting: (tr_ratiolimit) setting;
- (CGFloat) ratioLimit;
- (void) setRatioLimit: (CGFloat) limit;
- (CGFloat) progressStopRatio;

- (tr_idlelimit) idleSetting;
- (void) setIdleSetting: (tr_idlelimit) setting;
- (NSUInteger) idleLimitMinutes;
- (void) setIdleLimitMinutes: (NSUInteger) limit;

- (BOOL) usesSpeedLimit: (BOOL) upload;
- (void) setUseSpeedLimit: (BOOL) use upload: (BOOL) upload;
- (NSInteger) speedLimit: (BOOL) upload;
- (void) setSpeedLimit: (NSInteger) limit upload: (BOOL) upload;
- (BOOL) usesGlobalSpeedLimit;
- (void) setUseGlobalSpeedLimit: (BOOL) use;

- (void) setMaxPeerConnect: (uint16_t) count;
- (uint16_t) maxPeerConnect;

- (BOOL) waitingToStart;

- (tr_priority_t) priority;
- (void) setPriority: (tr_priority_t) priority;

+ (void) trashFile: (NSString *) path;
- (void) moveTorrentDataFileTo: (NSString *) folder;
- (void) copyTorrentFileTo: (NSString *) path;

- (BOOL) alertForRemainingDiskSpace;

- (NSString *) name;
- (BOOL) isFolder;
- (uint64_t) size;
- (uint64_t) sizeLeft;

- (NSMutableArray *) allTrackerStats;
- (NSArray *) allTrackersFlat; //used by GroupRules
- (BOOL) addTrackerToNewTier: (NSString *) tracker;
- (void) removeTrackers: (NSSet *) trackers;

- (NSString *) comment;
- (NSString *) creator;
- (NSDate *) dateCreated;

- (NSInteger) pieceSize;
- (NSInteger) pieceCount;
- (NSString *) hashString;
- (BOOL) privateTorrent;

- (NSString *) torrentLocation;
- (NSString *) dataLocation;
- (NSString *) fileLocation: (ITFileListNode *) node;

- (CGFloat) progress;
- (CGFloat) progressDone;
- (CGFloat) progressLeft;
- (CGFloat) checkingProgress;

- (CGFloat) availableDesired;

- (BOOL) isActive;
- (BOOL) isSeeding;
- (BOOL) isChecking;
- (BOOL) isCheckingWaiting;
- (BOOL) allDownloaded;
- (BOOL) isComplete;
- (BOOL) isFinishedSeeding;
- (BOOL) isError;
- (BOOL) isAnyErrorOrWarning;
- (NSString *) errorMessage;

- (NSArray *) peers;

- (NSUInteger) webSeedCount;
- (NSArray *) webSeeds;

- (NSString *) progressString;
- (NSString *) statusString;
- (NSString *) shortStatusString;
- (NSString *) remainingTimeString;

- (NSString *) stateString;
- (NSInteger) totalPeersConnected;
- (NSInteger) totalPeersTracker;
- (NSInteger) totalPeersIncoming;
- (NSInteger) totalPeersCache;
- (NSInteger) totalPeersPex;
- (NSInteger) totalPeersDHT;
- (NSInteger) totalPeersLocal;
- (NSInteger) totalPeersLTEP;

- (NSInteger) peersSendingToUs;
- (NSInteger) peersGettingFromUs;

- (CGFloat) downloadRate;
- (CGFloat) uploadRate;
- (CGFloat) totalRate;
- (uint64_t) haveVerified;
- (uint64_t) haveTotal;
- (uint64_t) totalSizeSelected;
- (uint64_t) downloadedTotal;
- (uint64_t) uploadedTotal;
- (uint64_t) failedHash;

- (NSInteger) groupValue;
- (void) setGroupValue: (NSInteger) groupValue;
//- (NSInteger) groupOrderValue;
- (void) checkGroupValueForRemoval: (NSNotification *) notification;

- (NSArray *) fileList;
- (NSArray *) flatFileList;
- (NSInteger) fileCount;
- (void) updateFileStat;

//methods require fileStats to have been updated recently to be accurate
- (CGFloat) fileProgress: (ITFileListNode *) node;
- (BOOL) canChangeDownloadCheckForFile: (NSUInteger) index;
- (BOOL) canChangeDownloadCheckForFiles: (NSIndexSet *) indexSet;
- (NSInteger) checkForFiles: (NSIndexSet *) indexSet;
- (void) setFileCheckState: (NSInteger) state forIndexes: (NSIndexSet *) indexSet;
- (void) setFilePriority: (tr_priority_t) priority forIndexes: (NSIndexSet *) indexSet;
- (BOOL) hasFilePriority: (tr_priority_t) priority forIndexes: (NSIndexSet *) indexSet;
- (NSSet *) filePrioritiesForIndexes: (NSIndexSet *) indexSet;

- (NSDate *) dateAdded;
- (NSDate *) dateCompleted;
- (NSDate *) dateActivity;
- (NSDate *) dateActivityOrAdd;

- (NSInteger) secondsDownloading;
- (NSInteger) secondsSeeding;

- (NSInteger) stalledMinutes;
- (BOOL) isStalled;

- (NSInteger) stateSortKey;
- (NSString *) trackerSortKey;

- (tr_torrent *) torrentStruct;

- (void)startIfAllowed;

@end
