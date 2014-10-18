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
                      [Key key:@"w" numbers:@"#" symbols:nil],
                      [Key key:@"e" numbers:@"$" symbols:nil],
                      [Key key:@"r" numbers:@"%" symbols:nil],
                      [Key key:@"t" numbers:@"&" symbols:nil],
                      [Key key:@"y" numbers:@"/" symbols:nil],
                      [Key key:@"u" numbers:@"7" symbols:nil],
                      [Key key:@"i" numbers:@"8" symbols:nil],
                      [Key key:@"o" numbers:@"9" symbols:nil],
                      [Key key:@"p" numbers:@"-" symbols:nil],
                      ];
    
    NSArray* row2 = @[
                      [Key key:@"a" numbers:@"(" symbols:nil],
                      [Key key:@"s" numbers:@")" symbols:nil],
                      [Key key:@"d" numbers:@"@" symbols:nil],
                      [Key key:@"f" numbers:@"\"" symbols:nil],
                      [Key key:@"g" numbers:@"*" symbols:nil],
                      [Key key:@"h" numbers:@"4" symbols:nil],
                      [Key key:@"j" numbers:@"5" symbols:nil],
                      [Key key:@"k" numbers:@"6" symbols:nil],
                      [Key key:@"l" numbers:@"+" symbols:nil],
                      ];
    
    Key* shiftKey       = [Key key:@"⬆︎" width:1 tag:ShiftKey font:22];
    Key* backspaceKey   = [Key key:@"⬅︎"  width:1 tag:BackspaceKey font:22];

    NSArray* row3 = @[
                      shiftKey,
                      [Key key:@"z" numbers:@"!" symbols:nil],
                      [Key key:@"x" numbers:@":" symbols:nil],
                      [Key key:@"c" numbers:@"'" symbols:nil],
                      [Key key:@"v" numbers:@"=" symbols:nil],
                      [Key key:@"b" numbers:@"1" symbols:nil],
                      [Key key:@"n" numbers:@"2" symbols:nil],
                      [Key key:@"m" numbers:@"3" symbols:nil],
                      backspaceKey,
                      ];
    
    Key* numbersKey     = [Key key:@"123" width:1.25f tag:NumbersKey   font:17];
    Key* nextKeyboard   = [Key key:@"🌍"  width:1.25f tag:NextKeyboard font:24];
    Key* spaceBar       = [Key key:@" "   width:3.00f tag:SpaceBar     font:28];
    Key* returnKey      = [Key key:@"return" width:1.5f tag:ReturnKey font:17];
    
    NSArray* row4 = @[
                      numbersKey,
                      nextKeyboard,
                      spaceBar,
                      [Key key:@"?" numbers:@"0" symbols:nil],
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
}

// viewWillLayoutSubviews gets called twice at the start of an orientation change
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self adjustKeyboardViewHeight];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
}

- (void)keyPressed:(Key*)sender
{
    switch (sender.tag) {
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
            break;
        case SpaceBar:
            [self.textDocumentProxy insertText:@" "];
            break;
        case ReturnKey:
            [self.textDocumentProxy insertText:@"\r"];
            break;
        default:
            [self.textDocumentProxy insertText:sender.title];
            
            // if we are shifted (but not locked) then unshift now
            if (self.keyboardView.shiftState == Shifted) {
                self.keyboardView.shiftState = Unshifted;
            }
    }
}

@end
