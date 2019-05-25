//
//  AliyunRecordCameraView.h
//  AliVideoDemo
//
//  Created by Apple on 2019/5/25.
//  Copyright © 2019 Apple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MagicCameraPressCircleView.h"
#import "AliyunRateSelectView.h"
#import "QUProgressView.h"
#import "AlivcRecordUIConfig.h"
@class AliyunEffectFilterInfo,AliyunMagicCameraView;

NS_ASSUME_NONNULL_BEGIN
@protocol RecordCameraViewDelegate <NSObject>

/**
 选中某滤镜、动图
 
 @param index 序号
 @param cell cell对象
 */
- (void)effectItemFocusToIndex:(NSInteger)index cell:(UICollectionViewCell *)cell;

/**
 返回按钮被点击的代理方法
 */
- (void)backButtonClicked;

/**
 前后摄像头切换按钮被点击的代理方法
 */
- (void)cameraIdButtonClicked;
/**
 音乐按钮被点击的代理方法
 */
- (void)musicButtonClicked;

/**
 定时器按钮被点击的代理方法
 */
- (void)timerButtonClicked;

/**
 回删按钮被点击的代理方法
 */
- (void)deleteButtonClicked;

/**
 完成按钮被点击的代理方法
 */
- (void)finishButtonClicked;

/**
 开始录制的代理方法
 */
- (void)recordButtonRecordVideo;

/**
 暂停录制的代理方法
 */
- (void)recordButtonPauseVideo;

/**
 完成录制的代理方法
 */
- (void)recordButtonFinishVideo;

/**
 基础美颜的美颜值改变
 
 @param beautyValue 美颜值（1-100）
 */
- (void)didChangeBeautyValue:(CGFloat)beautyValue;

/**
 选中某个滤镜
 
 @param filter 滤镜数据模型
 */
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;

/**
 高级美颜的美白值改变
 
 @param beautyWhiteValue 高级美颜：美白参数值
 */
- (void)didChangeAdvancedBeautyWhiteValue:(CGFloat)beautyWhiteValue;

/**
 高级美颜的磨皮值改变
 
 @param blurValue 高级美颜：磨皮参数值
 */
- (void)didChangeAdvancedBlurValue:(CGFloat)blurValue;

/**
 美肌的大眼值改变
 
 @param bigEyeValue 美肌：大眼参数值
 */
- (void)didChangeAdvancedBigEye:(CGFloat)bigEyeValue;

/**
 美肌的瘦脸值改变
 
 @param slimFaceValue 美肌：瘦脸参数值
 */
- (void)didChangeAdvancedSlimFace:(CGFloat)slimFaceValue;

/**
 高级美颜的红润值改变
 
 @param buddyValue 高级美颜：红润参数值
 */
- (void)didChangeAdvancedBuddy:(CGFloat)buddyValue;


/**
 单击拍文字被点击的代理方法
 */
- (void)tapButtonClicked;
/**
 切换高级美颜
 */
- (void)didChangeAdvancedMode;

/**
 切换普通美颜
 */
- (void)didChangeCommonMode;

/**
 退出AliyunRecordBeautyView的view
 
 @param view 此类的view
 @param button 退出按钮
 */
- (void)magicCameraView:(AliyunMagicCameraView *)view dismissButtonTouched:(UIButton *)button;



@end


@interface AliyunRecordCameraView : UIView
/**
 指定初始化
 @param uiConfig 短视频拍摄界面UI配置
 @return self对象
 */
- (instancetype)initWithUIConfig:(AlivcRecordUIConfig *)uiConfig;

@property (nonatomic, weak) id<RecordCameraViewDelegate> delegate;

@property (nonatomic, strong) UIView *previewView;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong)UIButton *circleBtn;

@property (nonatomic, strong)UIButton *finishButton;

@property (nonatomic, strong)UIButton *musicButton;

@property (nonatomic, strong)UIButton *beautyButton;

@property (nonatomic, strong) UIButton *cameraIdButton;//前后摄像头切换

@property (nonatomic, strong) UIButton *deleteButton;// 回删按钮

@property (nonatomic, strong)UIButton *backButton;

@property (nonatomic, strong)UIButton *gifPictureButton;

@property (nonatomic, strong)UIButton *tapButton;

/**
 如果为Yes，只显示录制按钮和时间
 */
@property (nonatomic, assign) BOOL hide;

/**
 是否正在录制
 */
@property (nonatomic, assign) BOOL recording;

/**
 隐藏底部的相关view（点击录制按钮旁边左右两个按钮弹出的view时需要隐藏底部view）
 */
@property (nonatomic, assign) BOOL bottomHide;

/**
 进度条
 */
@property (nonatomic, strong) QUProgressView *progressView;

/**
 最大时间
 */
@property (nonatomic, assign) CGFloat maxDuration;

/**
 最小时间
 */
@property (nonatomic, assign) CGFloat minDuration;

/**
 准确的视频个数
 */
@property (nonatomic, assign) NSInteger realVideoCount;

/**
 刷新进度条的进度
 
 @param percent 进度
 */
- (void)recordingPercent:(CGFloat)percent;

/**
 停止录制时的一些状态恢复
 */
- (void)destroy;

/**
 手指按下录制按钮
 */
- (void)recordButtonTouchDown;

/**
 手指松开录制按钮
 */
- (void)recordButtonTouchUp;
/**
 刷新焦点UI
 
 @param point 焦点坐标
 */
-(void)refreshFocusPointWithPoint:(CGPoint)point;
/**
 取消beautyView(点击录制按钮旁边左右两个按钮弹出的view)
 */
- (void)cancelRecordBeautyView;
/**
 录制按钮的UI恢复到点击录制前
 */
- (void)resetRecordButtonUI;

@end

NS_ASSUME_NONNULL_END
