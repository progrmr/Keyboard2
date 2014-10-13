//
//  KeyboardConstants.m
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardConstants.h"


// Colors
UIColor* kKeyboardBackgroundColor;
UIColor* kKeyBackgroundColor;
UIColor* kKeyFontColor;
UIColor* kKeyBorderColor;

@implementation KeyboardConstants

+ (void)initialize
{
    if (kKeyFontColor == nil) {
        kKeyboardBackgroundColor =  [UIColor colorWithWhite:0.30f alpha:1];
        kKeyBackgroundColor =       [UIColor colorWithWhite:0.85f alpha:1];
        kKeyFontColor =             [UIColor colorWithWhite:0.00f alpha:1];
        kKeyBorderColor =           [UIColor colorWithWhite:0.00f alpha:1];
    }
}

@end
