//
//  RZRoundNumpad.m
//  RZNumberPadDemo
//
//  Created by Rob Visentin on 12/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZRoundNumpad.h"

@implementation RZRoundNumpad

+ (CGPoint)buttonSpacing
{
    return CGPointMake(15.0f, 15.0f);
}

+ (RZNumberPadDimensions)dimensions
{
    return (RZNumberPadDimensions){3, 6};
}

- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number
{
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
    
    [(UIButton *)button setTitle:[number stringValue] forState:UIControlStateNormal];
    [(UIButton *)button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)configureBackButton:(UIView *)button
{
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
}

- (void)configureDoneButton:(UIView *)button
{
    button.backgroundColor = [UIColor greenColor];
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
}

@end
