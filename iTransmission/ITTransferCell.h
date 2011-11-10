//
//  ITTransferCell.h
//  iTransmission
//
//  Created by Mike Chen on 10/23/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITColoredProgressView;
@class ITRoundProgressView;
@class ITShadowView;

@interface ITTransferCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *sizeLabel;
@property (strong, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) IBOutlet ITShadowView *topShadow;
@property (strong, nonatomic) IBOutlet ITShadowView *bottomShadow;
@property (strong, nonatomic) IBOutlet ITColoredProgressView *linearProgressView;
@property (strong, nonatomic) IBOutlet ITRoundProgressView *roundProgressView;
@property (strong, nonatomic) IBOutlet UIView *topBorder;
@property (strong, nonatomic) IBOutlet UIView *bottomBorder;

+ (NSString*)identifier;
+ (CGFloat)defaultHeight;
+ (CGFloat)extendedHeight;

@end
