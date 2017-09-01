//
//  LXQRCodeViewController.m
//  LXQRCodeDemo
//
//  Created by alisa on 2017/9/1.
//  Copyright © 2017年 alisa. All rights reserved.
//

#import "LXQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "LXQRCodeView.h"
#import "Masonry.h"
#import "UIColor+HexString.h"
@interface LXQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate>
@property(nonatomic, strong)AVCaptureDeviceInput        *deviceInput;//!< 摄像头输入
@property(nonatomic, strong)AVCaptureMetadataOutput     *metadataOutput;//!< 输出
@property(nonatomic, strong)AVCaptureSession            *session;//!< 会话
@property(nonatomic, strong)AVCaptureVideoPreviewLayer  *previewLayer;//!< 预览
@property(nonatomic, strong)LXQRCodeView     *preView;
@property(nonatomic, strong)AVCaptureDevice *device;
@property(nonatomic, assign)BOOL isONFlash;

@end

@implementation LXQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor blackColor];
    UIImage *leftNormalImage = [UIImage imageNamed:@"icon-back"];
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setImage:leftNormalImage forState:UIControlStateNormal];
    customButton.frame = CGRectMake(0, 0, 25, 25);
    [customButton addTarget:self action:@selector(customButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    _preView.isFlashON = NO;
    _isONFlash = YES;
    [self turnONOrOffFlash];
}

-(void)customButtonClicked{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNavSettings];
    [self initUiConfig];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.session beginConfiguration];
    [_device lockForConfiguration:nil];
    [_device setTorchMode:AVCaptureTorchModeOff];
    [_device unlockForConfiguration];
    [self.session commitConfiguration];
    _preView.isFlashON = NO;
    [self resetNavNavSettings];
}

- (void)setNavSettings
{
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"000000"];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)resetNavNavSettings{
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)initUiConfig {
    // 默认为后置摄像头
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:NULL];
    // 解析输入的数据
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    // 会话
    self.session = [[AVCaptureSession alloc] init];
    if ([self.session canAddInput:self.deviceInput]){
        [self.session addInput:self.deviceInput];
    }
    if([self.session canAddOutput:self.metadataOutput]){
        [self.session addOutput:self.metadataOutput];
    }
    // 设置数据采集质量
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    _preView = [[LXQRCodeView alloc] init];
    __weak typeof(self)weakSelf = self;
    _preView.flashBlock = ^{
        [weakSelf turnONOrOffFlash];
    };
    [self.view addSubview:_preView];
    [_preView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.equalTo(@0);
    }];
    CGSize size = self.view.bounds.size;
    CGRect cropRect = CGRectMake(size.width/2-130,100,260,260);
    self.metadataOutput.rectOfInterest =  CGRectMake(cropRect.origin.y/size.height,
                                                     cropRect.origin.x/size.width,
                                                     cropRect.size.height/size.height,
                                                     cropRect.size.width/size.width);
    _preView.session = self.session;
    [self.session startRunning];
    //////获取权限
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//相机权限
    if (AVstatus == AVAuthorizationStatusDenied) {/////拒绝
        [[[UIAlertView alloc] initWithTitle:@"相机授权未开启" message:@"请在手机设置开启相机授权" delegate:self cancelButtonTitle:@"暂不" otherButtonTitles:@"去设置", nil] show];
        return ;
    } else if (AVstatus == AVAuthorizationStatusNotDetermined){/////用户未选择
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                // 设置需要解析的数据类型，二维码
                self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
            }else{
                return ; //用户拒绝
            }
        }];
    } else {
        // 设置需要解析的数据类型，二维码
        self.metadataOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
}

-(void)turnONOrOffFlash{
    //    NSLog(@"flashButtonClick");
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //修改前必须先锁定
    [_device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([_device hasFlash]) {
        if ( !_isONFlash) {
            [self.session beginConfiguration];
            [_device lockForConfiguration:nil];
            [_device setTorchMode:AVCaptureTorchModeOn];
            [_device unlockForConfiguration];
            [self.session commitConfiguration];
            _isONFlash = YES;
        } else {
            [self.session beginConfiguration];
            [_device lockForConfiguration:nil];
            [_device setTorchMode:AVCaptureTorchModeOff];
            [_device unlockForConfiguration];
            [self.session commitConfiguration];
            _isONFlash = NO;
        }
    }
    [_device unlockForConfiguration];
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    //判断是否有数据
    if (metadataObjects != nil && [metadataObjects count] > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            [self performSelectorOnMainThread:@selector(stopReading) withObject:nil waitUntilDone:NO];
        }
    }
}

//停止扫描
-(void)stopReading{
    [self.session stopRunning];
    self.session = nil;
    [self.previewLayer removeFromSuperlayer];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 1:{
            NSURL *url = nil;
            if ([[UIDevice currentDevice] systemVersion].floatValue >= 8.0 && UIApplicationOpenSettingsURLString != NULL) {
                url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            } else {
                url = [NSURL URLWithString:@"prefs:root=prefs:root=Photos"];
            }
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            } else {
                
            }
        }
            break;
        default:
            break;
    }
}


@end
