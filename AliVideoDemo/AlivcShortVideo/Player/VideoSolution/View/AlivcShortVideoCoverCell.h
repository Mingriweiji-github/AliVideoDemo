//
//  AlivcShortVideoCoverCell.h
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/4/3.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AliyunPlayer/AliyunPlayer.h>
#import "AlivcQuVideoModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface AlivcShortVideoCoverCell : UICollectionViewCell

@property (nonatomic, strong) AlivcQuVideoModel *model;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (void)addPlayer:(AliListPlayer *)player;




@end

NS_ASSUME_NONNULL_END
