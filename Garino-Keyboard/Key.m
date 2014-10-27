//
//  Key.m
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "Key.h"
#import "KeyboardConstants.h"

@interface Key () {
    UIColor* _keyColor;
    UIColor* _borderColor;
    CGFloat  _borderWidth;
    CGFloat  _cornerRadius;
}
@end

#define kShadowOpacity (0.75f)

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
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        
        [self setTitle:alpha forState:UIControlStateNormal];
        [self setTitleColor:kKeyFontColor forState:UIControlStateNormal];
        
        // add a border outline
        _borderColor = kKeyBorderColor;
        _borderWidth = kKeyNormalBorderWidth;
        _cornerRadius = kKeyCornerRadius;
        
        if (self.tag == Untagged || self.tag == SpaceBar) {
            _keyColor = kKeyBackgroundColor;
        } else {
            _keyColor = kSpecialKeyColor;
        }
        
        self.layer.shadowColor  = [UIColor blackColor].CGColor;
        self.layer.shadowRadius = 1.0f;
        self.layer.shadowOffset = CGSizeMake(0,1);
        self.layer.shadowOpacity = kShadowOpacity;

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

    [self setNeedsDisplay];
}

- (NSString*)title
{
    return [self titleForState:UIControlStateNormal];
}

- (void)updateShiftKey
{
    if (_isTouched || _shiftState == Shifted) {
//        _borderWidth = kKeyTouchedBorderWidth;
        self.layer.shadowOpacity = 0;
        
    } else if (_shiftState == ShiftLock || _shiftState == Symbols) {
//        _borderWidth = kKeyTouchedBorderWidth;
        self.layer.shadowOpacity = 0;
        
    } else {
//        _borderWidth = kKeyNormalBorderWidth;
        self.layer.shadowOpacity = kShadowOpacity;
    }
    
    [self setNeedsDisplay];
}

- (void)updateNumbersKey
{
    if (_isTouched || _shiftState == Numbers || _shiftState == Symbols) {
        self.layer.shadowOpacity = 0;
    } else {
        self.layer.shadowOpacity = kShadowOpacity;
    }
    
    [self setNeedsDisplay];
}

- (void)setIsTouched:(BOOL)isTouched
{
    if (_isTouched != isTouched) {
        _isTouched = isTouched;
        
        //DLog(@"%@ key %@", self.name, isTouched ? @"touched" : @"released");
        if (self.tag == ShiftKey) {
            [self updateShiftKey];
            
        } else if (self.tag == NumbersKey) {
            [self updateNumbersKey];
        
        } else if (isTouched) {
            //_borderWidth = kKeyTouchedBorderWidth;
            self.layer.shadowOpacity = 0;
            
        } else {
            //_borderWidth = kKeyNormalBorderWidth;
            self.layer.shadowOpacity = kShadowOpacity;
        }
    }
    
    [self setNeedsDisplay];
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
            
        } else if (self.tag == NumbersKey) {
            [self updateNumbersKey];
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

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    CGRect insetRect = CGRectInset(rect, kKeyInsetX, kKeyInsetY);
    
    // Drawing code.
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, _keyColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, _borderColor.CGColor);
    
    UIBezierPath* path = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:_cornerRadius];
    [path fill];
    
    path.lineWidth = _borderWidth;
    [path stroke];
    
    self.layer.shadowPath = path.CGPath;
}

@end
