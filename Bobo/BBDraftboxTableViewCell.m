//
//  BBDraftboxTableViewCell.m
//  Bobo
//
//  Created by Zhouboli on 15/10/12.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBDraftboxTableViewCell.h"
#import "Utils.h"
#import "UIColor+Custom.h"

static CGFloat dSmallGap = 5;
static CGFloat dBigGap = 10;

@interface BBDraftboxTableViewCell ()

@property (strong, nonatomic) UIButton *resendButton; //重新发送按钮
@property (strong, nonatomic) UILabel *type; //草稿类型
@property (strong, nonatomic) UILabel *content; //草稿内容
@property (strong, nonatomic) UILabel *time; //草稿保存时间
@property (strong, nonatomic) UIImageView *preview; //草稿第一张附图预览(如果有)

//转发草稿
@property (strong, nonatomic) UILabel *repostContent; //原微博文本

@end

@implementation BBDraftboxTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews
{
    _type = [[UILabel alloc] initWithFrame:CGRectZero];
    [_type setTextColor:[UIColor customGreen]];
    [_type setFont:[UIFont systemFontOfSize:[Utils fontSizeForComment]]];
    [_type setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_type];
    
    _content = [[UILabel alloc] initWithFrame:CGRectZero];
    [_content setTextColor:[UIColor customGray]];
    [_content setFont:[UIFont systemFontOfSize:[Utils fontSizeForStatus]]];
    [_content setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_content];
    
    _time = [[UILabel alloc] initWithFrame:CGRectZero];
    [_time setTextColor:[UIColor lightTextColor]];
    [_time setFont:[UIFont systemFontOfSize:13.0]];
    [_time setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_time];
    
    _preview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_preview setBackgroundColor:[UIColor clearColor]];
    [_preview setContentMode:UIViewContentModeScaleAspectFit];
    [self.contentView addSubview:_preview];
    
    _resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resendButton setBackgroundColor:[UIColor customGray]];
    [_resendButton setBackgroundImage:[UIImage imageNamed:@"resend_icon"] forState:UIControlStateNormal];
    [_resendButton addTarget:self action:@selector(resendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_resendButton];
}

-(void)resendButtonPressed:(UIButton *)sender
{
    
}

@end
