//
//  ITWebViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVWebViewController.h"
#import "ITSidebarItemDatasource.h"

@interface ITWebViewController : SVWebViewController <ITSidebarItemDatasource>

@property (nonatomic, strong) ITSidebarItem *sidebarItem;

- (id)init;
- (void)navigateToURL:(NSURL*)url;
@end
