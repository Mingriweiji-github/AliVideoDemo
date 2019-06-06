//
//  AliPlayer.h
//  AliPlayer
//
//  Created by shiping.csp on 2018/11/16.
//  Copyright © 2018年 com.alibaba.AliyunPlayer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVPDelegate.h"
#import "AVPSource.h"
#import "AVPDef.h"
#import "AVPMediaInfo.h"
#import "AVPConfig.h"
OBJC_EXPORT
@interface AliPlayer : NSObject

/**
 @brief 初始化播放器
 */
- (instancetype)init;

/**
 @brief 初始化播放器
 @param traceID 用于跟踪debug信息
 */
- (instancetype)init:(NSString*)traceID;

/**
 @brief 使用url方式来播放视频
 @param source AVPUrlSource的输入类型
 @see AVPUrlSource
 */
- (void)setUrlSource:(AVPUrlSource*)source;

/**
 @brief 用vid和sts来播放视频，临时AccessKeyId、AccessKeySecret和SecurityToken：开启RAM授权，并通过STS授权系统提供的OpenAPI或SDK获取的AccessKeyId、AccessKeySecret和SecurityToken，用于播放和下载请求参数明细：https://help.aliyun.com/document_detail/28788.html?spm=5176.doc28787.6.706.2G5SLS
 @param source AVPVidStsSource的输入类型
 @see AVPVidStsSource
 */
- (void)setStsSource:(AVPVidStsSource*)source;

/**
 @brief 用vid和MPS信息来播放视频，视频转码服务用户使用播放方式。部分参数参考:https://help.aliyun.com/document_detail/53522.html?spm=5176.doc53534.2.5.mhSfOh
 @param source AVPVidMpsSource的输入类型
 @see AVPVidMpsSource
 */
- (void)setMpsSource:(AVPVidMpsSource*)source;

/**
 @brief 使用vid+playauth方式播放。playauth获取方法：https://help.aliyun.com/document_detail/52881.html?spm=5176.doc52879.6.650.aQZsBR
 @param source AVPVidAuthSource的输入类型
 @see AVPVidAuthSource
 */
- (void)setAuthSource:(AVPVidAuthSource*)source;

/**
 @brief 播放准备，异步
 */
-(void)prepare;

/**
 @brief 开始播放
 */
-(void)start;

/**
 @brief 暂停播放
 */
-(void)pause;

/**
 @brief 刷新view，例如view size变化时。
 */
-(void)redraw;

/**
 @brief 重置播放
 */
-(void)reset;

/**
 @brief 停止播放
 */
-(void)stop;

/**
 @brief 销毁播放器
 */
-(void)destroy;

/**
 @brief 跳转到指定的播放位置
 @param time 新的播放位置
 @param seekMode seek模式
 @see AVPSeekMode
 */
-(void)seekToTime:(int64_t)time seekMode:(AVPSeekMode)seekMode;

/**
 @brief 截图 AVPImage: mac平台返回NSImage，iOS平台返回UIImage
 */
-(void) snapShot;

/**
 @brief 根据trackIndex，切换清晰度
 @param trackIndex 选择清晰度的index，SELECT_AVPTRACK_TYPE_VIDEO_AUTO代表自适应码率
 */
-(void)selectTrack:(int)trackIndex;

/**
 @brief 获取媒体信息，包括track信息
 */
-(AVPMediaInfo*) getMediaInfo;

/**
 @brief 获取当前播放track
 @param type track类型
 @see AVPTrackType
 */
-(AVPTrackInfo*) getCurrentTrack:(AVPTrackType)type;

/**
 @brief 获取指定位置的缩略图
 @param positionMs 代表在哪个指定位置的缩略图
 */
-(void)getThumbnail:(int64_t)positionMs;

/**
 @brief 用于跟踪debug信息
 @param traceID 指定和其他客户端连接可跟踪的id
 */
- (void) setTraceID:(NSString*)traceID;


/**
 @brief 设置转换播放的url的回调函数，一般用于p2p中的url地址转换
 @param callback 回调函数指针
 */
- (void) setPlayUrlConvertCallback:(PlayURLConverCallback)callback;

/**
 @brief 播放器设置
 @param config AVPConfig类型
 @see AVPConfig
 */
-(void) setConfig:(AVPConfig*)config;

/**
 @brief 获取播放器设置
 @see AVPConfig
 */
-(AVPConfig*) getConfig;

/**
 @brief 获取SDK版本号信息
 */
+ (NSString*) getSDKVersion;

/**
 @brief 初始化播放器组件。这些组件是可裁剪的。App可删除相应动态库，去掉初始化组件代码，实现裁剪。
 */
+ (void) initPlayerComponent:(NSString *)functionName function:(void*)function;

/**
 @brief 设置是否静音
 */
@property(nonatomic, getter=isMuted) BOOL muted;

/**
 @brief 播放速率，0.5-2.0之间，1为正常播放
 */
@property(nonatomic) float rate;

/**
 @brief 是否开启硬件解码
 */
@property(nonatomic) BOOL enableHardwareDecoder;

/**
 @brief 设置是否循环播放
 */
@property(nonatomic, getter=isLoop) BOOL loop;

/**
 @brief 设置是否自动播放
 */
@property(nonatomic, getter=isAutoPlay) BOOL autoPlay;

/**
 @brief 是否打开log输出
 */
@property(nonatomic) BOOL enableLog;

/**
 @brief 渲染镜像模式
 @see AVPMirrorMode
 */
@property(nonatomic) AVPMirrorMode mirrorMode;

/**
 @brief 渲染旋转模式
 @see AVPRotateMode
 */
@property(nonatomic) AVPRotateMode rotateMode;

/**
 @brief 渲染填充模式
 @see AVPScalingMode
 */
@property(nonatomic) AVPScalingMode scalingMode;


/**
 @brief 设置播放器的视图playerView
 * AVPView: mac下为NSOpenGLView，iOS下为UIView
 */
@property(nonatomic, strong) AVPView* playerView;

/**
 @brief 获取视频的宽度
 */
@property (nonatomic, readonly) int width;

/**
 @brief 获取视频的高度
 */
@property (nonatomic, readonly) int height;

/**
 @brief 获取视频的旋转角度，从metadata中获取出来
 */
@property (nonatomic, readonly) int rotation;

/**
 @brief 获取/设置播放器的音量
 */
@property (nonatomic, assign) float volume;

/**
 @brief 获取视频的长度
 */
@property (nonatomic, readonly) int64_t duration;

/**
 @brief 获取当前播放位置
 */
@property (nonatomic, readonly) int64_t currentPosition;

/**
 @brief 获取已经缓存的位置
 */
@property (nonatomic, readonly) int64_t bufferedPosition;

/**
 @brief 设置代理，参考AVPDelegate
 @see AVPDelegate
 */
@property (nonatomic, weak) id<AVPDelegate> delegate;

@end

