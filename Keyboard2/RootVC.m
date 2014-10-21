//
//  RootVC.m
//  Keyboard2
//
//  Created by Gary Morris on 9/29/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "RootVC.h"

@interface RootVC()
@property (nonatomic, strong) UITextField* textField;
@end


@implementation RootVC

- (void)loadView
{
    UIView* view = [[UIView alloc] init];
    self.view = view;
    view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:1 alpha:1];
    
    UITextField* textField = [[UITextField alloc] initWithFrame:CGRectMake(10,10,300,40)];
    self.textField = textField;
    textField.backgroundColor = [UIColor whiteColor];
    [view addSubview:textField];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.textField becomeFirstResponder];
}

@end
