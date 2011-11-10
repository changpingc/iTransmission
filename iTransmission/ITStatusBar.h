//
//  ITStatusBar.h
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITRoundCornerView.h"
#import "ITVerticalLinearGradientView.h"

@interface ITStatusBar : ITRoundCornerView

@property (strong, nonatomic) ITVerticalLinearGradientView *gradientView;
@property (nonatomic, strong) IBOutlet UILabel *uploadSpeedLabel;
@property (nonatomic, strong) IBOutlet UILabel *downloadSpeedLabel;

@end
