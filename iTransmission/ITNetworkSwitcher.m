//
//  ITNetworkSwitcher.m
//  iTransmission
//
//  Created by Mike Chen on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITNetworkSwitcher.h"
#import "ITController.h"
#import "ITTorrent.h"
#import "ITAppDelegate.h"

@implementation ITNetworkSwitcher
@synthesize currentNetworkStatus;
@synthesize reachabilityHandle;
@synthesize enforcedPolicy = _enforcedPolicy;
@dynamic useWiFiNetwork;
@dynamic useMobileNetwork;

- (void)setEnforcedPolicy:(ITNetworkSwitcherPolicy)enforcedPolicy
{
    if (enforcedPolicy == self.enforcedPolicy) {
        return;
    }
    NSArray *torrents = [[ITController sharedController] torrents];
    if (enforcedPolicy == kITDisableTorrentNetworkActivities)
        [torrents makeObjectsPerformSelector:@selector(sleep)];
    else if (enforcedPolicy == kITEnableTorrentNetworkActivities)
        [torrents makeObjectsPerformSelector:@selector(wakeUp)];
    _enforcedPolicy = enforcedPolicy;
    [[NSNotificationCenter defaultCenter] postNotificationName:kITNetworkSwitcherPolicyChangedNotification object:nil];
    if (enforcedPolicy == kITDisableTorrentNetworkActivities)
        LogMessageCompat(@"Disabling all torrent network activities\n");
    else if (enforcedPolicy == kITEnableTorrentNetworkActivities)
        LogMessageCompat(@"Enabling all torrent network activities\n");
}

- (BOOL)canUseWiFiNetwork
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UseWiFi"];
}

- (void)setUseWiFiNetwork:(BOOL)useWiFiNetwork
{
    [[NSUserDefaults standardUserDefaults] setBool:useWiFiNetwork forKey:@"UseWiFi"];
    [self updatePolicyForNetworkStatus:self.currentNetworkStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:kITNetworkPrefUseWiFiChangedNotification object:nil];
}

- (BOOL)canUseMobileNetwork
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"UseCellular"];
}

- (void)setUseMobileNetwork:(BOOL)useMobileNetwork
{
    [[NSUserDefaults standardUserDefaults] setBool:useMobileNetwork forKey:@"UseCellular"];
    [self updatePolicyForNetworkStatus:self.currentNetworkStatus];
    [[NSNotificationCenter defaultCenter] postNotificationName:kITNetworkPrefUseMobileChangedNotification object:nil];
}

+ (id)sharedNetworkSwitcher
{
    return [[ITAppDelegate sharedDelegate] networkSwitcher];
}

- (id)init
{
    if ((self = [super init])) {
        self.reachabilityHandle = [Reachability reachabilityForInternetConnection];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChangedNotification:) name:kReachabilityChangedNotification object:nil];
        [self setEnforcedPolicy:kITDisableTorrentNetworkActivities];
        [self.reachabilityHandle performSelector:@selector(startNotifier) withObject:nil afterDelay:0.0f];
//        [self.reachabilityHandle startNotifier];
    }
    return self;
}

- (void)reachabilityChangedNotification:(NSNotification *)notification
{
    NetworkStatus newNetworkStatus = [self.reachabilityHandle currentReachabilityStatus];
    if (self.currentNetworkStatus == newNetworkStatus) {
        return;
    }
    else {
        switch (newNetworkStatus) {
            case NotReachable:
                [[NSNotificationCenter defaultCenter] postNotificationName:kITNetworkNotReachableNotification object:nil];
                LogMessageCompat(@"Network is down\n");
                break;
            case ReachableViaWiFi:
                [[NSNotificationCenter defaultCenter] postNotificationName:kITUsingWiFiNetworkNotification object:nil];
                LogMessageCompat(@"Now connected to WiFi\n");
                break;
            case ReachableViaWWAN:
                [[NSNotificationCenter defaultCenter] postNotificationName:kITUsingCellularNetworkNotification object:nil];
                LogMessageCompat(@"Now connected to carrier network\n");
            default:
                break;
        }
        [self updatePolicyForNetworkStatus:newNetworkStatus];
    }
    self.currentNetworkStatus = newNetworkStatus;
}

- (void)updatePolicyForNetworkStatus:(NetworkStatus)status
{
    switch (status) {
        case NotReachable:
            [self setEnforcedPolicy:kITDisableTorrentNetworkActivities];
            break;
        case ReachableViaWiFi:
            [self setEnforcedPolicy:[self canUseWiFiNetwork] ? kITEnableTorrentNetworkActivities : kITDisableTorrentNetworkActivities];
        case ReachableViaWWAN:
            [self setEnforcedPolicy:[self canUseMobileNetwork] ? kITEnableTorrentNetworkActivities : kITDisableTorrentNetworkActivities];
        default:
            break;
    }
}

- (void)dealloc
{
    [self.reachabilityHandle stopNotifier];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
