//
//  ITFileInspectorCell.m
//  iTransmission
//
//  Created by Mike Chen on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITFileInspectorCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ITFileInspectorCell
@synthesize checkmarkSeperator = _checkmarkSeperator;
@synthesize checkmarkControl = _checkmarkControl;
@synthesize nameLabel = _nameLabel;
@synthesize progressView = _progressView;

- (void)awakeFromNib
{
    [self.checkmarkSeperator removeFromSuperview];
    [self addSubview:self.checkmarkSeperator];
    self.checkmarkSeperator.layer.zPosition = 1;
    /* this does the trick */
    [self.checkmarkControl removeFromSuperview];
    [self insertSubview:self.checkmarkControl atIndex:1];
    [self.checkmarkSeperator setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [self.checkmarkSeperator setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    if (selected)
        [self.nameLabel setTextColor:[UIColor whiteColor]];
    else 
        [self.nameLabel setTextColor:[UIColor blackColor]];
    [super setSelected:selected animated:animated];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self.checkmarkSeperator setBackgroundColor:[UIColor colorWithWhite:0.8f alpha:1.0f]];
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted)
        [self.nameLabel setTextColor:[UIColor whiteColor]];
    else 
        [self.nameLabel setTextColor:[UIColor blackColor]];
}

@end
