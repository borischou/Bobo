//
//  BBAlbumCollectionViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/10/9.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import <Accounts/Accounts.h>
#import <MJRefresh.h>

#import "BBAlbumCollectionViewController.h"
#import "BBPhotoSelectionCollectionViewCell.h"
#import "AppDelegate.h"
#import "Utils.h"
#import "NSString+Convert.h"
#import "BBImageBrowserView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

typedef NS_ENUM(NSInteger, fetchResultType) {
    fetchResultTypeRefresh,
    fetchResultTypeHistory
};

@interface BBAlbumCollectionViewController ()

@property (strong, nonatomic) NSMutableArray *urls;
@property (strong, nonatomic) ACAccount *weiboAccount;
@property (copy, nonatomic) NSString *currentLastStatusId;

@end

@implementation BBAlbumCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    self.clearsSelectionOnViewWillAppear = YES;
    
    // Register cell classes
    [self.collectionView registerClass:[BBPhotoSelectionCollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    _weiboAccount = [[AppDelegate delegate] defaultAccount];
    _currentLastStatusId = @"";
    [self setMJRefresh];
    [self.collectionView.header beginRefreshing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.delegate collectionViewControllerDidPushBack:self];
}

#pragma mark - Weibo support & helpers

-(void)setMJRefresh
{
    self.collectionView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self refreshPhoto];
    }];
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(historyPhoto)];
    [footer setTitle:@"上拉以获取更多" forState:MJRefreshStateIdle];
    [footer setTitle:@"正在获取" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"暂无更多数据" forState:MJRefreshStateNoMoreData];
    self.collectionView.footer = footer;
}

-(void)refreshPhoto
{
    NSString *requestUrl = @"statuses/user_timeline.json";
    NSDictionary *param = @{@"uid": _user.idstr};
    
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:requestUrl SLRequestHTTPMethod:SLRequestMethodGET parameters:param completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error = nil;
        [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:fetchResultTypeRefresh];
    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"main error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"更新失败"];
            [self.collectionView.header endRefreshing];
        });
    }];
}

-(void)historyPhoto
{
    [Utils genericWeiboRequestWithAccount:_weiboAccount URL:@"statuses/user_timeline.json" SLRequestHTTPMethod:SLRequestMethodGET parameters:@{@"uid": _user.idstr, @"count": @"20", @"max_id": _currentLastStatusId} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSError *error = nil;
         [self handleWeiboResult:[NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error] fetchResultType:fetchResultTypeHistory];
     }
               completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"profile footer error: %@", [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding]);
         dispatch_async(dispatch_get_main_queue(), ^{
             [Utils presentNotificationWithText:@"更新失败"];
             [self.collectionView.footer endRefreshing];
         });
     }];
}

-(void)handleWeiboResult:(id)result fetchResultType:(NSInteger)type
{
    NSMutableArray *downloadedStatuses = [result objectForKey:@"statuses"];
    if (!_urls)
    {
        _urls = @[].mutableCopy;
    }
    if (type == fetchResultTypeRefresh)
    {
        [_urls removeAllObjects];
        [self.collectionView reloadData];
    }
    if (downloadedStatuses.count > 0)
    {
        
        for (int i = 0; i < downloadedStatuses.count; i ++)
        {
            Status *status = [[Status alloc] initWithDictionary:downloadedStatuses[i]];
            if (status.pic_urls.count > 0) {
                for (NSString *url in status.pic_urls) {
                    [_urls addObject:[NSString middlePictureUrlConvertedFromThumbUrl:url]];
                }
            }
            if (i == downloadedStatuses.count-1) {
                _currentLastStatusId = status.idstr;
            }
        }
    }
    
    [self.collectionView.header endRefreshing];
    [self.collectionView.footer endRefreshing];
    [self.collectionView reloadData];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _urls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BBPhotoSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:_urls[indexPath.item]] placeholderImage:[UIImage imageNamed:@"pic_placeholder"] options:SDWebImageLowPriority];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //全屏查看照片
    BBImageBrowserView *imageBrowser = [[BBImageBrowserView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) imageUrls:_urls imageTag:indexPath.item];
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:imageBrowser];
}

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
