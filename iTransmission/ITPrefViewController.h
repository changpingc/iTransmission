//
//  ITPrefViewController.h
//  iTransmission
//
//  Created by Mike Chen on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ITPrefViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UITableViewCell *enableRPCCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *enableRPCAuthenticationCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *useWiFiCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *useMobileCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *enablePortMapCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *RPCPortCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *RPCUsernameCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *RPCPasswordCell;
@property (nonatomic, strong) IBOutlet UITableViewCell *bindPortCell;
@property (nonatomic, strong) IBOutlet UISwitch *enableRPCSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *enableRPCAuthenticationSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *useWiFiSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *useMobileSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *enablePortMapSwitch;

- (void)registerNotifications;

- (IBAction)enableRPCValueChanged:(id)sender;
- (IBAction)enableRPCAuthenticationValueChanged:(id)sender;
- (IBAction)useWiFiValueChanged:(id)sender;
- (IBAction)useMobileValueChanged:(id)sender;
- (IBAction)enablePortMapValueChanged:(id)sender;

- (void)preferencesUpdateNotificationReceived:(NSNotification*)notification;

@end
