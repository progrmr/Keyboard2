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
@property (nonatomic, assign)   NSUInteger      selectedIndex;
@end


@implementation ExtraKeys

- (id)init
{
    self = [super init];
    if (self) {
        self.layer.shadowOffset  = CGSizeMake(0,0);
        self.layer.shadowOpacity = 0.75f;
        self.layer.shadowRadius  = 3;
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

- (void)setExtraTitles:(NSArray *)extraTitles
{
    if (_extraTitles != extraTitles) {
        _extraTitles = [extraTitles copy];
        
        // get rid of old subviews
        for (UIView* subview in [self subviews]) {
            [subview removeFromSuperview];
        }
        
        // create UILabel subviews for each extra title
        self.selectedIndex = NSNotFound;
        
        // skip index 0, that's the super key's title
        for (NSUInteger index=1; index<extraTitles.count; index++) {
            NSString* extraTitle = extraTitles[index];
            
            unichar ch = [extraTitle characterAtIndex:0];
            if (ch == '*' && self.selectedIndex == NSNotFound) {
                NSRange range;
                range.length   = 1;
                range.location = 0;
                extraTitle = [extraTitle stringByReplacingCharactersInRange:range withString:@""];
                self.selectedIndex = index;
            }
 
            UILabel* extraLabel = [[UILabel alloc] init];
            extraLabel.text = extraTitle;
            extraLabel.textAlignment = NSTextAlignmentCenter;
            extraLabel.font = [UIFont fontWithName:kKeyboardFontName size:kKeyboardFontSize];
            extraLabel.textColor = kKeyFontColor;
            [self addSubview:extraLabel];
        }
        
        [self setNeedsLayout];
    }
}

@end
