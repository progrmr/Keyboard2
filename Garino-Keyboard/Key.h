//
//  Key.h
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum { Unshifted=0, Shifted=1, ShiftLock=2, Numbers=3, Symbols=4 } ShiftState;
typedef enum { Untagged=0, ShiftKey, NumbersKey, BackspaceKey, SpaceBar, ReturnKey, NextKeyboard } KeyTags;

@interface Key : UIButton

+ (instancetype)key:(NSString*)title;
+ (instancetype)key:(NSString*)title numbers:(NSString*)numbers symbols:(NSString*)symbols;
+ (instancetype)key:(NSString*)title width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize;

@property (nonatomic, readonly) NSString*   name;       // name for debug purposes, uses tag
@property (nonatomic, readonly) NSString*   title;      // string that currently appears to user
@property (nonatomic, readonly) CGFloat     width;      // relative key width, default 1.0

@property (nonatomic, assign) BOOL          isTouched;
@property (nonatomic, assign) ShiftState    shiftState;

@end
