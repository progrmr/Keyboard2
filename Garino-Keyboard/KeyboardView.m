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

@interface KeyboardView ()
@property (nonatomic, strong) NSMutableArray* keyRows;      // array of array of Key
@property (nonatomic, assign) CGFloat         keyHeight;
@property (nonatomic, assign) CGFloat         keyWidth;
@property (nonatomic, strong) NSMutableArray* keyHeights;   // array of NSLayoutConstraint
@property (nonatomic, strong) CrosshairsView* crossHairView;
@end

@implementation KeyboardView

- (id)init
{
    self = [super init];
    if (self) {
        _shiftState = Unshifted;
        _keyRows    = [NSMutableArray arrayWithCapacity:kNumberOfRows];
        _keyHeights = [NSMutableArray arrayWithCapacity:kNumberOfKeysPerRow * kNumberOfRows];
        _keyHeight  = kKeyboardHeightPortrait;
        
        _crossHairView = [[CrosshairsView alloc] init];
        _crossHairView.autoresizingMask = 0;        // manually resized in layoutSubviews
        _crossHairView.alpha = 0;
        [self addSubview:_crossHairView];
        
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
    bounds = CGRectInset(bounds, -bounds.size.width/2, -bounds.size.height/2);
    self.crossHairView.frame = bounds;
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
   
        DLog(@"%0.1f", keyHeight);
        
        for (NSLayoutConstraint* heightConstraint in self.keyHeights) {
            heightConstraint.constant = keyHeight;
        }
        
        [self setNeedsUpdateConstraints];
    }
}

- (void)setKeyWidth:(CGFloat)keyWidth
{
    if (_keyWidth != keyWidth) {
        _keyWidth = keyWidth;
        
        DLog(@"%0.1f", keyWidth);
    }
}

- (void)setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    
    [super setFrame:frame];

    if (oldFrame.size.height != frame.size.height) {
        DLog(@"%@", NSStringFromCGRect(frame));
        
        const CGFloat keyboardHeight = frame.size.height;
        const CGFloat spaceBetweenRows = kKeySpacerY * (kNumberOfRows-1);
        self.keyHeight = (keyboardHeight - spaceBetweenRows) / kNumberOfRows;
        
        const CGFloat keyboardWidth = frame.size.width;
        self.keyWidth = keyboardWidth / kNumberOfKeysPerRow;
    }
}

- (void)appendRowOfKeys:(NSArray *)keys target:(id)target action:(SEL)action
{
    const NSUInteger rowIndex = self.keyRows.count;
    const NSUInteger nKeys = keys.count;
    const BOOL firstRow = (rowIndex == 0);
    const NSLayoutAttribute belowAttr = firstRow ? NSLayoutAttributeTop : NSLayoutAttributeBottom;
    UIView* belowView = firstRow ? self : self.keyRows[rowIndex-1][0];
    CGFloat rowWidth = 0;
    
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
    }
    
    // this is a full row of keys, pin them to the view left and right bounds
    [self addConstraint: NSLC(keys[0], self, NSLayoutAttributeLeft, 1, 0)];
    
    if (lroundf(rowWidth) == kNumberOfKeysPerRow) {
        DLog(@"row %d is full row of %0.0f keys", rowIndex, rowWidth);
        [self addConstraint: NSLC(keys[nKeys-1], self, NSLayoutAttributeRight, 1, 0)];
    } else {
        DLog(@"row %d is partial row of %0.1f keys", rowIndex, rowWidth);
    }
   
    // add the row of keys array to the keyRows array
    [self.keyRows addObject:keys];
    
    // make sure the crossHairsView stays in front of the keys
    [self bringSubviewToFront:self.crossHairView];
}

#pragma mark -
#pragma mark Touch Tracking
static Key* s_curKey;           // currently touched Key

- (void)showCrossHairsForTouchPoint:(CGPoint)touchPoint
                             forKey:(Key*)touchedKey
                      atKeyRowIndex:(NSUInteger)rowIndex
                      atKeyColIndex:(NSUInteger)colIndex
                    withMaxColIndex:(NSUInteger)maxColIndex
{
    CGRect keyFrame = touchedKey.frame;
    
    CGFloat xOffset = touchPoint.x - CGRectGetMidX(keyFrame);
    CGFloat xError  = xOffset / (keyFrame.size.width * 0.5f);
    if (xError < 0 && colIndex == 0) {
        xError = 0;     // ignore errors off the left side of the leftmost key
    } else if (xError > 0 && colIndex == maxColIndex) {
        xError = 0;     // ignore errors off the right side of the rightmost key
    }
    
    CGFloat yOffset = touchPoint.y - CGRectGetMidY(keyFrame);
    CGFloat yError  = yOffset / (keyFrame.size.height * 0.5f);
    if (yError < 0 && rowIndex == 0) {
        yError = 0;     // ignore errors off the top side of the first row, there is no row above it
    } else if (yError > 0 && rowIndex == kNumberOfRows-1) {
        yError = 0;     // ignore errors off the bottom side of the last row, no row below it
    }
    
    CGFloat maxError = MAX(fabsf(xError), fabsf(yError));
    
    ///DLog(@"touchPoint: %3.0f %3.0f, err: %0.2f", touchPoint.x, touchPoint.y, maxError);
    
    UIColor* crossHairColor = nil;
    //crossHairColor = [UIColor colorWithRed:maxError green:1-maxError blue:0 alpha:1];
    if (maxError > 0.60f) {
        crossHairColor = [UIColor redColor];
    } else {
        crossHairColor = [UIColor colorWithRed:0 green:1 blue:0 alpha:0.7f];
    }
    
    CGFloat crossLineWidth = 1;
    if (maxError > 0.82f) {
        crossLineWidth = 3.0f;
    } else if (maxError > 0.76f) {
        crossLineWidth = 2.5f;
    } else if (maxError > 0.68f) {
        crossLineWidth = 2.0f;
    } else if (maxError > 0.60f) {
        crossLineWidth = 1.5f;
    }

    self.crossHairView.crossColor   = crossHairColor;
    self.crossHairView.lineWidth    = crossLineWidth;
    self.crossHairView.center       = touchPoint;
}

- (Key*)keyFromTouch:(UITouch*)touch
{
    const CGPoint touchPoint  = [touch locationInView:self];

    NSUInteger curRow = (NSUInteger) ((touchPoint.y / self.bounds.size.height) * kNumberOfRows);
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
    
    [self showCrossHairsForTouchPoint:touchPoint
                               forKey:touchedKey
                        atKeyRowIndex:curRow
                        atKeyColIndex:curCol
                      withMaxColIndex:keys.count-1];
     
    return touchedKey;
}

//-----------------------------------------------------------------------
// touchingStation
//-----------------------------------------------------------------------
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        s_curKey = [self keyFromTouch:touch];
        DLog(@">>> key: %@", s_curKey.name);
        
        [s_curKey sendActionsForControlEvents:UIControlEventTouchDown];
        
        self.crossHairView.alpha = 1;
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        Key* newKey = [self keyFromTouch:touch];
        if (newKey != s_curKey) {
            // dragged to a new key
            [s_curKey sendActionsForControlEvents:UIControlEventTouchDragExit];
            [newKey sendActionsForControlEvents:UIControlEventTouchDragEnter];
            s_curKey = newKey;
        }
    }
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent*)event
{
    if (event.type == UIEventTypeTouches) {
        DLog(@"key: %@", s_curKey.name);
        
        [s_curKey sendActionsForControlEvents:UIControlEventTouchCancel];
        
        self.crossHairView.alpha = 0;
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        Key* newKey = [self keyFromTouch:touch];
        DLog(@"  <<< key: %@", s_curKey.name);
        
        if (newKey != s_curKey) {
            // dragged outside previous key into a new key
            [s_curKey sendActionsForControlEvents:UIControlEventTouchDragExit];
            [newKey sendActionsForControlEvents:UIControlEventTouchDragEnter];
        }
        
        [newKey sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.crossHairView.alpha = 0;
                         }];
    }
}

@end
