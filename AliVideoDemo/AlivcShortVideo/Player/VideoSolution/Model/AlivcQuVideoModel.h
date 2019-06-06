//
//  AlivcQuVideoModel.h
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2019/1/9.
//  Copyright © 2019年 Alibaba. All rights reserved.
//  视频信息的抽象 - 属性有为空的情况，注意判断

#import <Foundation/Foundation.h>


/**
 视频的抽象状态

 - AlivcQuVideoAbstractionStatus_On: 进行中
 - AlivcQuVideoAbstractionStatus_Success: 成功
 - AlivcQuVideoAbstractionStatus_Fail: 失败
 */
typedef NS_ENUM(NSInteger,AlivcQuVideoAbstractionStatus){
    AlivcQuVideoAbstractionStatus_On = 0,
    AlivcQuVideoAbstractionStatus_Success,
    AlivcQuVideoAbstractionStatus_Fail
};

@interface AlivcQuVideoModel : NSObject
#pragma mark - 初始化方法

/**
 指定初始化方法 - Designated Initializers

 @param dic 用于初始化的数据
 @return 实例化对象
 */
- (instancetype)initWithDic:(NSDictionary *)dic;

#pragma mark - 原始数据

/**
 id - 数据库自动递增的标识
 */
@property (strong, nonatomic, readonly) NSString *ID;

/**
 视频标题
 */
@property (strong, nonatomic, readonly) NSString *title;

/**
 视频id
 */
@property (strong, nonatomic, readonly) NSString *videoId;

/**
 视频file地址
 */
@property (nonatomic, strong)NSString *fileUrl;


/**
 视频描述
 */
@property (strong, nonatomic, readonly) NSString *videoDescription;

/**
 视频时长（秒）
 */
@property (strong, nonatomic, readonly) NSString *durationString;

/**
 视频封面URL
 */
@property (strong, nonatomic, readonly) NSString *coverUrl;

/**
 视频状态 - 现在没有用到 - 以后可能用到 - 所以先放这里
 */
@property (strong, nonatomic, readonly) NSString *statusString __attribute__((deprecated("视频状态 - 现在没有用到 - 统一由具体的四个状态来确定")));

/**
 首帧地址
 */
@property (strong, nonatomic, readonly) NSString *firstFrameUrl;

/**
 视频源文件大小（字节）
 */
@property (strong, nonatomic, readonly) NSString *sizeString;

/**
 视频标签,多个用逗号分隔?
 */
@property (strong, nonatomic, readonly) NSString *tags;

/**
 视频分类
 */
@property (strong, nonatomic, readonly) NSString *cateId;

/**
 视频分类名称
 */
@property (strong, nonatomic, readonly) NSString *cateName;

/**
 创建时间-字符串的原始数据
 */
@property (strong, nonatomic, readonly) NSString *creationTimeString;

/**
 转码状态 - onTranscode（转码中），success（转码成功），fail（转码失败）
 */
@property (strong, nonatomic, readonly) NSString *transcodeStatusString;

/**
 截图状态 - onSnapshot（截图中），success（截图成功），fail（截图失败）
 */
@property (strong, nonatomic, readonly) NSString *snapshotStatusString;

/**
 审核状态 - onCensor（审核中），success（审核成功），fail（审核不通过）
 */
@property (strong, nonatomic, readonly) NSString *censorStatusString;

/**
 窄带高清转码状态 - onTranscode（转码中），success（转码成功），fail（转码失败）
 ps:窄带高清也是一种特殊的转码
 */
@property (strong, nonatomic, readonly) NSString *narrowTranscodeStatusString;

/**
 所属的用户id
 */
@property (strong, nonatomic, readonly) NSString *belongUserId;

/**
 所属的用户名
 */
@property (strong, nonatomic, readonly) NSString *belongUserName;

/**
 所属的用户的头像URL
 */
@property (strong, nonatomic, readonly) NSString *belongUserAvatarUrl;

#pragma mark - 方便开发者使用的二次包装 - 基于原始数据
/**
 视频时长（秒）
 */
@property (assign, nonatomic, readonly) NSInteger duration;

/**
 封面图 - 内部不会请求，由使用者自己管理
 */
@property (strong, nonatomic) UIImage *coverImage;

/**
 首帧图 - 内部不会请求，由使用者自己管理
 */
@property (strong, nonatomic) UIImage *firstFrameImage;

/**
 创建时间
 */
@property (strong, nonatomic, readonly) NSDate *creationDate;

/**
 转码状态 - onTranscode（转码中），success（转码成功），fail（转码失败）
 */
@property (assign, nonatomic, readonly) AlivcQuVideoAbstractionStatus transcodeStatus;

/**
 截图状态 - onSnapshot（截图中），success（截图成功），fail（截图失败）
 */
@property (assign, nonatomic, readonly) AlivcQuVideoAbstractionStatus snapshotStatus;

/**
 审核状态 - assign（审核中），success（审核成功），fail（审核不通过）
 */
@property (assign, nonatomic, readonly) AlivcQuVideoAbstractionStatus ensorStatus;

/**
 窄带高清转码状态 - onTranscode（转码中），success（转码成功），fail（转码失败）
 ps:窄带高清也是一种特殊的转码
 */
@property (assign, nonatomic, readonly) AlivcQuVideoAbstractionStatus narrowTranscodeStatus;

/**
 所属的用户的头像
 */
@property (strong, nonatomic) UIImage *belongUserAvatarImage;

@end


