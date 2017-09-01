//
//  LXQRCodeView.h
//  LXQRCodeDemo
//
//  Created by alisa on 2017/9/1.
//  Copyright © 2017年 alisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef void (^LXQRCodeFlashBlock)();
@interface LXQRCodeView : UIView
@property(nonatomic, strong)AVCaptureSession    *session;//!< 渲染会话层
@property(nonatomic, strong)NSTimer             *timer;//!< <#value#>
@property(nonatomic, copy)  LXQRCodeFlashBlock flashBlock;
@property(nonatomic, assign)BOOL isFlashON;
@end
