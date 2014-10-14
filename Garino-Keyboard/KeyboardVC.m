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

@end


@implementation KeyboardVC

const ShiftState nextShiftState[] = { Shifted, Unshifted };

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        
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
    const long preferredHeight = isLandscape ? kKeyboardHeightLandscape : kKeyboardHeightPortrait;
    const BOOL heightChanged = lroundf(self.view.bounds.size.height) != preferredHeight;
    
    if (heightChanged) {
        DLog(@"orientation: %@, height: %ld", isLandscape ? @"LANDSCAPE" : @"PORTRAIT", preferredHeight);

        self.heightConstraint.constant = preferredHeight;
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.keyboardView appendRowOfKeys:@[ @"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p" ]];
    [self.keyboardView appendRowOfKeys:@[ @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l" ]];
    [self.keyboardView appendRowOfKeys:@[ @"🌍", @"z", @"x", @"c", @"v", @"b", @"n", @"m", @".", @"?"]];
    
    [self.view addSubview:self.keyboardView];
    
    // REQUIRED: next keyboard button, we use the first key in row3
//    [self.row3key1 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [self.row3key1 addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
    self.backspaceGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backspaceGesture:)];
    self.backspaceGR.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.spaceGR     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(spaceGesture:)];
    self.spaceGR.direction = UISwipeGestureRecognizerDirectionRight;
    
    self.returnGR    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnGesture:)];
    self.returnGR.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.shiftGR     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shiftGesture:)];
    self.shiftGR.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.view addGestureRecognizer:self.backspaceGR];
    [self.view addGestureRecognizer:self.spaceGR];
    [self.view addGestureRecognizer:self.returnGR];
    [self.view addGestureRecognizer:self.shiftGR];
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

@end
