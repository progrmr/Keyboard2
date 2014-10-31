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
    const float preferredHeight = isLandscape ? kKeyboardHeightLandscape : kKeyboardHeightPortrait;
    const BOOL heightChanged = lroundf((float)self.heightConstraint.constant) != lroundf(preferredHeight);
    
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
                      [Key key:@"w" number:@"1" symbol:@"["],
                      [Key key:@"e" number:@"2" symbol:@"]"],
                      [Key key:@"r" number:@"3" symbol:@"{"],
                      [Key key:@"t" number:@"4" symbol:@"}"],
                      [Key key:@"y" number:@"5" symbol:@"#"],
                      [Key key:@"u" number:@"6" symbol:@"%"],
                      [Key key:@"i" number:@"7" symbol:@"^"],
                      [Key key:@"o" number:@"8" symbol:@"*"],
                      [Key key:@"p" number:@"9" symbol:@"+"],
                      ];
    
    NSArray* row2 = @[
                      [Key key:@"a" number:@"-" symbol:@"_"],
                      [Key key:@"s" number:@":" symbol:@"|"],
                      [Key key:@"d" number:@";" symbol:@"~"],
                      [Key key:@"f" number:@"(" symbol:@"<"],
                      [Key key:@"g" number:@")" symbol:@">"],
                      [Key key:@"h" number:@"$" symbol:@"€"],
                      [Key key:@"j" number:@"&" symbol:@"£"],
                      [Key key:@"k" number:@"@" symbol:@"•"],
                      [Key key:@"l" number:@"0" symbol:@"="],
                      ];
    
    NSArray* row3 = @[
                      [Key key:@"⬆︎" upper:@"⇪" number:@"#+=" symbol:@"123" width:1.25f tag:ShiftKey font:22],
                      [Key key:@[@"qzx", @"q", @"*z", @"x"] number:@"/" symbol:@"\\" width:1.25f],
                      [Key key:@"c" number:@"," symbol:nil],
                      [Key key:@"v" number:@"?" symbol:nil],
                      [Key key:@"b" number:@"!" symbol:nil],
                      [Key key:@[@"n", @"ñ", @"n"] number:@"'" symbol:nil],
                      [Key key:@"m" number:@"\"" symbol:nil],
                      [Key key:@"⬅︎" number:nil width:1.50f tag:BackspaceKey font:22],
                      ];
    
    NSArray* row4 = @[
                      [Key key:@"123" number:@"abc" width:1.25f tag:NumbersKey   font:17],
                      [Key key:@"🌍"  number:nil    width:1.25f tag:NextKeyboard font:24],
                      [Key key:@" "   number:nil    width:3.50f tag:SpaceBar     font:kKeyboardFontSize],
                      [Key key:@"."],
                      [Key key:@"return" number:nil width:2.00f tag:ReturnKey    font:17],
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

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    [self.keyboardView updatePreviewText];
    DLog(@"");
}

//- (void)selectionDidChange:(id<UITextInput>)textInput
//{
//    UITextRange* selectedRange = textInput.selectedTextRange;
//    NSString* selectedText = [textInput textInRange:selectedRange];
//    DLog(@"selected: \"%@\"", selectedText);
//}

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
            [self.textDocumentProxy insertText:@"\n"];
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
