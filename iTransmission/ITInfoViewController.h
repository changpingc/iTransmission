//
//  ITInfoViewController.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITSidebarItemDatasource.h"

@interface ITInfoViewController : UIViewController <UIWebViewDelegate, ITSidebarItemDatasource>
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSString *pageName;
@property (nonatomic, strong) ITSidebarItem *sidebarItem;
- (id)initWithPageName:(NSString*)p;
@end
