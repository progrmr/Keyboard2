//
//  CrosshairsView.m
//  ClockU
//
//  Created by Gary Morris on 4/15/10.
//  Copyright 2010 Gary A. Morris. All rights reserved.
//

#import "CrosshairsView.h"
#import "UtilitiesUI.h"

@implementation CrosshairsView

- (id)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        self.autoresizingMask   = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor    = [UIColor clearColor];
        self.crossColor         = [UIColor blackColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setNeedsDisplay];
}

- (void)setCrossColor:(UIColor *)newColor
{
	_crossColor = newColor;
	
	[self setNeedsDisplay];		// new crosshairs color, needs redrawing
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const CGFloat CENTERGAP = 4.5f;
	const CGFloat THICKNESS = 1.0f;

	CGContextSetFillColorWithColor(context, [_crossColor CGColor]);
	
	// Draw the crosshairs in the center of the view rectangle
	// draw the horizontal line
	CGFloat centerX = self.bounds.size.width  * 0.5f;
	CGFloat centerY = self.bounds.size.height * 0.5f;
	
	CGContextFillRect(context,
						CGRectMake(0, centerY-THICKNESS/2, 
								   centerX-CENTERGAP, THICKNESS));
	CGContextFillRect(context, 
						CGRectMake(centerX+CENTERGAP, centerY-THICKNESS/2,
								   centerX-CENTERGAP, THICKNESS));
	
	// draw the vertical line
	CGContextFillRect(context,
						CGRectMake(centerX-THICKNESS/2, 0, 
								   THICKNESS, centerY-CENTERGAP));
	CGContextFillRect(context,
						CGRectMake(centerX-THICKNESS/2, centerY+CENTERGAP,
								   THICKNESS, centerY-CENTERGAP));
}

@end









