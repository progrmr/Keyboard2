//
//  CrosshairsView.m
//  ClockU
//
//  Created by Gary Morris on 4/15/10.
//  Copyright 2010 Gary A. Morris. All rights reserved.
//

#import "CrosshairsView.h"
#import "KeyboardConstants.h"
#import "UtilitiesUI.h"

@implementation CrosshairsView

- (id)init
{
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        self.autoresizingMask   = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor    = [UIColor clearColor];
        
        _crossColor = [UIColor blackColor];
        _lineWidth  = 1.0f;
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
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

	CGContextSetFillColorWithColor(context, [_crossColor CGColor]);
	
	// Draw the crosshairs in the center of the view rectangle
	// draw the horizontal line
	CGFloat centerX = self.bounds.size.width  * 0.5f;
	CGFloat centerY = self.bounds.size.height * 0.5f;
	
	CGContextFillRect(context,
						CGRectMake(0, centerY-_lineWidth/2,
								   centerX-CENTERGAP, _lineWidth));
	CGContextFillRect(context, 
						CGRectMake(centerX+CENTERGAP, centerY-_lineWidth/2,
								   centerX-CENTERGAP, _lineWidth));
	
	// draw the vertical line
	CGContextFillRect(context,
						CGRectMake(centerX-_lineWidth/2, 0,
								   _lineWidth, centerY-CENTERGAP));
	CGContextFillRect(context,
						CGRectMake(centerX-_lineWidth/2, centerY+CENTERGAP,
								   _lineWidth, centerY-CENTERGAP));
}

@end









