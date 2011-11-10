//
//  ITVerticalLinearGradientView.h
//  iTransmission
//
//  Created by Mike Chen on 10/24/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ITVerticalLinearGradientView : UIView

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

- (id)initWithGradientColorTop:(UIColor*)topColor bottom:(UIColor*)bottomColor;

@end
