//
//  ITColoredProgressView.m
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITColoredProgressView.h"
#import "ITProgressGradientView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ITColoredProgressView
@synthesize style = _style;
@synthesize completedGradientView= _completedGradientView;
@synthesize totalGradientView = _totalGradientView;
@synthesize progress = _progress;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width == 0 ? 200.0f : frame.size.width, frame.size.height == 0 ? 20.0f : frame.size.height)];
    if (self) {
        [self doInitialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInitialization];
    }
    return self;
}

- (void)doInitialization
{
    self.layer.borderWidth = 1.0f;
    self.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    self.style = ITColoredProgressViewStyleGray;
    
    self.totalGradientView = [[ITProgressGradientView alloc] initWithFrame:self.bounds];
    self.totalGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    self.completedGradientView = [[ITProgressGradientView alloc] initWithFrame:self.bounds];
    self.totalGradientView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.totalGradientView];
    [self addSubview:self.completedGradientView];
    [self.totalGradientView setBaseColor:[UIColor colorWithRed:0.95f green:0.95f blue:0.95f alpha:1.0f]];
    [self.completedGradientView setBaseColor:[UIColor colorWithRed:0.7f green:0.7f blue:0.7f alpha:1.0f]];
    
    [self setProgress:0.0f];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    if (progress > 1)
        _progress = 1;
    if (progress < 0)
        _progress = 0;
    
    [self setCompletedGradientViewWidthRatio:self.progress];
}

- (void)setCompletedGradientViewWidthRatio:(CGFloat)ratio
{
    self.completedGradientView.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width * ratio, self.frame.size.height);
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.5f];
    }
    [self setProgress:progress];
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
