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

#define bCellBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

static CGFloat dSmallGap = 5;
static CGFloat dBigGap = 10;
static CGFloat previewLength = 40;
static CGFloat smallHeight = 15;
static CGFloat bigHeight = 20;

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
    [self.contentView setBackgroundColor:bCellBGColor];
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    _type = [[UILabel alloc] initWithFrame:CGRectZero];
    [_type setTextColor:[UIColor customGreen]];
    [_type setFont:[UIFont systemFontOfSize:[Utils fontSizeForComment]]];
    [_type setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_type];
    
    _content = [[UILabel alloc] initWithFrame:CGRectZero];
    [_content setTextColor:[UIColor customGray]];
    [_content setFont:[UIFont systemFontOfSize:[Utils fontSizeForStatus]]];
    [_content setBackgroundColor:[UIColor clearColor]];
    [_content setNumberOfLines:1];
    [self.contentView addSubview:_content];
    
    _repostContent = [[UILabel alloc] initWithFrame:CGRectZero];
    [_repostContent setTextColor:[UIColor lightTextColor]];
    [_repostContent setFont:[UIFont systemFontOfSize:[Utils fontSizeForStatus]]];
    [_repostContent setBackgroundColor:[UIColor clearColor]];
    [_repostContent setNumberOfLines:1];
    [self.contentView addSubview:_repostContent];
    
    _time = [[UILabel alloc] initWithFrame:CGRectZero];
    [_time setTextColor:[UIColor lightTextColor]];
    [_time setFont:[UIFont systemFontOfSize:13.0]];
    [_time setBackgroundColor:[UIColor clearColor]];
    [self.contentView addSubview:_time];
    
    _preview = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_preview setBackgroundColor:[UIColor clearColor]];
    [_preview setContentMode:UIViewContentModeScaleAspectFill];
    [_preview setClipsToBounds:YES];
    [self.contentView addSubview:_preview];
    
    _resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resendButton setBackgroundColor:[UIColor clearColor]];
    [_resendButton setImage:[UIImage imageNamed:@"resend_icon"] forState:UIControlStateNormal];
    [_resendButton addTarget:self action:@selector(resendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_resendButton];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self loadData];
    [self loadSubviews];
}

-(void)loadData
{
    NSInteger type = _draft.draftType;
    NSDictionary *params = _draft.params;
    NSData *imageData = _draft.images.firstObject;
    
    switch (type) {
        case DraftTypeOriginal:
            [_type setText:@"微博草稿"];
            break;
        case DraftTypeComment:
            [_type setText:@"评论草稿"];
            break;
        case DraftTypeRepost:
            [_type setText:@"转发草稿"];
            break;
        case DraftTypeReply:
            [_type setText:@"回复草稿"];
            break;
        default:
            break;
    }
    
    if (type != DraftTypeOriginal) {
        [_repostContent setText:params[@"original"]];
    }
    [_content setText:_draft.text];
    [_time setText:_draft.time];
    [_preview setImage:[UIImage imageWithData:imageData]];
}

-(void)loadSubviews
{
    NSInteger type = _draft.draftType;
    CGSize typeSize = [_type sizeThatFits:CGSizeMake(MAXFLOAT, smallHeight)];
    CGFloat btnLength = 30;
    CGFloat contentWidth = 0;
    CGFloat contentViewWidth = self.contentView.frame.size.width;
    
    if (type == DraftTypeOriginal) //微博草稿
    {
        if (_draft.images.count > 0) //有图模式
        {
            contentWidth = contentViewWidth-dBigGap*2-previewLength-dBigGap*2-btnLength;
            [_type setFrame:CGRectMake(dBigGap, dBigGap, typeSize.width, smallHeight)];
            [_preview setFrame:CGRectMake(dBigGap, dBigGap+smallHeight+dSmallGap, previewLength, previewLength)];
            [_content setFrame:CGRectMake(dBigGap+previewLength+dBigGap, dBigGap+smallHeight+dSmallGap, contentWidth, bigHeight)];
            [_time setFrame:CGRectMake(dBigGap+previewLength+dBigGap, dBigGap+smallHeight+dSmallGap+bigHeight+dSmallGap, contentWidth, smallHeight)];
        }
        else //无图模式
        {
            contentWidth = contentViewWidth-dBigGap*2-btnLength-dBigGap;
            [_type setFrame:CGRectMake(dBigGap, dBigGap, typeSize.width, smallHeight)];
            [_content setFrame:CGRectMake(dBigGap, dBigGap+smallHeight+dSmallGap, contentWidth, bigHeight)];
            [_time setFrame:CGRectMake(dBigGap, dBigGap+smallHeight+dSmallGap+bigHeight+dSmallGap, contentWidth, smallHeight)];
        }
    }
    else
    {
        contentWidth = contentViewWidth-dBigGap*2-btnLength-dBigGap;
        [_type setFrame:CGRectMake(dBigGap, dBigGap, typeSize.width, smallHeight)];
        [_content setFrame:CGRectMake(dBigGap, dBigGap+smallHeight+dSmallGap, contentWidth, bigHeight)];
        [_repostContent setFrame:CGRectMake(dBigGap, dBigGap+smallHeight+dSmallGap+bigHeight+dSmallGap, contentWidth, bigHeight)];
        [_time setFrame:CGRectMake(dBigGap, dBigGap+smallHeight+dSmallGap+bigHeight+dSmallGap+bigHeight+dSmallGap, contentWidth, smallHeight)];
    }
    [_resendButton setFrame:CGRectMake(contentViewWidth-dBigGap-btnLength, (self.contentView.frame.size.height-btnLength)/2, btnLength, btnLength)];
}

-(void)resendButtonPressed:(UIButton *)sender
{
    [self.delegate tableViewCell:self didPressResendButton:sender];
}

@end
