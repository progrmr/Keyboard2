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

// Border
CGFloat kKeyNormalBorderWidth;
CGFloat kKeyTouchedBorderWidth;

// Spacing
CGFloat kKeySpacerY;

@implementation KeyboardConstants

+ (void)initialize
{
    if (kKeyFontColor == nil) {
        kKeyboardBackgroundColor    = [UIColor colorWithRed:210/255.0f green:213/255.0f blue:219/255.0f alpha:1];
        kKeyBackgroundColor         = [UIColor colorWithWhite:1.00f alpha:1];
        kKeyFontColor               = [UIColor colorWithWhite:0.00f alpha:1];
        kKeyBorderColor             = [UIColor colorWithWhite:0.00f alpha:1];
        
        kKeyNormalBorderWidth       = 0.5f;
        kKeyTouchedBorderWidth      = 2.0f;
        
        kKeySpacerY                 = -5.0f;        
    }
}

@end
