//
//  ITSidebar.h
//  iTransmission
//
//  Created by Mike Chen on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITShadowView;

@interface ITSidebar : UIView

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet ITShadowView *shadowView;

+ (id)sidebarFromNib;

@end
