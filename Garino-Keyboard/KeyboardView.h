//
//  KeyboardView.h
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Key.h"

@interface KeyboardView : UIControl

@property (nonatomic, assign)   ShiftState  shiftState;

@property (nonatomic, strong)   NSObject <UITextDocumentProxy> *textDocumentProxy;

// adds a row of keys to the keyboard,
// also sets target/action on each key for TouchUpInside event
- (void)appendRowOfKeys:(NSArray *)keys target:(id)target action:(SEL)action;

- (void)updatePreviewText;

@end
