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
        
        _crossHairView  = [[CrosshairsView alloc] init];
        _crossHairView.autoresizingMask = 0;        // manually resized in layoutSubviews
        _crossHairView.hidden = YES;
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

- (void)setFrame:(CGRect)frame
{
    const CGRect oldFrame = self.frame;
    
    [super setFrame:frame];

    if (oldFrame.size.height != frame.size.height) {
        DLog(@"%@", NSStringFromCGRect(frame));
        
        const CGFloat keyboardHeight = frame.size.height;
        const CGFloat spaceBetweenRows = kKeySpacerY * (kNumberOfRows-1);
        self.keyHeight = (keyboardHeight - spaceBetweenRows) / kNumberOfRows;
    }
}

- (void)appendRowOfKeys:(NSArray *)keys target:(id)target action:(SEL)action
{
    const NSUInteger rowIndex = self.keyRows.count;
    const NSUInteger nKeys = keys.count;
    const BOOL firstRow = (rowIndex == 0);
    const NSLayoutAttribute belowAttr = firstRow ? NSLayoutAttributeTop : NSLayoutAttributeBottom;
    UIView* belowView = firstRow ? self : self.keyRows[rowIndex-1][0];
    
    for (NSUInteger keyIndex=0; keyIndex<nKeys; keyIndex++) {
        Key* key = keys[keyIndex];
        
        [self addSubview:key];
        
        // width of key
        [self addConstraint: NSLC(key, self, NSLayoutAttributeWidth,  1.0f / kNumberOfKeysPerRow, 0)];
        
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
    
    const BOOL oddNumber = (nKeys % 2) == 1;    // odd number of keys in row

    if (oddNumber) {
        // the number of keys in this row is odd, then center X the middle key
        [self addConstraint: NSLC(keys[nKeys/2], self, NSLayoutAttributeCenterX, 1, 0)];
        
    } else {
        // the number of keys in this row is even then first key should be at left edge
        [self addConstraint: NSLC(keys[0], self, NSLayoutAttributeLeft, 1, 0)];
        
        // last key should be at right edge (helps size the containing view)
        [self addConstraint: NSLC(keys[nKeys-1], self, NSLayoutAttributeRight, 1, 0)];
    }
    
    // add the row of keys array to the keyRows array
    [self.keyRows addObject:keys];
    
    // make sure the crossHairsView stays in front of the keys
    [self bringSubviewToFront:self.crossHairView];
}

#pragma mark -
#pragma mark Touch Tracking
NSUInteger  curRow;         // currently touched keyboard row
NSUInteger  curCol;         // currently touched keyboard column
Key*        curKey;         // currently touched Key

- (Key*)keyFromTouch:(UITouch*)touch
{
    const CGPoint touchPoint  = [touch locationInView:self];
    DLog(@"touchPoint: %3.0f %3.0f", touchPoint.x, touchPoint.y);

    self.crossHairView.center = touchPoint;
    
    curRow = (NSUInteger) ((touchPoint.y / self.bounds.size.height) * kNumberOfRows);
    
    NSArray* keys   = self.keyRows[curRow];
    Key* firstKey   = keys[0];
    CGRect keyFrame = firstKey.frame;
    
    CGFloat keyColumn = ((touchPoint.x - keyFrame.origin.x) / keyFrame.size.width);
    curCol = (NSUInteger) keyColumn;
    
    Key* key = (curRow < keys.count) ? keys[curCol] : nil;
    
    CGPoint keyCenter = key.center;
    CGFloat xOffset = fabsf(keyCenter.x-touchPoint.x);
    CGFloat yOffset = fabsf(keyCenter.y-touchPoint.y);
    CGFloat maxError = MAX(xOffset/keyFrame.size.width, yOffset/_keyHeight);
    
    self.crossHairView.crossColor = [UIColor colorWithRed:maxError*2 green:1-(maxError*2) blue:0 alpha:1];
    
    return key;
}

//-----------------------------------------------------------------------
// touchingStation
//-----------------------------------------------------------------------
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    if (event.type == UIEventTypeTouches) {
        self.crossHairView.hidden = NO;
        
        curKey = [self keyFromTouch:touch];
        [curKey sendActionsForControlEvents:UIControlEventTouchDown];
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        Key* newKey = [self keyFromTouch:touch];
        if (newKey != curKey) {
            // dragged to a new key
            [curKey sendActionsForControlEvents:UIControlEventTouchDragExit];
            [newKey sendActionsForControlEvents:UIControlEventTouchDragEnter];
            curKey = newKey;
        }
        
    }
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent*)event
{
    [curKey sendActionsForControlEvents:UIControlEventTouchCancel];
    
    self.crossHairView.hidden = YES;
    DLog(@"\n\n");
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        Key* newKey = [self keyFromTouch:touch];
        if (newKey != curKey) {
            // dragged outside previous key
            [curKey sendActionsForControlEvents:UIControlEventTouchDragExit];
        }
        [newKey sendActionsForControlEvents:UIControlEventTouchUpInside];
        
        self.crossHairView.hidden = YES;
    }
    DLog(@"\n\n");
}

@end
