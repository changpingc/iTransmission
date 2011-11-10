//
//  ITFileInspectorCell.h
//  iTransmission
//
//  Created by Mike Chen on 11/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITRoundProgressView;

@interface ITFileInspectorCell : UITableViewCell

@property (strong, nonatomic) IBOutlet ITRoundProgressView *progressView;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UIButton *checkmarkControl;
@property (strong, nonatomic) IBOutlet UIView *checkmarkSeperator;

@end
