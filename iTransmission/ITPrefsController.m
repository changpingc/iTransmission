//
//  ITPrefsController.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITPrefsController.h"
#import <Security/Security.h>

#define WEBUI_URL @"http://127.0.0.1:%d/"
#define RPC_KEYCHAIN_SERVICE    "iTransmission:Remote"
#define RPC_KEYCHAIN_NAME       "Remote"

@implementation ITPrefsController

@synthesize handle = _handle;
@synthesize userDefaults = _userDefaults;
@synthesize RPCWhitelistArray = _RPCWhitelistArray;

- (id)initWithHandle:(tr_session*)h
{
    if (self = [super init]) {
        self.handle = h;
        self.userDefaults = [NSUserDefaults standardUserDefaults];
            
        //save a new random port
        if ([self.userDefaults boolForKey: @"RandomPort"])
            [self.userDefaults setInteger:tr_sessionGetPeerPort(self.handle) forKey:@"BindPort"];
            
        //set blocklist scheduler
        /*
        [[BlocklistScheduler scheduler] updateSchedule];
         */
        
        //update rpc whitelist
        [self updateRPCPassword];
        
        self.RPCWhitelistArray = [[self.userDefaults arrayForKey: @"RPCWhitelist"] mutableCopy];
        if (!self.RPCWhitelistArray)
            self.RPCWhitelistArray = [NSMutableArray arrayWithObject: @"127.0.0.1"];
        [self updateRPCWhitelist];
    
    }
    return self;
}

- (void)unload
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    self.RPCWhitelistArray = nil;
    
    /*
    [fPortStatusTimer invalidate];
    if (fPortChecker)
    {
        [fPortChecker cancelProbe];
        [fPortChecker release];
    }
    
    [fRPCWhitelistArray release];
    
    [fRPCPassword release];
    */
     
}

- (void) awakeFromNib
{
    /*
    fHasLoaded = YES;
    
    NSToolbar * toolbar = [[NSToolbar alloc] initWithIdentifier: @"Preferences Toolbar"];
    [toolbar setDelegate: self];
    [toolbar setAllowsUserCustomization: NO];
    [toolbar setDisplayMode: NSToolbarDisplayModeIconAndLabel];
    [toolbar setSizeMode: NSToolbarSizeModeRegular];
    [toolbar setSelectedItemIdentifier: TOOLBAR_GENERAL];
    [[self window] setToolbar: toolbar];
    [toolbar release];
    
    [self setPrefView: nil];
    
    //set download folder
    [fFolderPopUp selectItemAtIndex: [self.userDefaults boolForKey: @"DownloadLocationConstant"] ? DOWNLOAD_FOLDER : DOWNLOAD_TORRENT];
    
    //set stop ratio
    [fRatioStopField setFloatValue: [self.userDefaults floatForKey: @"RatioLimit"]];
    
    //set idle seeding minutes
    [fIdleStopField setIntegerValue: [self.userDefaults integerForKey: @"IdleLimitMinutes"]];
    
    //set limits
    [self updateLimitFields];
    
    //set speed limit
    [fSpeedLimitUploadField setIntValue: [self.userDefaults integerForKey: @"SpeedLimitUploadLimit"]];
    [fSpeedLimitDownloadField setIntValue: [self.userDefaults integerForKey: @"SpeedLimitDownloadLimit"]];
    
    //set port
    [fPortField setIntValue: [self.userDefaults integerForKey: @"BindPort"]];
    fNatStatus = -1;
    
    [self updatePortStatus];
    fPortStatusTimer = [NSTimer scheduledTimerWithTimeInterval: 5.0 target: self
                                                      selector: @selector(updatePortStatus) userInfo: nil repeats: YES];
    
    //set peer connections
    [fPeersGlobalField setIntValue: [self.userDefaults integerForKey: @"PeersTotal"]];
    [fPeersTorrentField setIntValue: [self.userDefaults integerForKey: @"PeersTorrent"]];
    
    //set queue values
    [fQueueDownloadField setIntValue: [self.userDefaults integerForKey: @"QueueDownloadNumber"]];
    [fQueueSeedField setIntValue: [self.userDefaults integerForKey: @"QueueSeedNumber"]];
    [fStalledField setIntValue: [self.userDefaults integerForKey: @"StalledMinutes"]];
    
    //set blocklist
    NSString * blocklistURL = [self.userDefaults stringForKey: @"BlocklistURL"];
    if (blocklistURL)
        [fBlocklistURLField setStringValue: blocklistURL];
    
    [self updateBlocklistButton];
    [self updateBlocklistFields];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateLimitFields)
                                                 name: @"UpdateSpeedLimitValuesOutsidePrefs" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateRatioStopField)
                                                 name: @"UpdateRatioStopValueOutsidePrefs" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateLimitStopField)
                                                 name: @"UpdateIdleStopValueOutsidePrefs" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateBlocklistFields)
                                                 name: @"BlocklistUpdated" object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(updateBlocklistURLField)
                                                 name: NSControlTextDidChangeNotification object: fBlocklistURLField];
    
    //set rpc port
    [fRPCPortField setIntValue: [self.userDefaults integerForKey: @"RPCPort"]];
    
    //set rpc password
    if (fRPCPassword)
        [fRPCPasswordField setStringValue: fRPCPassword];
     */
}

/*
- (NSToolbarItem *) toolbar: (NSToolbar *) toolbar itemForItemIdentifier: (NSString *) ident willBeInsertedIntoToolbar: (BOOL) flag
{
    NSToolbarItem * item = [[NSToolbarItem alloc] initWithItemIdentifier: ident];
    
    if ([ident isEqualToString: TOOLBAR_GENERAL])
    {
        [item setLabel: NSLocalizedString(@"General", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: NSImageNamePreferencesGeneral]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([ident isEqualToString: TOOLBAR_TRANSFERS])
    {
        [item setLabel: NSLocalizedString(@"Transfers", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: @"Transfers.png"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([ident isEqualToString: TOOLBAR_GROUPS])
    {
        [item setLabel: NSLocalizedString(@"Groups", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: @"Groups.png"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([ident isEqualToString: TOOLBAR_BANDWIDTH])
    {
        [item setLabel: NSLocalizedString(@"Bandwidth", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: @"Bandwidth.png"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([ident isEqualToString: TOOLBAR_PEERS])
    {
        [item setLabel: NSLocalizedString(@"Peers", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: NSImageNameUserGroup]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([ident isEqualToString: TOOLBAR_NETWORK])
    {
        [item setLabel: NSLocalizedString(@"Network", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: NSImageNameNetwork]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else if ([ident isEqualToString: TOOLBAR_REMOTE])
    {
        [item setLabel: NSLocalizedString(@"Remote", "Preferences -> toolbar item title")];
        [item setImage: [NSImage imageNamed: @"Remote.png"]];
        [item setTarget: self];
        [item setAction: @selector(setPrefView:)];
        [item setAutovalidates: NO];
    }
    else
    {
        [item release];
        return nil;
    }
    
    return [item autorelease];
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects: TOOLBAR_GENERAL, TOOLBAR_TRANSFERS, TOOLBAR_GROUPS, TOOLBAR_BANDWIDTH,
            TOOLBAR_PEERS, TOOLBAR_NETWORK, TOOLBAR_REMOTE, nil];
}

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *) toolbar
{
    return [self toolbarAllowedItemIdentifiers: toolbar];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar
{
    return [self toolbarAllowedItemIdentifiers: toolbar];
}

 */


//for a beta release, always use the beta appcast
/*
#if defined(TR_BETA_RELEASE)
#define SPARKLE_TAG YES
#else
#define SPARKLE_TAG [self.userDefaults boolForKey: @"AutoUpdateBeta"]
#endif
- (void) setAutoUpdateToBeta: (id) sender
{
    [[SUUpdater sharedUpdater] setAllowedTags: SPARKLE_TAG ? [NSSet setWithObject: @"beta"] : nil];
}
 */

- (void)setPort:(NSInteger)port
{
    [self.userDefaults setInteger: port forKey: @"BindPort"];
    tr_sessionSetPeerPort(self.handle, port);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsBindPortUpdatedNotification object:nil];
}

- (void)setRandomPort
{
    const tr_port port = tr_sessionSetPeerPortRandom(self.handle);
    [self.userDefaults setInteger: port forKey: @"BindPort"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsBindPortUpdatedNotification object:nil];
}

- (void)setRandomPortOnStart:(BOOL)onStart
{
    tr_sessionSetPeerPortRandomOnStart(self.handle, onStart);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRandomBindPortFlagUpdatedNotification object:nil];
}

- (void)setNatTraverselEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"NatTraversal"];
    tr_sessionSetPortForwardingEnabled(self.handle, [self.userDefaults boolForKey: @"NatTraversal"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsNatTraversalFlagUpdatedNotification object:nil];
}

- (void)setUTPEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey: @"UTPGlobal"];
    tr_sessionSetUTPEnabled(self.handle, [self.userDefaults boolForKey: @"UTPGlobal"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsUTPFlagUpdateNotification object:nil];
}

- (void)setPeersGlobalLimit:(NSInteger)limit
{
    [self.userDefaults setInteger:limit forKey: @"PeersTotal"];
    tr_sessionSetPeerLimit(self.handle, limit);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsPeersGlobalLimitUpdatedNotification object:nil];
}

- (void)setPeersPerTorrent:(NSInteger)limit
{
    [self.userDefaults setInteger:limit forKey: @"PeersTorrent"];
    tr_sessionSetPeerLimitPerTorrent(self.handle, limit);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsPeersPerTorrentUpdatedNotification object:nil];
}

- (void) setPEXEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"PEXGlobal"];
    tr_sessionSetPexEnabled(self.handle, [self.userDefaults boolForKey:@"PEXGlobal"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsPEXFlagUpdatedNotification object:nil];
    
}

- (void) setDHTEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"DHTGlobal"];
    tr_sessionSetDHTEnabled(self.handle, [self.userDefaults boolForKey: @"DHTGlobal"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsDHTFlagUpdatedNotification object:nil];
}

- (void) setLPDEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"LocalPeerDiscoveryGlobal"];
    tr_sessionSetLPDEnabled(self.handle, [self.userDefaults boolForKey: @"LocalPeerDiscoveryGlobal"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsLPDFlagUpdatedNotification object:nil];
}

- (void)setEncryptionMode:(tr_encryption_mode)mode
{
    [self.userDefaults setBool:mode forKey:@"EncryptionMode"];
    tr_sessionSetEncryption(self.handle, mode);
}

- (void)setBlocklistEnabled: (id) sender
{
    tr_blocklistSetEnabled(self.handle, [self.userDefaults boolForKey:@"BlocklistEnabled"]);
    
    /*
    [[BlocklistScheduler scheduler] updateSchedule];
    */
    
}

/*
- (void) updateBlocklist: (id) sender
{
    [BlocklistDownloaderViewController downloadWithPrefsController: self];
}

- (void) setBlocklistAutoUpdate: (id) sender
{
    [[BlocklistScheduler scheduler] updateSchedule];
}
 */

/*

- (void) updateBlocklistFields
{
    const BOOL exists = tr_blocklistExists(self.handle);
    
    if (exists)
    {
        NSString * countString = [NSString formattedUInteger: tr_blocklistGetRuleCount(self.handle)];
        [fBlocklistMessageField setStringValue: [NSString stringWithFormat: NSLocalizedString(@"%@ IP address rules in list",
                                                                                              "Prefs -> blocklist -> message"), countString]];
    }
    else 
        [fBlocklistMessageField setStringValue: NSLocalizedString(@"A blocklist must first be downloaded",
                                                                  "Prefs -> blocklist -> message")];
    
    NSString * updatedDateString;
    if (exists)
    {
        NSDate * updatedDate = [self.userDefaults objectForKey: @"BlocklistEnabledLastUpdateSuccess"];
        
        if (updatedDate)
        {
            if ([NSApp isOnSnowLeopardOrBetter])
                updatedDateString = [NSDateFormatter localizedStringFromDate: updatedDate dateStyle: NSDateFormatterFullStyle
                                                                   timeStyle: NSDateFormatterShortStyle];
            else
            {
                NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateStyle: NSDateFormatterFullStyle];
                [dateFormatter setTimeStyle: NSDateFormatterShortStyle];
                
                updatedDateString = [dateFormatter stringFromDate: updatedDate];
                [dateFormatter release];
            }
        }
        else
            updatedDateString = NSLocalizedString(@"N/A", "Prefs -> blocklist -> message");
    }
    else
        updatedDateString = NSLocalizedString(@"Never", "Prefs -> blocklist -> message");
    
    [fBlocklistDateField setStringValue: [NSString stringWithFormat: @"%@: %@",
                                          NSLocalizedString(@"Last updated", "Prefs -> blocklist -> message"), updatedDateString]];
}

- (void) updateBlocklistURLField
{
    NSString * blocklistString = [fBlocklistURLField stringValue];
    
    [self.userDefaults setObject: blocklistString forKey: @"BlocklistURL"];
    tr_blocklistSetURL(self.handle, [blocklistString UTF8String]);
    
    [self updateBlocklistButton];
}

- (void) updateBlocklistButton
{
    NSString * blocklistString = [self.userDefaults objectForKey: @"BlocklistURL"];
    const BOOL enable = (blocklistString && ![blocklistString isEqualToString: @""])
    && [self.userDefaults boolForKey: @"BlocklistEnabled"];
    [fBlocklistButton setEnabled: enable];
}

*/

- (void) setAutoStartDownloads:(BOOL)autostart
{
    [self.userDefaults setBool:autostart forKey:@"AutoStartDownload"];
    tr_sessionSetPaused(self.handle, ![self.userDefaults boolForKey: @"AutoStartDownload"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsAutoStartDownloadFlagUpdatedNotification object:nil];
}


- (void)setRadioStopEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"RatioCheck"];
    tr_sessionSetRatioLimited(self.handle, [self.userDefaults boolForKey: @"RatioCheck"]);
    tr_sessionSetRatioLimit(self.handle, [self.userDefaults floatForKey: @"RatioLimit"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRadioStopFlagUpdatedNotification object:nil];
}

- (void) setRatioStop:(CGFloat)ratio
{
    [self.userDefaults setFloat:ratio forKey:@"RatioLimit"];
    tr_sessionSetRatioLimited(self.handle, [self.userDefaults boolForKey: @"RatioCheck"]);
    tr_sessionSetRatioLimit(self.handle, [self.userDefaults floatForKey: @"RatioLimit"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRadioStopUpdatedNotification object:nil];
}

/*
- (void) applyIdleStopSetting: (id) sender
{
    tr_sessionSetIdleLimited(self.handle, [self.userDefaults boolForKey: @"IdleLimitCheck"]);
    tr_sessionSetIdleLimit(self.handle, [self.userDefaults integerForKey: @"IdleLimitMinutes"]);
    
    //reload main table for remaining seeding time
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUI" object: nil];
    
    //reload global settings in inspector
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateGlobalOptions" object: nil];
}

- (void) setIdleStop: (id) sender
{
    [self.userDefaults setInteger: [sender integerValue] forKey: @"IdleLimitMinutes"];
    
    [self applyIdleStopSetting: nil];
}
 */

/*

- (void) updateLimitStopField
{
    if (fHasLoaded)
        [fIdleStopField setIntegerValue: [self.userDefaults integerForKey: @"IdleLimitMinutes"]];
}

- (void) updateLimitFields
{
    if (!fHasLoaded)
        return;
    
    [fUploadField setIntValue: [self.userDefaults integerForKey: @"UploadLimit"]];
    [fDownloadField setIntValue: [self.userDefaults integerForKey: @"DownloadLimit"]];
}

 */
 
- (void) setUploadLimit:(NSInteger)limit
{
    [self.userDefaults setInteger:limit forKey:@"UploadLimit"];
    tr_sessionLimitSpeed(self.handle, TR_UP, [self.userDefaults boolForKey: @"CheckUpload"]);
    tr_sessionSetSpeedLimit_KBps(self.handle, TR_UP, [self.userDefaults integerForKey: @"UploadLimit"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsUploadLimitUpdatedNotification object:nil];
}

- (void) setDownloadLimit:(NSInteger)limit
{
    [self.userDefaults setInteger:limit forKey:@"DownloadLimit"];
    tr_sessionLimitSpeed(self.handle, TR_DOWN, [self.userDefaults boolForKey: @"CheckDownload"]);
    tr_sessionSetSpeedLimit_KBps(self.handle, TR_DOWN, [self.userDefaults integerForKey: @"DownloadLimit"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsDownloadLimitUpdatedNotification object:nil];
}

/*
- (void) setSpeedLimit: (id) sender
{
    [self.userDefaults setInteger: [sender intValue] forKey: sender == fSpeedLimitUploadField
     ? @"SpeedLimitUploadLimit" : @"SpeedLimitDownloadLimit"];
    [self applyAltSpeedSettings];
}

- (void) setAutoSpeedLimit: (id) sender
{
    tr_sessionUseAltSpeedTime(self.handle, [self.userDefaults boolForKey: @"SpeedLimitAuto"]);
}

- (void) setAutoSpeedLimitTime: (id) sender
{
    tr_sessionSetAltSpeedBegin(self.handle, [PrefsController dateToTimeSum: [self.userDefaults objectForKey: @"SpeedLimitAutoOnDate"]]);
    tr_sessionSetAltSpeedEnd(self.handle, [PrefsController dateToTimeSum: [self.userDefaults objectForKey: @"SpeedLimitAutoOffDate"]]);
}

- (void) setAutoSpeedLimitDay: (id) sender
{
    tr_sessionSetAltSpeedDay(self.handle, [[sender selectedItem] tag]);
}
 */

+ (NSInteger) dateToTimeSum: (NSDate *) date
{
    NSCalendar * calendar = [NSCalendar currentCalendar];
    NSDateComponents * components = [calendar components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate: date];
    return [components hour] * 60 + [components minute];
}

+ (NSDate *) timeSumToDate: (NSInteger) sum
{
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setHour: sum / 60];
    [comps setMinute: sum % 60];
    
    return [[NSCalendar currentCalendar] dateFromComponents: comps];
}

/*
- (void) setBadge: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUI" object: self];
}
 */

/*
- (void) resetWarnings: (id) sender
{
    // MARK
    [self.userDefaults removeObjectForKey: @"WarningDuplicate"];
    [self.userDefaults removeObjectForKey: @"WarningRemainingSpace"];
    [self.userDefaults removeObjectForKey: @"WarningFolderDataSameName"];
    [self.userDefaults removeObjectForKey: @"WarningResetStats"];
    [self.userDefaults removeObjectForKey: @"WarningCreatorBlankAddress"];
    [self.userDefaults removeObjectForKey: @"WarningCreatorPrivateBlankAddress"];
    [self.userDefaults removeObjectForKey: @"WarningRemoveTrackers"];
    [self.userDefaults removeObjectForKey: @"WarningInvalidOpen"];
    [self.userDefaults removeObjectForKey: @"WarningRemoveCompleted"];
    [self.userDefaults removeObjectForKey: @"WarningDonate"];
    //[self.userDefaults removeObjectForKey: @"WarningLegal"];
}
 */

/*
- (void) setDefaultForMagnets: (id) sender
{
    NSString * bundleID = [[NSBundle mainBundle] bundleIdentifier];
    const OSStatus result = LSSetDefaultHandlerForURLScheme((CFStringRef)@"magnet", (__bridge_retained CFStringRef)bundleID);
    if (result != noErr)
        LogMessageCompat(@"Failed setting default magnet link handler");
}
 */

/*
- (void) setQueueEnabled:(BOOL)enabled;
{
    //let's just do both - easier that way
    
    [self.userDefaults setBool:enabled forKey:@"Queue"];
    [self.userDefaults setBool:enabled forKey:@"QueueSeed"];
    
    tr_sessionSetQueueEnabled(self.handle, TR_DOWN, [self.userDefaults boolForKey: @"Queue"]);
    tr_sessionSetQueueEnabled(self.handle, TR_UP, [self.userDefaults boolForKey: @"QueueSeed"]);
    
    //handle if any transfers switch from queued to paused
    MARK
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateQueue" object: self];

}
*/

/*
- (void) setQueueNumber: (id) sender
{
    const NSInteger number = [sender intValue];
    const BOOL seed = sender == fQueueSeedField;
    
    [self.userDefaults setInteger: number forKey: seed ? @"QueueSeedNumber" : @"QueueDownloadNumber"];
    
    tr_sessionSetQueueSize(self.handle, seed ? TR_UP : TR_DOWN, number);
}

 */

/*
- (void) setStalled: (id) sender
{
    tr_sessionSetQueueStalledEnabled(self.handle, [self.userDefaults boolForKey: @"CheckStalled"]);
    
    //reload main table for stalled status
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUI" object: nil];
}

- (void) setStalledMinutes: (id) sender
{
    const NSInteger min = [sender intValue];
    [self.userDefaults setInteger: min forKey: @"StalledMinutes"];
    tr_sessionSetQueueStalledMinutes(self.handle, min);
    
    //reload main table for stalled status
    [[NSNotificationCenter defaultCenter] postNotificationName: @"UpdateUI" object: self];
}
 */

/*
- (void) setDownloadLocation: (id) sender
{
    [self.userDefaults setBool: [fFolderPopUp indexOfSelectedItem] == DOWNLOAD_FOLDER forKey: @"DownloadLocationConstant"];
}

- (void) folderSheetShow: (id) sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    
    [panel setPrompt: NSLocalizedString(@"Select", "Preferences -> Open panel prompt")];
    [panel setAllowsMultipleSelection: NO];
    [panel setCanChooseFiles: NO];
    [panel setCanChooseDirectories: YES];
    [panel setCanCreateDirectories: YES];
    
    [panel beginSheetForDirectory: nil file: nil types: nil
                   modalForWindow: [self window] modalDelegate: self didEndSelector:
     @selector(folderSheetClosed:returnCode:contextInfo:) contextInfo: nil];
}

- (void) incompleteFolderSheetShow: (id) sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    
    [panel setPrompt: NSLocalizedString(@"Select", "Preferences -> Open panel prompt")];
    [panel setAllowsMultipleSelection: NO];
    [panel setCanChooseFiles: NO];
    [panel setCanChooseDirectories: YES];
    [panel setCanCreateDirectories: YES];
    
    [panel beginSheetForDirectory: nil file: nil types: nil
                   modalForWindow: [self window] modalDelegate: self didEndSelector:
     @selector(incompleteFolderSheetClosed:returnCode:contextInfo:) contextInfo: nil];
}

- (void) doneScriptSheetShow:(id)sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    
    [panel setPrompt: NSLocalizedString(@"Select", "Preferences -> Open panel prompt")];
    [panel setAllowsMultipleSelection: NO];
    [panel setCanChooseFiles: YES];
    [panel setCanChooseDirectories: NO];
    [panel setCanCreateDirectories: NO];
    
    [panel beginSheetForDirectory: nil file: nil types: nil
                   modalForWindow: [self window] modalDelegate: self didEndSelector:
     @selector(doneScriptSheetClosed:returnCode:contextInfo:) contextInfo: nil];
}
 */

- (void) setUseIncompleteFolder:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"UseIncompleteDownloadFolder"];
    tr_sessionSetIncompleteDirEnabled(self.handle, [self.userDefaults boolForKey: @"UseIncompleteDownloadFolder"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsUseIncompleteDownloadFolderFlagUpdatedNotification object:nil];
}

- (void) setRenamePartialFiles:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"RenamePartialFiles"];
    tr_sessionSetIncompleteFileNamingEnabled(self.handle, [self.userDefaults boolForKey: @"RenamePartialFiles"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRenamePartialFilesFlagUpdatedNotification object:nil];
}

/*
- (void) setDoneScriptEnabled: (id) sender
{
    if ([self.userDefaults boolForKey: @"DoneScriptEnabled"] && ![[NSFileManager defaultManager] fileExistsAtPath: [self.userDefaults stringForKey:@"DoneScriptPath"]])
    {
        // enabled is set but script file doesn't exist, so prompt for one and disable until they pick one
        [self.userDefaults setBool: NO forKey: @"DoneScriptEnabled"];
        [self doneScriptSheetShow: sender];
    }
    tr_sessionSetTorrentDoneScriptEnabled(self.handle, [self.userDefaults boolForKey: @"DoneScriptEnabled"]);
}
 */

/*
- (void) setAutoImport: (id) sender
{
    NSString * path;
    if ((path = [self.userDefaults stringForKey: @"AutoImportDirectory"]))
    {
        path = [path stringByExpandingTildeInPath];
        if ([self.userDefaults boolForKey: @"AutoImport"])
            [[UKKQueue sharedFileWatcher] addPath: path];
        else
            [[UKKQueue sharedFileWatcher] removePathFromQueue: path];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"AutoImportSettingChange" object: self];
    }
    else
        [self importFolderSheetShow: nil];
}

- (void) importFolderSheetShow: (id) sender
{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    
    [panel setPrompt: NSLocalizedString(@"Select", "Preferences -> Open panel prompt")];
    [panel setAllowsMultipleSelection: NO];
    [panel setCanChooseFiles: NO];
    [panel setCanChooseDirectories: YES];
    [panel setCanCreateDirectories: YES];
    
    [panel beginSheetForDirectory: nil file: nil types: nil
                   modalForWindow: [self window] modalDelegate: self didEndSelector:
     @selector(importFolderSheetClosed:returnCode:contextInfo:) contextInfo: nil];
}
*/
 
/*
- (void) setAutoSize: (id) sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName: @"AutoSizeSettingChange" object: self];
}
*/
 
- (void)setRPCEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"RPC"];
    tr_sessionSetRPCEnabled(self.handle, enabled);
    /*
    [self setRPCWebUIDiscovery: nil];
     */
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCFlagUpdatedNotification object:nil];
}

- (NSString*)linkToWebUI
{
    NSString * urlString = [NSString stringWithFormat: WEBUI_URL, [self.userDefaults integerForKey: @"RPCPort"]];
    return urlString;
}

- (void) setRPCAuthorizionEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"RPCAuthorize"];
    tr_sessionSetRPCPasswordEnabled(self.handle, [self.userDefaults boolForKey: @"RPCAuthorize"]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCAuthorizationFlagUpdatedNotification object:nil];
}

- (void) setRPCUsername:(NSString*)username
{
    [self.userDefaults setObject:username forKey:@"RPCUsername"];
    tr_sessionSetRPCUsername(self.handle, [[self.userDefaults stringForKey: @"RPCUsername"] UTF8String]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCUsernameUpdatedNotification object:nil];
}

- (void) setRPCPassword:(NSString*)password
{
    [self setKeychainPassword:[password UTF8String] forService: RPC_KEYCHAIN_SERVICE username: RPC_KEYCHAIN_NAME];
    
    tr_sessionSetRPCPassword(self.handle, [password cStringUsingEncoding:NSUTF8StringEncoding]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCPasswordUpdatedNotification object:nil];
}

- (void) updateRPCPassword
{
    /*
    UInt32 passwordLength;
    const char * password = nil;
    SecKeychainFindGenericPassword(NULL, strlen(RPC_KEYCHAIN_SERVICE), RPC_KEYCHAIN_SERVICE,
                                   strlen(RPC_KEYCHAIN_NAME), RPC_KEYCHAIN_NAME, &passwordLength, (void **)&password, NULL);
    
    [fRPCPassword release];
    if (password != NULL)
    {
        char fullPassword[passwordLength+1];
        strncpy(fullPassword, password, passwordLength);
        fullPassword[passwordLength] = '\0';
        SecKeychainItemFreeContent(NULL, (void *)password);
        
        tr_sessionSetRPCPassword(self.handle, fullPassword);
        
        fRPCPassword = [[NSString alloc] initWithUTF8String: fullPassword];
        [fRPCPasswordField setStringValue: fRPCPassword];
    }
    else
        fRPCPassword = nil;
     */
}

- (void) setRPCPort:(NSInteger)port
{
    [self.userDefaults setInteger: port forKey: @"RPCPort"];
    tr_sessionSetRPCPort(self.handle, port);
    
    /*
    [self setRPCWebUIDiscovery: nil];
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCPortUpdatedNotification object:nil];
}

- (void) setRPCUseWhitelistEnabled:(BOOL)enabled
{
    [self.userDefaults setBool:enabled forKey:@"RPCUseWhiteList"];
    tr_sessionSetRPCWhitelistEnabled(self.handle, [self.userDefaults boolForKey: @"RPCUseWhitelist"]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCWhiteListFlagUpdatedNotification object:nil];
}

/*

- (void) setRPCWebUIDiscovery: (id) sender
{
    if ([self.userDefaults boolForKey:@"RPC"] && [self.userDefaults boolForKey: @"RPCWebDiscovery"])
        [[BonjourController defaultController] startWithPort: [self.userDefaults integerForKey: @"RPCPort"]];
    else
        [[BonjourController defaultController] stop];
}

 */
 
- (void) updateRPCWhitelist
{
    NSString * string = [self.RPCWhitelistArray componentsJoinedByString: @","];
    tr_sessionSetRPCWhitelist(self.handle, [string UTF8String]);
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsRPCWhiteListUpdatedNotification object:nil];
}

/*
- (void) addRemoveRPCIP: (id) sender
{
    //don't allow add/remove when currently adding - it leads to weird results
    if ([fRPCWhitelistTable editedRow] != -1)
        return;
    
    if ([[sender cell] tagForSegment: [sender selectedSegment]] == RPC_IP_REMOVE_TAG)
    {
        [fRPCWhitelistArray removeObjectsAtIndexes: [fRPCWhitelistTable selectedRowIndexes]];
        [fRPCWhitelistTable deselectAll: self];
        [fRPCWhitelistTable reloadData];
        
        [self.userDefaults setObject: fRPCWhitelistArray forKey: @"RPCWhitelist"];
        [self updateRPCWhitelist];
    }
    else
    {
        [fRPCWhitelistArray addObject: @""];
        [fRPCWhitelistTable reloadData];
        
        const int row = [fRPCWhitelistArray count] - 1;
        [fRPCWhitelistTable selectRowIndexes: [NSIndexSet indexSetWithIndex: row] byExtendingSelection: NO];
        [fRPCWhitelistTable editColumn: 0 row: row withEvent: nil select: YES];
    }
}
 
 */

/*
- (NSInteger) numberOfRowsInTableView: (NSTableView *) tableView
{
    return [fRPCWhitelistArray count];
}

- (id) tableView: (NSTableView *) tableView objectValueForTableColumn: (NSTableColumn *) tableColumn row: (NSInteger) row
{
    return [fRPCWhitelistArray objectAtIndex: row];
}

- (void) tableView: (NSTableView *) tableView setObjectValue: (id) object forTableColumn: (NSTableColumn *) tableColumn
               row: (NSInteger) row
{
    NSArray * components = [object componentsSeparatedByString: @"."];
    NSMutableArray * newComponents = [NSMutableArray arrayWithCapacity: 4];
    
    //create better-formatted ip string
    BOOL valid = false;
    if ([components count] == 4)
    {
        valid = true;
        for (NSString * component in components)
        {
            if ([component isEqualToString: @"*"])
                [newComponents addObject: component];
            else
            {
                int num = [component intValue];
                if (num >= 0 && num < 256)
                    [newComponents addObject: [[NSNumber numberWithInt: num] stringValue]];
                else
                {
                    valid = false;
                    break;
                }
            }
        }
    }
    
    NSString * newIP;
    if (valid)
    {
        newIP = [newComponents componentsJoinedByString: @"."];
        
        //don't allow the same ip address
        if ([fRPCWhitelistArray containsObject: newIP] && ![[fRPCWhitelistArray objectAtIndex: row] isEqualToString: newIP])
            valid = false;
    }
    
    if (valid)
    {
        [fRPCWhitelistArray replaceObjectAtIndex: row withObject: newIP];
        [fRPCWhitelistArray sortUsingSelector: @selector(compareNumeric:)];
    }
    else
    {
        NSBeep();
        if ([[fRPCWhitelistArray objectAtIndex: row] isEqualToString: @""])
            [fRPCWhitelistArray removeObjectAtIndex: row];
    }
    
    [fRPCWhitelistTable deselectAll: self];
    [fRPCWhitelistTable reloadData];
    
    [self.userDefaults setObject: fRPCWhitelistArray forKey: @"RPCWhitelist"];
    [self updateRPCWhitelist];
}

 */
 
/*
- (void) tableViewSelectionDidChange: (NSNotification *) notification
{
    [fRPCAddRemoveControl setEnabled: [fRPCWhitelistTable numberOfSelectedRows] > 0 forSegment: RPC_IP_REMOVE_TAG];
}

- (void) helpForScript: (id) sender
{
    [[NSHelpManager sharedHelpManager] openHelpAnchor: @"script"
                                               inBook: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"]];
}

- (void) helpForPeers: (id) sender
{
    [[NSHelpManager sharedHelpManager] openHelpAnchor: @"peers"
                                               inBook: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"]];
}

- (void) helpForNetwork: (id) sender
{
    [[NSHelpManager sharedHelpManager] openHelpAnchor: @"network"
                                               inBook: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"]];
}

- (void) helpForRemote: (id) sender
{
    [[NSHelpManager sharedHelpManager] openHelpAnchor: @"remote"
                                               inBook: [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"]];
}
 
 */

- (void) rpcUpdatePrefs
{
    //encryption
    const tr_encryption_mode encryptionMode = tr_sessionGetEncryption(self.handle);
    
    [self.userDefaults setInteger:encryptionMode forKey:@"EncryptionMode"];
    
    /*
    [self.userDefaults setBool: encryptionMode != TR_CLEAR_PREFERRED forKey: @"EncryptionPrefer"];
    [self.userDefaults setBool: encryptionMode == TR_ENCRYPTION_REQUIRED forKey: @"EncryptionRequire"];
    */
    
    //download directory
    NSString * downloadLocation = [[NSString stringWithUTF8String: tr_sessionGetDownloadDir(self.handle)] stringByStandardizingPath];
    [self.userDefaults setObject: downloadLocation forKey: @"DownloadFolder"];
    
    NSString * incompleteLocation = [[NSString stringWithUTF8String: tr_sessionGetIncompleteDir(self.handle)] stringByStandardizingPath];
    [self.userDefaults setObject: incompleteLocation forKey: @"IncompleteDownloadFolder"];
    
    const BOOL useIncomplete = tr_sessionIsIncompleteDirEnabled(self.handle);
    [self.userDefaults setBool: useIncomplete forKey: @"UseIncompleteDownloadFolder"];
    
    const BOOL usePartialFileRanaming = tr_sessionIsIncompleteFileNamingEnabled(self.handle);
    [self.userDefaults setBool: usePartialFileRanaming forKey: @"RenamePartialFiles"];
    
    //utp
    const BOOL utp = tr_sessionIsUTPEnabled(self.handle);
    [self.userDefaults setBool: utp forKey: @"UTPGlobal"];
    
    //peers
    const uint16_t peersTotal = tr_sessionGetPeerLimit(self.handle);
    [self.userDefaults setInteger: peersTotal forKey: @"PeersTotal"];
    
    const uint16_t peersTorrent = tr_sessionGetPeerLimitPerTorrent(self.handle);
    [self.userDefaults setInteger: peersTorrent forKey: @"PeersTorrent"];
    
    //pex
    const BOOL pex = tr_sessionIsPexEnabled(self.handle);
    [self.userDefaults setBool: pex forKey: @"PEXGlobal"];
    
    //dht
    const BOOL dht = tr_sessionIsDHTEnabled(self.handle);
    [self.userDefaults setBool: dht forKey: @"DHTGlobal"];
    
    //lpd
    const BOOL lpd = tr_sessionIsLPDEnabled(self.handle);
    [self.userDefaults setBool: lpd forKey: @"LocalPeerDiscoveryGlobal"];
    
    //auto start
    const BOOL autoStart = !tr_sessionGetPaused(self.handle);
    [self.userDefaults setBool: autoStart forKey: @"AutoStartDownload"];
    
    //port
    const tr_port port = tr_sessionGetPeerPort(self.handle);
    [self.userDefaults setInteger: port forKey: @"BindPort"];
    
    const BOOL nat = tr_sessionIsPortForwardingEnabled(self.handle);
    [self.userDefaults setBool: nat forKey: @"NatTraversal"];
    
    /*
    fPeerPort = -1;
    fNatStatus = -1;
    [self updatePortStatus];
    */
     
    const BOOL randomPort = tr_sessionGetPeerPortRandomOnStart(self.handle);
    [self.userDefaults setBool: randomPort forKey: @"RandomPort"];
    
    //speed limit - down
    const BOOL downLimitEnabled = tr_sessionIsSpeedLimited(self.handle, TR_DOWN);
    [self.userDefaults setBool: downLimitEnabled forKey: @"CheckDownload"];
    
    const int downLimit = tr_sessionGetSpeedLimit_KBps(self.handle, TR_DOWN);
    [self.userDefaults setInteger: downLimit forKey: @"DownloadLimit"];
    
    //speed limit - up
    const BOOL upLimitEnabled = tr_sessionIsSpeedLimited(self.handle, TR_UP);
    [self.userDefaults setBool: upLimitEnabled forKey: @"CheckUpload"];
    
    const int upLimit = tr_sessionGetSpeedLimit_KBps(self.handle, TR_UP);
    [self.userDefaults setInteger: upLimit forKey: @"UploadLimit"];
    
    //alt speed limit enabled
    const BOOL useAltSpeed = tr_sessionUsesAltSpeed(self.handle);
    [self.userDefaults setBool: useAltSpeed forKey: @"SpeedLimit"];
    
    //alt speed limit - down
    const int downLimitAlt = tr_sessionGetAltSpeed_KBps(self.handle, TR_DOWN);
    [self.userDefaults setInteger: downLimitAlt forKey: @"SpeedLimitDownloadLimit"];
    
    //alt speed limit - up
    const int upLimitAlt = tr_sessionGetAltSpeed_KBps(self.handle, TR_UP);
    [self.userDefaults setInteger: upLimitAlt forKey: @"SpeedLimitUploadLimit"];
    
    //alt speed limit schedule
    const BOOL useAltSpeedSched = tr_sessionUsesAltSpeedTime(self.handle);
    [self.userDefaults setBool: useAltSpeedSched forKey: @"SpeedLimitAuto"];
    
    NSDate * limitStartDate = [ITPrefsController timeSumToDate: tr_sessionGetAltSpeedBegin(self.handle)];
    [self.userDefaults setObject: limitStartDate forKey: @"SpeedLimitAutoOnDate"];
    
    NSDate * limitEndDate = [ITPrefsController timeSumToDate: tr_sessionGetAltSpeedEnd(self.handle)];
    [self.userDefaults setObject: limitEndDate forKey: @"SpeedLimitAutoOffDate"];
    
    const int limitDay = tr_sessionGetAltSpeedDay(self.handle);
    [self.userDefaults setInteger: limitDay forKey: @"SpeedLimitAutoDay"];
    
    //blocklist
    const BOOL blocklist = tr_blocklistIsEnabled(self.handle);
    [self.userDefaults setBool: blocklist forKey: @"BlocklistEnabled"];
    
    NSString * blocklistURL = [NSString stringWithUTF8String: tr_blocklistGetURL(self.handle)];
    [self.userDefaults setObject: blocklistURL forKey: @"BlocklistURL"];
    
    //seed ratio
    const BOOL ratioLimited = tr_sessionIsRatioLimited(self.handle);
    [self.userDefaults setBool: ratioLimited forKey: @"RatioCheck"];
    
    const float ratioLimit = tr_sessionGetRatioLimit(self.handle);
    [self.userDefaults setFloat: ratioLimit forKey: @"RatioLimit"];
    
    //idle seed limit
    const BOOL idleLimited = tr_sessionIsIdleLimited(self.handle);
    [self.userDefaults setBool: idleLimited forKey: @"IdleLimitCheck"];
    
    const NSUInteger idleLimitMin = tr_sessionGetIdleLimit(self.handle);
    [self.userDefaults setInteger: idleLimitMin forKey: @"IdleLimitMinutes"];
    
    //queue
    const BOOL downloadQueue = tr_sessionGetQueueEnabled(self.handle, TR_DOWN);
    [self.userDefaults setBool: downloadQueue forKey: @"Queue"];
    
    const int downloadQueueNum = tr_sessionGetQueueSize(self.handle, TR_DOWN);
    [self.userDefaults setInteger: downloadQueueNum forKey: @"QueueDownloadNumber"];
    
    const BOOL seedQueue = tr_sessionGetQueueEnabled(self.handle, TR_UP);
    [self.userDefaults setBool: seedQueue forKey: @"QueueSeed"];
    
    const int seedQueueNum = tr_sessionGetQueueSize(self.handle, TR_UP);
    [self.userDefaults setInteger: seedQueueNum forKey: @"QueueSeedNumber"];
    
    const BOOL checkStalled = tr_sessionGetQueueStalledEnabled(self.handle);
    [self.userDefaults setBool: checkStalled forKey: @"CheckStalled"];
    
    const int stalledMinutes = tr_sessionGetQueueStalledMinutes(self.handle);
    [self.userDefaults setInteger: stalledMinutes forKey: @"StalledMinutes"];
    
    //done script
    const BOOL doneScriptEnabled = tr_sessionIsTorrentDoneScriptEnabled(self.handle);
    [self.userDefaults setBool: doneScriptEnabled forKey: @"DoneScriptEnabled"];
    
    NSString * doneScriptPath = [NSString stringWithUTF8String: tr_sessionGetTorrentDoneScript(self.handle)];
    [self.userDefaults setObject: doneScriptPath forKey: @"DoneScriptPath"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kITPrefsUpdatedFromRPCNotification object:nil];
}

/*
- (void) setPrefView: (id) sender
{
    NSString * identifier;
    if (sender)
    {
        identifier = [sender itemIdentifier];
        [[NSUserDefaults standardUserDefaults] setObject: identifier forKey: @"SelectedPrefView"];
    }
    else
        identifier = [[NSUserDefaults standardUserDefaults] stringForKey: @"SelectedPrefView"];
    
    NSView * view;
    if ([identifier isEqualToString: TOOLBAR_TRANSFERS])
        view = fTransfersView;
    else if ([identifier isEqualToString: TOOLBAR_GROUPS])
        view = fGroupsView;
    else if ([identifier isEqualToString: TOOLBAR_BANDWIDTH])
        view = fBandwidthView;
    else if ([identifier isEqualToString: TOOLBAR_PEERS])
        view = fPeersView;
    else if ([identifier isEqualToString: TOOLBAR_NETWORK])
        view = fNetworkView;
    else if ([identifier isEqualToString: TOOLBAR_REMOTE])
        view = fRemoteView;
    else
    {
        identifier = TOOLBAR_GENERAL; //general view is the default selected
        view = fGeneralView;
    }
    
    [[[self window] toolbar] setSelectedItemIdentifier: identifier];
    
    NSWindow * window = [self window];
    if ([window contentView] == view)
        return;
    
    NSRect windowRect = [window frame];
    float difference = ([view frame].size.height - [[window contentView] frame].size.height) * [window userSpaceScaleFactor];
    windowRect.origin.y -= difference;
    windowRect.size.height += difference;
    
    [view setHidden: YES];
    [window setContentView: view];
    [window setFrame: windowRect display: YES animate: YES];
    [view setHidden: NO];
    
    //set title label
    if (sender)
        [window setTitle: [sender label]];
    else
    {
        NSToolbar * toolbar = [window toolbar];
        NSString * itemIdentifier = [toolbar selectedItemIdentifier];
        for (NSToolbarItem * item in [toolbar items])
            if ([[item itemIdentifier] isEqualToString: itemIdentifier])
            {
                [window setTitle: [item label]];
                break;
            }
    }
}

- (void) folderSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
{
    if (code == NSOKButton)
    {
        [fFolderPopUp selectItemAtIndex: DOWNLOAD_FOLDER];
        
        NSString * folder = [[openPanel filenames] objectAtIndex: 0];
        [self.userDefaults setObject: folder forKey: @"DownloadFolder"];
        [self.userDefaults setObject: @"Constant" forKey: @"DownloadChoice"];
        
        tr_sessionSetDownloadDir(self.handle, [folder UTF8String]);
    }
    else
    {
        //reset if cancelled
        [fFolderPopUp selectItemAtIndex: [self.userDefaults boolForKey: @"DownloadLocationConstant"] ? DOWNLOAD_FOLDER : DOWNLOAD_TORRENT];
    }
}

- (void) incompleteFolderSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
{
    if (code == NSOKButton)
    {
        NSString * folder = [[openPanel filenames] objectAtIndex: 0];
        [self.userDefaults setObject: folder forKey: @"IncompleteDownloadFolder"];
        
        tr_sessionSetIncompleteDir(self.handle, [folder UTF8String]);
    }
    [fIncompleteFolderPopUp selectItemAtIndex: 0];
}

- (void) importFolderSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
{
    NSString * path = [self.userDefaults stringForKey: @"AutoImportDirectory"];
    if (code == NSOKButton)
    {
        UKKQueue * sharedQueue = [UKKQueue sharedFileWatcher];
        if (path)
            [sharedQueue removePathFromQueue: [path stringByExpandingTildeInPath]];
        
        path = [[openPanel filenames] objectAtIndex: 0];
        [self.userDefaults setObject: path forKey: @"AutoImportDirectory"];
        [sharedQueue addPath: [path stringByExpandingTildeInPath]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"AutoImportSettingChange" object: self];
    }
    else if (!path)
        [self.userDefaults setBool: NO forKey: @"AutoImport"];
    
    [fImportFolderPopUp selectItemAtIndex: 0];
}

- (void) doneScriptSheetClosed: (NSOpenPanel *) openPanel returnCode: (int) code contextInfo: (void *) info
{
    if (code == NSOKButton)
    {
        NSString * filePath = [[openPanel filenames] objectAtIndex: 0];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath: filePath])  // script file exists
        {
            [self.userDefaults setObject: filePath forKey: @"DoneScriptPath"];
            [self.userDefaults setBool: YES forKey: @"DoneScriptEnabled"];
        }
        else // script file doesn't exist so don't enable
        {
            [self.userDefaults setObject: nil forKey:@"DoneScriptPath"];
            [self.userDefaults setBool: NO forKey: @"DoneScriptEnabled"];
        }
        tr_sessionSetTorrentDoneScript(self.handle, [[self.userDefaults stringForKey:@"DoneScriptPath"] UTF8String]);
        tr_sessionSetTorrentDoneScriptEnabled(self.handle, [self.userDefaults boolForKey:@"DoneScriptEnabled"]);
    }
    [fDoneScriptPopUp selectItemAtIndex: 0];
}
*/

- (void) setKeychainPassword: (const char *) password forService: (const char *) service username: (const char *) username
{
    /*
    SecKeychainItemRef item = NULL;
    NSUInteger passwordLength = strlen(password);
    
    OSStatus result = SecKeychainFindGenericPassword(NULL, strlen(service), service, strlen(username), username, NULL, NULL, &item);
    if (result == noErr && item)
    {
        if (passwordLength > 0) //found, so update
        {
            result = SecKeychainItemModifyAttributesAndData(item, NULL, passwordLength, (const void *)password);
            if (result != noErr)
                LogMessageCompat(@"Problem updating Keychain item: %s", GetMacOSStatusErrorString(result));
        }
        else //remove the item
        {
            result = SecKeychainItemDelete(item);
            if (result != noErr)
                LogMessageCompat(@"Problem removing Keychain item: %s", GetMacOSStatusErrorString(result));
        }
    }
    else if (result == errSecItemNotFound) //not found, so add
    {
        if (passwordLength > 0)
        {
            result = SecKeychainAddGenericPassword(NULL, strlen(service), service, strlen(username), username,
                                                   passwordLength, (const void *)password, NULL);
            if (result != noErr)
                LogMessageCompat(@"Problem adding Keychain item: %s", GetMacOSStatusErrorString(result));
        }
    }
    else
        LogMessageCompat(@"Problem accessing Keychain: %s", GetMacOSStatusErrorString(result));
     */
}

- (BOOL)isRPCEnabled
{
    return tr_sessionIsRPCEnabled(self.handle);
}

- (BOOL)isRPCAuthorizationEnabled
{
    return tr_sessionIsRPCPasswordEnabled(self.handle);
}

- (BOOL)isNatTransversalEnabled
{
    return tr_sessionIsPortForwardingEnabled(self.handle);
}

- (NSInteger)RPCPort
{
    return tr_sessionGetRPCPort(self.handle);
}

- (NSInteger)bindPort
{
    return tr_sessionGetPeerPort(self.handle);
}

@end
