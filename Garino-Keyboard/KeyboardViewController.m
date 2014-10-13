//
//  KeyboardViewController.m
//  Garino-Keyboard
//
//  Created by Gary Morris on 9/29/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardViewController.h"
#import "NSLayoutConstraint+Additions.h"
#import "UtilitiesUI.h"
#import <AVFoundation/AVFoundation.h>
#import "KeyboardConstants.h"
#import "KeyboardView.h"
#import "Key.h"

@interface KeyboardViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    NSMutableArray* _keyHeightConstraints;
}

@property (nonatomic, strong) KeyboardView* keyboardView;

@property (nonatomic, strong) NSLayoutConstraint* heightConstraint;

@property (nonatomic, strong) UIView* nextKeyboardButton;

@property (nonatomic, strong) NSMutableArray* keyRows;

@property (nonatomic, strong) UISwipeGestureRecognizer* backspaceGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* spaceGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* returnGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* shiftGR;

@property (nonatomic, assign) ShiftState shiftState;

@end


@implementation KeyboardViewController

const ShiftState nextShiftState[] = { Shifted, Unshifted };

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
        
        _keyboardView = [[KeyboardView alloc] init];
        _keyboardView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        
        _shiftState = Unshifted;
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
        NSLog(@"orientation: %@", isLandscape ? @"LANDSCAPE" : @"PORTRAIT");
        NSLog(@"height: %ld", preferredHeight);
        self.heightConstraint.constant = preferredHeight;
        
        for (NSLayoutConstraint* keyHeightConstraint in _keyHeightConstraints) {
            keyHeightConstraint.constant = isLandscape ? kKeyHeightLandscape : kKeyHeightPortrait;
        }
        
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view addSubview:self.keyboardView];
    
    NSLog(@"viewDidLoad:            %@", [self viewSizeInfo]);

    // Perform custom UI setup here
    self.keyboardView.backgroundColor = kKeyboardBackgroundColor;
    
    _keyHeightConstraints = [NSMutableArray arrayWithCapacity:kNumberOfKeysPerRow * kNumberOfRows];
    
    self.keyRows = [NSMutableArray arrayWithCapacity:kNumberOfRows];
    
    [self.keyRows addObject:[self addRowOfKeys:@[ @"q", @"w", @"e", @"r", @"t", @"y", @"u", @"i", @"o", @"p" ]
                                      rowIndex:0
                                     belowView:self.keyboardView
                                 belowViewAttr:NSLayoutAttributeTop]];
    
    [self.keyRows addObject:[self addRowOfKeys:@[ @"a", @"s", @"d", @"f", @"g", @"h", @"j", @"k", @"l" ]
                                      rowIndex:1
                                     belowView:self.keyRows[0][0]
                                 belowViewAttr:NSLayoutAttributeBottom]];
                      
    [self.keyRows addObject:[self addRowOfKeys:@[ @"🌍", @"z", @"x", @"c", @"v", @"b", @"n", @"m", @".", @"?"]
                                      rowIndex:2
                                     belowView:self.keyRows[1][0]
                                 belowViewAttr:NSLayoutAttributeBottom]];
    
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
    
    NSLog(@"viewDidAppear:          %@", [self viewSizeInfo]);

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
    
    NSLog(@"viewWillLayoutSubviews: %@", [self viewSizeInfo]);
    
    [self adjustKeyboardViewHeight];
}

- (NSString*)viewSizeInfo
{
    return [NSString stringWithFormat:@"frame: %@, window: %@, screen: %@", NSStringFromCGSize(self.view.bounds.size), NSStringFromCGSize(self.view.window.bounds.size), NSStringFromCGSize([UIScreen mainScreen].bounds.size)];
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
    //[self.textDocumentProxy insertText:@"\n"];
}

- (void)shiftGesture:(UISwipeGestureRecognizer*)gr
{
    self.shiftState = nextShiftState[self.shiftState];
    
    for (NSArray* rowOfKeys in self.keyRows) {
        for (Key* key in rowOfKeys) {
            key.shiftState = self.shiftState;
        }
    }
}

// returns an array of Key objects
- (NSArray*)addRowOfKeys:(NSArray*)keyTitles
                rowIndex:(NSInteger)rowIndex
               belowView:(UIView*)belowView
           belowViewAttr:(NSLayoutAttribute)belowViewAttr
{
    const NSInteger NumberOfKeys = keyTitles.count;
    const BOOL oddRow = (NumberOfKeys % 2) == 1;
    const BOOL firstRow = (rowIndex == 0);
    NSMutableArray* keys = [NSMutableArray arrayWithCapacity:NumberOfKeys];
    
    for (NSInteger keyIndex=0; keyIndex<NumberOfKeys; keyIndex++) {
        NSString* keyTitle = keyTitles[keyIndex];
        
        Key* key = [[Key alloc] initWithTitle:keyTitle];
        [keys addObject:key];
        
        [self.keyboardView addSubview:key];
        
        // width of key
        [self.keyboardView addConstraint: NSLC(key, self.keyboardView, NSLayoutAttributeWidth,  kKeyWidthFactor, 0)];
        
        // height of key
        NSLayoutConstraint* keyHeight = NSLC2(key, NSLayoutAttributeHeight, nil, NSLayoutAttributeNotAnAttribute, 0, kKeyHeightPortrait);
        [_keyHeightConstraints addObject:keyHeight];
        [self.keyboardView addConstraint: keyHeight];
        
        // top edge of key
        [self.keyboardView addConstraint: NSLC2(key, NSLayoutAttributeTop,  belowView, belowViewAttr, 1, firstRow ? 0 : kKeySpacerY)];
        
        if (keyIndex > 0) {
            // left edge of key at right edge of previous key
            [self.keyboardView addConstraint: NSLC2(key, NSLayoutAttributeLeft, keys[keyIndex-1],  NSLayoutAttributeRight, 1, 0) ];
        }
    }
    
    if (oddRow) {
        // the number of keys in this row is odd, then center X the middle key
        [self.keyboardView addConstraint: NSLC(keys[NumberOfKeys/2], self.keyboardView, NSLayoutAttributeCenterX, 1, 0)];
        
    } else {
        // the number of keys in this row is even then first key should be at left edge
        [self.keyboardView addConstraint: NSLC(keys[0], self.keyboardView, NSLayoutAttributeLeft, 1, 0)];
        
        // last key should be at right edge
        [self.keyboardView addConstraint: NSLC(keys[NumberOfKeys-1], self.keyboardView, NSLayoutAttributeRight, 1, 0)];
    }
    
    return keys;
}

@end
