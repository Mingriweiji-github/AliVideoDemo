//
//  ViewController.m
//  AliyunVideo
//
//  Created by Vienta on 2016/12/29.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraViewController.h"
#import <AliyunVideoSDKPro/AliyunIRecorder.h>
#import "AliyunMagicCameraView.h"
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVCaptureSession.h>
#import <AliyunVideoSDKPro/AliyunFacePoint.h>
#import <AliyunVideoSDKPro/AliyunEffectFilter.h>
#import <AliyunVideoSDKPro/AliyunEffectPaster.h>
#import <AliyunVideoSDKPro/AliyunClipManager.h>
#import <AliyunVideoSDKPro/AliyunHttpClient.h>
//#import "AliyunPasterInfoGroup.h"
//#import "AliyunPasterInfo.h"
//#import "AliyunDownloadManager.h"
#import "AliyunMagicCameraEffectCell.h"
#import <CoreMotion/CoreMotion.h>
//#import "AliyunResourceManager.h"
#import "AliyunMusicPickViewController.h"
#import "AliyunPathManager.h"
#import "MBProgressHUD.h"
#import "AliyunEffectResourceModel.h"
#import "AVC_ShortVideo_Config.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AlivcUIConfig.h"
#import "AliyunResourceRequestManager.h"
#import "AliyunReachability.h"
#import "AliyunDBHelper.h"
#import "AlivcBeautySettingUIDefine.h"
#import "AlivcDefine.h"
#import "AlivcWebViewController.h"

//#if SDK_VERSION == SDK_VERSION_CUSTOM
//#import "AlivcShortVideoFaceUnityManager.h"
//#endif

#import "AliyunMediator.h"
#import "AliyunMediaConfig.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcPushBeautyDataManager.h"
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectFilterView.h"
#import "UIView+AlivcHelper.h"
#import "AliyunPhotoViewController.h"
#import "AliyunEditViewController.h"
@interface AliyunMagicCameraViewController () <AliyunMusicPickViewControllerDelegate,UIGestureRecognizerDelegate,UIAlertViewDelegate,AliyunIRecorderDelegate,AliyunEffectFilter2ViewDelegate,AliyunPhotoViewControllerDelegate>

/**
 SDK录制类
 */
@property (nonatomic, strong) AliyunIRecorder *recorder;

@property (nonatomic, strong)AliyunMediaConfig *mediaConfig;

/**
 控制器view
 */
@property (nonatomic, strong) AliyunMagicCameraView *magicCameraView;
@property (nonatomic, strong) NSMutableArray *effectFilterItems; //滤镜数组
/**
 最新的摄像头位置（前置还是后置）
 */
@property (nonatomic, assign) AliyunIRecorderCameraPosition lastCameraPosition;

/**
 iPhone4s机型以下
 */
@property (nonatomic, assign) BOOL belowiPhone4s;

/**
 倒计时控件
 */
@property (nonatomic, weak) UILabel *countLabel;

/**
 定时器
 */
@property (nonatomic,weak) NSTimer *timer;

/**
 高级美颜美白参数值（0-1）
 */
@property (nonatomic,assign) CGFloat beautyWhiteValue;

/**
 高级美颜磨皮参数值（0-1）
 */
@property (nonatomic,assign) CGFloat blurValue;

/**
 美肌大眼参数值（0-1）
 */
@property (nonatomic,assign) CGFloat bigEyeValue;

/**
 美肌瘦脸参数值（0-1）
 */
@property (nonatomic,assign) CGFloat slimFaceValue;

/**
 高级美颜红润参数值（0-1）
 */
@property (nonatomic,assign) CGFloat buddyValue;

@property (nonatomic, strong) AlivcPushBeautyDataManager *beautyFaceDataManager_normal;     //普通美颜的数据管理器
@property (nonatomic, strong) AlivcPushBeautyDataManager *beautyFaceDataManager_advanced;   //高级美颜的数据管理器
@property (nonatomic, strong) AlivcPushBeautyDataManager *beautySkinDataManager;            //美肌的数据管理器
@property (nonatomic, strong) AliyunMusicPickModel *music;  //之前应用的音乐
@property (nonatomic, assign) NSInteger tab;  //之前应用的音乐的所属0远程 1本地
@property (nonatomic, strong) AliyunReachability *reachability;       //网络监听
@property (nonatomic, strong) AliyunDBHelper *dbHelper; //数据库

/**
 美颜状态默认是否开启
 */
@property (nonatomic, assign) BOOL beauty;

/**
 开始录制时间
 */
@property (nonatomic, assign) double downTime;

/**
 结束录制时间
 */
@property (nonatomic, assign) double upTime;

/**
 开始录制视频段数
 */
@property (nonatomic, assign) NSInteger downVideoCount;

/**
 结束录制视频段数
 */
@property (nonatomic, assign) NSInteger upVideoCount;

/**
 当前的人脸动图
 */
@property (nonatomic, strong) AliyunEffectPaster *currentEffectPaster;

/**
 视频片段管理器
 */
@property (nonatomic, strong) AliyunClipManager *clipManager;

/**
 录制时间
 */
@property (nonatomic, assign) CFTimeInterval recordingDuration;


/**
 APP是否处于悬挂状态
 */
@property (nonatomic, assign) BOOL suspend;

@property (nonatomic, assign) BOOL needStopPreview;


@property (nonatomic, assign) BOOL isPreviewing;

@property (nonatomic, assign) AlivcPushBeautyParamsLevel beautyLevel;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) NSInteger cameraRotate;//相机旋转角度

@property(nonatomic, strong) AliyunEffectFilterView *filterView;

@property (nonatomic, strong)AVPlayer *avPlayer;//音频播放
@property (nonatomic, copy)NSString * selectBgMusic;//自己自作的背景音乐
@property (nonatomic, copy)NSString * bgMusic;//音乐列表

@end

@implementation AliyunMagicCameraViewController



- (instancetype)init
{
    self = [super init];
    if (self) {
        _beautyFaceDataManager_normal = [[AlivcPushBeautyDataManager alloc]initWithType:AlivcPushBeautyParamsTypeShortVideo customSaveString:@"beautyFaceDataManager_normal"];
        _beautyFaceDataManager_advanced = [[AlivcPushBeautyDataManager alloc]initWithType:AlivcPushBeautyParamsTypeShortVideo customSaveString:@"beautyFaceDataManager_advanced"];
        _beautySkinDataManager = [[AlivcPushBeautyDataManager alloc]initWithType:AlivcPushBeautyParamsTypeShortVideo customSaveString:@"beautySkinDataManager"];
        
        AlivcPushBeautyParams *params = [_beautyFaceDataManager_advanced getBeautyParamsOfLevel:[_beautyFaceDataManager_advanced getBeautyLevel]];
        self.beautyWhiteValue = params.beautyWhite/100.0;
        self.blurValue = params.beautyBuffing/100.0;
        self.buddyValue = params.beautyRuddy/100.0;
        self.beautyLevel = [self.beautyFaceDataManager_normal getBeautyLevel];
        
        AlivcPushBeautyParams *params2 = [_beautySkinDataManager getBeautyParamsOfLevel:[_beautySkinDataManager getBeautyLevel]];
        self.bigEyeValue = params2.beautyBigEye/100.0;
        self.slimFaceValue = params2.beautySlimFace/100.0;
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        AlivcBeautySettingViewStyle beautyStyle = (AlivcBeautySettingViewStyle)[defaults integerForKey:@"shortVideo_beautyType"];
        _beauty = (beautyStyle ==AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base);
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            Class c = NSClassFromString(@"AliyunEffectPrestoreManager");
            NSObject *prestore = (NSObject *)[[c alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [prestore performSelector:@selector(insertInitialData)];
#pragma clang diagnostic pop
        });
        
        if(!_uiConfig){
            _uiConfig = [[AlivcRecordUIConfig alloc]init];
        }
    }
    return self;
}


- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _cameraRotate =90;
    _needStopPreview =YES;
    
    Class c = NSClassFromString(@"AliyunEffectPrestoreManager");
    NSObject *prestore = (NSObject *)[[c alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [prestore performSelector:@selector(insertInitialData)];
#pragma clang diagnostic pop
    
    if(!_uiConfig){
        _uiConfig = [[AlivcRecordUIConfig alloc]init];
    }
    [self configBaseUI];
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (CGSizeEqualToSize(size, CGSizeMake(320, 480)) || CGSizeEqualToSize(size, CGSizeMake(480, 320))) {
        _belowiPhone4s = YES;
    }
    [self updateUIWithVideoSize:_quVideo.outputSize];
    self.view.backgroundColor = [UIColor blackColor];
    
    //清除之前生成的录制路径
    NSString *recordDir = [AliyunPathManager createRecrodDir];
    [AliyunPathManager clearDir:recordDir];
    //生成这次的存储路径
    NSString *taskPath = [recordDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
    //视频存储路径
    NSString *videoSavePath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
    
    _recorder = [[AliyunIRecorder alloc] initWithDelegate:self videoSize:_quVideo.outputSize];
    _recorder.preview = self.magicCameraView.previewView;
    
    _recorder.outputType = AliyunIRecorderVideoOutputPixelFormatType420f;//SDK自带人脸识别只支持YUV格式
    _recorder.useFaceDetect = YES;
    _recorder.faceDetectCount = 2;
    _recorder.faceDectectSync = NO;
    _recorder.frontCaptureSessionPreset = AVCaptureSessionPreset640x480;
    if (_quVideo.encodeMode == AliyunEncodeModeSoftFFmpeg) {
        _recorder.encodeMode = 0;
    }else if(_quVideo.encodeMode == AliyunEncodeModeHardH264){
        _recorder.encodeMode = 1;
    }
    NSLog(@"录制编码方式：%d",_recorder.encodeMode);
    
    _recorder.GOP = _quVideo.gop;
    _recorder.videoQuality = (AliyunVideoQuality)_quVideo.videoQuality;
    _recorder.recordFps = _quVideo.fps;
    _recorder.outputPath = _quVideo.outputPath?_quVideo.outputPath:videoSavePath;
    _recorder.taskPath = taskPath;
    _recorder.beautifyStatus = self.beauty;
    
    _recorder.bitrate = _quVideo.bitrate;
    
    //录制片段设置
    _clipManager = _recorder.clipManager;
    _clipManager.maxDuration = _quVideo.maxDuration;
    _clipManager.minDuration = _quVideo.minDuration;
    self.magicCameraView.maxDuration = _quVideo.maxDuration;
    self.magicCameraView.minDuration = _quVideo.minDuration;
    _lastCameraPosition = AliyunIRecorderCameraPositionFront;
    _quVideo.outputPath = _recorder.outputPath;
    
    [self addGesture];
    [self addNotification];
    [self setupFilterEffectData];
    
    [self.dbHelper openResourceDBSuccess:nil failure:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    AlivcBeautySettingViewStyle beautyStyle = (AlivcBeautySettingViewStyle)[defaults integerForKey:@"shortVideo_beautyType"];
    if (beautyStyle == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base) {
        [self didChangeCommonMode];
    }else if (beautyStyle == AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Advanced){
        [self didChangeAdvancedMode];
    }else{
        _recorder.beautifyValue = 50;
    }
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //实现背景音乐连续播放
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playItemDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}
/**
 *  背景音乐播放完成通知
 */
- (void)playItemDidEnd:(NSNotification *)noti{
    // 跳到最新的时间点开始播放
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer play];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self starPreview];
    if (_recordingDuration >= _quVideo.minDuration) {
        [self.magicCameraView enableFinishButton:YES];
    } else {
        [self.magicCameraView enableFinishButton:NO];
    }
    _magicCameraView.musicButton.enabled = ![_clipManager partCount];
    NSLog(@"%zd",[_clipManager partCount]);
    [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];//录制模块禁止自动熄屏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self startRetainCameraRotate];
    //禁用侧滑手势
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.magicCameraView.userInteractionEnabled = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self startRetainCameraRotate];
    });
    if (self.selectBgMusic) {
        self.avPlayer = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:self.selectBgMusic]];
        [self.avPlayer seekToTime:kCMTimeZero];
        [self.avPlayer play];
    }
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.avPlayer) {
        self.avPlayer = nil;
        [self.avPlayer pause];
    }
    
    if (self.needStopPreview) {
        [self stopPreview];
    }
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    //启用侧滑手势
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self.motionManager stopDeviceMotionUpdates];
}
- (void)dealloc
{
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
    [_recorder stopPreview];
    [_recorder destroyRecorder];
    _recorder = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.timer invalidate];
    self.timer = nil;
    self.avPlayer = nil;
}
// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}
// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
- (void)appDidEnterBackground:(NSNotification *)noti
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    [self stopPreview];
}
- (void)appWillEnterForeground:(NSNotification *)noti
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    [self starPreview];
    _magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
    
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageOpen forState:0];
    } else if (mode == AliyunIRecorderTorchModeOff) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    } else {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageAuto forState:0];
    }
}
/**
 设置UI
 */
- (void)configBaseUI{
    self.magicCameraView = [[AliyunMagicCameraView alloc] initWithUIConfig:self.uiConfig];
    self.magicCameraView.delegate = (id)self;
    [self.view addSubview:self.magicCameraView];
    self.view.backgroundColor = _uiConfig.backgroundColor;
    [self.view addSubview:self.filterView];
}


/**
 根据要求设置录制view的大小
 
 @param videoSize 输出的视频size
 */
- (void)updateUIWithVideoSize:(CGSize)videoSize {
    CGFloat r = videoSize.width / videoSize.height;
    BOOL is_W9_H16 = (r - 9/16.0)<0.01; //是否是9：16的比例
    CGFloat y =  CGRectGetMaxY(self.magicCameraView.topView.frame);
    CGRect preFrame = CGRectMake(0, y, ScreenWidth, ScreenWidth / r);
    
    if (_belowiPhone4s && is_W9_H16) {
        preFrame = CGRectMake((ScreenWidth - ScreenHeight * r)/2.f , 0, ScreenHeight * r, ScreenHeight);
    }
    
    if (is_W9_H16) {
        //9:16的 是全屏 裁剪模式
        preFrame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        _magicCameraView.previewView.frame = preFrame;
    }];
    
    y = CGRectGetMaxY(_magicCameraView.previewView.frame);
    if (_belowiPhone4s) {
        _magicCameraView.bottomView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);
        self.magicCameraView.topView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        
    } else {
        if (!is_W9_H16) {
            self.magicCameraView.topView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
            //
            _magicCameraView.bottomView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);
            
        } else {
            
            _magicCameraView.bottomView.frame = CGRectMake(0, ScreenHeight, 0, 0);
            
            self.magicCameraView.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
            
        }
    }
}

/**
 录制界面的UI配置
 */
- (void)setupSDKUI {
    
    AliyunIConfig *config = [[AliyunIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"filter/炽黄",@"filter/粉桃",@"filter/海蓝",@"filter/红润",@"filter/灰白",@"filter/经典",@"filter/麦茶",@"filter/浓烈",@"filter/柔柔",@"filter/闪耀",@"filter/鲜果",@"filter/雪梨",@"filter/阳光",@"filter/优雅",@"filter/朝阳",@"filter/波普",@"filter/光圈",@"filter/海盐",@"filter/黑白",@"filter/胶片",@"filter/焦黄",@"filter/蓝调",@"filter/迷糊",@"filter/思念",@"filter/素描",@"filter/鱼眼",@"filter/马赛克",@"filter/模糊"];
    config.imageBundleName = @"QPSDK";
    config.recordType = AliyunIRecordActionTypeClick;
    config.filterBundleName = nil;
    config.showCameraButton = NO;
    
    [AliyunIConfig setConfig:config];
}



#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ( [[UIApplication sharedApplication] canOpenURL: url] ) {
        
        NSURL*url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        [[UIApplication sharedApplication] openURL:url];
        
    }
    
}


/**
 添加手势
 */
- (void)addGesture
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToFocusPoint:)];
    [_recorder.preview addGestureRecognizer:tapGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    pinchGesture.delegate = self;
    [_recorder.preview addGestureRecognizer:pinchGesture];
    
    
}

//需要旋转 缩放同时起效 设置delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    return YES;
}


/**
 监听通知
 */
- (void)addNotification
{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceDelete:) name:AliyunEffectResourceDeleteNotification object:nil];
    
}

/**
 资源被删除的通知
 
 @param noti 通知对象
 */
- (void)resourceDelete:(NSNotification *)noti{
    
}



- (void)appWillResignActive:(id)sender
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    if ([_recorder isRecording]) {
        [_recorder stopRecording];
        [self stopPreview];
        _suspend = YES;
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
//            [self.magicCameraView recordButtonTouchDown];
            [self.magicCameraView recordButtonTouchUp];
        }else{
            [self.magicCameraView recordButtonTouchUp];
        }
    } else {
        [self stopPreview];
    }
    if (self.countLabel) {
        [self.timer invalidate];
        self.timer = nil;
        [self.countLabel removeFromSuperview];
        _suspend = YES;
        self.magicCameraView.circleBtn.hidden = NO;
        self.magicCameraView.countdownButton.enabled = (_clipManager.duration <_clipManager.maxDuration);
    }
    
    AliyunIRecorderCameraPosition position = _recorder.cameraPosition;
    if (position == AliyunIRecorderCameraPositionBack) {
        [_recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    }
}

- (void)appDidBecomeActive:(id)sender
{
    if ([self.navigationController.childViewControllers lastObject] != self) {
        return;
    }
    if([_recorder isRecording]){
        [_recorder stopRecording];
        [self stopPreview];
        _suspend = YES;
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
//            [self.magicCameraView recordButtonTouchDown];
            [self.magicCameraView recordButtonTouchUp];
        }else{
            [self.magicCameraView recordButtonTouchUp];
        }
    }
    
    if (_suspend) {
        _suspend = NO;
    }
    
    [self starPreview];
    
    _magicCameraView.hide = NO;
    [_magicCameraView resetRecordButtonUI];
    _magicCameraView.recording = NO;
    _magicCameraView.realVideoCount = [_clipManager partCount];
    // hide的隐藏状态会覆盖bottomHide的隐藏状态，重新调用bottomHide的set方法
    if (_magicCameraView.bottomHide == YES) {
        _magicCameraView.bottomHide = YES;
    }
}
#pragma mark - 设置滤镜数据
- (void)setupFilterEffectData
{
    NSArray *filters = @[@"炽黄",@"粉桃",@"海蓝",@"红润",@"灰白",
                         @"经典",@"麦茶",@"浓烈",@"柔柔",@"闪耀",
                         @"鲜果",@"雪梨",@"阳光",@"优雅",@"朝阳",
                         @"波普",@"光圈",@"海盐",@"黑白",@"胶片",
                         @"焦黄",@"蓝调",@"迷糊",@"思念",@"素描",
                         @"鱼眼",@"马赛克",@"模糊"];
    
    [self.effectFilterItems removeAllObjects];
    
    AliyunEffectFilter *effectFilter1 = [[AliyunEffectFilter alloc] init];
    [self.effectFilterItems addObject:effectFilter1];//作为空效果
    for (int idx = 0; idx < [filters count]; idx++ ){
        NSString *filterName = [NSString stringWithFormat:@"filter/%@",filters[idx]];
        NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:filterName ofType:nil];
        AliyunEffectFilter *effectFilter = [[AliyunEffectFilter alloc] initWithFile:path];
        [self.effectFilterItems addObject:effectFilter];
    }
}
- (AliyunDBHelper *)dbHelper {
    
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}



/**
 点按手势的触发方法
 
 @param tapGesture 点按手势
 */
- (void)tapToFocusPoint:(UITapGestureRecognizer *)tapGesture {
    //    UIView *tapView = tapGesture.view;
    CGPoint point = [tapGesture locationInView:self.magicCameraView.previewView];
    self.recorder.focusPoint = point;
    [self.magicCameraView refreshFocusPointWithPoint:point];
    if (!self.recorder.isRecording) {
        [self.magicCameraView cancelRecordBeautyView];
    }
    
    [self hideFilterView:YES];
    
}


/**
 捏合手势的触发方法
 
 @param pinchGesture 捏合方法
 */
- (void)pinchGesture:(UIPinchGestureRecognizer *)pinchGesture {
    if (isnan(pinchGesture.velocity) || pinchGesture.numberOfTouches != 2) {
        return;
    }
    _recorder.videoZoomFactor = pinchGesture.velocity;
    pinchGesture.scale = 1;
    
    return;
}
- (NSMutableArray *)effectFilterItems
{
    if (!_effectFilterItems) {
        _effectFilterItems = [[NSMutableArray alloc] init];
    }
    return _effectFilterItems;
}

#pragma mark - MagicCameraViewDelegate -

- (void)magicCameraView:(AliyunMagicCameraView *)view dismissButtonTouched:(UIButton *)button{
    [self.magicCameraView cancelRecordBeautyView];
}

- (void)didChangeAdvancedMode{
    _recorder.beautifyStatus = NO;
    _recorder.beautifyValue = 0;
    AlivcPushBeautyParams *params = [_beautyFaceDataManager_advanced getBeautyParamsOfLevel:[_beautyFaceDataManager_advanced getBeautyLevel]];
    self.beautyWhiteValue = params.beautyWhite/100.0;
    self.blurValue = params.beautyBuffing/100.0;
    self.buddyValue = params.beautyRuddy/100.0;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Advanced forKey:@"shortVideo_beautyType"];
    [defaults synchronize];
}

- (void)didChangeCommonMode{
    self.beautyWhiteValue = 0;
    self.blurValue = 0;
    self.buddyValue = 0;
    _recorder.beautifyStatus = YES;
    _recorder.beautifyValue = [_beautyFaceDataManager_normal getBeautyLevel]*20;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:AlivcBeautySettingViewStyle_ShortVideo_BeautyFace_Base forKey:@"shortVideo_beautyType"];
    [defaults synchronize];
}

- (void)tapButtonClicked{
    [AliyunIConfig config].recordType = AliyunIRecordActionTypeClick;
}

- (void)longPressButtonClicked{
    [AliyunIConfig config].recordType = AliyunIRecordActionTypeHold;
}
- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue{
    self.beautyWhiteValue = beautyWhiteValue/100;
    NSLog(@"beautyWhiteValue：%f",beautyWhiteValue);
}
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue{
    self.blurValue = blurValue/100;
    NSLog(@"blurValue：%f",blurValue);
}
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue{
    self.bigEyeValue = bigEyeValue/100;
    NSLog(@"bigEyeValue：%f",bigEyeValue);
}
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue{
    self.slimFaceValue = slimFaceValue/100;
    NSLog(@"slimFaceValue：%f",slimFaceValue);
}
- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue{
    self.buddyValue = buddyValue/100;
}
- (void)didChangeBeautyValue:(CGFloat)beautyValue{
    _recorder.beautifyValue = beautyValue*20;
}

- (void)didSelectedHowToGet{
    
    AlivcWebViewController *introduceC = [[AlivcWebViewController alloc] initWithUrl:kIntroduceUrl title:NSLocalizedString(@"Third-party capability acquisition instructions", nil)];
    [self.navigationController pushViewController:introduceC animated:YES];
}

//滤镜
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter{
    AliyunEffectFilter *effectFilter =[[AliyunEffectFilter alloc] initWithFile:[filter localFilterResourcePath]];
    [_recorder applyFilter:effectFilter];
}

- (void)recordButtonRecordVideo{
    if (self.magicCameraView.backButton.enabled == NO) {
        _magicCameraView.hide = NO;
        self.magicCameraView.progressView.videoCount--;
        [self.magicCameraView resetRecordButtonUI];
        self.magicCameraView.recording = NO;
        _magicCameraView.realVideoCount = [_clipManager partCount];
        return;
    }
    
    NSLog(@"---------->点击了录制按钮");
    self.downTime = CFAbsoluteTimeGetCurrent();
    self.downVideoCount = [_clipManager partCount];
    NSLog(@"开始拍摄：动图测试");
    if (_clipManager.partCount<=0) {
        _recorder.cameraRotate = self.cameraRotate;
        _quVideo.videoRotate = _recorder.cameraRotate;
    }
    int code =  [_recorder startRecording];
    if (code == 0) {
        _magicCameraView.hide = YES;
        _magicCameraView.backButton.enabled = NO;
    }else{
        NSLog(@"---------->startRecording错误error:  code:%d",code);
        _magicCameraView.hide = NO;
        _magicCameraView.backButton.enabled = YES;
        self.magicCameraView.progressView.videoCount--;
        [self.magicCameraView resetRecordButtonUI];
        self.magicCameraView.recording = NO;
        _magicCameraView.realVideoCount = [_clipManager partCount];
    }
}

- (void)recordButtonPauseVideo{
    NSLog(@"---------->点击了暂停录制按钮");
    [_recorder stopRecording];
    _magicCameraView.userInteractionEnabled =NO;
    self.upTime = CFAbsoluteTimeGetCurrent();
    _magicCameraView.hide = NO;
}

- (void)recordButtonFinishVideo{
    [self stopPreview];
    _quVideo.videoRotate = [_clipManager firstClipVideoRotation];
    [_recorder finishRecording];
    _magicCameraView.hide = NO;
}

- (void)timerButtonClicked{
    UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    countLabel.center = self.view.center;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.userInteractionEnabled =YES;
    countLabel.textColor = [UIColor whiteColor];
    countLabel.font = [UIFont systemFontOfSize:144];
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.text = @"3";
    [self.view addSubview:countLabel];
    [self.view bringSubviewToFront:countLabel];
    self.countLabel = countLabel;
    
    self.magicCameraView.hide = YES;
    self.magicCameraView.circleBtn.hidden = YES;
    
    NSTimer* timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    self.timer = timer;
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

/**
 定时器触发方法（每隔一段时间调用一次）
 */
- (void)countDown{
    int count = [self.countLabel.text intValue] ;
    count--;
    if (count == 0) {
        [self.countLabel removeFromSuperview];
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
//            [self.magicCameraView recordButtonTouchDown];
            [self.magicCameraView recordButtonTouchUp];
            
        }else{
//            [self.magicCameraView recordButtonTouchDown];
        }
        
        self.magicCameraView.circleBtn.hidden = NO;
        [self.timer invalidate];
    }else{
        self.countLabel.text = [NSString stringWithFormat:@"%d",count];
    }
}

- (void)backButtonClicked
{
    [self stopPreview];
//#if SDK_VERSION == SDK_VERSION_CUSTOM
//    [[AlivcShortVideoFaceUnityManager shareManager] destoryItems];
//#endif
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)flashButtonClicked
{
    if (_recorder.cameraPosition == AliyunIRecorderCameraPositionFront) {
        return @"shortVideo_noLight";
    }
    if (_recorder.torchMode == AliyunIRecorderTorchModeOff) {
        [_recorder switchTorchWithMode:AliyunIRecorderTorchModeOn];
        return @"shortVideo_onLight";
    }else{
        [_recorder switchTorchWithMode:AliyunIRecorderTorchModeOff];
        return @"shortVideo_noLight";
    }
    //    AliyunIRecorderTorchMode mode = [_recorder switchTorchMode];
    //    if (mode == AliyunIRecorderTorchModeOn) {
    //        return @"shortVideo_onLight";
    //    } else if (mode == AliyunIRecorderTorchModeOff) {
    //        return @"shortVideo_noLight";
    //    } else {
    //        return @"shortVideo_noLight";
    //    }
}

- (void)cameraIdButtonClicked
{
    if (self.magicCameraView.backButton.enabled == NO) {
        return;
    }
    
    [_recorder switchCameraPosition];
    _lastCameraPosition = _recorder.cameraPosition;
    _magicCameraView.flashButton.enabled = (_recorder.cameraPosition != 0);
    AliyunIRecorderTorchMode mode = _recorder.torchMode;
    if (mode == AliyunIRecorderTorchModeOn) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageOpen forState:0];
    } else if (mode == AliyunIRecorderTorchModeOff) {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
    } else {
        [_magicCameraView.flashButton setImage:_uiConfig.ligheImageAuto forState:0];
    }
}

- (void)filterButtonClicked {
    [self hideFilterView:NO];
}

- (void)hideFilterView:(BOOL)hidden {
    CGRect frame = self.filterView.frame;
    if (hidden) {
        frame.origin.y = ScreenHeight;
    }else {
        frame.origin.y = ScreenHeight - self.filterView.bounds.size.height;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        self.filterView.frame = frame;
    }];
}

-(void)stopPreview{
    if (_isPreviewing) {
        [_recorder stopPreview];
        _isPreviewing =NO;
    }
}

-(void)starPreview{
    if (!_isPreviewing) {
        [_recorder startPreviewWithPositon:_lastCameraPosition];
        if (_recorder.cameraPosition == AliyunIRecorderCameraPositionFront) {
            [_magicCameraView.flashButton setImage:_uiConfig.ligheImageClose forState:0];
        }
        _isPreviewing =YES;
    }
}
- (void)backBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark 视频裁剪选择页
- (void)photoButtonClicked {
#warning AliyunPhotoViewController.m 和 👇 这些类必须手动添加到 Build setting-> Compile Souces中
    /*Showing Recent Messages
     :-1: Undefined symbol: _OBJC_CLASS_$_AliyunAlbumViewController
     :-1: Undefined symbol: _OBJC_CLASS_$_AliyunCropViewController
     :-1: Undefined symbol: _OBJC_CLASS_$_AliyunPhotoLibraryManager
     :-1: Undefined symbol: _OBJC_CLASS_$_AliyunAssetModel
     :-1: Undefined symbol: _OBJC_CLASS_$_AliyunPhotoListViewCell*/
    
    UIViewController *vc = [[AliyunMediator shared] cropModule];// AliyunPhotoViewController
    [vc setValue:self.mediaConfig forKey:@"cutInfo"];
    [vc setValue:self forKey:@"delegate"];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark 音乐click
- (void)musicButtonClicked{
    //    AliyunMusicPickViewController *vc =[[AliyunMusicPickViewController alloc] init];
    //    vc.delegate = self;
    //    vc.duration = _clipManager.maxDuration;
    //    vc.selectedMusic = self.music;
    //    vc.selectedTab = self.tab;
    //    self.needStopPreview =NO;
    //    [self.navigationController pushViewController:vc animated:YES];
    UIViewController *vc = [[AliyunMediator shared] cropModule];// AliyunPhotoViewController
    AliyunPhotoViewController *photo = (AliyunPhotoViewController *)vc;
    [photo setValue:self.mediaConfig forKey:@"cutInfo"];
    [photo setValue:self forKey:@"delegate"];
    photo.needBackWithMusic = YES;
    [self.navigationController pushViewController:photo animated:YES];
}
#pragma mark 自己制作的背景音乐
- (void)backMagicPageWithAudio:(NSString *)audioPath{
    NSLog(@"Magic成功获取剪切后音频>>>>>>>>%@",audioPath);
//    [MBProgressHUD showSucessMessage:@"背景音乐获取成功" inView:self.view];
    self.selectBgMusic = audioPath;
    //todo:播放背景音乐
    self.avPlayer = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:audioPath]];
    [self.avPlayer play];
}
-(AliyunMediaConfig *)mediaConfig{
    
    if (!_mediaConfig) {//默认配置
        _mediaConfig = [AliyunMediaConfig defaultConfig];
        _mediaConfig.minDuration = 2.0;
        _mediaConfig.maxDuration = 10.0*60;
        _mediaConfig.fps = 25;
        _mediaConfig.gop = 5;
        _mediaConfig.cutMode = AliyunMediaCutModeScaleAspectFill;
        _mediaConfig.videoOnly = NO;
        _mediaConfig.backgroundColor = [UIColor blackColor];
        
    }
    return _mediaConfig;
}

-(void)deleteButtonClicked {
    [_clipManager deletePart];
    _magicCameraView.progressView.videoCount--;
    [self.magicCameraView recordingPercent:_clipManager.duration];
    _recordingDuration = _clipManager.duration;
    [_magicCameraView enableFinishButton:[_clipManager partCount]];
    _magicCameraView.musicButton.enabled = ![_clipManager partCount];
    _magicCameraView.countdownButton.enabled = (_clipManager.duration < _clipManager.maxDuration);
    
    if (_recordingDuration >= _quVideo.minDuration) {
        [self.magicCameraView enableFinishButton:YES];
        self.magicCameraView.finishButton.enabled = YES;
    } else {
        [self.magicCameraView enableFinishButton:NO];
    }
    if ((self.magicCameraView.progressView.videoCount == 0)&&([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold)) {
        [self.magicCameraView.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
    }
}

- (void)startRetainCameraRotate {
    //初始化全局管理对象
    if (!self.motionManager) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    if ([self.motionManager isDeviceMotionAvailable]) {
        self.motionManager.deviceMotionUpdateInterval =1;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
            // Gravity 获取手机的重力值在各个方向上的分量，根据这个就可以获得手机的空间位置，倾斜角度等
            double gravityX = motion.gravity.x;
            double gravityY = motion.gravity.y;
            //            double gravityZ = motion.gravity.z;
            double xyTheta = atan2(gravityX,gravityY)/M_PI*180.0;//手机旋转角度。
            //            double zTheta = atan2(gravityZ,sqrtf(gravityX*gravityX+gravityY*gravityY))/M_PI*180.0;//与水平方向角度
            //            BOOL isMirror = _recorder.cameraPosition == AliyunIRecorderCameraPositionFront;
            if (xyTheta >= -45 && xyTheta <= 45) {
                //down
                _cameraRotate =180;
            } else if (xyTheta > 45 && xyTheta < 135) {
                //left
                _cameraRotate = 90;
            } else if ((xyTheta >= 135 && xyTheta < 180) || (xyTheta >= -180 && xyTheta < -135)) {
                //up
                _cameraRotate = 0;
            } else if (xyTheta >= -135 && xyTheta < -45) {
                //right
                _cameraRotate = 270;
            }
            //            NSLog(@"手机旋转的角度为 --- %d", _cameraRotate);
        }];
    }
}

- (void)recorderVideoDuration:(CGFloat)duration {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //        CGFloat percent = duration / _clipManager.maxDuration;
        [self.magicCameraView recordingPercent:duration];
        _recordingDuration = duration;
    });
}

//需要reset
- (void)recordReset {
    if (_recordingDuration < [_clipManager minDuration]) {
        [_clipManager deletePart];
        _recordingDuration = 0;
        return;
    }
    
    _recordingDuration = 0;
    [_clipManager deleteAllPart];
}

- (void)didSelectRate:(CGFloat)rate {
    [self.recorder setRate:rate];
}

#pragma mark - AliyunIRecorderDelegate -

- (void)recorderDeviceAuthorization:(AliyunIRecorderDeviceAuthor)status {
    if (status == 1) {
        [self showAlertViewWithWithTitle:@"麦克风无权限"];
    } else if (status == 2) {
        [self showAlertViewWithWithTitle:@"摄像头无权限"];
    }
}

/**
 弹框提示
 
 @param title 弹框文字
 */
- (void)showAlertViewWithWithTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"打开相机失败" message:title delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

- (CVPixelBufferRef) pixelBufferFromCGImage: (CGImageRef) image
{
    
    NSDictionary *options = @{
                              (NSString*)kCVPixelBufferCGImageCompatibilityKey : @YES,
                              (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                              };
    
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, CGImageGetWidth(image),
                                          CGImageGetHeight(image), kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef) options,
                                          &pxbuffer);
    if (status!=kCVReturnSuccess) {
        NSLog(@"Operation failed");
    }
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, CGImageGetWidth(image),
                                                 CGImageGetHeight(image), 8, 4*CGImageGetWidth(image), rgbColorSpace,
                                                 kCGImageAlphaNoneSkipFirst);
    NSParameterAssert(context);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGAffineTransform flipVertical = CGAffineTransformMake( 1, 0, 0, -1, 0, CGImageGetHeight(image) );
    CGContextConcatCTM(context, flipVertical);
    CGAffineTransform flipHorizontal = CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGImageGetWidth(image), 0.0 );
    CGContextConcatCTM(context, flipHorizontal);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image),
                                           CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    
    return pxbuffer;
}
- (void)recorderDidStopRecording {
    NSLog(@"---------->暂停录制回调");
    self.magicCameraView.backButton.enabled = YES;
    // 注释允许多段录制
    //[_recorder finishRecording];
    self.upVideoCount = [_clipManager partCount];
    if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold){
        // 录制时间小于0.2秒，并且录制结束后的视频段大于录制开始时的视频段，回删最后一段视频。
        //        if (((self.upTime - self.downTime)<0.2)&&(self.upVideoCount>self.downVideoCount)) {
        //            NSInteger code = [_clipManager partCount];
        //            [self deleteButtonClicked];
        //            [_clipManager partCount];
        //            NSInteger code2 = [_clipManager partCount];
        //            NSLog(@"录制参数：%zd--%zd",code,code2);
        //        }else
        if((self.upVideoCount == self.downVideoCount)){
            self.magicCameraView.progressView.videoCount--;
            //            CGFloat percent = _clipManager.duration / _clipManager.maxDuration;
            if (_clipManager.duration>0) {
                [self.magicCameraView recordingPercent:_clipManager.duration];
            }
            _recordingDuration = _clipManager.duration;
            // 当录制结束后的视频段=录制开始时的视频=0时，恢复默认UI
            if ((self.downVideoCount==0)&&(self.upVideoCount == 0)) {
                self.magicCameraView.bottomHide = NO;
            }
        }
    }
    if (_recordingDuration >= _quVideo.minDuration) {
        [self.magicCameraView enableFinishButton:YES];
    } else {
        [self.magicCameraView enableFinishButton:NO];
    }
    _magicCameraView.musicButton.enabled = ![_clipManager partCount];
    [_magicCameraView destroy];
    _magicCameraView.userInteractionEnabled =YES;
}
#pragma mark 手动跳转编辑页-下一页
- (void)finishButtonClicked {
    if ([_clipManager partCount]) {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_recorder finishRecording];
    }
}
#pragma mark 录制完成的回调
- (void)recorderDidFinishRecording {
    NSLog(@"---------->完成录制回调");
    self.magicCameraView.backButton.enabled = YES;
    [self stopPreview];
    _magicCameraView.userInteractionEnabled =YES;
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    if (_suspend == NO) {
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick) {
            if (self.magicCameraView.recording) {
//                [self.magicCameraView recordButtonTouchDown];
                [self.magicCameraView recordButtonTouchUp];
            }
            
        }else if([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold){
            [self.magicCameraView recordButtonTouchUp];
        }
        self.magicCameraView.countdownButton.enabled = (_clipManager.duration < _clipManager.maxDuration);
        self.magicCameraView.hide = NO;
        
        NSString *outputPath = _recorder.outputPath;
        //        UISaveVideoAtPathToSavedPhotosAlbum(_recorder.outputPath, self, nil, nil);
        if (self.finishBlock) {
            self.finishBlock(outputPath);
        }else{
            [[AlivcShortVideoRoute shared]registerEditVideoPath:outputPath];
            [[AlivcShortVideoRoute shared]registerEditMediasPath:nil];
            AliyunEditViewController *editVC = (AliyunEditViewController *)[[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlEdit];
            if (self.selectBgMusic) {//有背景音乐
                editVC.bgMusic = self.selectBgMusic;
            }else if (self.bgMusic){//音乐列表
                editVC.bgMusic = self.bgMusic;
            }
            [self.navigationController pushViewController:editVC animated:YES];
        }
        
    }
    
}

- (void)recorderDidStopWithMaxDuration {
    self.magicCameraView.backButton.enabled = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.magicCameraView.flashButton.userInteractionEnabled = (_recorder.cameraPosition != 0);
    self.magicCameraView.progressView.videoCount++;
    self.magicCameraView.progressView.showBlink = NO;
    [self.recorder finishRecording];
    [self.magicCameraView destroy];
}

- (void)recoderError:(NSError *)error
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"---------->recoderError");
    self.magicCameraView.backButton.enabled = YES;
    _magicCameraView.hide = NO;
    [_magicCameraView resetRecordButtonUI];
    _magicCameraView.recording = NO;
    _magicCameraView.realVideoCount = [_clipManager partCount];
    _magicCameraView.userInteractionEnabled =YES;
    [MBProgressHUD showWarningMessage:error.localizedDescription inView:self.view];
    
}
-(void)recorderDidStartPreview{
    //    self.magicCameraView.userInteractionEnabled =YES;
}
//#pragma mark - 网络变化
////网络状态判定
//- (void)reachabilityChanged{
//    AliyunPVNetworkStatus status = [self.reachability currentReachabilityStatus];
//    if (status != AliyunPVNetworkStatusNotReachable) {
//        [self fetchData];
//    }
//}
//滤镜
- (AliyunEffectFilterView *)filterView {
    if (!_filterView) {
        _filterView = [[AliyunEffectFilterView alloc]
                       initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 180)];
        _filterView.delegate = (id<AliyunEffectFilter2ViewDelegate>)self;
        [self.view addSubview:_filterView];
        [_filterView addVisualEffect];
    }
    return _filterView;
}
#pragma mark - AliyunMusicPickViewControllerDelegate
-(void)didSelectMusic:(AliyunMusicPickModel *)music tab:(NSInteger)tab{
    self.music = music;
    self.tab = tab;
    
    if ([music.name isEqualToString:@"无音乐"] || !music.path || ![[NSFileManager defaultManager] fileExistsAtPath:music.path]) {
        //清除音乐效果
        [_recorder applyMusic:nil];
        self.tab =0;
        [self.magicCameraView setMusicButtonImage:nil];
    }else{
        AliyunEffectMusic *effectMusic = [[AliyunEffectMusic alloc] initWithFile:music.path];
        effectMusic.startTime = music.startTime;
        effectMusic.duration = music.duration;
        [_recorder applyMusic:effectMusic];
        NSLog(@"%@",effectMusic.path);
        NSLog(@"----------->:有path，有文件");
        //        [self.magicCameraView setMusicButtonImage:music.image];
    }
    
}

-(void)didCancelPick {
}


#pragma mark 裁剪完成 AliyunPhotoViewControllerDelegate
- (void)backBtnClick:(UIViewController *)vc{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 特殊需求：选择视频后返回该视频的音频
 */
- (void)backWithAssert:(NSString *)audioPath{
    
    NSLog(@"返回MagicVC音频元素assert=%@",audioPath);
    
}
- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        NSLog(@"文件不存在!");
    }
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"裁剪完成，保存到相册失败");
        }
        BOOL isVideoOK = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath);
        if (!isVideoOK){
            NSLog(@"视频已损坏:%@",videoPath);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪完成" message:@"已保存到手机相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}
- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath {
    if (type == kPhotoMediaTypePhoto) {
        UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error != NULL){
        NSLog(@"裁剪完成，保存到相册失败");
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪完成" message:@"已保存到手机相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    });
}


@end
