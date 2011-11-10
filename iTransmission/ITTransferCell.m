;//
//  ITTransferCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITTransferCell.h"
#import "ITColoredProgressView.h"
#import "ITRoundProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "ITShadowView.h"
#import "ITVerticalLinearGradientView.h"

// Background gradient: 0.95, 0.85, 

@implementation ITTransferCell

@synthesize sizeLabel = _sizeLabel;
@synthesize titleLabel = _titleLabel;
@synthesize descriptionLabel = _descriptionLabel;
@synthesize linearProgressView = _linearProgressView;
@synthesize roundProgressView = _roundProgressView;
@synthesize topShadow = _topShadow;
@synthesize bottomShadow = _bottomShadow;
@synthesize topBorder, bottomBorder;

- (void)awakeFromNib
{
    UIColor *topColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
    UIColor *bottomColor = [UIColor colorWithWhite:0.85f alpha:1.0f];
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = [[ITVerticalLinearGradientView alloc] initWithGradientColorTop:topColor bottom:bottomColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.topShadow setShadowOpacity:0.0f];
    [self.topShadow setShadowDirection:ITShadowTopToBottom];
    [self.bottomShadow setShadowOpacity:0.0f];
    [self.bottomShadow setShadowDirection:ITShadowBottomToTop];
    [self.topBorder removeFromSuperview];
    [self addSubview:self.topBorder];
    [self.bottomBorder removeFromSuperview];
    [self addSubview:self.bottomBorder];
    self.topBorder.layer.zPosition = 1;
    self.bottomBorder.layer.zPosition = 1;
//    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

+ (NSString *)identifier
{
    static NSString *identifier = @"ITTransferCell";
    return identifier;
}

+ (CGFloat)defaultHeight
{
    return 64.0f;
}

+ (CGFloat)extendedHeight
{
    return 64.0f;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:YES];
    
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.8f];
    }
    
    if (self.selected) {
        [self.topShadow setShadowOpacity:0.5f];
        [self.bottomShadow setShadowOpacity:0.5f];
    }
    else {
        [self.topShadow setShadowOpacity:0.0f];
        [self.bottomShadow setShadowOpacity:0.0f];
    }
    
    if (animated)
        [UIView commitAnimations];
}

@end
