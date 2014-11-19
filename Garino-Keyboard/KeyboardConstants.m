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
UIColor* kSpecialKeyColor;
UIColor* kLockedKeyColor;
UIColor* kHighlightedKeyColor;   // highlighted key background color
UIColor* kHighlightedFontColor;

// Spacing
CGFloat kKeySpacerY;

// Font
NSString* kKeyboardFontName;

@implementation KeyboardConstants

+ (void)initialize
{
    if (kKeyFontColor == nil) {
        kSpecialKeyColor            = [UIColor colorWithRGB:0xabb3bd];
        kLockedKeyColor             = [UIColor colorWithRGB:0x000000];
        kKeyboardBackgroundColor    = [UIColor colorWithRGB:0xd2d5db];
        kKeyBackgroundColor         = [UIColor colorWithWhite:1.00f alpha:1];
        kHighlightedKeyColor        = [UIColor colorWithRGB:0x007aff];
        kKeyFontColor               = [UIColor colorWithWhite:0.00f alpha:1];
        kHighlightedFontColor       = [UIColor whiteColor];
        kKeySpacerY                 = 0.0f;
        
        kKeyboardFontName           = @"Helvetica-Light";
    }
}

@end
