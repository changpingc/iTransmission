//
//  ITPrefViewController.m
//  iTransmission
//
//  Created by Mike Chen on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITPrefViewController.h"
#import "ITController.h"
#import "ITPrefsController.h"
#import "ITNetworkSwitcher.h"

@implementation ITPrefViewController

@synthesize tableView = _tableView;
@synthesize enableRPCCell;
@synthesize enableRPCAuthenticationCell;
@synthesize useWiFiCell;
@synthesize useMobileCell;
@synthesize enablePortMapCell;
@synthesize RPCPortCell;
@synthesize RPCUsernameCell;
@synthesize RPCPasswordCell;
@synthesize bindPortCell;
@synthesize enableRPCSwitch;
@synthesize enableRPCAuthenticationSwitch;
@synthesize useWiFiSwitch;
@synthesize useMobileSwitch;
@synthesize enablePortMapSwitch;

- (id)init
{
    if ((self = [super initWithNibName:@"ITPrefViewController" bundle:[NSBundle mainBundle]])) {
        [self registerNotifications];
        self.title = @"Preferences";
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 1;
    }
    return 0;
}

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsBindPortUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsNatTraversalFlagUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsRPCAuthorizationFlagUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsRPCPasswordUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsRPCUsernameUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsRPCFlagUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITPrefsRPCPortUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITNetworkPrefUseWiFiChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(preferencesUpdateNotificationReceived:) name:kITNetworkPrefUseMobileChangedNotification object:nil];
}

- (void)preferencesUpdateNotificationReceived:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:kITPrefsBindPortUpdatedNotification]) {
        
    }
    else if ([[notification name] isEqualToString:kITPrefsBindPortUpdatedNotification]) {
        
    }
    else if ([[notification name] isEqualToString:kITPrefsNatTraversalFlagUpdatedNotification]) {
        self.enablePortMapSwitch.on = [[[ITController sharedController] prefsController] isNatTransversalEnabled];
    }
    else if ([[notification name] isEqualToString:kITPrefsRPCAuthorizationFlagUpdatedNotification]) {
        self.enableRPCAuthenticationSwitch.on = [[[ITController sharedController] prefsController] isRPCAuthorizationEnabled];
    }
    else if ([[notification name] isEqualToString:kITPrefsRPCPasswordUpdatedNotification]) {
        
    }
    else if ([[notification name] isEqualToString:kITPrefsRPCUsernameUpdatedNotification]) {
        
    }
    else if ([[notification name] isEqualToString:kITPrefsRPCFlagUpdatedNotification]) {
        self.enableRPCSwitch.on = [[[ITController sharedController] prefsController] isRPCEnabled];
    }
    else if ([[notification name] isEqualToString:kITPrefsRPCPortUpdatedNotification]) {
    }
    
    else if ([[notification name] isEqualToString:kITNetworkPrefUseWiFiChangedNotification]) {
        self.useWiFiSwitch.on = [[ITNetworkSwitcher sharedNetworkSwitcher] canUseWiFiNetwork];
    }   
    else if ([[notification name] isEqualToString:kITNetworkPrefUseMobileChangedNotification]) {
        self.useMobileSwitch.on = [[ITNetworkSwitcher sharedNetworkSwitcher] canUseMobileNetwork];
    }   
    else if ([[notification name] isEqualToString:kITPrefsBindPortUpdatedNotification]) {
        
    }
    
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"Web Interface";
        case 1: return @"Network Interface";
        case 2: return @"Port Listening";
//        case 3: return @"Logging";
    }
    return nil;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {
        case 0: return @"You may manage iTransmission remotely using web interface at port 9091";
//        case 0: return @"It's always recommended to use authentication if web interface is enabled. ";
        case 1: return @"Enabling cellular network may generate significant data charges. ";
        case 2: return nil;
//        case 3: return @"Only use logging for debugging. Extensive loggings will shorten both battery and Nand life. Saved logs will be available in iTunes. ";
    }
    return nil;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: return self.enableRPCCell;
                case 1: return self.enableRPCAuthenticationCell;
                case 2: return self.RPCUsernameCell;
                case 3: return self.RPCPasswordCell;
                case 4: return self.RPCPortCell;
            }
        }
        case 1: {
            switch (indexPath.row) {
                case 0: return self.useWiFiCell;
                case 1: return self.useMobileCell;
            }
        }
        case 2: {
            switch (indexPath.row) {
//                case 0: return self.bindPortCell;
                case 0: return self.enablePortMapCell;
            }
        }
//        case 3: {
//            switch (indexPath.row) {
//                case 0: return fEnableLoggingCell;
//            }
//        }
    }
    return nil;
}

- (void)enableRPCValueChanged:(id)sender
{
    [[[ITController sharedController] prefsController] setRPCEnabled:[sender isOn]];
}

- (IBAction)useWiFiValueChanged:(id)sender
{
    [[ITNetworkSwitcher sharedNetworkSwitcher] setUseWiFiNetwork:[sender isOn]];
}

- (IBAction)useMobileValueChanged:(id)sender
{
    [[ITNetworkSwitcher sharedNetworkSwitcher] setUseMobileNetwork:[sender isOn]];
}

- (IBAction)enableRPCAuthenticationValueChanged:(id)sender
{
    [[[ITController sharedController] prefsController] setRPCAuthorizionEnabled:[sender isOn]];
}

- (IBAction)enablePortMapValueChanged:(id)sender
{
    [[[ITController sharedController] prefsController] setNatTraverselEnabled:[sender isOn]];
}


@end
