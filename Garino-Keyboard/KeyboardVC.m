//
//  KeyboardVC.m
//  Garino-Keyboard
//
//  Created by Gary Morris on 9/29/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardVC.h"
#import "KeyboardConstants.h"
#import "KeyboardView.h"
#import "Key.h"
#import "NSLayoutConstraint+Additions.h"
#import "UtilitiesUI.h"

@interface KeyboardVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) KeyboardView* keyboardView;

@property (nonatomic, strong) NSLayoutConstraint* heightConstraint;

@property (nonatomic, strong) UIView* nextKeyboardButton;

//@property (nonatomic, strong) UISwipeGestureRecognizer* backspaceGR;
//@property (nonatomic, strong) UISwipeGestureRecognizer* spaceGR;
//@property (nonatomic, strong) UISwipeGestureRecognizer* returnGR;
//@property (nonatomic, strong) UISwipeGestureRecognizer* shiftGR;
//@property (nonatomic, strong) UISwipeGestureRecognizer* shiftLockGR;

@end


@implementation KeyboardVC

const ShiftState nextShiftState[] = {
    /* Unshifted  -> */  Shifted,
    /* Shifted    -> */  ShiftLock,
    /* ShiftLock  -> */  Unshifted,
    
    /* NumLock    -> */  Symbols,
    /* SymLock    -> */  Numbers,
};

const ShiftState nextNumberState[] = {
    /* Unshifted  -> */  Numbers,
    /* Shifted    -> */  Numbers,
    /* ShiftLock  -> */  Numbers,
    
    /* Numbers    -> */  Unshifted,
    /* SymLock    -> */  Unshifted,
};

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _keyboardView = [[KeyboardView alloc] init];
    }
    return self;
}

+ (void)initialize
{
    [KeyboardConstants initialize];
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
    //NSLog(@"updateViewConstraints:  %@", [self viewSizeInfo]);
}

- (void)adjustKeyboardViewHeight
{
    // update keyboard height constraint for orientation change
    const CGSize screenSize = [UIScreen mainScreen].bounds.size;
    const BOOL isLandscape = screenSize.width > screenSize.height;
    const CGFloat preferredHeight = isLandscape ? kKeyboardHeightLandscape : kKeyboardHeightPortrait;
    const BOOL heightChanged = lroundf(self.heightConstraint.constant) != lroundf(preferredHeight);
    
    if (heightChanged && self.heightConstraint) {
        DLog(@"orientation: %@, height: %0.0f, was: %0.0f", isLandscape ? @"LANDSCAPE" : @"PORTRAIT", preferredHeight, self.heightConstraint.constant);

        self.heightConstraint.constant = preferredHeight;
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSArray* row1 = @[
                      [Key key:@"w" numbers:@"1" symbols:@"["],
                      [Key key:@"e" numbers:@"2" symbols:@"]"],
                      [Key key:@"r" numbers:@"3" symbols:@"{"],
                      [Key key:@"t" numbers:@"4" symbols:@"}"],
                      [Key key:@"y" numbers:@"5" symbols:@"#"],
                      [Key key:@"u" numbers:@"6" symbols:@"%"],
                      [Key key:@"i" numbers:@"7" symbols:@"^"],
                      [Key key:@"o" numbers:@"8" symbols:@"*"],
                      [Key key:@"p" numbers:@"9" symbols:@" "],
                      ];
    
    NSArray* row2 = @[
                      [Key key:@"a" numbers:@"-" symbols:@"_"],
                      [Key key:@"s" numbers:@"/" symbols:@"\\"],
                      [Key key:@"d" numbers:@":" symbols:@"|"],
                      [Key key:@"f" numbers:@";" symbols:@"~"],
                      [Key key:@"g" numbers:@"(" symbols:@"<"],
                      [Key key:@"h" numbers:@")" symbols:@">"],
                      [Key key:@"j" numbers:@"$" symbols:@"€"],
                      [Key key:@"k" numbers:@"&" symbols:@"£"],
                      [Key key:@"l" numbers:@"0" symbols:@"¥"],
                      ];
    
    // special case for ShiftKey, uppercaseTitle used for ShiftLock state only
    Key* shiftKey       = [Key key:@"⬆︎" numbers:@"#+=" width:1.25f tag:ShiftKey font:22];
    shiftKey.uppercaseTitle = @"⇪";
    shiftKey.symbolTitle    = @"123";
    
    Key* zqxKey = [Key key:@"qzx" numbers:@"@" width:1.25f tag:0 font:kKeyboardFontSize];
    zqxKey.symbolTitle = @"•";
    
    NSArray* row3 = @[
                      shiftKey,
                      zqxKey,
                      //[Key key:@"x" numbers:@"'" symbols:@"`"],
                      [Key key:@"c" numbers:@"\"" symbols:@"°"],
                      [Key key:@"v" numbers:@"," symbols:@","],
                      [Key key:@"b" numbers:@"!" symbols:@"!"],
                      [Key key:@"n" numbers:@"+" symbols:@"+"],
                      [Key key:@"m" numbers:@"=" symbols:@"="],
                      [Key key:@"⬅︎" numbers:nil width:1.50f tag:BackspaceKey font:22],
                      ];
    
    Key* numbersKey     = [Key key:@"123" numbers:@"abc" width:1.25f tag:NumbersKey   font:17];
    Key* nextKeyboard   = [Key key:@"🌍"  numbers:nil    width:1.25f tag:NextKeyboard font:24];
    Key* spaceBar       = [Key key:@" "   numbers:nil    width:3.50f tag:SpaceBar     font:kKeyboardFontSize];
    Key* returnKey      = [Key key:@"return" numbers:nil width:2.00f tag:ReturnKey    font:17];
    
    NSArray* row4 = @[
                      numbersKey,
                      nextKeyboard,
                      spaceBar,
                      [Key key:@"."],
                      returnKey,
                      ];
    
    [self.keyboardView appendRowOfKeys:row1 target:self action:@selector(keyPressed:)];
    [self.keyboardView appendRowOfKeys:row2 target:self action:@selector(keyPressed:)];
    [self.keyboardView appendRowOfKeys:row3 target:self action:@selector(keyPressed:)];
    [self.keyboardView appendRowOfKeys:row4 target:self action:@selector(keyPressed:)];
    
    [self.view addSubview:self.keyboardView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add auto layout constraints for view
    self.heightConstraint = [NSLayoutConstraint constraintWithItem: self.view
                                                         attribute: NSLayoutAttributeHeight
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: nil
                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                        multiplier: 0 constant: 0];
    self.heightConstraint.priority = 999;
    [self.view addConstraint:self.heightConstraint];
    [self adjustKeyboardViewHeight];
    
    // provide textDocumentProxy to keyboardView
    self.keyboardView.textDocumentProxy = self.textDocumentProxy;
    [self.keyboardView updatePreviewText];
}

// viewWillLayoutSubviews gets called twice at the start of an orientation change
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self adjustKeyboardViewHeight];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
    DLog(@"");
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    DLog(@"");
}

- (void)selectionWillChange:(id<UITextInput>)textInput
{
    DLog(@"");
}

- (void)selectionDidChange:(id<UITextInput>)textInput
{
    DLog(@"");
}

- (void)keyPressed:(Key*)sender
{
    switch ((KeyTags)sender.tag) {
        case NextKeyboard:
            [self advanceToNextInputMode];
            break;
        case ShiftKey:
            self.keyboardView.shiftState = nextShiftState[self.keyboardView.shiftState];
            break;
        case NumbersKey:
            self.keyboardView.shiftState = nextNumberState[self.keyboardView.shiftState];
            break;
        case BackspaceKey:
            [self.textDocumentProxy deleteBackward];
            [self.keyboardView updatePreviewText];
            break;
        case SpaceBar:
            [self.textDocumentProxy insertText:@" "];
            [self.keyboardView updatePreviewText];
            break;
        case ReturnKey:
            [self.textDocumentProxy insertText:@"\r"];
            [self.keyboardView updatePreviewText];
            break;
        case Untagged:
            [self.textDocumentProxy insertText:sender.title];
            [self.keyboardView updatePreviewText];
            
            // if we are shifted (but not locked) then unshift now
            if (self.keyboardView.shiftState == Shifted) {
                self.keyboardView.shiftState = Unshifted;
            }
    }
}

@end
