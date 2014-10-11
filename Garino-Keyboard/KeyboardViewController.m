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
#import "Key.h"

#define USE_CAMERA 0

@interface KeyboardViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSLayoutConstraint* heightConstraint;

@property (nonatomic, strong) UIColor*  textColor;

@property (nonatomic, strong) UIView* nextKeyboardButton;

@property (nonatomic, strong) UIView* row1key1;
@property (nonatomic, strong) UIView* row2key1;
@property (nonatomic, strong) UIView* row3key1;

@property (nonatomic, strong) UISwipeGestureRecognizer* backspaceGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* spaceGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* returnGR;
@property (nonatomic, strong) UISwipeGestureRecognizer* shiftGR;

@end


enum {
    kKeyboardHeightPortrait  = 132,
    kKeyboardHeightLandscape = 105,
    kNumberOfRows = 3,
};

const CGFloat keyHeightFactor = 1.0f / kNumberOfRows;

NSArray* row1Keys = nil;
NSArray* row2Keys = nil;
NSArray* row3Keys = nil;

@implementation KeyboardViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    return self;
}

- (void)updateViewConstraints {
    [super updateViewConstraints];
    
    // Add custom view sizing constraints here
    //NSLog(@"updateViewConstraints:  %@", [self viewSizeInfo]);
}

- (void)adjustKeyboardHeight
{
    // update keyboard height constraint for orientation change
    const CGSize screenSize = [UIScreen mainScreen].bounds.size;
    const BOOL isLandscape = screenSize.width > screenSize.height;
    const long preferredHeight = isLandscape ? kKeyboardHeightLandscape : kKeyboardHeightPortrait;
    const BOOL heightChanged = lroundf(self.view.bounds.size.height) != preferredHeight;
    
    if (heightChanged) {
        NSLog(@"orientation: %@", isLandscape ? @"LANDSCAPE" : @"PORTRAIT");
        NSLog(@"height: %ld", preferredHeight);
        self.heightConstraint.constant = preferredHeight;
        [self.view setNeedsUpdateConstraints];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad:            %@", [self viewSizeInfo]);

    row1Keys = @[ @"W", @"E", @"R", @"T", @"Y", @"U", @"I", @"O", @"P" ];
    row2Keys = @[ @"A", @"S", @"D", @"F", @"G", @"H", @"J", @"K", @"L" ];
    row3Keys = @[ @"🌍", @"Z", @"X", @"C", @"V", @"B", @"N", @"M", @"."];
    
    // Perform custom UI setup here
    self.textColor = [UIColor blackColor];
    
    self.row1key1 = [self addRowOfKeys:row1Keys belowView:self.view     belowViewAttr:NSLayoutAttributeTop];
    self.row2key1 = [self addRowOfKeys:row2Keys belowView:self.row1key1 belowViewAttr:NSLayoutAttributeBottom];
    self.row3key1 = [self addRowOfKeys:row3Keys belowView:self.row2key1 belowViewAttr:NSLayoutAttributeBottom];
    
    // REQUIRED: next keyboard button, we use the first key in row3
//    [self.row3key1 removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
//    [self.row3key1 addTarget:self action:@selector(advanceToNextInputMode) forControlEvents:UIControlEventTouchUpInside];
    
    self.backspaceGR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backspaceGesture:)];
    self.backspaceGR.direction = UISwipeGestureRecognizerDirectionLeft;
    
    self.spaceGR     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(spaceGesture:)];
    self.spaceGR.direction = UISwipeGestureRecognizerDirectionRight;
    
    self.returnGR    = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(returnGesture:)];
    self.returnGR.direction = UISwipeGestureRecognizerDirectionDown;
    
    self.shiftGR     = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shiftGesture:)];
    self.shiftGR.direction = UISwipeGestureRecognizerDirectionUp;
    
    [self.view addGestureRecognizer:self.backspaceGR];
    [self.view addGestureRecognizer:self.spaceGR];
    [self.view addGestureRecognizer:self.returnGR];
    [self.view addGestureRecognizer:self.shiftGR];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"viewDidAppear:          %@", [self viewSizeInfo]);

    // add auto layout constraints for view
    self.heightConstraint = [NSLayoutConstraint constraintWithItem: self.view
                                                         attribute: NSLayoutAttributeHeight
                                                         relatedBy: NSLayoutRelationEqual
                                                            toItem: nil
                                                         attribute: NSLayoutAttributeNotAnAttribute
                                                        multiplier: 0 constant: 0];
    self.heightConstraint.priority = 999;
    [self.view addConstraint:self.heightConstraint];
    [self adjustKeyboardHeight];
}

// viewWillLayoutSubviews gets called twice at the start of an orientation change
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    NSLog(@"viewWillLayoutSubviews: %@", [self viewSizeInfo]);
    
    [self adjustKeyboardHeight];
}

- (NSString*)viewSizeInfo
{
    return [NSString stringWithFormat:@"frame: %@, window: %@, screen: %@", NSStringFromCGSize(self.view.bounds.size), NSStringFromCGSize(self.view.window.bounds.size), NSStringFromCGSize([UIScreen mainScreen].bounds.size)];
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
//    [self.nextKeyboardButton setTitleColor:textColor forState:UIControlStateNormal];
}

- (void)keyPressed:(UIButton*)sender
{
    NSString* title = [sender titleForState:UIControlStateNormal];
    
    [self.textDocumentProxy insertText:title];
    
    if ([title isEqualToString:@"X"]) {
        dumpView(self.view.window, @"", NO);
        
#if USE_CAMERA
    } else if ([title isEqualToString:@"C"]) {
        [self startCameraPreview];
#endif
    }
}

- (void)backspaceGesture:(UISwipeGestureRecognizer*)gr
{
    [self.textDocumentProxy deleteBackward];
}

- (void)spaceGesture:(UISwipeGestureRecognizer*)gr
{
    [self.textDocumentProxy insertText:@" "];
}

- (void)returnGesture:(UISwipeGestureRecognizer*)gr
{
    //[self.textDocumentProxy insertText:@"\n"];
}

- (void)shiftGesture:(UISwipeGestureRecognizer*)gr
{
    
}

- (UIView*)addRowOfKeys:(NSArray*)keyTitles
              belowView:(UIView*)belowView
          belowViewAttr:(NSLayoutAttribute)belowViewAttr
{
    const CGFloat keyWidthFactor  = 1.0f / keyTitles.count;
    
    UIView* leftView = self.view;
    NSLayoutAttribute leftAttr = NSLayoutAttributeLeft;
    UIView* firstKey = nil;
    
    for (NSString* keyTitle in keyTitles) {
        Key* key = [[Key alloc] initWithTitle:keyTitle];

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
