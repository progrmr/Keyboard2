//
//  Key.m
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "Key.h"
#import "KeyboardConstants.h"


@interface Key ()
@property (nonatomic, strong) NSString* title;
@property (nonatomic, strong) NSString* uppercaseTitle;
@property (nonatomic, assign) BOOL isAlpha;
@end


@implementation Key

- (id)initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        _title = title;
        
        unichar ch = [title characterAtIndex:0];
        _isAlpha = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:ch];
        
        if (_isAlpha) {
            _uppercaseTitle = [title uppercaseString];
        }
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.userInteractionEnabled = NO;
        self.autoresizesSubviews = YES;
        self.backgroundColor = kKeyBackgroundColor;
        self.titleLabel.adjustsFontSizeToFitWidth = NO;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:@"Courier" size:28];
        
        //self.titleEdgeInsets = UIEdgeInsetsMake(3, 0, 0, 0);
        
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:kKeyFontColor forState:UIControlStateNormal];
        
        // add a border outline
        self.layer.borderColor = kKeyBorderColor.CGColor;
        self.layer.borderWidth = kKeyNormalBorderWidth;
        self.layer.masksToBounds = YES;
        
        [self setNeedsLayout];      // layoutSubviews computes cornerRadius
        
        // track touches to change looks when touched
        [self addTarget:self action:@selector(touchStarted) forControlEvents:UIControlEventTouchDown];
        [self addTarget:self action:@selector(touchStarted) forControlEvents:UIControlEventTouchDragEnter];
        [self addTarget:self action:@selector(touchEnded)   forControlEvents:UIControlEventTouchUpInside];
        [self addTarget:self action:@selector(touchEnded)   forControlEvents:UIControlEventTouchDragExit];
        [self addTarget:self action:@selector(touchEnded)   forControlEvents:UIControlEventTouchCancel];
    }
    return self;
}

+ (instancetype)key:(NSString *)title
{
    return [[Key alloc] initWithTitle:title];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.cornerRadius = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setIsTouched:(BOOL)isTouched
{
    if (_isTouched != isTouched) {
        _isTouched = isTouched;
        
        DLog(@"key %@ %@", self.title, isTouched ? @"touched" : @"released");
        
        self.layer.borderWidth = isTouched ? kKeyTouchedBorderWidth : kKeyNormalBorderWidth;
    }
}

- (void)setShiftState:(ShiftState)shiftState
{
    _shiftState = shiftState;
    
    switch (shiftState) {
        case Unshifted:
            [self setTitle:self.title forState:UIControlStateNormal];
            break;
        case Shifted:
        case Shift_Lock:
            if (self.isAlpha) {
                [self setTitle:self.uppercaseTitle forState:UIControlStateNormal];
            }
            break;
        case Number_Lock:
        case Symbol_Lock:
            break;
    }
}

#pragma mark - Touch Tracking

- (void)touchStarted
{
    self.isTouched = YES;
}

- (void)touchEnded
{
    self.isTouched = NO;
}

@end
