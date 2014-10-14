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
#import "NSLayoutConstraint+Additions.h"

@interface KeyboardView () {
    BOOL _touching;
}

@property (nonatomic, strong) NSMutableArray* keyRows;
@property (nonatomic, assign) CGFloat         keyHeight;
@property (nonatomic, strong) NSMutableArray* keyHeights;

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
        
        self.userInteractionEnabled = YES;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor  = kKeyboardBackgroundColor;
    }
    return self;
}

- (NSArray*)keyboardRows
{
    return _keyRows;
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
    DLog(@"%0.1f", keyHeight);

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
    
    DLog(@"%@", NSStringFromCGRect(frame));
    
    [super setFrame:frame];

    if (!CGRectEqualToRect(oldFrame, frame)) {
        const CGFloat keyboardHeight = frame.size.height;
        const CGFloat keyHeight = (keyboardHeight + (-kKeySpacerY * (kNumberOfRows-1))) / kNumberOfRows;
        
        self.keyHeight = keyHeight;
    }
}

- (void)setBounds:(CGRect)bounds
{
    DLog(@"%@", NSStringFromCGRect(bounds));
    
    [super setBounds:bounds];
}

- (void)appendRowOfKeys:(NSArray *)keys
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
}

#pragma mark -
#pragma mark Touch Tracking

//-----------------------------------------------------------------------
// touchingStation
//-----------------------------------------------------------------------
- (void)touching:(UITouch*)touch
{
    const CGSize size = self.bounds.size;
    const CGPoint touchPoint  = [touch locationInView:self];
    
    DLog(@"touchPoint: %@", NSStringFromCGPoint(touchPoint));
    
//    StationId newStation = (StationId) touchPoint.x / sectionWidth;
//    
//    // move curStationView to where the touch is while touch is down
//    if (touchDragInProgress) {
//        // move station view and label along with touch
//        [self moveStationViewToX:touchPoint.x];
//        [self moveStationLabel:curStationLabel XCoordinate:touchPoint.x];
//        
//    } else {
//        CGFloat x = [self stationCenterX:newStation];
//        [self moveStationViewToX:x];
//        [self moveStationLabel:curStationLabel XCoordinate:x];
//    }
//    
//    if (newStation >= nStations) newStation = nStations-1;
//    
//    if (newStation != curStation) {
//        // Moved to a new station, update everyone
//        self.curStation = newStation;
//        
//        // Invoke action routine
//        [self sendActionsForControlEvents: UIControlEventValueChanged];
//    }
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    if (event.type == UIEventTypeTouches) {
        _touching = YES;
        [self touching:touch];
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        _touching = YES;
        [self touching:touch];
    }
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent*)event
{
    DLog(@"");
    _touching = NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    if (event.type == UIEventTypeTouches) {
        _touching = NO;
        [self touching:touch];
    }
}

@end
