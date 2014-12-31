RZNumberPad
===========

Next time design requires yet another custom number pad, don't cringe. Instead rejoice at the task, made incredibly simple by `RZNumberPad`. 

## Usage
`RZNumberPad` provides a base class that contains logic and performs tasks that are inherent to every number pad. Instead of reinventing the wheel with each new design requirement, simply create a subclass of `RZNumberPad` and override the appropriate methods to specify the style. Key methods to override for customization:

``` objc
// The size in points of each button in the number pad.
+ (CGSize)buttonSize;

// The amount of space between each button. 
// The X value is horizontal spacing, and Y value is vertical spacing.
+ (CGPoint)buttonSpacing;

 // The dimensions of the number pad. 
 // Width is the be number of columns, and height is the be number of rows.
+ (RZNumberPadDimensions)dimensions;

// The class used to create the button views. 
// The returned class must be a subclass of UIControl.
+ (Class)buttonClass;

// Called when the number pad needs to configure one of its button views.
// The default implementation sets the title of the button if it is a UIButton subclass, 
// and adds a UILabel to the view otherwise.
- (void)configureButton:(UIView *)button forNumber:(NSNumber *)number;

//  Called when the number pad needs to configure its done button. 
- (void)configureDoneButton:(UIView *)button;

// Called when the number pad needs to configure its back button.
- (void)configureBackButton:(UIView *)button;

// Called internally to determine what numerical value each button represents. 
// The default implementation just returns the index, but for the last button returns 0 
// (so that the zero button is at the bottom of the numberpad).
- (NSNumber *)numberForButton:(UIView *)button atIndex:(NSUInteger)index;
```

**No xibs needed**

Number pads are created programmatically, with buttons and dimensions configured according to each subclass. No xib is required to setup a new number pad, but `RZNumberPad` is `IBDesignable`, so you can view the look and feel of your custom number pad directly in Interface Builder.

**No IBActions or delegates involved**

`RZNumberPad` receives number, done, and back button tap events and broadcasts them similar to `UIControl`. You can add and remove target/action pairs to the number pad to receive event callbacks. However, `RZNumberPad` provides an even simpler option for the general use case where number pad is meant to output to a `UITextField`.

**Link output directly to a UITextField**

Number pad output can be linked directly to text fields either programmatically or via Interface Builder. When `RZNumberPad` is linked to a `UITextField`, it functions similar to an input view. Number and back button presses trigger the appropriate methods on the the text field's delegate, and then can directly update the text of the field. The number pad's "done" button functions as the return key in this case. In most cases, this functionality is sufficient, and therefore makes adding a number pad to your project as simple as dropping in a view in Interface Builder.
