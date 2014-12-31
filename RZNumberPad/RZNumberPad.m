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

@property (strong, nonatomic) NSMutableOrderedSet *linkedTextFields;
@property (weak, nonatomic) UITextField *activeTextField;

// for setting linked text fields via IB
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *outputTextFields;

@end

@implementation RZNumberPad

@synthesize backButton = _backButton;
@synthesize doneButton = _doneButton;

#pragma mark - lifecycle

+ (void)initialize
{
    NSAssert([[self buttonClass] isSubclassOfClass:[UIControl class]], @"%@ button class must be a subclass of UIControl.", NSStringFromClass([RZNumberPad class]));
}

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
    _showingBackButton = YES;
    _showingDoneButton = YES;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.bounds = (CGRect){.size = [[self class] defaultSize]};
    
    [self configureView];
    
    if ( self.outputTextFields != nil ) {
        [self linkToTextFields:self.outputTextFields];
        self.outputTextFields = nil;
    }
}

#pragma mark - public methods

+ (CGSize)defaultSize
{
    // NOTE: The number pad cannot be resized. This size is used on all devices.
    CGSize defaultSize;
    
    RZNumberPadDimensions dimensons = [self dimensions];
    CGSize buttonSize = [self buttonSize];
    CGPoint buttonSpacing = [self buttonSpacing];
    
    defaultSize.width = dimensons.width * (buttonSize.width + buttonSpacing.x) - buttonSpacing.x;
    defaultSize.height = dimensons.height * (buttonSize.height + buttonSpacing.y) - buttonSpacing.y;
    
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
        NSString *numString = [number stringValue];
        
        if ( [button isKindOfClass:[UIButton class]] ) {
            [(UIButton *)button setTitle:numString forState:UIControlStateNormal];
            [(UIButton *)button setTitle:numString forState:UIControlStateHighlighted];
        }
        else {
            UILabel *numLabel = [[UILabel alloc] initWithFrame:button.bounds];
            numLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            numLabel.textAlignment = NSTextAlignmentCenter;
            numLabel.adjustsFontSizeToFitWidth = YES;
            numLabel.text = numString;
            
            [button addSubview:numLabel];
        }
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

- (NSNumber *)numberForButton:(UIView *)button atIndex:(NSUInteger)index
{
    return @((index + 1) % self.numberButtons.count);
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

- (void)reloadButtons
{
    [self.numberButtons enumerateObjectsUsingBlock:^(UIControl *btn, NSUInteger idx, BOOL *stop) {
        NSNumber *num = [self numberForButton:btn atIndex:idx];
        [self configureButton:btn forNumber:num];
    }];
    
    [self configureDoneButton:self.doneButton];
    [self configureBackButton:self.backButton];
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

- (NSMutableOrderedSet *)linkedTextFields
{
    if ( _linkedTextFields == nil ) {
        _linkedTextFields = [NSMutableOrderedSet orderedSet];
    }
    return _linkedTextFields;
}

- (void)configureView
{
    RZNumberPadDimensions dimensions = [[self class] dimensions];
    CGSize buttonSize = [[self class] buttonSize];
    CGPoint buttonSpacing = [[self class] buttonSpacing];
    
    Class buttonClass = [[self class] buttonClass];
    
    // handle the last row (with special buttons) separately
    CGFloat lastRowY = (dimensions.height - 1) * (buttonSize.height + buttonSpacing.y);
    
    for ( NSUInteger row = 0; row < dimensions.height - 1; row++ ) {
        for ( NSUInteger col = 0; col < dimensions.width; col++ ) {
            CGPoint buttonOrigin = CGPointMake(col * (buttonSize.width + buttonSpacing.x), row * (buttonSize.height + buttonSpacing.y));
            
            CGRect viewFrame = (CGRect){.origin = buttonOrigin, .size = buttonSize};
            UIControl *numButton = [[buttonClass alloc] initWithFrame:viewFrame];
            
            [numButton addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            [self addSubview:numButton];
            [self.numberButtons addObject:numButton];
        }
    }
    
    // take care of the last row of number buttons
    for ( NSUInteger col = 0; col + 2 < dimensions.width; col++ ) {
        CGPoint buttonOrigin = CGPointMake((col + 1) * (buttonSize.width + buttonSpacing.x), lastRowY);
        
        CGRect viewFrame = (CGRect){.origin = buttonOrigin, .size = buttonSize};
        UIControl *numButton = [[buttonClass alloc] initWithFrame:viewFrame];
        
        [numButton addTarget:self action:@selector(numberButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:numButton];
        [self.numberButtons addObject:numButton];
    }
    
    UIControl *doneButton = [[buttonClass alloc] initWithFrame:(CGRect){.origin.y = lastRowY, .size = buttonSize}];
    [doneButton addTarget:self action:@selector(doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:doneButton];
    self.doneButton = doneButton;
    
    CGRect backFrame = CGRectMake(CGRectGetWidth(self.bounds) - buttonSize.width, lastRowY, buttonSize.width, buttonSize.height);
    UIControl *backButton = [[buttonClass alloc] initWithFrame:backFrame];
    
    [backButton addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:backButton];
    self.backButton = backButton;
    
    self.backButton.hidden = !self.isShowingBackButton;
    self.doneButton.hidden = !self.isShowingDoneButton;
    
    [self reloadButtons];
}

- (void)numberButtonPressed:(UIControl *)sender
{
    NSUInteger buttonIndex = [self.numberButtons indexOfObject:sender];
    NSNumber *number = [self numberForButton:sender atIndex:buttonIndex];
    
    if ( self.activeTextField != nil ) {
        [self replaceRange:[self textFieldSelectedRange:self.activeTextField] withString:[number stringValue]];
    }
    
    if ( buttonIndex < [self.numberButtons count] ) {
        [self sendActionsForEvents:RZNumberPadEventKeypress object:number];
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
