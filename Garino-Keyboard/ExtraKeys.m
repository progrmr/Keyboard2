//
//  ExtraKeys.m
//  Keyboard2
//
//  Created by Gary Morris on 10/30/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "ExtraKeys.h"

@implementation ExtraKeys

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.shadowOffset  = CGSizeMake(0,0);
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius  = 3;
    }
    return self;
}

@end
