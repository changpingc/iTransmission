//
//  ITShadowView.h
//  iTransmission
//
//  Created by Mike Chen on 10/26/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum ITShadowDirection {
    ITShadowUnknownDirection = 0,
    ITShadowTopToBottom = 1,
    ITShadowBottomToTop = 2,
} ITShadowDirection;

@interface ITShadowView : UIImageView

@property (nonatomic, strong) UIImage *shadowImage;
@property (nonatomic, assign) ITShadowDirection shadowDirection;

+ (id)shadowImageWithDirection:(ITShadowDirection)direction andHeight:(CGFloat)height;
- (void)update;
- (void)setShadowOpacity:(CGFloat)opacity;

@end
