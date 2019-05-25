//
//  AliyunRecordCameraView.m
//  AliVideoDemo
//
//  Created by Apple on 2019/5/25.
//  Copyright © 2019 Apple. All rights reserved.
//

#import "AliyunRecordCameraView.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcUIConfig.h"
#import "AliyunRecordBeautyView.h"
#import "AlivcRecordFocusView.h"

@interface AliyunRecordCameraView()

@property (nonatomic, strong)UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *dotImageView;// 时间显示控件旁边的小圆点，正在录制的时候显示

@property (nonatomic, strong) UIImageView *triangleImageView;// 底部显示三角形的view

@property (nonatomic, strong)AlivcRecordUIConfig *uiConfig;

@property (nonatomic, strong)AlivcRecordFocusView *focusView;


@property (nonatomic, weak) AliyunRecordBeautyView *beautyView;

@property (nonatomic, strong) AliyunRecordBeautyView *rightView;// 录制按钮右边的按钮
@property (nonatomic, strong) AliyunRecordBeautyView *leftView;// 录制按钮左边的按钮
@property (nonatomic, assign) double startTime;// 手指按下录制按钮的时间
@property (nonatomic, assign)CFTimeInterval cameraIdButtonClickTime;
@end
@implementation AliyunRecordCameraView
- (instancetype)initWithUIConfig:(AlivcRecordUIConfig *)uiConfig{
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    if (self) {
        _uiConfig = uiConfig;
        [AliyunIConfig config].recordType = AliyunIRecordActionTypeClick;
        [self setupSubview];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubview];
    }
    return self;
}
- (void)setupSubview {
    _cameraIdButtonClickTime =CFAbsoluteTimeGetCurrent();
    if(!_uiConfig){
        _uiConfig = [[AlivcRecordUIConfig alloc]init];
    }
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0,(IPHONEX ? 44 : 0), CGRectGetWidth(self.bounds), 44+8)];
    [self addSubview:self.topView];
    [self.topView addSubview:self.backButton];
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
    
    [self.topView addSubview:self.backButton];
    [self.topView addSubview:self.cameraIdButton];
    [self.topView addSubview:self.finishButton];
    [self.topView addSubview:self.musicButton];
    [self insertSubview:self.previewView atIndex:0];
    
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 60 , CGRectGetWidth(self.bounds), 60)];
    self.bottomView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    [self addSubview:self.bottomView];
    
    self.deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-40, ScreenHeight-42 - SafeBottom, 70, 40)];
    self.deleteButton.hidden = YES;
    self.deleteButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.deleteButton setTitle:@" 回删" forState:UIControlStateNormal];
    [self.deleteButton setImage:_uiConfig.deleteImage forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deletePartClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.deleteButton];
    
    self.circleBtn = [[MagicCameraPressCircleView alloc] initWithFrame:CGRectMake(ScreenWidth/2-40, ScreenHeight - 120 - SafeBottom, 80, 80)];
    [self addSubview:self.circleBtn];
    [self.circleBtn addTarget:self action:@selector(recordButtonTouchUp) forControlEvents:UIControlEventTouchUpInside];
    [self.circleBtn addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.circleBtn addTarget:self action:@selector(recordButtonTouchUpDragOutside) forControlEvents:UIControlEventTouchDragOutside];
    
    
    self.beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.beautyButton setImage:_uiConfig.faceImage forState:UIControlStateNormal];
    [self.beautyButton setBackgroundColor:[UIColor clearColor]];
    [self.beautyButton addTarget:self action:@selector(beauty) forControlEvents:UIControlEventTouchUpInside];
    self.beautyButton.frame = CGRectMake(0, 0, 40, 40);
    CGFloat y = self.circleBtn.center.y;
    CGFloat x = ScreenWidth/2-120;
    self.beautyButton.center = CGPointMake(x, y);
    [self addSubview:self.beautyButton];
    
    self.gifPictureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.gifPictureButton setImage:_uiConfig.magicImage forState:UIControlStateNormal];
    [self.gifPictureButton setBackgroundColor:[UIColor clearColor]];
    [self.gifPictureButton addTarget:self action:@selector(getGifPictureView) forControlEvents:UIControlEventTouchUpInside];
    self.gifPictureButton.frame = CGRectMake(0, 0, 40, 40);
    self.gifPictureButton.center = CGPointMake(ScreenWidth/2+120, y);
    [self addSubview:self.gifPictureButton];
    
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.frame = CGRectMake(0, 0, 60, 16);
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.textColor = [UIColor whiteColor];
    self.timeLabel.center = CGPointMake(ScreenWidth / 2+10, ScreenHeight - 152-SafeBottom);
    [self addSubview:self.timeLabel];
    
    self.dotImageView = [[UIImageView alloc] initWithImage:_uiConfig.dotImage];
    self.dotImageView.center = CGPointMake(ScreenWidth/2-30, self.timeLabel.center.y);
    self.dotImageView.hidden = YES;
    [self addSubview:self.dotImageView];
    
    [self addSubview:self.progressView];
    
    self.triangleImageView = [[UIImageView alloc] initWithImage:_uiConfig.triangleImage];
    self.triangleImageView.center = CGPointMake(ScreenWidth/2, ScreenHeight-8-SafeBottom);
    [self addSubview:self.triangleImageView];
    
    UIButton *tapButton = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth/2-21, ScreenHeight-36-SafeBottom, 45, 20)];
    [tapButton setTitle:@"单击拍" forState:UIControlStateNormal];
    [tapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tapButton addTarget:self action:@selector(tapButtonClick) forControlEvents:UIControlEventTouchUpInside];
    tapButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.tapButton = tapButton;
    [self addSubview:tapButton];
    
    [self setExclusiveTouchInButtons];
}
/**
 按钮间设置不能同时点击
 */
- (void)setExclusiveTouchInButtons{
    [self.tapButton setExclusiveTouch:YES];
    [self.beautyButton setExclusiveTouch:YES];
    [self.gifPictureButton setExclusiveTouch:YES];
    [self.musicButton setExclusiveTouch:YES];
    [self.deleteButton setExclusiveTouch:YES];
    [self.finishButton setExclusiveTouch:YES];
    [self.cameraIdButton setExclusiveTouch:YES];
}
#pragma mark - Getter -
/**
 美颜按钮的点击事件
 */
- (void)beauty{
    
    self.beautyView = self.leftView;
    [self addSubview:self.beautyView];
    self.bottomHide = YES;
    
}
- (AliyunRecordBeautyView *)leftView{
    if (!_leftView) {
        _leftView = [[AliyunRecordBeautyView alloc] initWithFrame:CGRectMake(0, ScreenHeight-180-78-SafeAreaBottom, ScreenWidth, 180+78+SafeAreaBottom)  titleArray:@[@"滤镜",@"美颜",@"美肌"] imageArray:@[@"shortVideo_fliter",@"shortVideo_emotion",@"shortVideo_beautySkin"]];
        _leftView.delegate = self;
    }
    return _leftView;
}

/**
 动图按钮的点击事件
 */
- (void)getGifPictureView{
    self.beautyView = self.rightView;
    [self addSubview:self.beautyView];
    self.bottomHide = YES;
//    if (!self.isFirst) {
//        [self refreshUIWithGifItems:self.effectItems];
//        self.isFirst = YES;
//    }
}

- (AliyunRecordBeautyView *)rightView{
    if (!_rightView) {
        _rightView = [[AliyunRecordBeautyView alloc] initWithFrame:CGRectMake(0, ScreenHeight-200, ScreenWidth, 200)  titleArray:@[@"人脸贴纸"] imageArray:@[@"shortVideo_gifPicture"]];
        _rightView.delegate = self;
        
    }
    return _rightView;
}
- (void)cancelRecordBeautyView{
    if (self.beautyView) {
        self.bottomHide = NO;
        [self.beautyView removeFromSuperview];
    }
    
}
#pragma mark 录制相关
- (void)recordButtonTouchUp {
    NSLog(@" DD----  %f    %f  - %f", CFAbsoluteTimeGetCurrent(), _startTime, (CFAbsoluteTimeGetCurrent() - _startTime));
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
            if (_recording) {
                [self endRecord];
            }
            break;
            
        case AliyunIRecordActionTypeHold:
            if (_recording) {
                
                [self endRecord];
                self.circleBtn.transform = CGAffineTransformIdentity;
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
            }
            break;
            
        case AliyunIRecordActionTypeClick:
            if (_recording) {
                [self endRecord];
                self.circleBtn.transform = CGAffineTransformIdentity;
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
                return;
            }else{
                self.tapButton.hidden = YES;
                self.triangleImageView.hidden = YES;
                _recording = YES;
                _progressView.videoCount++;
                self.circleBtn.transform = CGAffineTransformScale(self.transform, 1.32, 1.32);
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageShooting forState:UIControlStateNormal];
                self.dotImageView.hidden = NO;
                [_delegate recordButtonRecordVideo];
            }
            break;
        default:
            break;
    }
    
}

- (void)recordButtonTouchDown {
    _startTime = CFAbsoluteTimeGetCurrent();
    
    NSLog(@"  YY----%f---%zd", _startTime,[AliyunIConfig config].recordType);
    
    switch ([AliyunIConfig config].recordType) {
        case AliyunIRecordActionTypeCombination:
            if (_recording) {
                [self endRecord];
                return;
            }else{
                _recording = YES;
            }
            break;
        case AliyunIRecordActionTypeHold:
            
            if (_recording == NO) {
                _recording = YES;
                self.tapButton.hidden = YES;
                self.triangleImageView.hidden = YES;
                self.circleBtn.transform = CGAffineTransformScale(self.transform, 1.32, 1.32);
                [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageLongPressing forState:UIControlStateNormal];
                [self.circleBtn setTitle:@"" forState:UIControlStateNormal];
                _progressView.videoCount++;
                self.dotImageView.hidden = NO;
                [_delegate recordButtonRecordVideo];
            }
            
            break;
            
        case AliyunIRecordActionTypeClick:
            
            break;
        default:
            break;
    }
}

- (void)recordButtonTouchUpDragOutside{
    if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold) {
        [self endRecord];
        self.circleBtn.transform = CGAffineTransformIdentity;
        [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
    }
}

/**
 结束录制
 */
- (void)endRecord{
    if (!_recording) {
        return;
    }
    _startTime = 0;
    _recording = NO;
    [_delegate recordButtonPauseVideo];
    _progressView.showBlink = NO;
    [self destroy];
    _deleteButton.enabled = YES;
    
    if ([AliyunIConfig config].recordOnePart) {
        if (_delegate) {
            [_delegate recordButtonFinishVideo];
        }
    }
    if (self.progressView.videoCount > 0 ) {
        self.deleteButton.hidden = NO;
    }
    self.dotImageView.hidden = YES;
}


- (void)recordingPercent:(CGFloat)percent
{
    [self.progressView updateProgress:percent];
    if(_recording){
        int d = percent;
        int m = d / 60;
        int s = d % 60;
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d",m,s];
    }
    
    if(percent == 0){
        [self.progressView reset];
        self.deleteButton.hidden = YES;
        self.triangleImageView.hidden = NO;
        self.tapButton.hidden = NO;
        self.timeLabel.text = @"";
    }
}

- (void)destroy
{
    self.timeLabel.text = @"";
    self.dotImageView.hidden = YES;
}


/**
 显示单击拍按钮的点击事件
 */
- (void)tapButtonClick{
    CGFloat y = self.tapButton.center.y;
    self.tapButton.center = CGPointMake(ScreenWidth/2, y);
    [self.tapButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.circleBtn setTitle:@"" forState:UIControlStateNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(tapButtonClicked)]) {
        [self.delegate tapButtonClicked];
    }
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor clearColor];
        _backButton.frame = CGRectMake(0, 8, 44, 44);
        [_backButton setImage:_uiConfig.backImage forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)finishButton
{
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishButton.backgroundColor = [UIColor clearColor];
        _finishButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 34 - 10, 8, 44, 44);
        _finishButton.hidden = NO;
        [_finishButton setImage:_uiConfig.finishImageUnable forState:UIControlStateDisabled];
        _finishButton.enabled = NO;
        [_finishButton setImage:_uiConfig.finishImageEnable forState:UIControlStateNormal];
        [_finishButton addTarget:self action:@selector(finishButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _finishButton;
}

- (UIButton *)cameraIdButton
{
    if (!_cameraIdButton) {
        _cameraIdButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cameraIdButton.backgroundColor = [UIColor clearColor];
        _cameraIdButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 78 - 10 - 5, 8, 44, 44);
        [_cameraIdButton setImage:_uiConfig.switchCameraImage forState:UIControlStateNormal];
        [_cameraIdButton addTarget:self action:@selector(cameraIdButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraIdButton;
}
- (UIButton *)musicButton{
    if (!_musicButton) {
        _musicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _musicButton.backgroundColor = [UIColor clearColor];
        _musicButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 210 - 10 - 20, 8, 44, 44);
        [_musicButton setImage:_uiConfig.musicImage forState:UIControlStateNormal];
        [_musicButton addTarget:self action:@selector(musicButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _musicButton;
}
- (QUProgressView *)progressView {
    if (!_progressView) {
        _progressView = [[QUProgressView alloc] initWithFrame:CGRectMake(0, IPHONEX ? 44 : 0, CGRectGetWidth(self.bounds), 4)];
        _progressView.showBlink = NO;
        _progressView.showNoticePoint = YES;
        _progressView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.01];
        _progressView.colorProgress = [UIColor purpleColor];
    }
    return _progressView;
}

- (UIView *)previewView{
    if (!_previewView) {
        _previewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    }
    return _previewView;
}

-(AlivcRecordFocusView *)focusView{
    if (!_focusView) {
        CGFloat size = 150;
        _focusView =[[AlivcRecordFocusView alloc]initWithFrame:CGRectMake(0, 0, size, size)];
        _focusView.animation =YES;
        [self.previewView addSubview:_focusView];
    }
    return _focusView;
}

-(void)refreshFocusPointWithPoint:(CGPoint)point{
    self.focusView.center = point;
    [self.previewView bringSubviewToFront:self.focusView];
}

#pragma mark Actions
- (void)musicButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicButtonClicked)]) {
        [self.delegate musicButtonClicked];
    }
}
- (void)deletePartClicked {
    if ([self.delegate respondsToSelector:@selector(deleteButtonClicked)]) {
        [self.delegate deleteButtonClicked];
    }
}
/**
 返回按钮的点击事件
 */
- (void)backButtonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(backButtonClicked)]) {
        [self.delegate backButtonClicked];
    }
}
/**
 前置、后置摄像头切换按钮的点击事件
 */
- (void)cameraIdButtonClicked:(id)sender
{
    if (CFAbsoluteTimeGetCurrent()-_cameraIdButtonClickTime >1.2) {//限制连续点击时间间隔不能小于1s
        //        NSLog(@"=============>切换摄像头");
        _cameraIdButtonClickTime =CFAbsoluteTimeGetCurrent();
        if (self.delegate && [self.delegate respondsToSelector:@selector(cameraIdButtonClicked)]) {
            [self.delegate cameraIdButtonClicked];
        }
    }
}
- (void)resetRecordButtonUI{
    self.circleBtn.transform = CGAffineTransformIdentity;
    [self.circleBtn setBackgroundImage:_uiConfig.videoShootImageNormal forState:UIControlStateNormal];
    self.dotImageView.hidden = YES;
    if([AliyunIConfig config].recordType == AliyunIRecordActionTypeClick){
        [self.circleBtn setTitle:@"" forState:UIControlStateNormal];
    }else if([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold){
        if (!self.progressView.videoCount) {
            [self.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
        }
        
    }
}

#pragma mark - MagicCameraScrollViewDelegate
//- (void)focusItemIndex:(NSInteger)index cell:(UICollectionViewCell *)cell
//{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(effectItemFocusToIndex:cell:)]&&(!_recording) && self.beautyView) {
//        [self.delegate effectItemFocusToIndex:index cell: cell];
//    }
//}
- (void)setHide:(BOOL)hide {
    self.deleteButton.hidden = hide;
    self.topView.hidden = hide;
    self.beautyButton.hidden = hide;
    self.gifPictureButton.hidden = hide;
}
- (void)setBottomHide:(BOOL)hide{
    _bottomHide = hide;
    self.beautyButton.hidden = hide;
    self.gifPictureButton.hidden = hide;
    self.circleBtn.hidden = hide;
    if(self.progressView.videoCount){
        self.triangleImageView.hidden = YES;
        self.tapButton.hidden = YES;
        self.deleteButton.hidden = NO;
    }else{
        self.triangleImageView.hidden = hide;
        self.tapButton.hidden = hide;
        self.deleteButton.hidden = YES;
        if ([AliyunIConfig config].recordType == AliyunIRecordActionTypeHold) {
            [self.circleBtn setTitle:@"按住拍" forState:UIControlStateNormal];
        }
    }
}
- (void)setRealVideoCount:(NSInteger)realVideoCount{
    if (realVideoCount) {
        self.triangleImageView.hidden = YES;
        self.tapButton.hidden = YES;
        self.deleteButton.hidden = NO;
    }else{
        self.triangleImageView.hidden = NO;
        self.tapButton.hidden = NO;
        self.deleteButton.hidden = YES;
    }
}
-(void)setMaxDuration:(CGFloat)maxDuration{
    _maxDuration = maxDuration;
    self.progressView.maxDuration = maxDuration;
}
-(void)setMinDuration:(CGFloat)minDuration{
    _minDuration = minDuration;
    self.progressView.minDuration = minDuration;
}
#pragma mark - AliyunRecordBeautyViewDelegate
- (void)didChangeAdvancedMode{
    if ([self.delegate respondsToSelector:@selector(didChangeAdvancedMode)]) {
        [self.delegate didChangeAdvancedMode];
    }
}

- (void)didChangeCommonMode{
    if ([self.delegate respondsToSelector:@selector(didChangeCommonMode)]) {
        [self.delegate didChangeCommonMode];
    }
}
//- (void)didFetchGIFListData{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didFetchGIFListData)]) {
//        [self.delegate didFetchGIFListData];
//    }
//}
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectEffectFilter:)]) {
        [self.delegate didSelectEffectFilter:filter];
    }
}

- (void)didChangeBeautyValue:(CGFloat)beautyValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeBeautyValue:)]) {
        [self.delegate didChangeBeautyValue:beautyValue];
    }
}

- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBeautyWhiteValue:)]) {
        [self.delegate didChangeAdvancedBeautyWhiteValue:beautyWhiteValue];
    }
}
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBlurValue:)]) {
        [self.delegate didChangeAdvancedBlurValue:blurValue];
    }
}
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBigEye:)]) {
        [self.delegate didChangeAdvancedBigEye:bigEyeValue];
    }
}
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedSlimFace:)]) {
        [self.delegate didChangeAdvancedSlimFace:slimFaceValue];
    }
}

- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChangeAdvancedBuddy:)]) {
        [self.delegate didChangeAdvancedBuddy:buddyValue];
    }
}

//- (void)recordBeautyView:(AliyunRecordBeautyView *)view dismissButtonTouched:(UIButton *)button{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(magicCameraView:dismissButtonTouched:)]) {
//        [self.delegate magicCameraView:self dismissButtonTouched:button];
//    }
//}

//- (void)recordBeatutyViewDidSelectHowToGet:(AliyunRecordBeautyView *)view{
//    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedHowToGet)]) {
//        [self.delegate didSelectedHowToGet];
//    }
//
//}

@end
