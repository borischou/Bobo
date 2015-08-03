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
@property (strong, nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSInteger count;

@end

@implementation BBImageBrowserView

-(instancetype)initWithFrame:(CGRect)frame withImageUrls:(NSMutableArray *)urls andImageTag:(NSInteger)tag
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.count = [urls count];
        [self setScrollViewWithImageUrls:urls andTag:tag];
        [self loadPageControl];
    }
    return self;
}

-(void)setScrollViewWithImageUrls:(NSMutableArray *)urls andTag:(NSInteger)tag
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
    self.scrollView.contentSize = CGSizeMake(bWidth * [urls count], bHeight);
    self.scrollView.contentOffset = CGPointMake(bWidth * tag, 0);
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.bounces = YES;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
    [self.scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)]];
    [self addSubview:self.scrollView];
    for (int i = 0; i < [urls count]; i ++) {
        [self layoutImageOnScrollViewFromUrl:urls[i] withImageOriginX:bWidth * i];
    }
}

-(void)layoutImageOnScrollViewFromUrl:(NSString *)url withImageOriginX:(CGFloat)originX
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 0, bWidth, bHeight)];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:imageView];
    [imageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"timeline_image_loading@2x"] options:SDWebImageRetryFailed completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!error) {
            [self setSizeForImage:image withImageView:imageView andOriginX:originX];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}

-(void)setSizeForImage:(UIImage *)image withImageView:(UIImageView *)imageView andOriginX:(CGFloat)originX
{
    CGFloat imageHeight = image.size.height * bWidth / image.size.width;
    if (imageHeight > bHeight) {
        imageView.frame = CGRectMake(originX, 0, bWidth, imageHeight);
        self.scrollView.pagingEnabled = NO;
        self.scrollView.alwaysBounceHorizontal = NO;
        self.scrollView.alwaysBounceVertical = YES;
        self.scrollView.contentSize = CGSizeMake(bWidth * self.count, imageHeight);
    } else {
        imageView.frame = CGRectMake(originX, 0, bWidth, bHeight);
    }
    imageView.image = image;
}

-(void)loadPageControl
{
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.bounds = CGRectMake(0, 0, bWidth/2, 20);
    _pageControl.center = CGPointMake(bWidth/2, bHeight-30);
    _pageControl.numberOfPages = _count;
    _pageControl.pageIndicatorTintColor = [UIColor darkGrayColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [self addSubview:_pageControl];
}

-(void)tapAction
{
    [self removeFromSuperview];
}

#pragma mark - UIScrollViewDelegate

@end
