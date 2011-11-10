//
//  ITInspectorCollectionViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITInspectorBaseViewController.h"

@class ITTorrent;
@class ITInspectorCollectionTabBar;

@interface ITInspectorCollectionViewController : ITInspectorBaseViewController

@property (nonatomic, strong) ITInspectorBaseViewController *currentInspector;
@property (nonatomic, strong) NSMutableArray *childViewControllers;

- (id)initWithTorrent:(ITTorrent*)torrent;
- (void)segmentControlSwitched:(id)sender;
@end
