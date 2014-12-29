//
//  RZViewController.m
//  RZNumberPadDemo
//
//  Created by Rob Visentin on 12/12/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZViewController.h"

@interface RZViewController ()

@property (weak, nonatomic) UITextField *activeField;

@end

@implementation RZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textFields enumerateObjectsUsingBlock:^(UITextField *field, NSUInteger idx, BOOL *stop) {
        field.clearButtonMode = UITextFieldViewModeWhileEditing;
    }];
    
    self.multiplePad.multiple = 2;
    
    [self.multiplePad addTarget:self action:@selector(decrementMultiple) forEvents:RZNumberPadEventDone];
    [self.multiplePad addTarget:self action:@selector(incrementMultiple) forEvents:RZNumberPadEventBack];
    [self.multiplePad addTarget:self action:@selector(multiplePressed:) forEvents:RZNumberPadEventKeypress];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textFields[0] becomeFirstResponder];
}

- (void)decrementMultiple
{
    self.multiplePad.multiple--;
}

- (void)incrementMultiple
{
    self.multiplePad.multiple++;
}

- (void)multiplePressed:(NSNumber *)multiple
{
    self.activeField.text = [self.activeField.text stringByAppendingString:[multiple stringValue]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSUInteger nextField = ([self.textFields indexOfObject:textField] + 1) % self.textFields.count;
    
    [self.textFields[nextField] becomeFirstResponder];
    
    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeField = textField;
}

@end
