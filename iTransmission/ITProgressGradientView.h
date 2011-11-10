//
//  ITProgressGradientView.h
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITProgressGradientView : UIView

@property (assign, nonatomic) CGGradientRef gradient;
@property (strong, nonatomic) UIImageView *gradientImageView;
@property (strong, nonatomic) UIImage *gradientImage;

- (void)updateGradientImage;
- (CGGradientRef)createGradientWithBaseColor:(UIColor*)color;
- (CGContextRef)createBitmapContextForSize:(CGSize)size;
- (void)setBaseColor:(UIColor*)color;

@end
