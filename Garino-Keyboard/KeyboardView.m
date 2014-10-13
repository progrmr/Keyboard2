//
//  KeyboardView.m
//  Keyboard2
//
//  Created by Gary Morris on 10/13/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardView.h"

@interface KeyboardView () {
    BOOL _touchDragInProgress;
}

@end

@implementation KeyboardView

#pragma mark -
#pragma mark Touch Tracking

//-----------------------------------------------------------------------
// touchingStation
//-----------------------------------------------------------------------
- (void)touchingStation:(UITouch*)touch
{
    const CGSize size = self.bounds.size;
    const CGPoint touchPoint  = [touch locationInView:self];
    
    
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
    if (event.type == UIEventTypeTouches) {
        _touchDragInProgress = YES;
        [self touchingStation:touch];
    }
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        _touchDragInProgress = YES;
        [self touchingStation:touch];
    }
    return YES;
}

- (void)cancelTrackingWithEvent:(UIEvent*)event
{
    _touchDragInProgress = NO;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeTouches) {
        _touchDragInProgress = NO;
        [self touchingStation:touch];
    }
}

@end
