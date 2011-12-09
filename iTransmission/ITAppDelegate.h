//
//  ITAppDelegate.h
//  iTransmission
//
//  Created by Mike Chen on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITStatusBarController.h"
#import "ITSidebarController.h"
#import "ITController.h"
#import "ITTimerListener.h"
#import "ITNetworkSwitcher.h"

@interface ITAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) ITController *controller;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ITStatusBarController *statusBarController;
@property (strong, nonatomic) ITSidebarController *sidebarController;
@property (nonatomic, strong) NSMutableArray *timerEventListeners;
@property (nonatomic, strong) NSTimer *persistentTimer;
@property (strong, nonatomic) ITNetworkSwitcher *networkSwitcher;

+ (id)sharedDelegate;
- (void)startTransmission;
- (void)stopTransmission;
- (void)_test;

- (void)startTimer;
- (void)stopTimer;
- (void)timerFired:(id)sender;
- (void)registerForTimerEvent:(id<ITTimerListener>)obj;
- (void)unregisterForTimerEvent:(id<ITTimerListener>)obj;

@end
