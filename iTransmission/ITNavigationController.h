//
//  ITNavigationController.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITSidebarItemDatasource.h"

@class ITSidebarController;

@interface ITNavigationController : UINavigationController <ITSidebarItemDatasource, UINavigationControllerDelegate>

@property (assign, nonatomic) UIViewController *rootViewController;
@property (strong, nonatomic) ITSidebarItem *sidebarItem;
@property (strong, nonatomic) ITSidebarController *sidebarController;
@property (nonatomic, assign) BOOL useDefaultTheme;
- (UIBarButtonItem*)sidebarButtonItem;
- (void)sidebarButtonItemClicked:(id)sender;

@end
