//
//  ITSidebarItemCell.m
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITSidebarItemCell.h"
#import <QuartzCore/QuartzCore.h>

#define SHADOW_HEIGHT 20.0
#define SHADOW_INVERSE_HEIGHT 10.0
#define SHADOW_RATIO (SHADOW_INVERSE_HEIGHT / SHADOW_HEIGHT)

@interface ITSidebarItemCell (Private)
@end

@implementation ITSidebarItemCell
@synthesize topShadow = _topShadow;
@synthesize bottomShadow = _bottomShadow;
@synthesize firstCell = _firstCell;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = [UIFont boldSystemFontOfSize:17.0f];
        self.textLabel.shadowColor = [UIColor grayColor];
        self.textLabel.shadowOffset = CGSizeMake(-1, -1);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(0, 0, 29, 29);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(contextRef, 0.2f);
    CGContextSetStrokeColorWithColor(contextRef, [[UIColor colorWithWhite:0.0f alpha:0.8f] CGColor]);
//    if ([self isFirstCell]) {
//        CGPoint topLine[] = {
//            {rect.origin.x, rect.origin.y+1}, {rect.origin.x + rect.size.width, rect.origin.y+1}
//        };
//        CGContextStrokeLineSegments(contextRef, topLine, 2);
//    }
    CGPoint bottomLine[] = {
        {rect.origin.x, rect.origin.y + rect.size.height-1}, {rect.origin.x + rect.size.width, rect.origin.y + rect.size.height-1}
    };
    CGContextStrokeLineSegments(contextRef, bottomLine, 1);
}

@end
