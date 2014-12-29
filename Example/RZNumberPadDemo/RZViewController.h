//
//  RZViewController.h
//  RZNumberPadDemo
//
//  Created by Rob Visentin on 12/12/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

@import UIKit;
#import "RZMultipleNumpad.h"

@interface RZViewController : UIViewController <UITextFieldDelegate>

@property (copy, nonatomic) IBOutletCollection(UITextField) NSArray *textFields;
@property (weak, nonatomic) IBOutlet  RZMultipleNumpad *multiplePad;

@end

