//
//  ITStatusBarController.h
//  iTransmission
//
//  Created by Mike Chen on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITStatusBar;

@interface ITStatusBarController : UIViewController

@property (strong, atomic) IBOutlet UIView *containerView;
@property (strong, atomic) IBOutlet ITStatusBar *statusBar;
@property (strong, nonatomic) UIViewController *contentViewController;

- (void)fillContentView;
- (void)newStatisticsArrived:(NSNotification*)notif;

@end
