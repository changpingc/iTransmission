//
//  ITPreferencePanelViewController.h
//  iTransmission
//
//  Created by Mike Chen on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITPreferencePanelViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, strong) UITableView *tableView;

- (void)setupTableContent;
- (void)callSetupTableContent;
- (void)setTableContentReloadNeeded;

@end
