//
//  Key.h
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum { Unshifted = 0, Shifted, Shift_Lock, Number_Lock, Symbol_Lock } ShiftState;

@interface Key : UIButton

- (id)initWithTitle:(NSString*)title;

+ (instancetype)key:(NSString*)title;

@property (nonatomic, assign) BOOL          isTouched;
@property (nonatomic, assign) ShiftState    shiftState;

@end
