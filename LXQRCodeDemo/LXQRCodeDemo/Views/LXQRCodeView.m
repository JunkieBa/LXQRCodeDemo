//
//  LXQRCodeView.m
//  LXQRCodeDemo
//
//  Created by alisa on 2017/9/1.
//  Copyright © 2017年 alisa. All rights reserved.
//

#import "LXQRCodeView.h"
#import "Masonry.h"
#import "UIColor+HexString.h"
@interface LXQRCodeView ()
{
    UIImageView   *_imageView;
    UIImageView   *_lineImageView;
    UIView        *_photoView;
    BOOL          _isONFlash;
}
@property (nonatomic, strong)UIButton *flashlightButton;

@end

@implementation LXQRCodeView

// 修改当前View 的图层类别
+(Class)layerClass {
    
    return [AVCaptureVideoPreviewLayer class];
}

-(void)setSession:(AVCaptureSession *)session {
    _session = session;
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.layer;
    layer.session = session;
    [layer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUiConfig];
    }
    return self;
}
- (void)initUiConfig {
    UIView *topMargeView = [[UIView alloc] init];
    topMargeView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.6f];
    [self addSubview:topMargeView];
    [topMargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(100);
    }];
    _imageView = [[UIImageView alloc] init];
    [self addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(topMargeView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(260, 260));
        
    }];
    UIImageView *leftTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shapeLeftTopIcon"]];
    [_imageView addSubview:leftTop];
    [leftTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(@0);
        make.size.mas_equalTo(leftTop.image.size);
    }];
    UIImageView *leftBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shapeLeftBottomIcon"]];
    [_imageView addSubview:leftBottom];
    [leftBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.equalTo(@0);
        make.size.mas_equalTo(leftBottom.image.size);
    }];
    UIImageView *rightTop = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shapeRightTopIcon"]];
    [_imageView addSubview:rightTop];
    [rightTop mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.equalTo(@0);
        make.size.mas_equalTo(rightTop.image.size);
    }];
    UIImageView *rightBottom = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shapeRightBottomIcon"]];
    [_imageView addSubview:rightBottom];
    [rightBottom mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottom.equalTo(@0);
        make.size.mas_equalTo(rightBottom.image.size);
    }];
    _lineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    _lineImageView.image = [UIImage imageNamed:@"RectangleLineIcon"];
    [_imageView addSubview:_lineImageView];
    UIView *leftMargeView = [[UIView alloc] init];
    leftMargeView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.6f];
    [self addSubview:leftMargeView];
    [leftMargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topMargeView.mas_bottom);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(_imageView.mas_left);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    UIView *rightMargeView = [[UIView alloc] init];
    rightMargeView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.6f];
    [self addSubview:rightMargeView];
    [rightMargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topMargeView.mas_bottom);
        make.right.mas_equalTo(0);
        make.left.mas_equalTo(_imageView.mas_right);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    UIView *bottomMargeView = [[UIView alloc] init];
    bottomMargeView.backgroundColor = [[UIColor colorWithHexString:@"#000000"] colorWithAlphaComponent:0.6f];
    [self addSubview:bottomMargeView];
    [bottomMargeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_bottom);
        make.left.mas_equalTo(_imageView.mas_left);
        make.right.mas_equalTo(_imageView.mas_right);
        make.top.mas_equalTo(_imageView.mas_bottom);
    }];
    UILabel *scanLabel = [[UILabel alloc] init];
    scanLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
    scanLabel.font = [UIFont systemFontOfSize:14];
    scanLabel.textAlignment = NSTextAlignmentCenter;
    scanLabel.text = @"对准二维码/条形码到框内即可扫描";
    [self addSubview:scanLabel];
    [scanLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_imageView.mas_left);
        make.right.mas_equalTo(_imageView.mas_right);
        make.top.mas_equalTo(_imageView.mas_bottom).offset(17);
        make.height.equalTo(@20);
    }];
    UIImage *flashImage = [UIImage imageNamed:@"turnOffFlashLightIcon"];
    _flashlightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flashlightButton setImage:[UIImage imageNamed:@"turnOffFlashLightIcon"] forState:UIControlStateNormal];
    [_flashlightButton setImage:[UIImage imageNamed:@"turnOnFlashLightIcon"] forState:UIControlStateSelected];
    [_flashlightButton addTarget:self action:@selector(flashlightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_flashlightButton];
    [_flashlightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(scanLabel.mas_bottom).offset(103);
        make.size.mas_equalTo(flashImage.size);
    }];
    UILabel *flashLabel = [[UILabel alloc] init];
    flashLabel.textColor = [UIColor colorWithHexString:@"ffffff"];
    flashLabel.font = [UIFont systemFontOfSize:14];
    flashLabel.textAlignment = NSTextAlignmentCenter;
    flashLabel.text = @"手电筒";
    [self addSubview:flashLabel];
    [flashLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.top.mas_equalTo(_flashlightButton.mas_bottom).offset(7);
        make.height.equalTo(@20);
        make.width.equalTo(@60);
    }];
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(animation) userInfo:nil repeats:YES];
}

-(void)flashlightButtonClicked:(UIButton *)sender{
    sender.selected = !sender.selected;
    if (self.flashBlock) {
        self.flashBlock();
    }
}

- (void)animation
{
    [UIView animateWithDuration:2.8 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        _lineImageView.frame = CGRectMake(30, 260, 220, 2);
    } completion:^(BOOL finished) {
        _lineImageView.frame = CGRectMake(30, 10, 220, 2);
    }];
}

-(void)setIsFlashON:(BOOL)isFlashON{
    _flashlightButton.selected = isFlashON;
}

-(void)dealloc{
    // 销毁定时器
    if (self.timer){
        [self.timer invalidate];
        self.timer = nil;
    }
}


@end
