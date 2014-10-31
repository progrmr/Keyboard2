//
//  KeyboardView.m
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardView.h"
#import "KeyboardConstants.h"
#import "Key.h"
#import "CrosshairsView.h"
#import "NSLayoutConstraint+Additions.h"
#import <AudioToolbox/AudioServices.h>

#define kInsertionBarWidth (2.0f)

@interface KeyboardView ()
@property (nonatomic, strong) UILabel*        beforeLabel;
@property (nonatomic, strong) UILabel*        afterLabel;
@property (nonatomic, strong) NSMutableArray* keyRows;      // array of array of Key
@property (nonatomic, assign) CGFloat         keyHeight;
@property (nonatomic, assign) CGFloat         keyWidth;
@property (nonatomic, strong) NSMutableArray* keyHeights;   // array of NSLayoutConstraint
@property (nonatomic, strong) UIView*         insertionBar;
@property (nonatomic, strong) CrosshairsView* crossHairView;
@property (nonatomic, strong) Key*            backspaceKey; // reference to backspace key
@property (nonatomic, strong) Key*            curKey;       // currently pressed key
@end

@implementation KeyboardView

- (id)init
{
    self = [super init];
    if (self) {
        _shiftState = Unshifted;
        _keyRows    = [NSMutableArray arrayWithCapacity:kNumberOfRows];
        _keyHeights = [NSMutableArray arrayWithCapacity:kNumberOfKeysPerRow * kNumberOfRows];
        _keyHeight  = kKeyHeightPortrait;
        
        _beforeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,kPreviewHeight)];
        _beforeLabel.textAlignment = NSTextAlignmentRight;
        _beforeLabel.lineBreakMode = NSLineBreakByTruncatingHead;
        _beforeLabel.font = [UIFont fontWithName:kKeyboardFontName size:kKeyboardFontSize];
        _beforeLabel.backgroundColor = kKeyboardBackgroundColor;
        [self addSubview:_beforeLabel];
        
        _afterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,0,kPreviewHeight)];
        _afterLabel.textAlignment = NSTextAlignmentLeft;
        _afterLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _afterLabel.font = [UIFont fontWithName:kKeyboardFontName size:kKeyboardFontSize];
        _afterLabel.backgroundColor = kKeyboardBackgroundColor;
        [self addSubview:_afterLabel];
        
        _crossHairView = [[CrosshairsView alloc] init];
        _crossHairView.autoresizingMask = 0;        // manually resized in layoutSubviews
        _crossHairView.alpha = 0;
        [self addSubview:_crossHairView];
        
        _insertionBar = [[UIView alloc] init];
        _insertionBar.backgroundColor = [UIColor colorWithRed:66/255.0f green:107/255.0f blue:242/255.0f alpha:1];
        [self addSubview:_insertionBar];
        
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor  = kKeyboardBackgroundColor;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    
    CGPoint crossHairCenter = self.crossHairView.center;
    self.crossHairView.frame = CGRectInset(bounds, -bounds.size.width/2, -bounds.size.height/2);
    self.crossHairView.center = crossHairCenter;
    
    CGRect beforeFrame = self.beforeLabel.frame;
    beforeFrame.size.width = bounds.size.width / 2;
    self.beforeLabel.frame = beforeFrame;
    
    CGRect afterFrame = self.afterLabel.frame;
    afterFrame.size.width = beforeFrame.size.width;
    afterFrame.origin.x = CGRectGetMaxX(beforeFrame) + kInsertionBarWidth;
    self.afterLabel.frame = afterFrame;
    
    CGRect insertionBarFrame = CGRectMake(CGRectGetMaxX(beforeFrame),
                                          beforeFrame.origin.y+4,
                                          kInsertionBarWidth,
                                          beforeFrame.size.height-6);
    self.insertionBar.frame = insertionBarFrame;
}

- (void)setShiftState:(ShiftState)shiftState
{
    if (_shiftState != shiftState) {
        DLog(@"change shift state from %d to %d", _shiftState, shiftState);
        
        _shiftState = shiftState;
        
        for (NSArray* rowOfKeys in self.keyRows) {
            for (Key* key in rowOfKeys) {
                key.shiftState = shiftState;
            }
        }
    }
}

- (void)setKeyHeight:(CGFloat)keyHeight
{
    if (_keyHeight != keyHeight) {
        _keyHeight = keyHeight;
   
        for (NSLayoutConstraint* heightConstraint in self.keyHeights) {
            heightConstraint.constant = keyHeight;
        }
        
        [self setNeedsUpdateConstraints];
    }
}

- (void)setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    
    [super setFrame:frame];

    if (oldFrame.size.height != frame.size.height) {
        const CGFloat keyboardHeight = frame.size.height - kPreviewHeight;
        const CGFloat spaceBetweenRows = kKeySpacerY * (kNumberOfRows-1);
        self.keyHeight = (keyboardHeight - spaceBetweenRows) / kNumberOfRows;
        
        const CGFloat keyboardWidth = frame.size.width;
        self.keyWidth = keyboardWidth / kNumberOfKeysPerRow;
        
        DLog(@"%@, keys: {%0.1f, %0.1f}", NSStringFromCGRect(frame), self.keyWidth, self.keyHeight);
    }
}

- (void)appendRowOfKeys:(NSArray *)keys target:(id)target action:(SEL)action
{
    const unsigned rowIndex = (unsigned) self.keyRows.count;
    const NSUInteger nKeys = keys.count;
    const BOOL firstRow = (rowIndex == 0);
    const NSLayoutAttribute belowAttr = /* firstRow ? NSLayoutAttributeTop : */ NSLayoutAttributeBottom;
    UIView* belowView = firstRow ? _beforeLabel : self.keyRows[rowIndex-1][0];
    float rowWidth = 0;
    
    for (NSUInteger keyIndex=0; keyIndex<nKeys; keyIndex++) {
        Key* key = keys[keyIndex];
        
        [self addSubview:key];
        
        // width of key
        [self addConstraint: NSLC(key, self, NSLayoutAttributeWidth,  key.width / (CGFloat)kNumberOfKeysPerRow, 0)];
        rowWidth += key.width;
        
        // height of key
        NSLayoutConstraint* keyHeight = NSLC2(key, NSLayoutAttributeHeight, nil, NSLayoutAttributeNotAnAttribute, 0, self.keyHeight);
        [self addConstraint: keyHeight];

        // save all key height constraints
        [self.keyHeights addObject:keyHeight];

        // top edge of key
        [self addConstraint: NSLC2(key, NSLayoutAttributeTop,  belowView, belowAttr, 1, firstRow ? 0 : kKeySpacerY)];
        
        if (keyIndex > 0) {
            // left edge of key at right edge of previous key
            [self addConstraint: NSLC2(key, NSLayoutAttributeLeft, keys[keyIndex-1],  NSLayoutAttributeRight, 1, 0) ];
        }
        
        // add target/action for touch up inside
        [key addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
        
        // find the backspace key
        if (key.tag == BackspaceKey) {
            self.backspaceKey = key;
        }
    }
    
    // this is a full row of keys, pin them to the view left and right bounds
    [self addConstraint: NSLC(keys[0], self, NSLayoutAttributeLeft, 1, 0)];
    
    if (lroundf(rowWidth) == kNumberOfKeysPerRow) {
        DLog(@"row %u is full row of %0.0f keys", rowIndex, rowWidth);
        [self addConstraint: NSLC(keys[nKeys-1], self, NSLayoutAttributeRight, 1, 0)];
    } else {
        DLog(@"row %u is partial row of %0.1f keys", rowIndex, rowWidth);
    }
   
    // add the row of keys array to the keyRows array
    [self.keyRows addObject:keys];
    
    // make sure the crossHairsView stays in front of the keys
    [self bringSubviewToFront:self.crossHairView];
}

#pragma mark -
#pragma mark Touch Tracking

- (void)showCrossHairsForTouchPoint:(CGPoint)touchPoint inKey:(Key*)touchedKey
{
    CGFloat touchError = touchedKey.errorPoints;
    
    if (touchError >= kDiscardPoints) {
        self.backgroundColor = [UIColor redColor];
        self.crossHairView.crossColor  = [UIColor redColor];
        self.crossHairView.lineWidth  = 3;
        
    } else if (touchError >= kWarningPoints) {
        self.backgroundColor = kKeyboardBackgroundColor;
        self.crossHairView.crossColor  = [UIColor orangeColor];
        self.crossHairView.lineWidth  = 2;
        
    } else {
        self.backgroundColor = kKeyboardBackgroundColor;
        self.crossHairView.crossColor  = [UIColor colorWithRed:0 green:0.66f blue:0 alpha:1];
        self.crossHairView.lineWidth  = 1;
    }
    
    self.crossHairView.center = touchPoint;
}

// returns currently touched key,
// updates self.keyError property
- (Key*)keyFromTouchPoint:(CGPoint)touchPoint
{
    const CGFloat touchOffset = touchPoint.y - kPreviewHeight;
    
    if (touchOffset < 0) {
        // touch is off the top of the keyboard in the preview area, treat as backspace
        return self.backspaceKey;
    }
    
    const CGFloat keyRowsHeight = self.bounds.size.height - kPreviewHeight;
    NSUInteger curRow = (NSUInteger) ((touchOffset / keyRowsHeight) * kNumberOfRows);
    if (curRow >= self.keyRows.count) {
        curRow = self.keyRows.count - 1;
    }
    
    NSArray* keys   = self.keyRows[curRow];
    Key* touchedKey = nil;
    unsigned curCol = 0;
    
    for (; curCol<keys.count; curCol++) {
        Key* key = keys[curCol];
        CGRect keyFrame = key.frame;
        if (touchPoint.x >= keyFrame.origin.x) {
            if (touchPoint.x < keyFrame.origin.x+keyFrame.size.width) {
                touchedKey = key;
                break;
            }
        }
    }
    return touchedKey;
}

- (void)updatePreviewText
{
    NSString* beforeText = [self.textDocumentProxy documentContextBeforeInput];
    if (!beforeText) {
        beforeText = @"";
    }
    NSString* afterText = [self.textDocumentProxy documentContextAfterInput];
    if (!afterText) {
        afterText = @"";
    }
    
    if (_curKey == nil) {
        self.beforeLabel.text = beforeText;
        self.afterLabel.text  = afterText;
        
    } else {
        switch ((KeyTags)_curKey.tag) {
            case Untagged:
                self.beforeLabel.text = [NSString stringWithFormat:@"%@%@", beforeText, _curKey.title];
                break;
            case SpaceBar:
                break;
            case BackspaceKey:
                if (beforeText.length) {
                    self.beforeLabel.text = [beforeText substringToIndex:beforeText.length-1];
                } else {
                    self.beforeLabel.text = @"";
                }
                break;
            case ShiftKey:
            case NumbersKey:
            case ReturnKey:
            case NextKeyboard:
                break;
        }
    }
}

//-----------------------------------------------------------------------
// touch tracking
//-----------------------------------------------------------------------

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        const CGPoint touchPoint  = [touch locationInView:self];
        _curKey = [self keyFromTouchPoint:touchPoint];
        
        DLog(@">>> key: %@", _curKey.name);
        
        if (_curKey) {
            [_curKey beginTrackingWithTouch:touch withEvent:event];
            
            self.crossHairView.alpha = 1;
            [self showCrossHairsForTouchPoint:touchPoint inKey:_curKey];
            
            [self updatePreviewText];
            
            [self insertSubview:_curKey belowSubview:_crossHairView];
        }
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        const CGPoint touchPoint  = [touch locationInView:self];
        
        // if a long press is in progress, showing extra keys, continue tracking that key
        Key* newKey = _curKey.isTouchedLong ? _curKey : [self keyFromTouchPoint:touchPoint];
        
        if (newKey == _curKey) {
            // continue tracking on current key
            [_curKey continueTrackingWithTouch:touch withEvent:event];
            [self showCrossHairsForTouchPoint:touchPoint inKey:_curKey];
            
            if (_curKey.isTouchedLong) {
                // selected key title may change even though we are tracking the same key
                [self updatePreviewText];
            }
            
        } else {
            // dragged to a new key
            [_curKey cancelTrackingWithEvent:event];
            _curKey = newKey;
            [_curKey beginTrackingWithTouch:touch withEvent:event];
            
            [self showCrossHairsForTouchPoint:touchPoint inKey:_curKey];

            [self updatePreviewText];
            
            [self insertSubview:_curKey belowSubview:_crossHairView];
        }
    }
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent*)event
{
    if (event.type == UIEventTypeTouches) {
        DLog(@"key: %@", _curKey.name);
        
        if (_curKey) {
            [_curKey cancelTrackingWithEvent:event];
            _curKey = nil;
            
            self.backgroundColor = kKeyboardBackgroundColor;
            self.crossHairView.alpha = 0;
            [self updatePreviewText];
        }
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        const CGPoint touchPoint  = [touch locationInView:self];
        
        // if a long press is in progress, showing extra keys, continue tracking that key
        Key* newKey = _curKey.isTouchedLong ? _curKey : [self keyFromTouchPoint:touchPoint];
        
        DLog(@"  <<< key: %@", _curKey.name);
        
        if (newKey != _curKey) {
            // dragged outside previous key into a new key
            [_curKey cancelTrackingWithEvent:event];
            _curKey = newKey;
            [newKey beginTrackingWithTouch:touch withEvent:event];
        }
        
        if (_curKey) {
            [_curKey endTrackingWithTouch:touch withEvent:event];
            
            [self showCrossHairsForTouchPoint:touchPoint inKey:_curKey];

            _curKey = nil;
            
            self.backgroundColor = kKeyboardBackgroundColor;
            [self updatePreviewText];
            
            [UIView animateWithDuration:0.15
                                  delay:0.35
                                options:0
                             animations:^{
                                 self.crossHairView.alpha = 0;
                             }
                             completion:nil];
        }
    }
}

@end
