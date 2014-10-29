//
//  KeyboardConstants.h
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    kPreviewOffset =            75,
    kPreviewWidth  =            100,
    kPreviewHeight =            32,
    
    kMaxErrorPoints =           20,
    kDiscardPoints =            15,
    kWarningPoints =            10,
    
    kKeyboardFontSize =         28,
    
    kNumberOfRows =             4,
    kNumberOfKeysPerRow =       9,
    
    kKeyHeightPortrait =        44,
    kKeyHeightLandscape =       38,
    kKeyInsetX =                2,
    kKeyInsetY =                5,
    kKeyCornerRadius =          4,
    
    kKeyboardHeightPortrait =   (kNumberOfRows * kKeyHeightPortrait) + kPreviewHeight,
    kKeyboardHeightLandscape =  (kNumberOfRows * kKeyHeightLandscape) + kPreviewHeight,
};

// Colors
extern UIColor* kKeyboardBackgroundColor;
extern UIColor* kKeyBackgroundColor;
extern UIColor* kKeyFontColor;
extern UIColor* kSpecialKeyColor;

// Spacing
extern CGFloat kKeySpacerY;

// Font
extern NSString* kKeyboardFontName;

@interface KeyboardConstants : NSObject

+ (void)initialize;     // must be called before using UIColor constants above

@end
