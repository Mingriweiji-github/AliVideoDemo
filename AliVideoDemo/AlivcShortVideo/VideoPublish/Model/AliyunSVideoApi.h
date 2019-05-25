//
//  AliyunSVideoApi.h
//  qusdk
//
//  Created by Worthy Zhang on 2019/1/2.
//  Copyright © 2019 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunSVideoApi : NSObject

+ (void)loginRandomUserWithHandler:(void (^)(NSString *userId, NSString *token, NSError *error))handler;



+ (void)getVideoUploadAuthWithWithTitle:(NSString *)title
                               filePath:(NSString *)filePath
                               coverURL:(NSString * _Nullable)coverURL
                                   desc:(NSString *_Nullable)desc
                                   tags:(NSString * _Nullable)tags
                                handler:(void (^)(NSString *uploadAddress, NSString *uploadAuth, NSString *videoId, NSError *error))handler;

+ (void)refreshVideoUploadAuthWithVideoId:(NSString *)videoId
                                  handler:(void (^)(NSString *uploadAddress, NSString *uploadAuth, NSError *error))handler;

+ (void)getImageUploadAuthWithTitle:(NSString * _Nullable)title
                           filePath:(NSString *)filePath
                               tags:(NSString * _Nullable)tags
                            handler:(void (^)(NSString *uploadAddress, NSString *uploadAuth, NSString *imageURL, NSString *imageId, NSError *error))handler;

@end

NS_ASSUME_NONNULL_END
