//
//  ITPrefViewController.h
//  iTransmission
//
//  Created by Mike Chen on 12/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITKeyboardController.h"

@interface ITPrefViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, ITKeyboardControllerDelegate>

@property (nonatomic, strong) ITKeyboardController *keyboardController;
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
@property (nonatomic, strong) IBOutlet UITableViewCell *openWebInterfaceCell;
@property (nonatomic, strong) IBOutlet UISwitch *enableRPCSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *enableRPCAuthenticationSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *useWiFiSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *useMobileSwitch;
@property (nonatomic, strong) IBOutlet UISwitch *enablePortMapSwitch;
@property (nonatomic, strong) IBOutlet UITextField *RPCPortTextField;
@property (nonatomic, strong) IBOutlet UITextField *bindPortTextField;
@property (nonatomic, strong) IBOutlet UITextView *webInterfaceURLTextView;
- (void)registerNotifications;

- (IBAction)enableRPCValueChanged:(id)sender;
- (IBAction)enableRPCAuthenticationValueChanged:(id)sender;
- (IBAction)useWiFiValueChanged:(id)sender;
- (IBAction)useMobileValueChanged:(id)sender;
- (IBAction)enablePortMapValueChanged:(id)sender;

- (void)preferencesUpdateNotificationReceived:(NSNotification*)notification;

@end
