//
//  main.m
//  iTransmission
//
//  Created by Mike Chen on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ITAppDelegate.h"
#import "ITApplication.h"

int main(int argc, char *argv[])
{
    [ITApplication setExecutionPath:argv[0]];
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([ITAppDelegate class]));
    }
}
