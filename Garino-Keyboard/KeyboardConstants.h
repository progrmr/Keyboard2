//
//  KeyboardConstants.h
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    kNumberOfRows =             3,
    kNumberOfKeysPerRow =       10,
    kKeyboardHeightPortrait =   132,
    kKeyboardHeightLandscape =  114,
};

#define kKeySpacerY         (-5.0f)
#define kKeyHeightPortrait  ((kKeyboardHeightPortrait  + (-kKeySpacerY*(kNumberOfRows-1))) / kNumberOfRows)
#define kKeyHeightLandscape ((kKeyboardHeightLandscape + (-kKeySpacerY*(kNumberOfRows-1))) / kNumberOfRows)
#define kKeyWidthFactor     (1.0f / kNumberOfKeysPerRow)

#define kKeyNormalBorderWidth (0.5f)
#define kKeyTouchedBorderWidth (2.0f)

// Colors
extern UIColor* kKeyboardBackgroundColor;
extern UIColor* kKeyBackgroundColor;
extern UIColor* kKeyFontColor;
extern UIColor* kKeyBorderColor;

@interface KeyboardConstants : NSObject

+ (void)initialize;     // must be called before using UIColor constants above

@end
