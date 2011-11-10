//
//  ShadowedTableView.h
//  ShadowedTableView
//
//  Created by Matt Gallagher on 2009/08/21.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class ITShadowView;

@interface ITShadowedTableView : UITableView
@property (strong, nonatomic) ITShadowView *originShadow;
@property (strong, nonatomic) CAGradientLayer *topShadow;
@property (strong, nonatomic) CAGradientLayer *bottomShadow;

@end
