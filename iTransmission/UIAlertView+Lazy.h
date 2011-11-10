//
//  UIAlertView+Lazy.h
//  iTransmission
//
//  Created by Mike Chen on 11/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Lazy)
+ (void)showMessageWithDismissButton:(NSString*)message;
@end
