//
//  ITKeyboardController.m
//  iTransmission
//
//  Created by Mike Chen on 12/10/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ITKeyboardController.h"

@implementation ITKeyboardController
@synthesize doneButton;
@synthesize cancelButton;
@synthesize resetToDefaultButton;
@synthesize keyboardToolbar = _keyboardToolbar;
@synthesize delegate = _delegate;
@synthesize currentTextField;
@synthesize originalText;

- (id)initWithDelegate:(id<ITKeyboardControllerDelegate>)d
{
    if ((self = [super init])) {
        self.delegate = d;
        self.keyboardToolbar = [[UIToolbar alloc] init];
        [self.keyboardToolbar sizeToFit];
        self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        self.doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonClicked:)];
        self.resetToDefaultButton = [[UIBarButtonItem alloc] initWithTitle:@"Reset Default" style:UIBarButtonItemStyleBordered target:self action:@selector(resetToDefaultButtonClicked:)];
        self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonClicked:)];
    }
    return self;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.keyboardToolbar sizeToFit];
    textField.inputAccessoryView = self.keyboardToolbar;
    
    ITKeyboardToolbarOptions options = [self.delegate keyboardOptionsForTextField:textField];
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:4];
    if (options & ITKeyboardOptionCancel) {
        [buttons addObject:self.cancelButton];
    }
    if (options & ITKeyboardOptionResetToDefault) {
        [buttons addObject:self.resetToDefaultButton];
    }
    [buttons addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil]];
    if (options & ITKeyboardOptionDone) {
        [buttons addObject:self.doneButton];
    }
    
    self.keyboardToolbar.items = buttons;
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([self.delegate textFieldCanFinishEditing:textField withText:newText]) {
        self.doneButton.enabled = YES;
    }
    else {
        self.doneButton.enabled = NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.currentTextField = textField;
    self.originalText = textField.text;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.currentTextField = nil;
    [self.delegate textFieldFinishedEditing:textField];
}

- (void)doneButtonClicked:(id)sender
{
    [self.currentTextField resignFirstResponder];
    self.originalText = nil;
}

- (void)cancelButtonClicked:(id)sender
{
    [self.currentTextField setText:self.originalText];
    [self.currentTextField resignFirstResponder];
}

- (void)resetToDefaultButtonClicked:(id)sender
{
    NSString *defaultText = [self.delegate defaultTextForTextField:self.currentTextField];
    assert(defaultText);
    [self.currentTextField setText:defaultText];
}

@end
