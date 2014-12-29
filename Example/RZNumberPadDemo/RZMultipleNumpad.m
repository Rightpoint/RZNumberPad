//
//  RZMultipleNumpad.m
//  RZNumberPadDemo
//
//  Created by Rob Visentin on 12/29/14.
//  Copyright (c) 2014 Raizlabs. All rights reserved.
//

#import "RZMultipleNumpad.h"

@implementation RZMultipleNumpad

+ (CGSize)buttonSize
{
    return CGSizeMake(30.0f, 30.0f);
}

+ (CGPoint)buttonSpacing
{
    return CGPointMake(-1.0f, -1.0f);
}

+ (RZNumberPadDimensions)dimensions
{
    return (RZNumberPadDimensions){11, 2};
}

- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number
{
    [super configureButton:button forNumber:number];

    [self configureButtonCommon:(UIButton *)button];
    button.backgroundColor = [UIColor blackColor];

    ((UIButton *)button).titleLabel.font = [UIFont systemFontOfSize:12.0f];
}

- (void)configureDoneButton:(UIView *)button
{
    [self configureButtonCommon:(UIButton *)button];
    button.backgroundColor = [UIColor redColor];
    
    [(UIButton *)button setTitle:@"-" forState:UIControlStateNormal];
}

- (void)configureBackButton:(UIView *)button
{
    [self configureButtonCommon:(UIButton *)button];
    button.backgroundColor = [UIColor greenColor];
    
    [(UIButton *)button setTitle:@"+" forState:UIControlStateNormal];
}

- (NSNumber *)numberForButton:(UIView *)button atIndex:(NSUInteger)index
{
    return @(self.multiple * (index + 1));
}

- (void)setMultiple:(NSInteger)multiple
{
    multiple = MAX(0, multiple);
    _multiple = multiple;
    
    [self reloadButtons];
}

#pragma mark - private methods

- (void)configureButtonCommon:(UIButton *)button
{
    button.layer.borderColor = [UIColor redColor].CGColor;
    button.layer.borderWidth = 1.0f;
    
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
}

@end
