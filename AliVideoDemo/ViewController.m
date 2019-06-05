//
//  ViewController.m
//  AliVideoDemo
//
//  Created by Apple on 2019/5/22.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "ViewController.h"
#import "AliyunMediaConfig.h"
#import "AlivcUIConfig.h"
#import "AliyunMagicCameraViewController.h"
#import "AlivcShortVideoRoute.h"
@interface ViewController ()
//@property (nonatomic, strong) AliyunMediaConfig *quVideo;// 录制参数

//@property (nonatomic, assign) CGFloat videoOutputWidth; //分辨率

//@property (nonatomic, assign) CGFloat videoOutputRatio;// 视频比例
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupView];
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
}
- (void)setupView {
    UIButton *captureButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 100)];
    captureButton.backgroundColor = [UIColor redColor];
    [captureButton setTitle:@"开始录制" forState:UIControlStateNormal];
    [captureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:captureButton];
    [captureButton addTarget:self action:@selector(toRecordView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *playViewButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 100)];
    playViewButton.backgroundColor = [UIColor greenColor];
    [playViewButton setTitle:@"开始播放" forState:UIControlStateNormal];
    [self.view addSubview:playViewButton];
    [playViewButton addTarget:self action:@selector(jumpPlayView) forControlEvents:UIControlEventTouchUpInside];
    
}
- (void)jumpPlayView{
    
}
/**
 进入录制界面
 */
- (void)toRecordView {
    AliyunMediaConfig *config = [AliyunMediaConfig defaultConfig];
    config.minDuration = 2;
    config.maxDuration = 15;
    CGFloat videoOutputRatio;
    //视频比例 9:16 3:4 1:1
    videoOutputRatio = 9.0f / 16.0f;
    //分辨率";
    CGFloat videoOutputWidth = config.outputSize.width;
    //码率 @"默认为0，根据视频质量参数计算";
    config.bitrate = 0;
    //关键帧间隔-建议1-300，默认250
    config.gop = 250;

    //最小时长大于0，默认值2s
    config.minDuration = 3;
    //不超过300S，默认值15s
    config.maxDuration = 15;
    
    CGFloat width = videoOutputWidth;
    CGFloat height = ceilf(videoOutputWidth / videoOutputRatio); // 视频的videoSize需为整偶数
    config.outputSize = CGSizeMake(width, height);
    
//    NSLog(@"videoSize:w:%f  h:%f", config.outputSize.width, config.outputSize.height);
    
    if (config.maxDuration > 300 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不能超过300s" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    AliyunMagicCameraViewController *controller = [[AliyunMagicCameraViewController alloc]init];
    controller.quVideo = config;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
