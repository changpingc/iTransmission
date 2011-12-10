//
//  ITKeyboardController.h
//  iTransmission
//
//  Created by Mike Chen on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _ITKeyboardToolbarOptions {
    ITKeyboardOptionCancel = 1 << 0,
    ITKeyboardOptionDone = 1 << 1, 
    ITKeyboardOptionResetToDefault = 1 << 2,
} ITKeyboardToolbarOptions;

@protocol ITKeyboardControllerDelegate <NSObject>
- (ITKeyboardToolbarOptions)keyboardOptionsForTextField:(UITextField*)textField;
- (BOOL)textFieldCanFinishEditing:(UITextField*)textField withText:(NSString *)string;
- (void)textFieldFinishedEditing:(UITextField*)textField;
- (NSString*)defaultTextForTextField:(UITextField*)textField;
@end

@interface ITKeyboardController : NSObject <UITextFieldDelegate>
@property (nonatomic, strong) UIToolbar *keyboardToolbar;
@property (nonatomic, assign) id<ITKeyboardControllerDelegate> delegate;
@property (nonatomic, retain) UIBarButtonItem *doneButton;
@property (nonatomic, retain) UIBarButtonItem *cancelButton;
@property (nonatomic, retain) UIBarButtonItem *resetToDefaultButton;
@property (nonatomic, assign) UITextField *currentTextField;
@property (nonatomic, strong) NSString *originalText;
- (id)initWithDelegate:(id<ITKeyboardControllerDelegate>)d;
- (void)doneButtonClicked:(id)sender;
- (void)cancelButtonClicked:(id)sender;
- (void)resetToDefaultButtonClicked:(id)sender;
@end
