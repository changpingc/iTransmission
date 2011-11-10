//
//  ITTimerListener.h
//  iTransmission
//
//  Created by Mike Chen on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ITTimerListener <NSObject>

- (void)timerFiredAfterDelay:(NSTimeInterval)timeInternalSinceLastCall;

@end
