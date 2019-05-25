//
//  AlivcEffectAudioEffectCell.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/3/4.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcEffectAudioEffectCell.h"
#import "UIColor+AlivcHelper.h"

@interface AlivcEffectAudioEffectCell()

@property(nonatomic, strong)UIButton *selectedBtn;

@end

@implementation AlivcEffectAudioEffectCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.layer.cornerRadius = CGRectGetHeight(frame)/2;
        self.layer.masksToBounds =YES;
    }
    return self;
}

-(void)setupSubviews{
    _selectedBtn =[[UIButton alloc]initWithFrame:self.bounds];
    [_selectedBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_affirm"] forState:UIControlStateNormal];
    _selectedBtn.backgroundColor =[UIColor colorWithHexString:@"#00C1DE"];
    [self.contentView addSubview:_selectedBtn];
    
//    _titleLab =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
//    _titleLab.font =[UIFont systemFontOfSize:14];
//    _titleLab.textAlignment =NSTextAlignmentCenter;
//    _titleLab.textColor =[UIColor blackColor];
//    _titleLab.backgroundColor =[UIColor whiteColor];
    [self.contentView addSubview:_titleLab];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        _titleLab.backgroundColor=[UIColor grayColor];
    }else{
        _titleLab.backgroundColor =[UIColor whiteColor];
    }
}

@end
