//
//  ITApplication.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITApplication.h"

BOOL __isInSandbox = YES;

@implementation ITApplication

+ (void)setExecutionPath:(const char *)path
{
    if (strncmp(path, "/Applications/", sizeof("/Applications/") == 0)) {
        __isInSandbox = NO;
    }
    else {
        __isInSandbox = YES;
    }
}

+ (BOOL)isRunningInSandbox
{
    return __isInSandbox;
}

+ (NSString*)defaultDocumentsPath
{
    if ([ITApplication isRunningInSandbox]) 
        return [ITApplication sandboxeDocumentsPath];
    else 
        return [ITApplication homeDocumentsPath];
}

+ (NSString*)sandboxeDocumentsPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (NSString*)homeDocumentsPath
{
    return @"/private/var/mobile/Documents/iTransmission";
}

+ (NSString*)applicationPath
{
    return [[NSBundle mainBundle] resourcePath];
}

@end
