//
//  ExtraKeys.h
//  Keyboard2
//
//  Created by Gary Morris on 10/30/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtraKeys : UIControl

// the default extraTitle starts with a "*" character
@property (nonatomic, copy)     NSArray*        extraTitles;        // extra key titles
@property (nonatomic, readonly) NSUInteger      selectedIndex;      // set by touch tracking

@property (nonatomic, readonly) NSTimeInterval  longTouchDelay;     // extra titles must be set first!

@end
