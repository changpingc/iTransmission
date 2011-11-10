//
//  ITVerticalLinearGradientView.m
//  iTransmission
//
//  Created by Mike Chen on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITVerticalLinearGradientView.h"

@implementation ITVerticalLinearGradientView
@synthesize gradientLayer = _gradientLayer;

- (id)initWithGradientColorTop:(UIColor*)topColor bottom:(UIColor*)bottomColor
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.gradientLayer = [[CAGradientLayer alloc] init];
        self.gradientLayer.colors = [NSArray arrayWithObjects:(id)[topColor CGColor], (id)[bottomColor CGColor], nil];
        [self.layer insertSublayer:self.gradientLayer atIndex:0];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.gradientLayer setFrame:self.bounds];
}

@end
