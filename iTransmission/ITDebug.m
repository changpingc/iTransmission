//
//  ITDebug.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITDebug.h"

void ITLogCGRect(CGRect rect)
{
    LogMessageCompat(@"Rect x: %f.2\ty: %f.2\twidth: %f.2\theight: %f.2\n", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}