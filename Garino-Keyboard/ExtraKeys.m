//
//  ExtraKeys.m
//  Keyboard2
//
//  Created by Gary Morris on 10/30/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "ExtraKeys.h"
#import "KeyboardConstants.h"

@interface ExtraKeys()
@property (nonatomic, assign) NSTimeInterval  longTouchDelay;
@property (nonatomic, assign) NSUInteger      selectedIndex;      // set by touch tracking
@end


@implementation ExtraKeys

- (id)init
{
    self = [super init];
    if (self) {
        self.layer.shadowOffset  = CGSizeMake(0,0);
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius  = 3;
        
        _selectedIndex = NSNotFound;
        _longTouchDelay = -1;       // invalid, needs to be computed
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect labelFrame = self.bounds;
    labelFrame.size.width /= self.subviews.count;
    
    for (UIView* extraLabel in self.subviews) {
        extraLabel.frame = labelFrame;
        
        labelFrame.origin.x += labelFrame.size.width;
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex) {
        if (_selectedIndex != NSNotFound) {
            // deselect previous entry
            UILabel* selectedLabel = self.subviews[_selectedIndex];
            selectedLabel.backgroundColor = self.backgroundColor;
            selectedLabel.textColor = kKeyFontColor;
        }
        
        _selectedIndex = selectedIndex;
        
        if (_selectedIndex != NSNotFound) {
            // select new entry
            UILabel* selectedLabel = self.subviews[_selectedIndex];
            selectedLabel.backgroundColor = kHighlightedKeyColor;
            selectedLabel.textColor = kHighlightedFontColor;
        }
    }
}

- (void)setExtraTitles:(NSArray *)extraTitles
{
    NSAssert(extraTitles.count >= 3, @"extraTitles must have at least 3 string entries");
    
    // get rid of old subviews
    _selectedIndex = NSNotFound;        // selected subview is being removed
    
    for (UIView* subview in [self subviews]) {
        [subview removeFromSuperview];
    }
    
    // create new array for extra titles, ignore first entry (superview's title)
    NSMutableArray* newExtraTitles = [NSMutableArray arrayWithCapacity:extraTitles.count-1];
    
    // skip index 0, that's the super key's title
    NSUInteger selectedIndex = NSNotFound;
    
    for (NSUInteger index=1; index<extraTitles.count; index++) {
        NSString* extraTitle = extraTitles[index];
        
        // a leading '*' marks the default selection in the array
        unichar ch = [extraTitle characterAtIndex:0];
        if (ch == '*') {
            extraTitle = [extraTitle stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:@""];
            selectedIndex = index-1;
        }
        
        // add title to the array
        [newExtraTitles addObject:extraTitle];
        
        // create a label for the extra title
        UILabel* extraLabel = [[UILabel alloc] init];
        extraLabel.text = extraTitle;
        extraLabel.textAlignment = NSTextAlignmentCenter;
        extraLabel.font = [UIFont fontWithName:kKeyboardFontName size:kKeyboardFontSize];
        extraLabel.textColor = kKeyFontColor;
        [self addSubview:extraLabel];
    }
    
    // if no entry was marked with '*' then choose the one that
    // matches the superview's title, or else use the last entry
    if (selectedIndex == NSNotFound) {
        selectedIndex = newExtraTitles.count-1;   // last entry unless...
        
        for (NSUInteger index=0; index<newExtraTitles.count; index++) {
            if ([newExtraTitles[index] isEqualToString:extraTitles[0]]) {
                selectedIndex = index;
                break;
            }
        }
    }
    
    // set the long touch delay based on the unmodified extraTitles
    [self setLongTouchDelayForTitles:newExtraTitles withSuperTitle:extraTitles[0]];
    
    // save the array of titles and select one of the labels
    _extraTitles = newExtraTitles;
    self.selectedIndex = selectedIndex;
    
    [self setNeedsLayout];
}

- (void)setLongTouchDelayForTitles:(NSArray*)extraTitles withSuperTitle:(NSString*)superTitle
{
    // determine the long touch delay time, if any entry matches the superview's
    // title, then we need a long touch delay, otherwise delay is 0
    _longTouchDelay = 0;
    
    for (NSString* extraTitle in extraTitles) {
        if ([extraTitle isEqualToString:superTitle]) {
            _longTouchDelay = kLongPressDelayMS / 1000.0;
            break;
        }
    }
}

- (NSUInteger)closestSubviewIndexToTouch:(UITouch*)touch
{
    const CGPoint touchPoint  = [touch locationInView:self];
    NSUInteger index = 0;
    
    while (index < self.subviews.count) {
        UIView* subview = self.subviews[index];
        CGRect svFrame = subview.frame;
        
        if (touchPoint.x <= CGRectGetMaxX(svFrame)) {
            return index;
        }
        index++;
    }
    
    return self.subviews.count-1;
}

#pragma mark - Touch Tracking

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    // which subview is the touch.x closest to?  make that the selected one
    self.selectedIndex = [self closestSubviewIndexToTouch:touch];
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    DLog(@"");
    self.selectedIndex = NSNotFound;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    DLog(@"");
    self.selectedIndex = [self closestSubviewIndexToTouch:touch];
}

@end
