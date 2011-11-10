//
//  ITInspectorCollectionView.m
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITInspectorCollectionView.h"
#import "ITInspectorCollectionTabBar.h"
#import "SVSegmentedControl.h"

@implementation ITInspectorCollectionView
@synthesize contentView = _contentView;
@synthesize tabBar = _tabBar;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView = [[UIView alloc] initWithFrame:self.bounds];
        [self addSubview:self.contentView];
    }
    return self;
}

- (void)layoutSubviews
{
    self.contentView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height - self.tabBar.bounds.size.height);
    [[[self.contentView subviews] objectAtIndex:0] setFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height - self.tabBar.bounds.size.height)];
    self.tabBar.frame = CGRectMake(0.0f, self.bounds.size.height - self.tabBar.segmentedControl.height - 4.0f, self.bounds.size.width, self.tabBar.segmentedControl.height + 4.0f);
}

@end
