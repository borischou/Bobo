//
//  BBMeHeaderView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/6.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "BBMeHeaderView.h"
#import "UIColor+Custom.h"
#import "Utils.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define bMaleColor [UIColor colorWithRed:0.0/255 green:154.0/255 blue:205.0/255 alpha:1.0] //light blue
#define bFemaleColor [UIColor colorWithRed:255.0/255 green:52.0/255 blue:181.0/255 alpha:1.0] //pink

@interface BBMeHeaderView () <UIScrollViewDelegate> {
    int _count;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;

@end

@implementation BBMeHeaderView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _count = 2;
        [self setupScrollViewWithFrame:frame];
        [self loadPageControlWithFrame:frame];
        [self setHeaderLayoutWithFrame:frame];
    }
    return self;
}

-(void)setupScrollViewWithFrame:(CGRect)frame
{
    _scrollView = [[UIScrollView alloc] initWithFrame:frame];
    [_scrollView setPagingEnabled:YES];
    [_scrollView setContentSize:CGSizeMake(bWidth*_count, frame.size.height)];
    [_scrollView setDelegate:self];
    [_scrollView setShowsHorizontalScrollIndicator:NO];
    [_scrollView setAlwaysBounceHorizontal:YES];
    [_scrollView setAlwaysBounceVertical:NO];
    [self addSubview:_scrollView];
}

-(void)setHeaderLayoutWithFrame:(CGRect)frame
{
    _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width/2-bWidth/10, 15, bWidth/5, bWidth/5)];
    _avatarView.layer.masksToBounds = YES;
    _avatarView.layer.cornerRadius = _avatarView.bounds.size.width*0.5;
    _avatarView.layer.borderWidth = 0.1;
    _avatarView.layer.borderColor = [UIColor blackColor].CGColor;
    [_scrollView addSubview:_avatarView];
    
    _name = [[UILabel alloc] initWithFrame:CGRectMake(0, 15+bWidth/5+10, bWidth, 30)];
    _name.textAlignment = NSTextAlignmentCenter;
    [_scrollView addSubview:_name];
    
    _vipView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [_scrollView addSubview:_vipView];
    
    _introduction = [[UILabel alloc] initWithFrame:CGRectMake(10, 15+bWidth/5+10+30+10, bWidth-20, 30)];
    [_introduction setTextAlignment:NSTextAlignmentCenter];
    [_scrollView addSubview:_introduction];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [_avatarView sd_setImageWithURL:[NSURL URLWithString:_user.avatar_large] placeholderImage:[UIImage imageNamed:@"bb_holder_profile_image"]];
    if ([_user.gender isEqualToString:@"m"])
    {
        _name.attributedText = [[NSAttributedString alloc] initWithString:_user.screen_name attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20.0], NSForegroundColorAttributeName: bMaleColor}];
    }
    else if ([_user.gender isEqualToString:@"f"])
    {
        _name.attributedText = [[NSAttributedString alloc] initWithString:_user.screen_name attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20.0], NSForegroundColorAttributeName: bFemaleColor}];
    }
    else
    {
        _name.attributedText = [[NSAttributedString alloc] initWithString:_user.screen_name attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:20.0], NSForegroundColorAttributeName: [UIColor customGray]}];
    }
    CGSize nameSize = [_name sizeThatFits:CGSizeMake(MAXFLOAT, 30)];
    if (_user.verified) {
        [_vipView setFrame:CGRectMake(self.center.x+nameSize.width*.5, 15+bWidth/5+10, 15, 15)];
        _vipView.image = [UIImage imageNamed:@"icon_vip"];
        _introduction.attributedText = [[NSAttributedString alloc] initWithString:_user.verified_reason attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[Utils fontSizeForStatus]], NSForegroundColorAttributeName: [UIColor customGray]}];
    } else {
        _vipView.image = nil;
        [_vipView setFrame:CGRectZero];
        _introduction.attributedText = [[NSAttributedString alloc] initWithString:_user.user_description attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[Utils fontSizeForStatus]], NSForegroundColorAttributeName: [UIColor customGray]}];
    }
}

-(void)loadPageControlWithFrame:(CGRect)frame
{
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.bounds = CGRectMake(0, 0, bWidth/2, 20);
    _pageControl.center = CGPointMake(bWidth/2, frame.size.height-10);
    _pageControl.numberOfPages = _count;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor lightTextColor];
    _pageControl.currentPage = 0;
    [self addSubview:_pageControl];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [_pageControl setCurrentPage:scrollView.contentOffset.x/bWidth];
    NSLog(@"current page: %f", scrollView.contentOffset.x/bWidth);
}

@end
