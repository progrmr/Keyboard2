//
//  KeyboardViewController.m
//  Garino-Keyboard
//
//  Created by Gary Morris on 9/29/14.
//  Copyright (c) 2014 Gary Morris. All rights reserved.
//

#import "KeyboardViewController.h"
#import "NSLayoutConstraint+Additions.h"
#import "UtilitiesUI.h"
#import <AVFoundation/AVFoundation.h>

#define USE_CAMERA 0

@interface KeyboardViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIColor*  textColor;

@property (nonatomic, strong) UIButton* nextKeyboardButton;

@property (nonatomic, strong) UIButton* row1key1;
@property (nonatomic, strong) UIButton* row2key1;
@property (nonatomic, strong) UIButton* row3key1;

@end


enum { kKeyHeight = 50, kKeyWidth = 40 };

enum { kNumberOfRows = 3 };

const CGFloat keyHeightFactor = 1.0f / kNumberOfRows;

NSArray* row1Keys = nil;
NSArray* row2Keys = nil;
NSArray* row3Keys = nil;

@implementation KeyboardViewController

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    row1Keys = @[ @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P" ];
    row2Keys = @[ @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L" ];
    row3Keys = @[ @"🌍", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @"."];
    
    // Perform custom UI setup here
    self.textColor = [UIColor blackColor];
    
    self.row1key1 = [self addRowOfKeys:row1Keys belowView:self.view     belowViewAttr:NSLayoutAttributeTop];
    self.row2key1 = [self addRowOfKeys:row2Keys belowView:self.row1key1 belowViewAttr:NSLayoutAttributeBottom];
    self.row3key1 = [self addRowOfKeys:row3Keys belowView:self.row2key1 belowViewAttr:NSLayoutAttributeBottom];
    
    // REQUIRED: next keyboard button, we use the first key in row3
    [self.row3key1 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.row3key1 addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
}

- (void)textWillChange:(id<UITextInput>)textInput {
    // The app is about to change the document's contents. Perform any preparation here.
}

- (void)textDidChange:(id<UITextInput>)textInput {
    // The app has just changed the document's contents, the document context has been updated.
    
    UIColor *textColor = nil;
    if (self.textDocumentProxy.keyboardAppearance == UIKeyboardAppearanceDark) {
        textColor = [UIColor whiteColor];
    } else {
        textColor = [UIColor blackColor];
    }
    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)keyPressed:(UIButton*)sender
{
    NSString* title = [sender titleForState:UIControlStateNormal];
    
    NSLog(@"key pressed: %@", title);
    
    if ([title isEqualToString:@"X"]) {
        dumpView(self.view, @"", YES);
        
#if USE_CAMERA
    } else if ([title isEqualToString:@"C"]) {
        [self startCameraPreview];
#endif
    }
}

- (UIButton*)addRowOfKeys:(NSArray*)keyTitles
                belowView:(UIView*)belowView
            belowViewAttr:(NSLayoutAttribute)belowViewAttr
{
    const CGFloat keyWidthFactor  = 1.0f / keyTitles.count;
    
    UIView* leftView = self.view;
    NSLayoutAttribute leftAttr = NSLayoutAttributeLeft;
    UIButton* firstKey = nil;
    
    for (NSString* keyTitle in keyTitles) {
        UIButton* key = [self keyboardButton:keyTitle target:self action:@selector(keyPressed:)];
        
        if (firstKey == nil) {
            firstKey = key;
        }
        
        [self.view addSubview:key];
        
        [self.view addConstraints:@[ NSLC(key, self.view, NSLayoutAttributeWidth,  keyWidthFactor,  0),
                                     NSLC(key, self.view, NSLayoutAttributeHeight, keyHeightFactor, 0) ]];
        
        [self.view addConstraints:@[ NSLC2(key, NSLayoutAttributeLeft, leftView,  leftAttr,      1, 0),
                                     NSLC2(key, NSLayoutAttributeTop,  belowView, belowViewAttr, 1, 0) ]];
        
        leftView = key;
        leftAttr = NSLayoutAttributeRight;
    }
    
    return firstKey;
}

- (UIButton*)keyboardButton:(NSString*)keyTitle
                     target:(id)target
                     action:(SEL)action
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = [UIColor whiteColor];
    button.titleLabel.font = [UIFont systemFontOfSize:24];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.minimumScaleFactor = 0.5f;
    [button setTitle:keyTitle forState:UIControlStateNormal];
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    // add a border outline
    button.layer.borderColor = self.textColor.CGColor;
    button.layer.borderWidth = 0.5f;

    return button;
}

#if USE_CAMERA
static AVCaptureSession* session = nil;

- (AVCaptureDevice*)backCameraDevice
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == AVCaptureDevicePositionBack) {
            return device;
        }
    }
    return nil;
}

- (void)startCameraPreview
{
    if (session) {
        NSLog(@"ERROR: AV camera session already running");
        return;
    }
    
    // based on: http://weblog.invasivecode.com/post/18445861158/a-very-cool-custom-video-camera-with
    //
    NSError* error = nil;
    AVCaptureDevice* backCameraDevice = [self backCameraDevice];
    AVCaptureDeviceInput* backCameraInput = [AVCaptureDeviceInput deviceInputWithDevice:backCameraDevice error:&error];
    
    if (!backCameraInput) {
        NSLog(@"ERROR: %@", error);
        return;
    }
    
    // create the AV session
    session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetLow;
    
    if (![session canAddInput:backCameraInput]) {
        NSLog(@"ERROR: session cannot add back camera as input device");
        return;
    }
    
    // add camera to the session
    [session addInput:backCameraInput];
    
    // create a preview layer over the keyboard
    CALayer* rootLayer = self.view.layer;
    rootLayer.masksToBounds = YES;
    
    AVCaptureVideoPreviewLayer* captureVideoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    captureVideoPreviewLayer.frame = rootLayer.bounds;
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [rootLayer addSublayer:captureVideoPreviewLayer];
    
    // monitor for AV session runtime errors
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sessionRuntimeErrorNotification:)
                                                 name:AVCaptureSessionRuntimeErrorNotification
                                               object:nil];

    // start the AV session
    [session startRunning];
}

- (void)sessionRuntimeErrorNotification:(NSNotification*)notif
{
    id info = notif.userInfo;
    NSLog(@"%@", info);
}
#endif

@end
