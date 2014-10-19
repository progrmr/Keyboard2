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

enum { kLabelOffset = 50 };

@interface CrosshairsView()
@property (nonatomic, strong) UILabel* lLabel;
@property (nonatomic, strong) UILabel* rLabel;
@end

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
        
        _lLabel = [[UILabel alloc] init];
        _lLabel.backgroundColor   = kKeyBackgroundColor;
        _lLabel.font              = [UIFont fontWithName:@"Helvetica" size:17];
        _lLabel.lineBreakMode     = NSLineBreakByTruncatingHead;
        _lLabel.layer.borderWidth = _lineWidth;
        _lLabel.frame = CGRectMake(0,0,100,22);
        [self addSubview:_lLabel];
        
        _rLabel = [[UILabel alloc] init];
        _rLabel.backgroundColor   = _lLabel.backgroundColor;
        _rLabel.font              = _lLabel.font;
        _rLabel.lineBreakMode     = _lLabel.lineBreakMode;
        _rLabel.layer.borderWidth = _lLabel.layer.borderWidth;
        _rLabel.frame = CGRectMake(0,0,100,22);
        [self addSubview:_rLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    CGRect labelFrame  = _rLabel.frame;
    labelFrame.origin.x = CGRectGetMidX(bounds) + kLabelOffset;
    labelFrame.origin.y = CGRectGetMidY(bounds) - labelFrame.size.height/2;
    _rLabel.frame = labelFrame;
    
    labelFrame.origin.x = CGRectGetMidX(bounds) - (kLabelOffset+labelFrame.size.width);
    _lLabel.frame = labelFrame;
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

- (void)setText:(NSString *)text
{
    _rLabel.text = text;
    _lLabel.text = text;
}

- (NSString*)text
{
    return _rLabel.text;
}

- (void)setCrossColor:(UIColor *)newColor
{
	_crossColor = newColor;
    _rLabel.layer.borderColor = newColor.CGColor;
    _lLabel.layer.borderColor = newColor.CGColor;
    
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









