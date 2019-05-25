//
//  ViewController.m
//  AliVideoDemo
//
//  Created by Apple on 2019/5/22.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "ViewController.h"
#import "AliyunMediaConfig.h"
#import "AlivcShortVideoRoute.h"
#import "AlivcUIConfig.h"
#import "AliyunMagicCameraViewController.h"
@interface ViewController ()
/**
 数据模型数组
 */
@property (nonatomic, strong) NSArray *dataArray;

/**
 录制参数
 */
@property (nonatomic, strong) AliyunMediaConfig *quVideo;

/**
 分辨率
 */
@property (nonatomic, assign) CGFloat videoOutputWidth;

/**
 视频比例
 */
@property (nonatomic, assign) CGFloat videoOutputRatio;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self configParmas];
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
}
- (void)configParmas{
    _quVideo = [AliyunMediaConfig defaultConfig];
    _quVideo.minDuration = 2;
    _quVideo.maxDuration = 15;
    //视频比例 9:16 3:4 1:1
    self.videoOutputRatio = 9.0f / 16.0f;
    //分辨率";
    self.videoOutputWidth = _quVideo.outputSize.width;
    //码率 @"默认为0，根据视频质量参数计算";
    self.quVideo.bitrate = 0;
    //最小时长大于0，默认值2s
    self.quVideo.minDuration = 3;
    //不超过300S，默认值15s
    self.quVideo.maxDuration = 15;
    //关键帧间隔-建议1-300，默认250
    self.quVideo.gop = 250;
    //视频质量，设置bitrate参数后，该参数无效
//    self.quVideo.videoQuality =  0.75
    //编码方式：0 软编 1 硬编 默认1
//    self.quVideo.encodeMode = 0
}

/**
 进入录制界面
 */
- (void)toRecordView {
    [self.view endEditing:YES];
    
    [self updatevideoOutputVideoSize];
    
    if((_quVideo.maxDuration == 0)&&(_quVideo.minDuration == 0)){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不小于最小时长" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(_quVideo.minDuration == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最小时长要大于0" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_quVideo.maxDuration == -1) {
        _quVideo.maxDuration = 15;
    }
    if (_quVideo.minDuration == -1) {
        _quVideo.minDuration = 2;
    }
    if (_quVideo.maxDuration <= _quVideo.minDuration ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不小于最小时长" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (_quVideo.maxDuration > 300 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不能超过300s" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    //配置
//    [[AlivcShortVideoRoute shared] registerMediaConfig:_quVideo];
//    UIViewController *record = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlRecord];
//    [self.navigationController pushViewController:record animated:YES];
    
    AliyunMagicCameraViewController *controller = [[AliyunMagicCameraViewController alloc]init];
    controller.quVideo = self.quVideo;
    [self.navigationController pushViewController:controller animated:YES];
}
// 根据调节结果更新videoSize
- (void)updatevideoOutputVideoSize {
    
    CGFloat width = self.videoOutputWidth;
    CGFloat height = ceilf(self.videoOutputWidth / self.videoOutputRatio); // 视频的videoSize需为整偶数
    _quVideo.outputSize = CGSizeMake(width, height);
    NSLog(@"videoSize:w:%f  h:%f", _quVideo.outputSize.width, _quVideo.outputSize.height);
}

@end
