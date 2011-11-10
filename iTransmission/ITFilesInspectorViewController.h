//
//  ITFilesInspectorViewController.h
//  iTransmission
//
//  Created by Mike Chen on 11/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ITInspectorBaseViewController.h"

@interface ITFilesInspectorViewController : ITInspectorBaseViewController <UITableViewDelegate, UITableViewDataSource, UIDocumentInteractionControllerDelegate>
@property (strong, nonatomic) UIDocumentInteractionController *interactionController;
- (void)checkmarkControlTapped:(id)sender;
- (void)torrentUpdated:(NSNotification*)notification;
@end
