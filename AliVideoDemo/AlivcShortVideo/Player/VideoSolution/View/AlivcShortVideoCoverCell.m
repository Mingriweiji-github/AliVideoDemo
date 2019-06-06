#import "AlivcShortVideoCoverCell.h"
#import "UIImageView+WebCache.h"

#define iconWH 40

@interface AlivcShortVideoCoverCell ()

/**
 视频类型图
 */
@property (nonatomic, strong) UIImage *type_image;


/**
 展示视频类型UIImageView
 */
@property (nonatomic, strong) UIImageView *typeImageView;

/**
 用户头像
 */
@property (nonatomic, strong) UIImageView *avatarImageView;

/**
 昵称
 */
@property (nonatomic, strong) UILabel *nickNameLabel;

/**
 描述label
 */
@property (nonatomic, strong) UILabel *desLabel;

@end

@implementation AlivcShortVideoCoverCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUI];
    
}



- (void)initUI {
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageW = ScreenWidth;
    CGFloat imageH = ScreenHeight - KquTabBarHeight;
    
    
    self.imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView addSubview:self.typeImageView];
    [self.imageView addSubview:self.avatarImageView];
    [self.imageView addSubview:self.desLabel];
    [self.imageView addSubview:self.nickNameLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.typeImageView.center = CGPointMake(ScreenWidth - iconWH/2 - 8, iconWH/2 + 8 + SafeTop);
}

#pragma mark - public method

- (void)addPlayer:(AliListPlayer *)player {
    UIView *playView = player.playerView;
    playView.frame = self.imageView.bounds;
    [self.imageView addSubview:playView];
    [self.imageView sendSubviewToBack:playView];
}


#pragma mark - setter & getter

- (void)setModel:(AlivcQuVideoModel *)model {
    _model = model;
    if (model) {
        //设置图片
         __weak typeof(self) weakSelf = self;
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:model.firstFrameUrl] placeholderImage:[UIImage imageNamed:@""] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            model.coverImage = image;
            if(image.size.width < image.size.height&&IPHONEX) {
                weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFill;
            }else {
                weakSelf.imageView.contentMode = UIViewContentModeScaleAspectFit;
            }
        }];
       

        CGFloat beside = 12;
        CGFloat cyFirst = ScreenHeight - 120 - SafeAreaBottom;
        self.avatarImageView.center = CGPointMake(beside + self.avatarImageView.frame.size.width / 2 ,cyFirst);
        //头像
        if (model.belongUserAvatarImage) {
            self.avatarImageView.hidden = NO;
            self.avatarImageView.image = model.belongUserAvatarImage;
        }else if (model.belongUserAvatarUrl){
            [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:model.belongUserAvatarUrl]];
        }else{
            self.avatarImageView.hidden = YES;
        }
        //昵称
        if (model.belongUserName) {
            self.nickNameLabel.hidden = NO;
            self.nickNameLabel.text = model.belongUserName;
            [self.nickNameLabel sizeToFit];
            self.nickNameLabel.center = CGPointMake(CGRectGetMaxX(self.avatarImageView.frame) + beside + self.nickNameLabel.frame.size.width / 2, self.avatarImageView.center.y);
        }else{
            self.nickNameLabel.hidden = YES;
        }
        
        //描述
        if (model.videoDescription) {
            self.desLabel.hidden = NO;
            self.desLabel.text = model.videoDescription;
            [self.desLabel sizeToFit];
            self.desLabel.center = CGPointMake(beside + self.desLabel.frame.size.width / 2, CGRectGetMaxY(self.avatarImageView.frame) + beside + self.desLabel.frame.size.height / 2);
        }else{
            self.desLabel.hidden = YES;
        }
        
        self.typeImageView.image= [AlivcImage imageNamed:@"alivc_shortVideo_zaiIcon"];
    }
}

- (UIImageView *)avatarImageView{
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc]init];
        _avatarImageView.frame = CGRectMake(0, 0, 36, 36);
        _avatarImageView.layer.cornerRadius = 4;
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.contentMode = UIViewContentModeScaleToFill;
    }
    return _avatarImageView;
}

- (UILabel *)nickNameLabel{
    if (!_nickNameLabel) {
        _nickNameLabel = [[UILabel alloc]init];
        _nickNameLabel.textColor = [UIColor whiteColor];
        _nickNameLabel.frame = CGRectMake(0, 0, 100, 30);
    }
    return _nickNameLabel;
}

- (UILabel *)desLabel{
    if (!_desLabel) {
        _desLabel = [[UILabel alloc]init];
        _desLabel.textColor = [UIColor whiteColor];
        _desLabel.frame = CGRectMake(0, 0, 150, 30);
        _desLabel.font = [UIFont systemFontOfSize:12];
    }
    return _desLabel;
}

- (UIImageView *)typeImageView {
    if (!_typeImageView) {
        _typeImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, iconWH, iconWH)];
        _typeImageView.backgroundColor = [UIColor clearColor];
        _typeImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _typeImageView;
}

@end
