//
//  ITInspectorCollectionTabBar.m
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITInspectorCollectionTabBar.h"
#import "SVSegmentedControl.h"

@implementation ITInspectorCollectionTabBar
@synthesize segmentedControl;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [self.segmentedControl setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
}

@end
