//
//  Key.m
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "Key.h"
#import "KeyboardConstants.h"
#import "ExtraKeys.h"

@interface Key () {
    UIColor*        keyColor;
    CGFloat         cornerRadius;
    UIBezierPath*   borderPath;
    
    NSString*       alphaTitle;
    NSArray*        alphaExtras;
    CGRect          alphaExtrasFrame;
    
    NSString*       uppercaseTitle;
    NSMutableArray* upperExtras;
    
    NSString*       numberTitle;
    NSString*       symbolTitle;
}

@property (nonatomic, assign)   BOOL        isTouched;
@property (nonatomic, readonly) UIView*     extrasView;     // lazy loaded

@end


#define kShadowOpacity (0.75f)

@implementation Key

@synthesize extrasView = _extrasView;

- (id)initWithTitle:(id)alpha
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
        
        if ([alpha isKindOfClass:[NSArray class]]) {
            alphaTitle  = alpha[0];    // primary title for this key
            alphaExtras = alpha;       // array of possible titles for this key
        } else {
            alphaTitle  = alpha;
        }
        
        if (number) {
            numberTitle = number;
        } else {
            numberTitle = alphaTitle;
        }
        
        if (symbol) {
            symbolTitle = symbol;
        } else {
            symbolTitle = numberTitle;
        }
        
        if (upper) {
            uppercaseTitle = upper;
        } else if (tag != Untagged) {
            // special key, use lowercase title even for shifted state
            uppercaseTitle = alphaTitle;
        } else {
            // no uppercase provided, convert lowercase if alphabetic key
            unichar ch = [alphaTitle characterAtIndex:0];
            _isAlpha = [[NSCharacterSet lowercaseLetterCharacterSet] characterIsMember:ch];
            
            if (_isAlpha) {
                uppercaseTitle = [alphaTitle uppercaseString];
                if (alphaExtras) {
                    upperExtras = [NSMutableArray arrayWithCapacity:alphaExtras.count];
                    for (NSString* lowerExtra in alphaExtras) {
                        [upperExtras addObject:[lowerExtra uppercaseString]];
                    }
                }
            } else {
                uppercaseTitle = alphaTitle;
            }
        }
        
        ///DLog(@"Key: %@ %@ %@ %@", _alphaTitle, _uppercaseTitle, _numberTitle, _symbolTitle);
        
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.userInteractionEnabled = NO;
        self.autoresizesSubviews = YES;
        self.clipsToBounds = NO;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.minimumScaleFactor = 0.5f;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont fontWithName:kKeyboardFontName size:fontSize];
        
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 2);
        
        [self setTitle:alphaTitle forState:UIControlStateNormal];
        [self setTitleColor:kKeyFontColor forState:UIControlStateNormal];
        
        if (self.tag == Untagged || self.tag == SpaceBar) {
            keyColor = kKeyBackgroundColor;
        } else {
            keyColor = kSpecialKeyColor;
        }
        cornerRadius = kKeyCornerRadius;
        
        self.layer.shadowColor   = [UIColor blackColor].CGColor;
        self.layer.shadowRadius  = 1.0f;
        self.layer.shadowOffset  = CGSizeMake(0,1);
        self.layer.shadowOpacity = kShadowOpacity;

//        self.layer.borderWidth = 0.5f;
//        self.layer.borderColor = [UIColor greenColor].CGColor;
        
        [self setNeedsLayout];      // layoutSubviews computes cornerRadius
    }
    return self;
}

+ (instancetype)key:(NSString *)title
{
    return [[Key alloc] initWithTitle:title upper:nil number:nil symbol:nil width:1 tag:Untagged font:kKeyboardFontSize];
}

+ (instancetype)key:(id)title number:(NSString*)number symbol:(NSString *)symbol
{
    return [[Key alloc] initWithTitle:title upper:nil number:number symbol:symbol width:1 tag:Untagged font:kKeyboardFontSize];
}

+ (instancetype)key:(id)title number:(NSString*)number symbol:(NSString*)symbol width:(CGFloat)width
{
    return [[Key alloc] initWithTitle:title upper:nil number:number symbol:symbol width:width tag:Untagged font:kKeyboardFontSize];
}

+ (instancetype)key:(id)title number:(NSString*)number width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize
{
    return [[Key alloc] initWithTitle:title upper:nil number:number symbol:nil width:width tag:tag font:fontSize];
}

+ (instancetype)key:(id)title upper:(NSString*)upper number:(NSString*)number symbol:(NSString*)symbol width:(CGFloat)width tag:(KeyTags)tag font:(CGFloat)fontSize
{
    return [[Key alloc] initWithTitle:title upper:upper number:number symbol:symbol width:width tag:tag font:fontSize];
}

- (UIView*)extrasView
{
    if (_extrasView == nil) {
        _extrasView = [[ExtraKeys alloc] initWithFrame:self.bounds];
        _extrasView.backgroundColor = keyColor;
        _extrasView.layer.cornerRadius = cornerRadius;
        [self setNeedsLayout];
    }
    return _extrasView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    // guard against initial size of 0
    CGRect bounds = self.bounds;
    if (bounds.size.height >= 1 && bounds.size.width >= 1) {
        // create path for normal key border
        CGRect insetRect = CGRectInset(bounds, kKeyInsetX, kKeyInsetY);
        borderPath = [UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:cornerRadius];
        self.layer.shadowPath = borderPath.CGPath;
        [self setNeedsDisplay];
    }

    if (_extrasView) {
        // compute frame for extra keys view
        const CGRect superBounds = self.superview.bounds;
        const CGRect keyFrame = self.frame;
        CGRect extraFrame;
        extraFrame.size.height = keyFrame.size.height;
        extraFrame.origin.y    = (keyFrame.origin.y - extraFrame.size.height);
        extraFrame.size.width  = (alphaExtras.count * (keyFrame.size.width/_width)) - kKeyInsetX*2;
        extraFrame.origin.x    = (CGRectGetMidX(keyFrame) - (extraFrame.size.width/2)) + kKeyInsetX;
        
        // make sure extrasView doesn't go outside bounds of our superview
        if (extraFrame.origin.y < superBounds.origin.y+kKeyInsetX) {
            extraFrame.origin.y = superBounds.origin.y+kKeyInsetX;
        }
        if (extraFrame.origin.x < superBounds.origin.x+kKeyInsetX) {
            extraFrame.origin.x = superBounds.origin.x+kKeyInsetX;
        }
        if (CGRectGetMaxX(extraFrame) > CGRectGetMaxX(superBounds)) {
            extraFrame.origin.x = CGRectGetMaxX(superBounds) - extraFrame.size.width;
        }
        
        extraFrame = [self.superview convertRect:extraFrame toView:self];
        self.extrasView.frame = extraFrame;
        [self setNeedsDisplay];
    }
}

- (NSString*)title
{
    return [self titleForState:UIControlStateNormal];
}

- (void)updateShiftKey
{
    const BOOL keyDown = _isTouched || _shiftState == Shifted || _shiftState == ShiftLock || _shiftState == Symbols;
    
    // no shadow when key is pressed or shifted or locked
    self.layer.shadowOpacity = keyDown ? 0 : kShadowOpacity;
    
    [self setNeedsDisplay];
}

- (void)updateNumbersKey
{
    const BOOL numbersMode = _isTouched || _shiftState == Numbers || _shiftState == Symbols;
    
    // no shadow when key pressed or in numbers/symbols mode
    self.layer.shadowOpacity = numbersMode ? 0 : kShadowOpacity;
    
    [self setNeedsDisplay];
}

- (BOOL)hasExtras
{
    BOOL hasExtras = NO;
    
    switch (_shiftState) {
        case Unshifted:     hasExtras = alphaExtras.count > 1;     break;
        case ShiftLock:
        case Shifted:
        case Numbers:
        case Symbols:
            break;
    }
    
    return hasExtras;
}

- (void)setIsTouchedLong:(BOOL)isTouchedLong
{
    if (_isTouchedLong != isTouchedLong) {
        _isTouchedLong = isTouchedLong;
        
        if (isTouchedLong) {
            [self addSubview:self.extrasView];
            [self setNeedsLayout];
            
        } else {
            // Caution: extrasView getter will lazy load
            [_extrasView removeFromSuperview];
        }
    }
}

- (void)setIsTouched:(BOOL)isTouched
{
    if (_isTouched != isTouched) {
        _isTouched = isTouched;
        
        if (!isTouched) {
            self.isTouchedLong = NO;
        }
        
        //DLog(@"%@ key %@", self.name, isTouched ? @"touched" : @"released");
        
        if (self.tag == ShiftKey) {
            [self updateShiftKey];
            
        } else if (self.tag == NumbersKey) {
            [self updateNumbersKey];
        
        } else {
            self.layer.shadowOpacity = isTouched ? 0 : kShadowOpacity;
    
            if ([self hasExtras]) {
                if (isTouched) {
                    [self performSelector:@selector(longTouchStarted:)
                               withObject:nil
                               afterDelay:kLongPressDelayMS / 1000.0];
                } else {
                    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                             selector:@selector(longTouchStarted:)
                                                               object:nil];
                }
            }
        }
    }
}

- (void)setShiftState:(ShiftState)shiftState
{
    if (_shiftState != shiftState) {
        _shiftState = shiftState;
        
        NSString* newTitle = nil;

        switch (shiftState) {
            case Unshifted: newTitle = alphaTitle;      break;
            case ShiftLock:
            case Shifted:   newTitle = uppercaseTitle;  break;
            case Numbers:   newTitle = numberTitle;     break;
            case Symbols:   newTitle = symbolTitle;     break;
        }

        if (self.tag == ShiftKey) {
            [self updateShiftKey];
            
            if (shiftState == Shifted) {
                newTitle = alphaTitle;
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
                case Unshifted: return alphaTitle;
                case Shifted:
                case ShiftLock: return uppercaseTitle;
                case Numbers:   return numberTitle;
                case Symbols:   return symbolTitle;
            }
    }
}

- (void)setErrorPointsForTouch:(UITouch*)touch
{
    const CGPoint touchPoint = [touch locationInView:self];
    CGRect keyRect = self.bounds;
    
    CGFloat xFromLeft  = kMaxErrorPoints - MIN(kMaxErrorPoints, touchPoint.x - CGRectGetMinX(keyRect));
    CGFloat xFromRight = kMaxErrorPoints - MIN(kMaxErrorPoints, CGRectGetMaxX(keyRect) - touchPoint.x);
    if (xFromLeft > 0 && self.leftmost) {
        xFromLeft = 0;      // ignore errors off the left side of the leftmost key
    } else if (xFromRight > 0 && self.rightmost) {
        xFromRight = 0;     // ignore errors off the right side of the rightmost key
    }
    CGFloat xError = MAX(xFromLeft, xFromRight);
    
    CGFloat yFromTop    = kMaxErrorPoints - MIN(kMaxErrorPoints, touchPoint.y - CGRectGetMinY(keyRect));
    CGFloat yFromBottom = kMaxErrorPoints - MIN(kMaxErrorPoints, CGRectGetMaxY(keyRect) - touchPoint.y);
    if (yFromBottom > 0 && self.lastRow) {
        yFromBottom = 0;     // ignore errors off the bottom side of the last row, no row below it
    }
    CGFloat yError = MAX(yFromTop, yFromBottom);
    
    _errorPoints = MAX(xError, yError);
    
    DLog(@"touchPoint: {%0.0f, %0.0f}  err: %0.0f pts", touchPoint.x, touchPoint.y, _errorPoints);
}

#pragma mark - Touch Start Stop

- (void)longTouchStarted:(id)object
{
    DLog(@"");
    self.isTouchedLong = YES;
}

#pragma mark - Touch Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    [self setErrorPointsForTouch:touch];
    
    self.isTouched = YES;
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setErrorPointsForTouch:touch];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    [self setErrorPointsForTouch:touch];
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    self.isTouched = NO;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    DLog(@"");
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
    self.isTouched = NO;
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    // Draw key border and fill inside
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(ctx, keyColor.CGColor);
    
    [borderPath fill];
}

@end
