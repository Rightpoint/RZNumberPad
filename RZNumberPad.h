//
//  RZNumberPad.h
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

@import UIKit;

typedef struct {
    NSUInteger width, height;
} RZNumberPadDimensions;

typedef NS_OPTIONS(NSUInteger, RZNumberPadEvents) {
    RZNumberPadEventKeypress    = 1 << 0,
    RZNumberPadEventBack        = 1 << 1,
    RZNumberPadEventDone        = 1 << 2,
    RZNumberPadEventAllEvents   = (RZNumberPadEventKeypress | RZNumberPadEventBack | RZNumberPadEventDone)
};

IB_DESIGNABLE
@interface RZNumberPad : UIView {
@protected
    __weak UIControl *_backButton;
    __weak UIControl *_doneButton;
}

/**
 *  Whether the back button is visible. Default YES.
 */
@property (assign, nonatomic, getter = isShowingBackButton) IBInspectable BOOL showingBackButton;

/**
 *  Whether the done button is visible. Default YES.
 */
@property (assign, nonatomic, getter = isShowingDoneButton) IBInspectable BOOL showingDoneButton;

/**
 *  The default size for the number pad. The default implementation computes the size using the dimensions,
 *  buttonSize, and buttonSpacing values.
 *
 *  @note Number pads cannot be resized--they will always be the default size.
 *
 */
+ (CGSize)defaultSize;

/**
 *  The size in points of each button in the number pad. Default is 44x44.
 */
+ (CGSize)buttonSize;

/**
 *  The amount of space between each button. The X value is horizontal spacing, and Y value is vertical spacing.
 *  Default is 0.0, 0.0.
 */
+ (CGPoint)buttonSpacing;

/**
 *  The dimensions of the number pad. Width is the be number of columns, and height is the be number of rows.
 *  Default is 3x4 (for 0-9 buttons).
 */
+ (RZNumberPadDimensions)dimensions;

/**
 *  The class used to create the button views. Subclasses may override this method to use different buttons
 *  on the number pad. The returned class must be a subclass of UIControl. Default is UIButton.
 */
+ (Class)buttonClass;

/**
 *  @note Size property of frame is ignored. Default size is used instead.
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 *  Called when the number pad needs to configure one of its button views. You should not call this method directly.
 *  Subclasses should override this method to perform custom configuration. The default implementation sets the title of the button
 *  if it is a UIButton subclass, and adds a UILabel to the view otherwise.
 *
 *  @param button The button to configure.
 *  @param number The number the button represents.
 */
- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number;

/**
 *  Called when the number pad needs to configure its done button. You should not call this method directly.
 *  Subclasses should override this method to perform custom configuration. The default implementation does nothing.
 *
 *  @param button The done button to configure.
 */
- (void)configureDoneButton:(UIView *)button;

/**
 *  Called when the number pad needs to configure its back button. You should not call this method directly.
 *  Subclasses should override this method to perform custom configuration. The default implementation does nothing.
 *
 *  @param button The back button to configure.
 */
- (void)configureBackButton:(UIView *)button;

/**
 *  Called internally to determine what numerical value each button represents. The default implementation just returns the index,
 *  but for the last button returns 0 (so that the zero button is at the bottom of the numberpad).
 *
 *  @param button The button representing some value.
 *  @param index  The index of the button. Starting with the top left button, indexes increase from 0.
 
 *  @note This method is not called for the done and back buttons.
 *
 *  @return The numerical value represented by the button.
 */
- (NSNumber *)numberForButton:(UIView *)button atIndex:(NSUInteger)index;

/**
 *  Links the input of the number pad to the given text field. While linked, the number pad effectively functions as a keyboard for the text field. 
 *  The number pad will call the appropriate methods on the text field's delegate before changing text or ending editing. The number pad's "done" button
 *  functions as the return key for the text field.
 *
 *  @param textField The text field to link input to.
 */
- (void)linkToTextField:(UITextField *)textField;
- (void)linkToTextFields:(NSArray *)array;

/**
 *  Unlinks the given text field.
 */
- (void)unlinkTextField:(UITextField *)textField;
- (void)unlinkAllTextFields;

/**
 *  Add an action to be called when the given events are fired.
 *
 *  @param target          The target of the action. Cannot be nil.
 *  @param action          The method to call when the events fire. Must have an NSNumber parameter (which will be the number pressed on RZNumberPadEventKeypress events), or no parameters at all. Cannot be NULL.
 *  @param numberPadEvents The events to register the actions for.
 */
- (void)addTarget:(id)target action:(SEL)action forEvents:(RZNumberPadEvents)numberPadEvents;

/**
 *  Remove the target/action pair for the given events.
 *
 *  @param target          The target to remove actions for.
 *  @param action          The action to remove. Pass NULL to remove all actions for the target.
 *  @param numberPadEvents The events to remove target/actions for.
 */
- (void)removeTarget:(id)target action:(SEL)action forEvents:(RZNumberPadEvents)numberPadEvents;

/**
 *  Re-configures all buttons. Useful for subclasses whose button values/appearances may change.
 */
- (void)reloadButtons;

@end
