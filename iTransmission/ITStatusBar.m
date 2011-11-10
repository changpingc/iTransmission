//
//  ITStatusBar.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITStatusBar.h"
#import <QuartzCore/QuartzCore.h>

@implementation ITStatusBar

@synthesize gradientView = _gradientView;
@synthesize uploadSpeedLabel = _uploadSpeedLabel;
@synthesize downloadSpeedLabel = _downloadSpeedLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.gradientView = [[ITVerticalLinearGradientView alloc] initWithGradientColorTop:[UIColor colorWithWhite:0.5f alpha:1.0f] bottom:[UIColor colorWithWhite:0.35f alpha:1.0f]];
    [self insertSubview:self.gradientView atIndex:0];
}

- (void)layoutSubviews
{
    [self.gradientView setFrame:CGRectMake(0.0f, 1.0f, self.bounds.size.width, self.bounds.size.height - 1.0f)];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetStrokeColorWithColor(contextRef, [[UIColor blackColor] CGColor]);
    CGPoint points[] = {
        {rect.origin.x, rect.origin.y}, {rect.origin.x + rect.size.width, rect.origin.y}
    };
    CGContextStrokeLineSegments(contextRef, points, 2);
}

@end
