//
//  ITInspectorCollectionView.h
//  iTransmission
//
//  Created by Mike Chen on 10/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ITInspectorCollectionTabBar;

@interface ITInspectorCollectionView : UIView
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ITInspectorCollectionTabBar *tabBar;
@end
