//
//  RZNumberPad.m
//
//  Created by Rob Visentin on 8/12/14.
//

// Copyright 2014 Raizlabs and other contributors
// http://raizlabs.com/
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RZNumberPad.h"

static CGFloat const kRZNumberPadButtonSize = 44.0f;

static NSUInteger const kRZNumberPadRows    = 4;
static NSUInteger const kRZNumberPadCols    = 3;

@interface RZNumberPadTargetActionPair : NSObject
@property (weak, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@end

@implementation RZNumberPadTargetActionPair
@end

@interface RZNumberPad ()

@property (strong, nonatomic) NSMutableArray *numberButtons;

@property (weak, nonatomic) UIControl *doneButton;
@property (weak, nonatomic) UIControl *backButton;

@property (strong, nonatomic) NSMutableDictionary *eventTargets;

@property (strong, nonatomic) NSMutableArray *linkedTextFields;
@property (weak, nonatomic) UITextField *activeTextField;

@end

@implementation RZNumberPad

@synthesize backButton = _backButton;
@synthesize doneButton = _doneButton;

#pragma mark - lifecycle

- (instancetype)initWithFrame:(CGRect)frame
{
    frame.size = [[self class] defaultSize];
    
    self = [super initWithFrame:frame];
    if ( self ) {
        [self commonInit];
        [self configureView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if ( self ) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.showingBackButton = YES;
    self.showingDoneButton = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.bounds = (CGRect){.size = [[self class] defaultSize]};
    
    [self configureView];
}

#pragma mark - public methods

+ (CGSize)defaultSize
{
    // NOTE: The number pad cannot be resized. This size is used on all devices.
    static CGSize defaultSize;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RZNumberPadDimensions dimensons = [self dimensions];
        CGSize buttonSize = [self buttonSize];
        CGPoint buttonSpacing = [self buttonSpacing];
        
        defaultSize.width = dimensons.width * (buttonSize.width + buttonSpacing.x) - buttonSpacing.x;
        defaultSize.height = dimensons.height * (buttonSize.height + buttonSpacing.y) - buttonSpacing.y;
    });
    
    return defaultSize;
}

+ (CGSize)buttonSize
{
    return CGSizeMake(kRZNumberPadButtonSize, kRZNumberPadButtonSize);
}

+ (CGPoint)buttonSpacing
{
    return CGPointZero;
}

+ (RZNumberPadDimensions)dimensions
{
    return (RZNumberPadDimensions){.width = kRZNumberPadCols, .height = kRZNumberPadRows};
}

+ (Class)buttonClass
{
    return [UIButton class];
}

- (void)setBounds:(CGRect)bounds
{
    bounds.size = [[self class] defaultSize];
    
    [super setBounds:bounds];
}

- (void)setFrame:(CGRect)frame
{
    frame.size = [[self class] defaultSize];
    
    [super setFrame:frame];
}

- (CGSize)intrinsicContentSize
{
    return [[self class] defaultSize];
}

- (void)setShowingBackButton:(BOOL)showingBackButton
{
    _showingBackButton = showingBackButton;
    self.backButton.hidden = !showingBackButton;
}

- (void)setShowingDoneButton:(BOOL)showingDoneButton
{
    _showingDoneButton = showingDoneButton;
    self.doneButton.hidden = !showingDoneButton;
}

- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number
{
    if ( number != nil ) {
        UILabel *numLabel = [[UILabel alloc] initWithFrame:button.bounds];
        numLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.adjustsFontSizeToFitWidth = YES;
        numLabel.text = [NSString stringWithFormat:@"%@", number];
        
        [button addSubview:numLabel];
    }
}

- (void)configureDoneButton:(UIView *)doneButton
{
    // subclass override
}

- (void)configureBackButton:(UIView *)backButton
{
    // subclass override
}

- (void)linkToTextField:(UITextField *)textField
{
    if ( textField != nil ) {
        [self.linkedTextFields addObject:textField];
        
        textField.inputView = [[UIView alloc] init];
        
        [textField addTarget:self action:@selector(textFieldDidBeginEditing:) forControlEvents:UIControlEventEditingDidBegin];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        [textField addTarget:self action:@selector(textFieldDidEndEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
    }
}

- (void)linkToTextFields:(NSArray *)array
{
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self linkToTextField:obj];
    }];
}

- (void)unlinkTextField:(UITextField *)textField
{
    [self.linkedTextFields removeObject:textField];
    
    textField.inputView = nil;
    
    [textField removeTarget:self action:NULL forControlEvents:UIControlEventAllEditingEvents];

    if ( textField == self.activeTextField ) {
        self.activeTextField = nil;
    }
}

- (void)unlinkAllTextFields
{
    [[self.linkedTextFields copy] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self unlinkTextField:obj];
    }];
    
    self.activeTextField = nil;
}

- (void)addTarget:(id)target action:(SEL)action forEvents:(RZNumberPadEvents)numberPadEvents
{
    NSParameterAssert(target);
    NSParameterAssert(action);
    
    RZNumberPadTargetActionPair *pair = [[RZNumberPadTargetActionPair alloc] init];
    pair.target = target;
    pair.action = action;
    
    for ( NSUInteger event = 1; event <= RZNumberPadEventAllEvents; event <<= 1 ) {
        if ( (numberPadEvents & event) != 0 ) {
            NSMutableArray *existingPairs = [self.eventTargets objectForKey:@(event)];
            
            if ( existingPairs == nil ) {
                existingPairs = [NSMutableArray array];
                [self.eventTargets setObject:existingPairs forKey:@(event)];
            }
            
            [existingPairs addObject:pair];
        }
    }
}

- (void)removeTarget:(id)target action:(SEL)action forEvents:(RZNumberPadEvents)numberPadEvents
{
    for ( NSUInteger event = 1; event <= RZNumberPadEventAllEvents; event <<= 1 ) {
        if ( (numberPadEvents & event) != 0 ) {
            NSMutableArray *existingPairs = [self.eventTargets objectForKey:@(event)];
            
            NSIndexSet *indexesToRemove = [existingPairs indexesOfObjectsPassingTest:^BOOL(RZNumberPadTargetActionPair *pair, NSUInteger idx, BOOL *stop) {
                return (pair.target == target && (pair.action == action || action == NULL));
            }];
            
            [existingPairs removeObjectsAtIndexes:indexesToRemove];
        }
    }
}

#pragma mark - private methods

- (NSMutableArray *)numberButtons
{
    if ( _numberButtons == nil ) {
        _numberButtons = [NSMutableArray array];
    }
    return _numberButtons;
}

- (NSMutableDictionary *)eventTargets
{
    if ( _eventTargets == nil ) {
        _eventTargets = [NSMutableDictionary dictionary];
    }
    return _eventTargets;
}

- (NSMutableArray *)linkedTextFields
{
    if ( _linkedTextFields == nil ) {
        _linkedTextFields = [NSMutableArray array];
    }
    return _linkedTextFields;
}

- (void)configureView
{
    RZNumberPadDimensions dimensions = [[self class] dimensions];
    CGSize buttonSize = [[self class] buttonSize];
    CGPoint buttonSpacing = [[self class] buttonSpacing];
    
    Class buttonClass = [[self class] buttonClass];
    
    for ( NSUInteger row = 0; row < dimensions.height - 1; row++ ) {
        for ( NSUInteger col = 0; col < dimensions.width; col++ ) {
            CGPoint buttonOrigin = CGPointMake(col * (buttonSize.width + buttonSpacing.x), row * (buttonSize.height + buttonSpacing.y));
            
            CGRect viewFrame = (CGRect){.origin = buttonOrigin, .size = buttonSize};
            UIControl *numButton = [[buttonClass alloc] initWithFrame:viewFrame];
            
            [self configureButton:numButton forNumber:@(1 + row * dimensions.width + col)];
            [numButton addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:numButton];
            [self.numberButtons addObject:numButton];
        }
    }
    
    // handle the last row (with special buttons) separately
    CGFloat lastRowY = (dimensions.height - 1) * (buttonSize.height + buttonSpacing.y);
    
    UIControl *doneButton = [[buttonClass alloc] initWithFrame:CGRectMake(0.0f, lastRowY, buttonSize.width, buttonSize.height)];
    
    [self configureDoneButton:doneButton];
    [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:doneButton];
    self.doneButton = doneButton;
    
    CGRect zeroFrame = CGRectMake(0.5f * (self.bounds.size.width - buttonSize.width), lastRowY, buttonSize.width, buttonSize.height);
    UIControl *zeroButton = [[buttonClass alloc] initWithFrame:zeroFrame];
    
    [self configureButton:zeroButton forNumber:@(0)];
    [zeroButton addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:zeroButton];
    [self.numberButtons insertObject:zeroButton atIndex:0];
    
    CGRect backFrame = CGRectMake(CGRectGetWidth(self.bounds) - buttonSize.width, lastRowY, buttonSize.width, buttonSize.height);
    UIControl *backButton = [[buttonClass alloc] initWithFrame:backFrame];
    
    [self configureBackButton:backButton];
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:backButton];
    self.backButton = backButton;
    
    self.backButton.hidden = self.isShowingBackButton;
    self.doneButton.hidden = self.isShowingDoneButton;
}

- (void)numberButtonPressed:(UIControl *)sender
{
    NSUInteger buttonIndex = [self.numberButtons indexOfObject:sender];
    
    if ( self.activeTextField != nil ) {
        [self replaceRange:[self textFieldSelectedRange:self.activeTextField] withString:[NSString stringWithFormat:@"%@", @(buttonIndex)]];
    }
    
    if ( buttonIndex < [self.numberButtons count] ) {
        [self sendActionsForEvents:RZNumberPadEventKeypress object:@(buttonIndex)];
    }
}

- (void)doneButtonPressed
{
    [self.activeTextField.delegate textFieldShouldReturn:self.activeTextField];
    
    [self sendActionsForEvents:RZNumberPadEventDone object:nil];
}

- (void)backButtonPressed
{
    if ( self.activeTextField != nil ) {
        
        NSRange deleteRange = [self textFieldSelectedRange:self.activeTextField];
        
        if ( deleteRange.length == 0 && deleteRange.location > 0 ) {
            deleteRange.location -= 1;
            deleteRange.length = 1;
        }
        
        [self replaceRange:deleteRange withString:@""];
    }
    
    [self sendActionsForEvents:RZNumberPadEventBack object:nil];
}

- (void)sendActionsForEvents:(RZNumberPadEvents)events object:(id)object;
{
    for ( NSUInteger event = 1; event <= RZNumberPadEventAllEvents; event <<= 1 ) {
        if ( (events & event) != 0 ) {
            NSMutableArray *existingPairs = [self.eventTargets objectForKey:@(event)];
            
            [[existingPairs copy] enumerateObjectsUsingBlock:^(RZNumberPadTargetActionPair *pair, NSUInteger idx, BOOL *stop) {
                NSMethodSignature *signature = [pair.target methodSignatureForSelector:pair.action];
                
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                [invocation setTarget:pair.target];
                [invocation setSelector:pair.action];
                
                if ( signature.numberOfArguments > 2 ) {
                    __unsafe_unretained id arg = object;
                    [invocation setArgument:&arg atIndex:2];
                }
                
                [invocation invoke];
            }];
        }
    }
}

#pragma mark - linked text field methods

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.activeTextField = textField;
    
    if ( textField.enablesReturnKeyAutomatically ) {
        self.showingDoneButton = ([textField.text length] > 0);
    }
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if ( textField == self.activeTextField && textField.enablesReturnKeyAutomatically ) {
        self.showingDoneButton = ([textField.text length] > 0);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ( textField == self.activeTextField ) {
        self.activeTextField = nil;
        
        if ( textField.enablesReturnKeyAutomatically ) {
            self.showingDoneButton = NO;
        }
    }
}

- (NSRange)textFieldSelectedRange:(UITextField *)textField
{
    UITextRange *selectedRange = textField.selectedTextRange;
    NSUInteger loc = [textField offsetFromPosition:textField.beginningOfDocument toPosition:selectedRange.start];
    NSUInteger len = [textField offsetFromPosition:selectedRange.start toPosition:selectedRange.end];

    return NSMakeRange(loc, len);
}

- (void)replaceRange:(NSRange)range withString:(NSString *)string
{
    UITextField *textField = self.activeTextField;
    BOOL responds = [textField.delegate respondsToSelector:@selector(textField:shouldChangeCharactersInRange:replacementString:)];
    
    if ( !responds || (responds && [textField.delegate textField:textField shouldChangeCharactersInRange:range replacementString:string]) ) {
        UITextPosition *start = [textField positionFromPosition:textField.beginningOfDocument offset:range.location];
        UITextPosition *end = [textField positionFromPosition:start offset:range.length];
        
        UITextRange *replaceRange = [textField textRangeFromPosition:start toPosition:end];
        
        [textField replaceRange:replaceRange withText:string];
    }
}

@end
