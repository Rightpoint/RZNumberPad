//
//  RZSquareNumpad.m
//  RZNumberPadDemo
//
//  Created by Rob Visentin on 12/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZSquareNumpad.h"

@implementation RZSquareNumpad

+ (CGSize)buttonSize
{
    return CGSizeMake(40.0f, 35.0f);
}

+ (CGPoint)buttonSpacing
{
    return CGPointMake(1.0f, 1.0f);
}

- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number
{
    [super configureButton:button forNumber:number];

    button.backgroundColor = [UIColor darkGrayColor];
    
    [(UIButton *)button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [(UIButton *)button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

- (void)configureBackButton:(UIView *)button
{
    button.backgroundColor = [UIColor redColor];
}

- (void)configureDoneButton:(UIView *)button
{
    button.backgroundColor = [UIColor blueColor];
}

@end
