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
              upper:(NSString*)upper
             number:(NSString*)number
             symbol:(NSString*)symbol
              width:(CGFloat)width
                tag:(KeyTags)tag
               font:(CGFloat)fontSize
{
    self = [super init];
    if (self) {
        self.tag        = tag;
        _width          = width;
        
        _alphaTitle     = alpha;
        
        if (number) {
            _numberTitle = number;
        } else {
            _numberTitle = _alphaTitle;
        }
        
        if (symbol) {
            _symbolTitle = symbol;
        } else {
            _symbolTitle = _numberTitle;
        }
        
        if (upper) {
            _uppercaseTitle = upper;
        } else if (tag != Untagged) {
            // special key, use lowercase title
            _uppercaseTitle = _alphaTitle;
        } else {
            // no uppercase provided, convert lowercase if alphabetic key
            unichar ch = [_alphaTitle characterAtIndex:0];
            _isAlpha = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:ch];
            
            if (_isAlpha) {
                _uppercaseTitle = [_alphaTitle uppercaseString];
            } else {
                _uppercaseTitle = _alphaTitle;
            }
        }
        
        DLog(@"Key: %@ %@ %@ %@", _alphaTitle, _uppercaseTitle, _numberTitle, _symbolTitle);
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.userInteractionEnabled = NO;
        self.autoresizesSubviews = YES;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5f;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:kKeyboardFontName size:fontSize];
        
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
    return [[Key alloc] initWithTitle:title upper:nil number:nil symbol:nil width:1 tag:0 font:kKeyboardFontSize];
}

+ (instancetype)key:(NSString *)title number:(NSString*)number symbol:(NSString *)symbol
{
    return [[Key alloc] initWithTitle:title upper:nil number:number symbol:symbol width:1 tag:0 font:kKeyboardFontSize];
}

+ (instancetype)key:(NSString*)title number:(NSString*)number width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize
{
    return [[Key alloc] initWithTitle:title upper:nil number:number symbol:nil width:width tag:tag font:fontSize];
}

+ (instancetype)key:(NSString*)title upper:(NSString*)upper number:(NSString*)number symbol:(NSString*)symbol width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize
{
    return [[Key alloc] initWithTitle:title upper:upper number:number symbol:symbol width:width tag:tag font:fontSize];
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
            switch (self.shiftState) {
                case Unshifted: return self.alphaTitle;
                case Shifted:
                case ShiftLock: return self.uppercaseTitle;
                case Numbers:   return self.numberTitle;
                case Symbols:   return self.symbolTitle;
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
