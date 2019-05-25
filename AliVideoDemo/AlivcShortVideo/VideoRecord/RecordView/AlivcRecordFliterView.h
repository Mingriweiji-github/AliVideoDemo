//
//  AlivcRecordFliterView.h
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/11/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunEffectFilterInfo.h"
#import "AliyunEffectMvGroup.h"
@protocol AliyunEffectFilter2ViewDelegate <NSObject>
@optional

/**
 选中某个滤镜滤镜
 
 @param filter 滤镜数据模型
 */
- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter;


@end
@interface AlivcRecordFliterView : UIView
/**
 此类的代理
 */
@property (nonatomic, weak) id<AliyunEffectFilter2ViewDelegate> delegate;

/**
 选中的滤镜数据模型
 */
@property (nonatomic, strong) AliyunEffectInfo *selectedEffect;
@end
