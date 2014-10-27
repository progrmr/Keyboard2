//
//  KeyboardConstants.m
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardConstants.h"
#import "UIColor+Additions.h"

// Colors
UIColor* kKeyboardBackgroundColor;
UIColor* kKeyBackgroundColor;
UIColor* kKeyFontColor;
UIColor* kKeyBorderColor;
UIColor* kSpecialKeyColor;

// Border
CGFloat kKeyNormalBorderWidth;
CGFloat kKeyTouchedBorderWidth;

// Spacing
CGFloat kKeySpacerY;

// Font
NSString* kKeyboardFontName;

@implementation KeyboardConstants

+ (void)initialize
{
    if (kKeyFontColor == nil) {
        kSpecialKeyColor            = [UIColor colorWithRGB:0xabb3bd];
        kKeyboardBackgroundColor    = [UIColor colorWithRGB:0xd2d5db];
        kKeyBackgroundColor         = [UIColor colorWithWhite:1.00f alpha:1];
        kKeyFontColor               = [UIColor colorWithWhite:0.00f alpha:1];
        kKeyBorderColor             = [UIColor colorWithWhite:0.00f alpha:1];
        
        kKeyNormalBorderWidth       = 0.0f;
        kKeyTouchedBorderWidth      = 2.0f;
        
        kKeySpacerY                 = -5.0f;
        
        kKeyboardFontName           = @"Helvetica-Light";
    }
}

@end
