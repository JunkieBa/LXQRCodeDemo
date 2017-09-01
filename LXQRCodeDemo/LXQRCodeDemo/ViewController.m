//
//  ViewController.m
//  LXQRCodeDemo
//
//  Created by alisa on 2017/9/1.
//  Copyright © 2017年 alisa. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "LXQRCodeViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [scanButton setTitle:@"扫一扫" forState:UIControlStateNormal];
    [scanButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(scanButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
    [scanButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@100);
        make.top.equalTo(@100);
        make.size.mas_equalTo(CGSizeMake(80, 80));
    }];
}

-(void)scanButtonClicked{
    LXQRCodeViewController *scanVC = [[LXQRCodeViewController alloc] init];
    [self.navigationController pushViewController:scanVC animated:YES];
}


@end
