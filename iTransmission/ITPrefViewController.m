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
#import "ITAppDelegate.h"

#define IN_RANGE(i, min, max) (i < min) || (i > max) ? NO : YES

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
@synthesize openWebInterfaceCell;
@synthesize enableRPCSwitch;
@synthesize enableRPCAuthenticationSwitch;
@synthesize useWiFiSwitch;
@synthesize useMobileSwitch;
@synthesize enablePortMapSwitch;
@synthesize RPCPortTextField;
@synthesize bindPortTextField;
@synthesize webInterfaceURLTextView;
@synthesize keyboardController;

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
            return 3;
        case 1:
            return 2;
        case 2:
            return 1;
    }
    return 0;
}

- (void)viewDidLoad
{
    self.enableRPCAuthenticationSwitch.on = [[[ITController sharedController] prefsController] isRPCAuthorizationEnabled];
    self.enablePortMapSwitch.on = [[[ITController sharedController] prefsController] isNatTransversalEnabled];
    self.enableRPCSwitch.on = [[[ITController sharedController] prefsController] isRPCEnabled];
    self.useWiFiSwitch.on = [[ITNetworkSwitcher sharedNetworkSwitcher] canUseWiFiNetwork];
    self.useMobileSwitch.on = [[ITNetworkSwitcher sharedNetworkSwitcher] canUseMobileNetwork];
    
    self.keyboardController = [[ITKeyboardController alloc] initWithDelegate:self];
    self.RPCPortTextField.delegate = self.keyboardController;
    self.bindPortTextField.delegate = self.keyboardController;
    self.RPCPortTextField.text = [NSString stringWithFormat:@"%d", [[[ITController sharedController] prefsController] RPCPort]];
    self.bindPortTextField.text = [NSString stringWithFormat:@"%d", [[[ITController sharedController] prefsController] bindPort]];
    self.webInterfaceURLTextView.text = [NSString stringWithFormat:@"http://127.0.0.1:%d/transmission/web/", [[[ITController sharedController] prefsController] RPCPort]];
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
        self.bindPortTextField.text = [NSString stringWithFormat:@"%d", [[[ITController sharedController] prefsController] bindPort]];

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
        self.RPCPortTextField.text = [NSString stringWithFormat:@"%d", [[[ITController sharedController] prefsController] RPCPort]];
        self.webInterfaceURLTextView.text = [NSString stringWithFormat:@"http://127.0.0.1:%d/transmission/web/", [[[ITController sharedController] prefsController] RPCPort]];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) {
        return self.openWebInterfaceCell.frame.size.height;
    }
    return 44.0f;
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
        case 0: 
            return nil;
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
                case 1: return self.RPCPortCell;
                case 2: return self.openWebInterfaceCell;
//                case 2: return self.enableRPCAuthenticationCell;
//                case 3: return self.RPCUsernameCell;
//                case 4: return self.RPCPasswordCell;
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

- (ITKeyboardToolbarOptions)keyboardOptionsForTextField:(UITextField*)textField
{
    return ITKeyboardOptionDone | ITKeyboardOptionCancel | ITKeyboardOptionResetToDefault;
}

- (BOOL)textFieldCanFinishEditing:(UITextField*)textField withText:(NSString *)string
{
    if (textField == self.RPCPortTextField) {
        NSInteger port = [string integerValue];
        if (IN_RANGE(port, 1025, 65535)) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (void)textFieldFinishedEditing:(UITextField *)textField
{
    if (textField == self.RPCPortTextField || textField == self.bindPortTextField) {
        NSInteger port = [textField.text integerValue];
        assert(IN_RANGE(port, 1025, 65535));
        if (textField == self.RPCPortTextField)
            [[[ITController sharedController] prefsController] setRPCPort:port];
        if (textField == self.bindPortTextField)
            [[[ITController sharedController] prefsController] setPort:port];
    }
}

- (NSString *)defaultTextForTextField:(UITextField *)textField
{
    if (textField == self.RPCPortTextField)
        return @"9091";
    if (textField == self.bindPortTextField)
        return @"51413";
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationLandscapeLeft || interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

- (NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 2) 
        return indexPath;
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 && indexPath.row == 2) {
        NSURL *URL = [NSURL URLWithString:[self.webInterfaceURLTextView text]];
        [[ITAppDelegate sharedDelegate] requestToOpenURL:URL];
    }
}

@end
