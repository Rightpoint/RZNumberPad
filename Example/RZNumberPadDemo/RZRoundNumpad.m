//
//  RZRoundNumpad.m
//  RZNumberPadDemo
//
//  Created by Rob Visentin on 12/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZRoundNumpad.h"

@implementation RZRoundNumpad

+ (CGSize)buttonSize
{
    return CGSizeMake(30.0f, 30.0f);
}

+ (CGPoint)buttonSpacing
{
    return CGPointMake(10.0f, 10.0f);
}

+ (RZNumberPadDimensions)dimensions
{
    return (RZNumberPadDimensions){4, 5};
}

- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number
{
    [super configureButton:button forNumber:number];

    button.backgroundColor = [UIColor lightGrayColor];
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
    
    [(UIButton *)button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [(UIButton *)button setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
}

- (void)configureBackButton:(UIView *)button
{
    button.backgroundColor = [UIColor redColor];
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
    
    [(UIButton *)button setTitle:@"<" forState:UIControlStateNormal];
}

- (void)configureDoneButton:(UIView *)button
{
    button.backgroundColor = [UIColor blueColor];
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
}

- (NSNumber *)numberForButton:(UIView *)button atIndex:(NSUInteger)index
{
    return @(index);
}

@end
