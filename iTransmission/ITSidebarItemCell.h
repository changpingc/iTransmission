//
//  ITSidebarItemCell.h
//  iTransmission
//
//  Created by Mike Chen on 10/22/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ITSidebarItemCell : UITableViewCell

@property (strong, nonatomic) CAGradientLayer *topShadow;
@property (strong, nonatomic) CAGradientLayer *bottomShadow;

@property (nonatomic, assign, getter = isFirstCell) BOOL firstCell;
@end
