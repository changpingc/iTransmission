
//
//  ITTouchRecognizer.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITTouchRecognizer.h"

@implementation ITTouchRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateRecognized;
}

@end
