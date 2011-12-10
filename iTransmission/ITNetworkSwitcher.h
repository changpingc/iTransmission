//
//  ITNetworkSwitcher.h
//  iTransmission
//
//  Created by Mike Chen on 12/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

typedef enum _ITNetworkSwitcherPolicy {
    kITDisableTorrentNetworkActivities = 1,
    kITEnableTorrentNetworkActivities = 2,
} ITNetworkSwitcherPolicy; 

#define kITNetworkNotReachableNotification @"kITNetworkNotReachableNotification"
#define kITUsingCellularNetworkNotification @"kITUsingCellularNetworkNotification"
#define kITUsingWiFiNetworkNotification @"kITUsingWiFiNetworkNotification"
#define kITNetworkPrefUseWiFiChangedNotification @"kITNetworkPrefUseWiFiChangedNotification"
#define kITNetworkPrefUseMobileChangedNotification @"kITNetworkPrefUseMobileChangedNotification"
#define kITNetworkSwitcherPolicyChangedNotification @"kITNetworkSwitcherPolicyChangedNotification"

@interface ITNetworkSwitcher : NSObject
@property (nonatomic, strong) Reachability *reachabilityHandle;
@property (nonatomic, assign) NetworkStatus currentNetworkStatus;
@property (nonatomic, assign, getter = canUseWiFiNetwork) BOOL useWiFiNetwork;
@property (nonatomic, assign, getter = canUseMobileNetwork) BOOL useMobileNetwork;
@property (nonatomic, assign) ITNetworkSwitcherPolicy enforcedPolicy;
+ (id)sharedNetworkSwitcher;
- (void)reachabilityChangedNotification:(NSNotification*)notification;
- (void)updatePolicyForNetworkStatus:(NetworkStatus)status;
- (BOOL)canStartTransfer;
@end
