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

@property (nonatomic, strong) UISwipeGestureRecognizer* backspaceGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* spaceGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* returnGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* shiftGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* shiftLockGR;

@end


@implementation KeyboardVC

const ShiftState nextShiftState[] = {
    /* Unshifted  -> */  Shifted,
    /* Shifted    -> */  Number_Lock,
    /* Shift_Lock -> */  Unshifted,
    /* Number_Lock -> */ Symbol_Lock,
    /* Symbol_Lock -> */ Number_Lock,
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
    
    NSArray* row1 = @[ [Key key:@"q"],
                       [Key key:@"w"],
                       [Key key:@"e"],
                       [Key key:@"r"],
                       [Key key:@"t"],
                       [Key key:@"y"],
                       [Key key:@"u"],
                       [Key key:@"i"],
                       [Key key:@"o"],
                       [Key key:@"p"] ];
    
    NSArray* row2 = @[ [Key key:@"a"],
                       [Key key:@"s"],
                       [Key key:@"d"],
                       [Key key:@"f"],
                       [Key key:@"g"],
                       [Key key:@"h"],
                       [Key key:@"j"],
                       [Key key:@"k"],
                       [Key key:@"l"] ];
    
    NSArray* row3 = @[ [Key key:@"🌍"],
                       [Key key:@"z"],
                       [Key key:@"x"],
                       [Key key:@"c"],
                       [Key key:@"v"],
                       [Key key:@"b"],
                       [Key key:@"n"],
                       [Key key:@"m"],
                       [Key key:@"."],
                       [Key key:@"?"] ];
    
    [self.keyboardView appendRowOfKeys:row1 target:self action:@selector(keyPressed:)];
    [self.keyboardView appendRowOfKeys:row2 target:self action:@selector(keyPressed:)];
    [self.keyboardView appendRowOfKeys:row3 target:self action:@selector(keyPressed:)];
    
    [self.view addSubview:self.keyboardView];
    
    // REQUIRED: next keyboard button, we use the first key in row3
    Key* nextKeyboardButton = row3[0];
    nextKeyboardButton.userInteractionEnabled = YES;
    [nextKeyboardButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [nextKeyboardButton addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
    self.backspaceGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backspaceGesture:)];
    self.backspaceGR.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.spaceGR     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(spaceGesture:)];
    self.spaceGR.direction = UISwipeGestureRecognizerDirectionRight;
    
    self.returnGR    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnGesture:)];
    self.returnGR.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.shiftGR     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shiftGesture:)];
    self.shiftGR.direction = UISwipeGestureRecognizerDirectionUp;
    
    self.shiftLockGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shiftLockGesture:)];
    self.shiftLockGR.numberOfTouchesRequired = 2;
    self.shiftLockGR.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.view addGestureRecognizer:self.backspaceGR];
    [self.view addGestureRecognizer:self.spaceGR];
    [self.view addGestureRecognizer:self.returnGR];
    [self.view addGestureRecognizer:self.shiftGR];
    [self.view addGestureRecognizer:self.shiftLockGR];
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
    
//    UIColor *textColor = nil;
//    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
//        textColor = [UIColor whiteColor];
//    } else {
//        textColor = [UIColor blackColor];
//    }
}

- (void)keyPressed:(UIButton*)sender
{
    NSString* title = [sender titleForState:UIControlStateNormal];
    
    [self.textDocumentProxy insertText:title];
    
    if ([title isEqualToString:@"X"]) {
        dumpView(self.view.window, @"", NO);
    }
}

- (void)backspaceGesture:(UISwipeGestureRecognizer*)gr
{
    [self.textDocumentProxy deleteBackward];
}

- (void)spaceGesture:(UISwipeGestureRecognizer*)gr
{
    [self.textDocumentProxy insertText:@" "];
}

- (void)returnGesture:(UISwipeGestureRecognizer*)gr
{
    [self.textDocumentProxy insertText:@"\r"];
}

- (void)shiftGesture:(UISwipeGestureRecognizer*)gr
{
    self.keyboardView.shiftState = nextShiftState[self.keyboardView.shiftState];
}

- (void)shiftLockGesture:(UISwipeGestureRecognizer*)gr
{
    if (self.keyboardView.shiftState != Shift_Lock) {
        self.keyboardView.shiftState = Shift_Lock;
    } else {
        self.keyboardView.shiftState = Unshifted;
    }
}

@end
