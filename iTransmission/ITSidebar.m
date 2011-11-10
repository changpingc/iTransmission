//
//  ITSidebar.m
//  iTransmission
//
//  Created by Mike Chen on 10/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITSidebar.h"
#import "ITShadowView.h"

@implementation ITSidebar

@synthesize tableView = _tableView;
@synthesize shadowView = _shadowView;

+ (id)sidebarFromNib
{
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:@"ITSidebar" owner:nil options:nil];
    if ([objects count]) return [objects objectAtIndex:0];
    return nil;
}

- (void)awakeFromNib
{
    UIImageView *tableViewBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sidebar-bg.png"]];
    self.tableView.backgroundView = tableViewBackground;
    self.shadowView.shadowDirection = ITShadowBottomToTop;
    [self.shadowView setShadowOpacity:0.5f];
}

@end
