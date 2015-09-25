//
//  BBImageBrowserView.m
//  Bobo
//
//  Created by Zhouboli on 15/6/25.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBImageBrowserView.h"
#import <UIImageView+WebCache.h>

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBImageBrowserView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSInteger count;

@end

@implementation BBImageBrowserView

-(instancetype)initWithFrame:(CGRect)frame withImageUrls:(NSMutableArray *)urls andImageTag:(NSInteger)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.0;
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.alpha = 1.0;
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        } completion:^(BOOL finished) {
            
        }];
        _count = [urls count]+2;
        [self setScrollViewWithImageUrls:urls andTag:tag];
        [self loadPageControl];
    }
    return self;
}

-(void)setScrollViewWithImageUrls:(NSMutableArray *)urls andTag:(NSInteger)tag
{
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(bWidth*_count, bHeight);
    _scrollView.contentOffset = CGPointMake(bWidth*(tag+1), 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.userInteractionEnabled = YES;
    _scrollView.minimumZoomScale = 0.5;
    _scrollView.maximumZoomScale = 2.0;
    _scrollView.alwaysBounceVertical = NO;
    _scrollView.alwaysBounceHorizontal = YES;
    [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    [self addSubview:_scrollView];
    [self layoutImageOnScrollViewFromUrl:[urls lastObject] withImageOriginX:0]; //第一个UIImageView放最后一张图
    for (int i = 1; i < [urls count]+1; i ++) {
        [self layoutImageOnScrollViewFromUrl:urls[i-1] withImageOriginX:bWidth*i]; //第二个UIImageView开始顺序放图
    }
    [self layoutImageOnScrollViewFromUrl:[urls firstObject] withImageOriginX:bWidth*(urls.count+1)]; //最后一个UIImageView放第一张图
}

-(void)layoutImageOnScrollViewFromUrl:(NSString *)url withImageOriginX:(CGFloat)originX
{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 0, bWidth, bHeight)];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_imageView];
    
    [_imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"pic_placeholder@3x"] options:SDWebImageCacheMemoryOnly completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            [self setSizeForImage:image withImageView:_imageView andOriginX:originX];
        } else {
            //下载图片失败后动作
        }
    }];
}

-(void)setSizeForImage:(UIImage *)image withImageView:(UIImageView *)imageView andOriginX:(CGFloat)originX
{
    CGFloat imageHeight = image.size.height*bWidth/image.size.width;
    if (imageHeight > bHeight) {
        [imageView setFrame:CGRectMake(0, 0, bWidth, imageHeight)];
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(originX, 0, bWidth, bHeight)];
        [scrollView setContentOffset:CGPointMake(originX, 0)];
        [scrollView setContentSize:CGSizeMake(bWidth, imageHeight)];
        [_imageView removeFromSuperview];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [scrollView addSubview:imageView];
        [_scrollView addSubview:scrollView];
    } else {
        [imageView setFrame:CGRectMake(originX, 0, bWidth, bHeight)];
    }
    [imageView setImage:image];
}

-(void)loadPageControl
{
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.bounds = CGRectMake(0, 0, bWidth/2, 20);
    _pageControl.center = CGPointMake(bWidth/2, bHeight-30);
    _pageControl.numberOfPages = _count-2;
    _pageControl.userInteractionEnabled = NO;
    _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor lightTextColor];
    _pageControl.currentPage = _scrollView.contentOffset.x/bWidth-1;
    [self addSubview:_pageControl];
}

-(void)tapAction
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [_imageView sd_cancelCurrentImageLoad];
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x == 0) {
        [_scrollView setContentOffset:CGPointMake(bWidth*(_count-2), 0) animated:NO];
        _pageControl.currentPage = _count-2;
    } else if (scrollView.contentOffset.x == bWidth*(_count-1)) {
        _pageControl.currentPage = 0;
        [_scrollView setContentOffset:CGPointMake(bWidth, 0) animated:NO];
    } else {
        _pageControl.currentPage = scrollView.contentOffset.x/bWidth-1;
    }
}

@end
