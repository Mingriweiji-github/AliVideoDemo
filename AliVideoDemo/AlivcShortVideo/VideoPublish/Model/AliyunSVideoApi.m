//
//  AliyunSVideoApi.m
//  qusdk
//
//  Created by Worthy Zhang on 2019/1/2.
//  Copyright © 2019 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunSVideoApi.h"

static NSString * AliyunSVideoApiDomain = @"https://alivc-demo.aliyuncs.com";

@implementation AliyunSVideoApi

+ (void)loginRandomUserWithHandler:(void (^)(NSString *userId, NSString *token, NSError *error))handler {
    [self getWithPath:@"/user/randomUser" params:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, error);
        }else {
            NSString *token = [responseObject objectForKey:@"token"];
            NSString *userId = [responseObject objectForKey:@"userId"];
            handler(userId, token, nil);
        }
    }];
}

+ (void)getVideoUploadAuthWithWithTitle:(NSString *)title
                               filePath:(NSString *)filePath
                               coverURL:(NSString * _Nullable)coverURL
                                   desc:(NSString *_Nullable)desc
                                   tags:(NSString * _Nullable)tags
                                handler:(void (^)(NSString *, NSString *, NSString *, NSError *))handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"title":title,
                                       @"fileName":filePath.lastPathComponent
                                       }];
    if (coverURL) {
        [params addEntriesFromDictionary:@{@"coverURL":coverURL}];
    }
    if (desc) {
        [params addEntriesFromDictionary:@{@"description":desc}];
    }
    if (tags) {
        [params addEntriesFromDictionary:@{@"tags":tags}];
    }
    
    [self getWithPath:@"/demo/getVideoUploadAuth" params:params completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, nil, error);
        }else {
            NSString *uploadAddress = [responseObject objectForKey:@"uploadAddress"];
            NSString *uploadAuth = [responseObject objectForKey:@"uploadAuth"];
            NSString *videoId = [responseObject objectForKey:@"videoId"];
            handler(uploadAddress, uploadAuth, videoId, nil);
        }
    }];
}

+ (void)refreshVideoUploadAuthWithVideoId:(NSString *)videoId handler:(void (^)(NSString *, NSString *, NSError *))handler {
    NSDictionary *params = @{
                             @"videoId":videoId
                             };
    [self getWithPath:@"/demo/refreshVideoUploadAuth" params:params completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, error);
        }else {
            NSString *uploadAddress = [responseObject objectForKey:@"uploadAddress"];
            NSString *uploadAuth = [responseObject objectForKey:@"uploadAuth"];
            handler(uploadAddress, uploadAuth, nil);
        }
    }];
}

+ (void)getImageUploadAuthWithTitle:(NSString * _Nullable)title
                           filePath:(NSString *)filePath
                               tags:(NSString * _Nullable)tags
                            handler:(void (^)(NSString *, NSString *, NSString *, NSString *, NSError *))handler {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params addEntriesFromDictionary:@{
                                       @"imageType":@"cover",
                                       @"imageExt":filePath.lastPathComponent.pathExtension
                                       }];
    if (title) {
        [params addEntriesFromDictionary:@{@"title":title}];
    }
    if (tags) {
        [params addEntriesFromDictionary:@{@"tags":tags}];
    }
    
    [self getWithPath:@"/demo/getImageUploadAuth" params:params completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            handler(nil, nil, nil, nil, error);
        }else {
            NSString *uploadAddress = [responseObject objectForKey:@"uploadAddress"];
            NSString *uploadAuth = [responseObject objectForKey:@"uploadAuth"];
            NSString *imageURL = [responseObject objectForKey:@"imageURL"];
            NSString *imageId = [responseObject objectForKey:@"imageId"];
            handler(uploadAddress, uploadAuth, imageURL, imageId, nil);
        }
    }];
}


#pragma mark - tool

+ (void)getWithPath:(NSString *)path params:(NSDictionary *)params completionHandler:(void (^)(NSURLResponse *response, id responseObject,  NSError * error))completionHandler {
    NSString *paramsString = [self getParamsString:params];
    NSString *urlString = [NSString
                    stringWithFormat:@"%@%@?%@", AliyunSVideoApiDomain, path, paramsString];
    
    NSURLSessionConfiguration *sessionConfiguration =
    [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:sessionConfiguration];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:@"application/json"
      forHTTPHeaderField:@"Content-Type"];
    [urlRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    NSURLSessionDataTask *task =
    [session dataTaskWithRequest:urlRequest
               completionHandler:^(NSData *_Nullable data,
                                   NSURLResponse *_Nullable response,
                                   NSError *_Nullable error) {
                   if (error) {
                       if (completionHandler) {
                           completionHandler(response, nil, error);
                       }
                       return;
                   }
                   
                   if (data == nil) {
                       NSError *emptyError =
                       [[NSError alloc] initWithDomain:@"AliyunSVideoApi"
                                                  code:-10000
                                              userInfo:nil];
                       if (completionHandler) {
                           completionHandler(response, nil, emptyError);
                       }
                       return;
                   }
                   
                   id jsonObj = [NSJSONSerialization
                                 JSONObjectWithData:data
                                 options:NSJSONReadingAllowFragments
                                 error:&error];
                   if (error) {
                       completionHandler(response, nil, error);
                       return;
                   }
                   
                   NSInteger code = [[jsonObj objectForKey:@"code"] integerValue];
                   if (code != 200) {
                       NSError *error = [NSError errorWithDomain:@"AliyunSVideoApi" code:code userInfo:jsonObj];
                       if (completionHandler) {
                           completionHandler(response, nil, error);
                       }
                       return;
                   }
                   
                   if (completionHandler) {
                       completionHandler(response, [jsonObj objectForKey:@"data"], nil);
                   }
                   
               }];
    
    [task resume];
    
    
}


+ (NSString *)getParamsString:(NSDictionary *)params {
    NSMutableArray *parts = [NSMutableArray array];
    for (id key in params.allKeys) {
        id value = [params objectForKey:key];
        NSString *part = [NSString stringWithFormat:@"%@=%@", [self percentEncode:key], [self percentEncode:value]];
        [parts addObject: part];
    }
    
    NSArray<NSString *> *sortedArray = [parts sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSString *string = [sortedArray componentsJoinedByString:@"&"];
    return string;
}

+ (NSString *)percentEncode:(id)object {
    NSString *string = [NSString stringWithFormat:@"%@", object];
    
    NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@?/"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
    
    
    NSString *percentstring = [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
    NSString * plusReplaced = [percentstring stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString * starReplaced = [plusReplaced stringByReplacingOccurrencesOfString:@"*" withString:@"%2A"];
    NSString * waveReplaced = [starReplaced stringByReplacingOccurrencesOfString:@"%7E" withString:@"~"];
    return waveReplaced;
}
@end
