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
    return CGSizeMake(35.0f, 35.0f);
}

+ (CGPoint)buttonSpacing
{
    return CGPointMake(5.0f, 5.0f);
}

+ (RZNumberPadDimensions)dimensions
{
    return (RZNumberPadDimensions){4, 5};
}

- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number
{
    [super configureButton:button forNumber:number];

    button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));
    button.layer.borderWidth = 1.0f;
    
    ((UIButton *)button).titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [(UIButton *)button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [(UIButton *)button setTitleColor:[UIColor greenColor] forState:UIControlStateHighlighted];
}

- (void)configureBackButton:(UIView *)button
{
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));

    button.backgroundColor = [UIColor redColor];
}

- (void)configureDoneButton:(UIView *)button
{
    button.layer.cornerRadius = 0.5f * MIN(CGRectGetWidth(button.bounds), CGRectGetHeight(button.bounds));

    button.backgroundColor = [UIColor blueColor];
}

- (NSNumber *)numberForButton:(UIView *)button atIndex:(NSUInteger)index
{
    return @(index);
}

@end
