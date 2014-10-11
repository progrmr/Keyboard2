//
//  Key.m
//  Keyboard2
//
//  Created by Gary Morris on 10/11/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "Key.h"

@implementation Key

- (id)initWithTitle:(NSString*)title
{
    self = [super init];
    if (self) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.backgroundColor = [UIColor whiteColor];
        self.textColor = [UIColor blackColor];
        self.adjustsFontSizeToFitWidth = NO;
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont fontWithName:@"Courier" size:24];
        self.text = title;
        
        // add a border outline
        self.layer.borderColor = self.textColor.CGColor;
        self.layer.borderWidth = 0.5f;
        self.layer.cornerRadius = 8;
    }
    return self;
}

@end
