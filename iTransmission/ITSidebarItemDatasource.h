//
//  ITSidebarItemDatasource.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ITSidebarItem;

@protocol ITSidebarItemDatasource <NSObject>

- (ITSidebarItem*)sidebarItem;

@end
