//
//  ITInfoInspectorViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITInspectorBaseViewController.h"

@interface ITInfoInspectorViewController : ITInspectorBaseViewController

@property (nonatomic, strong) UITableViewCell *nameCell;
@property (nonatomic, strong) UITableViewCell *sizeCell;

- (id)initWithTorrent:(ITTorrent*)torrent;

@end
