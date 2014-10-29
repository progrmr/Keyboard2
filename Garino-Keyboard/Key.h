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

// title can be an NSString* or NSArray* of NSString*
+ (instancetype)key:(id)title;
+ (instancetype)key:(id)title number:(NSString*)number symbol:(NSString*)symbol;
+ (instancetype)key:(id)title number:(NSString*)number width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize;
+ (instancetype)key:(id)title upper:(NSString*)upper number:(NSString*)number symbol:(NSString*)symbol width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize;

@property (nonatomic, readonly) NSString*   name;       // name for debug purposes, uses tag
@property (nonatomic, readonly) NSString*   title;      // string that currently appears to user
@property (nonatomic, readonly) CGFloat     width;      // relative key width, default 1.0
@property (nonatomic, readonly) BOOL        isAlpha;    // alpha key: A-Z

@property (nonatomic, assign)   BOOL        isTouched;
@property (nonatomic, readonly) BOOL        isTouchedLong;      // shows extra key options after long press
@property (nonatomic, assign)   ShiftState  shiftState;

@end
