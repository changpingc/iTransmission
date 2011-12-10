//
//  ITPrefsController.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <libtransmission/transmission.h>

#define kITPrefsBindPortUpdatedNotification @"kITPrefsBindPortUpdated"
#define kITPrefsRandomBindPortFlagUpdatedNotification @"kITPrefsRandomBindPortFlagUpdated"
#define kITPrefsNatTraversalFlagUpdatedNotification @"kITPrefsNatTraversalFlagUpdated"
#define kITPrefsUTPFlagUpdateNotification @"kITPrefsUTPFlagUpdate"
#define kITPrefsPeersGlobalLimitUpdatedNotification @"kITPrefsPeersGlobalLimitUpdated"
#define kITPrefsPeersPerTorrentUpdatedNotification @"kITPrefsPeersPerTorrentUpdated"
#define kITPrefsDHTFlagUpdatedNotification @"kITPrefsDHTFlagUpdated"
#define kITPrefsLPDFlagUpdatedNotification @"kITPrefsLPDFlagUpdated"
#define kITPrefsPEXFlagUpdatedNotification @"kITPrefsPEXFlagUpdated"
#define kITPrefsAutoStartDownloadFlagUpdatedNotification @"kITPrefsAutoStartDownloadFlagUpdated"
#define kITPrefsRadioStopUpdatedNotification @"kITPrefsRadioStopUpdated"
#define kITPrefsRadioStopFlagUpdatedNotification @"kITPrefsRadioStopFlagUpdated"
#define kITPrefsUploadLimitUpdatedNotification @"kITPrefsUploadLimitUpdated"
#define kITPrefsDownloadLimitUpdatedNotification @"kITPrefsDownloadLimitUpdated"
#define kITPrefsUseIncompleteDownloadFolderFlagUpdatedNotification @"kITPrefsUseIncompleteDownloadFolderFlagUpdated"
#define kITPrefsRenamePartialFilesFlagUpdatedNotification @"kITPrefsRenamePartialFilesFlagUpdated"
#define kITPrefsRPCFlagUpdatedNotification @"kITPrefsRPCFlagUpdated"
#define kITPrefsRPCAuthorizationFlagUpdatedNotification @"kITPrefsRPCAuthorizationFlagUpdated"
#define kITPrefsRPCUsernameUpdatedNotification @"kITPrefsRPCUsernameUpdated"
#define kITPrefsRPCPasswordUpdatedNotification @"kITPrefsRPCPasswordUpdated"
#define kITPrefsRPCPortUpdatedNotification @"kITPrefsRPCPortUpdated"
#define kITPrefsRPCWhiteListFlagUpdatedNotification @"kITPrefsRPCWhiteListFlagUpdated"
#define kITPrefsUpdatedFromRPCNotification @"kITPrefsUpdatedFromRPC"
#define kITPrefsRPCWhiteListUpdatedNotification @"kITPrefsRPCWhiteListUpdated"


@interface ITPrefsController : NSObject

@property (assign, nonatomic) tr_session *handle;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, strong) NSMutableArray *RPCWhitelistArray;
- (id)initWithHandle:(tr_session*)h;
- (void)unload;
- (void)awakeFromNib;
- (void)setPort:(NSInteger)port;
- (void)setRandomPort;
- (void)setRandomPortOnStart:(BOOL)onStart;
- (void)setNatTraverselEnabled:(BOOL)enabled;
- (void)setUTPEnabled:(BOOL)enabled;
- (void)setPeersGlobalLimit:(NSInteger)limit;
- (void)setPeersPerTorrent:(NSInteger)limit;
- (void)setPEXEnabled:(BOOL)enabled;
- (void)setDHTEnabled:(BOOL)enabled;
- (void)setLPDEnabled:(BOOL)enabled;
- (void)setEncryptionMode:(tr_encryption_mode)mode;
- (void)setBlocklistEnabled: (id) sender;
- (void)setAutoStartDownloads:(BOOL)autostart;
- (void)setRadioStopEnabled:(BOOL)enabled;
- (void)setRatioStop:(CGFloat)ratio;
- (void)setUploadLimit:(NSInteger)limit;
- (void)setDownloadLimit:(NSInteger)limit;
- (void)setUseIncompleteFolder:(BOOL)enabled;
- (void)setRenamePartialFiles:(BOOL)enabled;
- (void)setRPCEnabled:(BOOL)enabled;
- (NSString*)linkToWebUI;
- (void)setRPCAuthorizionEnabled:(BOOL)enabled;
- (void)setRPCUsername:(NSString*)username;
- (void)setRPCPassword:(NSString*)password;
- (void)updateRPCPassword;
- (void)setRPCPort:(NSInteger)port;
- (void)setRPCUseWhitelistEnabled:(BOOL)enabled;
- (void)rpcUpdatePrefs;
- (void)setKeychainPassword: (const char *) password forService: (const char *) service username: (const char *) username;
- (void)updateRPCWhitelist;
+ (NSInteger)dateToTimeSum: (NSDate *) date;
+ (NSDate *)timeSumToDate: (NSInteger) sum;
- (BOOL)isRPCEnabled;
- (BOOL)isRPCAuthorizationEnabled;
- (BOOL)isNatTransversalEnabled;
- (NSInteger)RPCPort;
- (NSInteger)bindPort;

// Commented from MacOSX version; NOT USED! //
/*
 - (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) ident willBeInsertedIntoToolbar: (BOOL) flag
 - (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
 - (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
 - (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
 - (void) setAutoUpdateToBeta: (id) sender
 - (void) updateBlocklist: (id) sender
 - (void) setBlocklistAutoUpdate: (id) sender
 - (void) updateBlocklistFields
 - (void) updateBlocklistURLField
 - (void) updateBlocklistButton
 - (void) applyIdleStopSetting: (id) sender
 - (void) setIdleStop: (id) sender
 - (void) updateLimitStopField
 - (void) updateLimitFields
 - (void) setSpeedLimit: (id) sender
 - (void) setAutoSpeedLimit: (id) sender
 - (void) setAutoSpeedLimitTime: (id) sender
 - (void) setAutoSpeedLimitDay: (id) sender
 - (void) setBadge: (id) sender
 - (void) resetWarnings: (id) sender
 - (void) setDefaultForMagnets: (id) sender
 - (void) setQueueEnabled:(BOOL)enabled;
 - (void) setQueueNumber: (id) sender
 - (void) setStalled: (id) sender
 - (void) setStalledMinutes: (id) sender
 - (void) setDownloadLocation: (id) sender
 - (void) folderSheetShow: (id) sender
 - (void) incompleteFolderSheetShow: (id) sender
 - (void) doneScriptSheetShow:(id)sender
 - (void) setDoneScriptEnabled: (id) sender
 - (void) setAutoImport: (id) sender
 - (void) importFolderSheetShow: (id) sender
 - (void) setAutoSize: (id) sender
 - (void) setRPCWebUIDiscovery: (id) sender
 - (void) addRemoveRPCIP: (id) sender
 - (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView
 - (id) tableView: (NSTableView *) tableView objectValueForTableColumn: (NSTableColumn *) tableColumn row: (NSInteger) row
 - (void) tableView: (NSTableView *) tableView setObjectValue: (id) object forTableColumn: (NSTableColumn *) tableColumn
 - (void) tableViewSelectionDidChange: (NSNotification *) notification
 - (void) helpForScript: (id) sender
 - (void) helpForPeers: (id) sender
 - (void) helpForNetwork: (id) sender
 - (void) helpForRemote: (id) sender
 - (void) setPrefView: (id) sender
 - (void) folderSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
 - (void) incompleteFolderSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
 - (void) importFolderSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
 - (void) doneScriptSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
*/
@end
