//
//  UIAlertView+Lazy.m
//  iTransmission
//
//  Created by Mike Chen on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "UIAlertView+Lazy.h"

@implementation UIAlertView (Lazy)

+ (void)showMessageWithDismissButton:(NSString*)message
{
    [[[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] show];
}

@end
