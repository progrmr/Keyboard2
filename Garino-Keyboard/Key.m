//
//  Key.m
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "Key.h"
#import "KeyboardConstants.h"

@implementation Key

- (id)initWithTitle:(NSString*)alpha
            numbers:(NSString*)numbers
            symbols:(NSString*)symbols
              width:(CGFloat)width
                tag:(KeyTags)tag
               font:(CGFloat)fontSize
{
    self = [super init];
    if (self) {
        self.tag        = tag;
        _width          = width;
        
        _alphaTitle     = alpha;
        if (numbers) {
            _numberTitle = numbers;
        } else {
            _numberTitle = _alphaTitle;
        }
        if (symbols) {
            _symbolTitle = symbols;
        } else {
            _symbolTitle = _numberTitle;
        }
        
        unichar ch = [_alphaTitle characterAtIndex:0];
        _isAlpha = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:ch];
        
        if (_isAlpha && tag == Untagged) {
            _uppercaseTitle = [_alphaTitle uppercaseString];
        } else {
            _uppercaseTitle = _alphaTitle;
        }
        
        DLog(@"Key: %@ %@ %@ %@", _alphaTitle, _uppercaseTitle, _numberTitle, _symbolTitle);
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.userInteractionEnabled = NO;
        self.autoresizesSubviews = YES;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5f;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:kKeyboardFont size:fontSize];
        
        if (tag == Untagged || tag == SpaceBar) {
            self.backgroundColor = kKeyBackgroundColor;
        } else {
            self.backgroundColor = kSpecialKeyColor;
        }
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        
        [self setTitle:alpha forState:UIControlStateNormal];
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
    return [[Key alloc] initWithTitle:title numbers:nil symbols:nil width:1 tag:0 font:28];
}

+ (instancetype)key:(NSString *)title numbers:(NSString*)numbers symbols:(NSString *)symbols
{
    return [[Key alloc] initWithTitle:title numbers:numbers symbols:symbols width:1 tag:0 font:28];
}

+ (instancetype)key:(NSString*)title numbers:(NSString*)numbers width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize
{
    return [[Key alloc] initWithTitle:title numbers:numbers symbols:nil width:width tag:tag font:fontSize];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    //self.layer.cornerRadius = MIN(self.bounds.size.width/2, self.bounds.size.height/2);
    self.layer.cornerRadius = 8;
}

- (NSString*)title
{
    return [self titleForState:UIControlStateNormal];
}

- (void)updateShiftKey
{
    if (_isTouched || _shiftState == Shifted) {
        self.layer.borderWidth = kKeyTouchedBorderWidth;
    } else if (_shiftState == ShiftLock || _shiftState == Symbols) {
        self.layer.borderWidth = kKeyTouchedBorderWidth;
    } else {
        self.layer.borderWidth = kKeyNormalBorderWidth;
    }
}

- (void)setIsTouched:(BOOL)isTouched
{
    if (_isTouched != isTouched) {
        _isTouched = isTouched;
        
        //DLog(@"%@ key %@", self.name, isTouched ? @"touched" : @"released");
        if (self.tag == ShiftKey) {
            [self updateShiftKey];
            
        } else if (isTouched) {
            self.layer.borderWidth = kKeyTouchedBorderWidth;
            
        } else {
            self.layer.borderWidth = kKeyNormalBorderWidth;
        }
    }
}

- (void)setShiftState:(ShiftState)shiftState
{
    if (_shiftState != shiftState) {
        _shiftState = shiftState;
        
        NSString* newTitle = nil;

        switch (shiftState) {
            case Unshifted: newTitle = _alphaTitle;      break;
            case ShiftLock:
            case Shifted:   newTitle = _uppercaseTitle;  break;
            case Numbers:   newTitle = _numberTitle;     break;
            case Symbols:   newTitle = _symbolTitle;     break;
        }

        if (self.tag == ShiftKey) {
            [self updateShiftKey];
            
            if (shiftState == Shifted) {
                newTitle = _alphaTitle;
            }
        }

        [self setTitle:newTitle forState:UIControlStateNormal];
    }
}

- (NSString*)name
{
    switch ((KeyTags)self.tag) {
        case BackspaceKey:      return @"BackSp";
        case SpaceBar:          return @"SpaceBar";
        case ShiftKey:          return @"Shift";
        case NumbersKey:        return @"Numbers";
        case ReturnKey:         return @"Return";
        case NextKeyboard:      return @"NextKeybd";
            
        case Untagged:
            if (self.shiftState == Numbers ) {
                return self.numberTitle;
            } else if (self.shiftState == Symbols) {
                return self.symbolTitle;
            } else {
                return self.title;
            }
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
