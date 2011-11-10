//
//  ITApplication.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITApplication : NSObject

+ (void)setExecutionPath:(const char *)path;
+ (BOOL)isRunningInSandbox;
+ (NSString*)defaultDocumentsPath;
+ (NSString*)sandboxeDocumentsPath;
+ (NSString*)homeDocumentsPath;
+ (NSString*)applicationPath;
@end
