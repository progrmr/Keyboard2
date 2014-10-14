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
@property (nonatomic, readonly) NSArray*    keyboardRows;

- (void)appendRowOfKeys:(NSArray*)keyTitles;

@end
