//
//  ITColoredProgressView.h
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum _ITColoredProgressViewStyle 
{
    ITColoredProgressViewStyleGray,
} ITColoredProgressViewStyle;

@class ITProgressGradientView;

@interface ITColoredProgressView : UIView

@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, strong) ITProgressGradientView *completedGradientView;
@property (nonatomic, strong) ITProgressGradientView *totalGradientView;
@property (nonatomic, assign) ITColoredProgressViewStyle style;

- (void)doInitialization;
- (void)setCompletedGradientViewWidthRatio:(CGFloat)ratio;
- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
