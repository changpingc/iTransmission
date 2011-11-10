//
//  NSArray+iTransmissionUtility.m
//  iTransmission
//
//  Created by Mike Chen on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "NSArray+iTransmissionUtility.h"

@implementation NSArray (iTransmissionUtility)

- (id)firstObjectOrNil
{
    if ([self count] > 0) return [self objectAtIndex:0];
    return nil;
}

@end
