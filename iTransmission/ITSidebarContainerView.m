//
//  ITSidebarContainerView.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ITSidebarContainerView.h"

@implementation ITSidebarContainerView

@synthesize horizontalShift = _horizontalShift;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(-20, 0);
        self.layer.shadowRadius = 20;
        self.layer.shadowOpacity = 0.5;
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
        self.horizontalShift = 0;
    }
    return self;
}

@end
