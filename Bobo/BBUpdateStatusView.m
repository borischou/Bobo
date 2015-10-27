//
//  BBUpdateStatusView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "Utils.h"
#import "BBUpdateStatusView.h"
#import "UIButton+Bobtn.h"
#import "BBKeyboardInputAccessoryView.h"
#import "AppDelegate.h"
#import "BBPhotoSelectionCollectionViewController.h"
#import "BBPhotoSelectionCollectionViewCell.h"
#import "BBStatusDetailViewController.h"
#import "BBNotificationView.h"
#import "UIColor+Custom.h"

#define uSmallGap 5
#define uBigGap 10
#define uBtnHeight 20
#define uBtnWidth 55
#define uImgHeight 60
#define uImgWidth uImgHeight

#define itemLength 45

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define bBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

static CGFloat compressionQuality = 0.7;
static NSString *reuseCell = @"photocell";

static NSString *filename = @"draft";
static NSString *filepath = @"draft.plist";

@interface BBUpdateStatusView () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BBPhotoSelectionCollectionViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    NSInteger _flag; //0-发微博; 1-写评论; 2-转发; 3-回复评论
    BOOL _statusChanged; //是否需要保存为新草稿
}

@property (strong, nonatomic) BBKeyboardInputAccessoryView *keyboardInputView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *mask;
@property (strong, nonatomic) UIImagePickerController *picker;

@end

@implementation BBUpdateStatusView

-(instancetype)initWithFlag:(NSInteger)flag
{
    self = [super init];
    if (self)
    {
        _flag = flag;
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        [self setupViewLayout];
    }
    return self;
}

-(void)setupViewLayout
{
    self.backgroundColor = bBGColor;
    self.alpha = 1.0;
    self.layer.cornerRadius = 8.0;
    self.layer.borderWidth = 0.2;
    self.layer.borderColor = [UIColor blackColor].CGColor;
    
    if (!_mask)
    {
        _mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0;
        [_mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressed:)]];
        
        AppDelegate *delegate = [AppDelegate delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _mask.alpha = 0.5;
        } completion:^(BOOL finished) {}];
    }
    
    //取消按钮
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"取消" withBackgroundColor:nil andTintColor:nil];
    [_cancelBtn setBackgroundColor:[UIColor firebrick]];
    [_cancelBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    
    //发送按钮
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"发送" withBackgroundColor:nil andTintColor:nil];
    [_sendBtn setBackgroundColor:[UIColor dodgerBlue]];
    [_sendBtn setTitleColor:[UIColor mintCream] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_sendBtn addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.enabled = NO;
    [self addSubview:_sendBtn];
    
    //标题
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _nameLabel.textColor = [UIColor lightTextColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
    
    //字数
    _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [_countLabel setTextColor:[UIColor lightTextColor]];
    [_countLabel setTextAlignment:NSTextAlignmentRight];
    [_countLabel setFont:[UIFont systemFontOfSize:14.0]];
    [self addSubview:_countLabel];
    
    //文本输入框
    _statusTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _statusTextView.textColor = [UIColor lightTextColor];
    _statusTextView.backgroundColor = bBGColor;
    _statusTextView.delegate = self;
    _statusTextView.typingAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:[Utils fontSizeForStatus]],
                                         NSForegroundColorAttributeName: [UIColor customGray]};
    [self addSubview:_statusTextView];
    
    //照片墙
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    [layout setMinimumInteritemSpacing:1.0];
    [layout setMinimumLineSpacing:1.0];
    [layout setItemSize:CGSizeMake(itemLength, itemLength)];
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
    
    [_cancelBtn setFrame:CGRectMake(uBigGap, uBigGap, uBtnWidth, uBtnHeight)];
    
    [_sendBtn setFrame:CGRectMake(self.frame.size.width-uBigGap-uBtnWidth, uBigGap, uBtnWidth, uBtnHeight)];
    
    [_nameLabel setFrame:CGRectMake(0, 0, self.frame.size.width/2, uBtnHeight)];
    [_nameLabel setCenter:CGPointMake(self.frame.size.width/2, uSmallGap+uBtnHeight/2)];
    
    [_countLabel setFrame:CGRectMake(self.frame.size.width-uBigGap-(self.frame.size.width-2*uBigGap)/2 , self.frame.size.height-uBigGap-uBtnHeight, (self.frame.size.width-2*uBigGap)/2, uBtnHeight)];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    if (_flag == 0)
    { //发微博
        _keyboardInputView = [[BBKeyboardInputAccessoryView alloc] init];
        _statusTextView.inputAccessoryView = _keyboardInputView;
        [_keyboardInputView.addPictureBtn addTarget:self action:@selector(addPictureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardInputView.callCameraBtn addTarget:self action:@selector(callCameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else //评论转发无法使用图片上传功能
    {
        _statusTextView.inputAccessoryView = nil;
        _todoLabel = [[UILabel alloc] initWithFrame:CGRectMake(uBigGap, self.frame.size.height-uBigGap-uBtnHeight, (self.frame.size.width-2*uBigGap)/2, uBtnHeight)];
        _todoLabel.textColor = [UIColor lightTextColor];
        _todoLabel.font = [UIFont systemFontOfSize:14.0];
        _todoLabel.userInteractionEnabled = YES;
        [_todoLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(todoLabelTapped)]];
        [self addSubview:_todoLabel];
        if (_flag == 1 || _flag == 3)
        { // 写评论(1)或回复评论(3)
            _todoLabel.text = @"同时发微博";
        }
        if (_flag == 2)
        { //转发(2)
            _todoLabel.text = @"评论给作者";
        }
    }
}

-(void)layoutSubviews
{
    [self loadData];
    [self loadSubviews];
}

-(void)loadData
{
    if (_draft)
    {
        NSDictionary *params = _draft.params;
        [_statusTextView setText:_draft.text];
        switch (_draft.draftType)
        {
            case DraftTypeOriginal:
                [_nameLabel setText:@"微博草稿"];
                [_todoLabel setHidden:YES];
                if (_draft.images.count > 0) {
                    _pickedOnes = _draft.images.copy;
                }
                break;
            case DraftTypeComment:
                [_nameLabel setText:@"评论草稿"];
                [_todoLabel setHidden:NO];
                [_todoLabel setTextColor:[params[@"comment_ori"] boolValue]? [UIColor greenColor]: [UIColor lightTextColor]];
                break;
            case DraftTypeRepost:
                [_nameLabel setText:@"转发草稿"];
                [_todoLabel setHidden:NO];
                [_todoLabel setTextColor:[params[@"is_comment"] boolValue]? [UIColor greenColor]: [UIColor lightTextColor]];
                break;
            case DraftTypeReply:
                [_nameLabel setText:@"回复草稿"];
                [_todoLabel setHidden:NO];
                [_todoLabel setTextColor:[params[@"comment_ori"] boolValue]? [UIColor greenColor]: [UIColor lightTextColor]];
                break;
            default:
                break;
        }
    }
}

-(void)loadSubviews
{
    //铺文本输入框
    if (_flag == 0)
    { //发微博时不考虑下方标签
        NSInteger num = _pickedOnes.count;
        if (num == 0)
        {
            [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
            [_collectionView setFrame:CGRectZero];
        }
        if (num == 1)
        { //单图
            [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
            [_collectionView setFrame:CGRectZero];
            [_imageView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight+self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight+uSmallGap, uImgWidth, uImgHeight)];
            NSData *imageData = _pickedOnes.firstObject;
            UIImage *image = [UIImage imageWithData:imageData];
            [_imageView setImage:image];
        }
        if (num > 1)
        { //多图
            CGFloat collectionViewHeight;
            if (num <= 3)
            {
                collectionViewHeight = itemLength;
            }
            else if (num > 3 && num <= 6)
            {
                collectionViewHeight = itemLength*2+1;
            }
            else
            {
                collectionViewHeight = itemLength*3+2;
            }
            CGFloat collectionViewWidth = itemLength*3+2;
            CGFloat textViewHeight = self.frame.size.height-uBigGap*2-uBtnHeight-uSmallGap-uBigGap-collectionViewHeight;
            [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, textViewHeight)];
            [_imageView setFrame:CGRectZero];
            //在文本框外面铺照片墙
            [_collectionView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight+textViewHeight+uSmallGap, collectionViewWidth, collectionViewHeight)];
        }
    }
    else
    {
        [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
        [_collectionView setFrame:CGRectZero];
    }
    
    if (!_mask)
    {
        _mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.0;
        [_mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonPressed:)]];
        
        AppDelegate *delegate = [AppDelegate delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _mask.alpha = 0.5;
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - UIButtons & Gestures

-(void)todoLabelTapped
{
    if ([_todoLabel.textColor isEqual:[UIColor lightTextColor]])
    {
        [_todoLabel setTextColor:[UIColor greenColor]];
    }
    else
    {
        [_todoLabel setTextColor:[UIColor lightTextColor]];
    }
}

-(void)cancelButtonPressed:(UIButton *)sender
{
    if (_statusChanged)
    {
        [self alertForDraft];
    }
    else
    {
        [self removeViewAnimation];
    }
}

-(void)resignTextViewAndMask:(BOOL)flag
{
    if (flag)
    {
        [_statusTextView resignFirstResponder];
        [_mask setFrame:CGRectZero];
    }
    else
    {
        [_mask setFrame:CGRectMake(0, 0, bWidth, bHeight)];
        [_statusTextView becomeFirstResponder];
    }
}

-(void)callbackForUpdateCompletionWithNotificationText:(NSString *)text
{
    [self refreshComments];
    if (_pickedOnes.count > 0)
    {
        [_pickedOnes removeAllObjects];
    }
    [Utils presentNotificationWithText:text];
}

-(void)refreshComments
{
    //Post成功后刷新评论区以显示发表的评论
}

-(void)assembleComment:(Comment *)comment user:(User *)user text:(NSString *)text
{
    comment.user = user;
    comment.created_at = [self stringFromDate:[NSDate date]];
    comment.text = text;
    [comment calculateHeights];
}

-(void)sendButtonPressed:(UIButton *)sender
{
    ACAccount *weiboAccount = [[AppDelegate delegate] defaultAccount];
    NSDictionary *params = nil;
    NSDictionary *draftParams = _draft.params;
    NSString *idstr, *cid;
    Comment *comment = [[Comment alloc] init];
    AppDelegate *appDelegate = [AppDelegate delegate];
    switch (_flag)
    {
        case 0: //发微博
            {
                if (_pickedOnes.count == 1)
                { //有一张配图
                    NSData *imgData = _pickedOnes.firstObject;
                    params = @{@"status": _statusTextView.text};
                    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeSinaWeibo requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.weibo.com/2/statuses/upload.json"] parameters:params];
                    [request setAccount:weiboAccount];
                    
                    //必须指定一个filename的字符串，可以是任意字符串，但必须有，原因未知。
                    [request addMultipartData:imgData withName:@"pic" type:@"multipart/form-data" filename:@"pic"];
                    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString *notificationText = nil;
                        if (!error) {
                            if (urlResponse.statusCode > 0 && urlResponse.statusCode < 300)
                            {
                                notificationText = @"微博发布成功";
                                if (_draft)
                                {
                                    [self.delegate updateStatusView:self shouldDeleteDraftAt:_draft.time];
                                }
                            }
                            else
                            {
                                notificationText = @"微博发布失败";
                                if (!_draft)
                                {
                                    [self saveToDraft];
                                }
                            }
                        }
                        else
                        {
                            NSLog(@"发布失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
                            if (!_draft)
                            {
                                [self saveToDraft];
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self callbackForUpdateCompletionWithNotificationText:notificationText];
                        });
                    }];
                }
                else if (_pickedOnes.count > 1)
                { //有多张配图
                    
                }
                else
                { //无配图
                    params = @{@"status": _statusTextView.text};
                    [Utils weiboPostRequestWithAccount:weiboAccount URL:@"statuses/update.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                        NSString *notificationText = nil;
                        if (!error)
                        {
                            if (urlResponse.statusCode < 300 && urlResponse.statusCode > 0)
                            {
                                notificationText = @"微博发布成功";
                                if (_draft)
                                {
                                    [self.delegate updateStatusView:self shouldDeleteDraftAt:_draft.time];
                                }
                            }
                            else
                            {
                                notificationText = @"微博发布失败";
                                if (!_draft)
                                {
                                    [self saveToDraft];
                                }
                            }
                        }
                        else
                        {
                            NSLog(@"发布失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
                            if (!_draft)
                            {
                                [self saveToDraft];
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self callbackForUpdateCompletionWithNotificationText:notificationText];
                        });
                    }];
                }
            }
            break;
        case 1: //写评论
            {
                //不管后续成功与否，本地立即显示内容
                [self assembleComment:comment user:appDelegate.user text:_statusTextView.text];
                [self.delegate updateStatusView:self shouldDisplayComment:comment];
                
                if (_status)
                {
                    idstr = _status.idstr;
                }
                else
                {
                    idstr = draftParams[@"id"];
                }
                params = @{@"comment": _statusTextView.text,
                           @"id": idstr,
                           @"comment_ori": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"comments/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error)
                    {
                        if (urlResponse.statusCode > 0 && urlResponse.statusCode < 300)
                        { //2xx
                            notificationText = @"评论发布成功";
                            if (_draft)
                            {
                                [self.delegate updateStatusView:self shouldDeleteDraftAt:_draft.time];
                            }
                        }
                        else
                        {
                            if (!_draft)
                            {
                                [self saveToDraft];
                            }
                        }
                    }
                    if (error)
                    {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                        if (!_draft)
                        {
                            [self saveToDraft];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
                    });
                }];
            }
            break;
        case 2: //转发微博
            {
                if (_status)
                {
                    idstr = _status.idstr;
                }
                else
                {
                    idstr = draftParams[@"id"];
                }
                params = @{@"status": _statusTextView.text,
                           @"id": idstr,
                           @"is_comment": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"statuses/repost.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error)
                    {
                        if (urlResponse.statusCode > 0 && urlResponse.statusCode < 300)
                        {
                            notificationText = @"转发发布成功";
                            if (_draft)
                            {
                                [self.delegate updateStatusView:self shouldDeleteDraftAt:_draft.time];
                            }
                        }
                        else
                        {
                            if (!_draft)
                            {
                                [self saveToDraft];
                            }
                        }
                    }
                    else
                    {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"转发发布失败: %@", error];
                        if (!_draft)
                        {
                            [self saveToDraft];
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
                    });
                }];
            }
            break;
        case 3: //回复评论
            {
                //不管后续成功与否，本地立即显示内容
                [self assembleComment:comment user:appDelegate.user text:[NSString stringWithFormat:@"Reply@%@:%@", _comment.user.screen_name, _statusTextView.text]];
                [self.delegate updateStatusView:self shouldDisplayComment:comment];
                
                if (_comment)
                {
                    idstr = _comment.status.idstr;
                    cid = _comment.idstr;
                }
                else
                {
                    idstr = draftParams[@"id"];
                    cid = draftParams[@"cid"];
                }
                params = @{@"comment": _statusTextView.text,
                           @"id": idstr,
                           @"cid": cid,
                           @"comment_ori": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"comments/reply.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error)
                    {
                        if (urlResponse.statusCode > 0 && urlResponse.statusCode < 300)
                        {
                            notificationText = @"评论发布成功";
                            if (_draft)
                            {
                                [self.delegate updateStatusView:self shouldDeleteDraftAt:_draft.time];
                            }
                        }
                        else
                        {
                            if (!_draft)
                            {
                                [self saveToDraft];
                            }
                        }
                    }
                    else
                    {
                        NSLog(@"发布失败：%@", error);
                        if (!_draft)
                        {
                            [self saveToDraft];
                        }
                        notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
                    });
                }];
            }
            break;
    }
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        if (_mask)
        {
            _mask.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (finished)
        {
            if (_mask)
            {
                [_mask removeFromSuperview];
                _mask = nil; //引用计数减一
            }
            [self removeFromSuperview];
        }
    }];
}

-(void)addPictureButtonPressed:(UIButton *)sender
{
    [_statusTextView resignFirstResponder];
    BBPhotoSelectionCollectionViewController *photoSelectionCollectionViewController = [[BBPhotoSelectionCollectionViewController alloc] initWithCollectionViewLayout:[self flowLayout]];
    photoSelectionCollectionViewController.delegate = self;
    UINavigationController *uinvc = [[UINavigationController alloc] initWithRootViewController:photoSelectionCollectionViewController];
    [self shouldHideMaskAndView:YES];
    [self.window.rootViewController presentViewController:uinvc animated:YES completion:^{}];
}

-(void)callCameraButtonPressed:(UIButton *)sender
{
    [self.statusTextView resignFirstResponder];
    [self pickFromCamera];
}

-(UICollectionViewFlowLayout *)flowLayout
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((bWidth-3)/4, (bWidth-3)/4);
    layout.minimumInteritemSpacing = 1.0;
    layout.minimumLineSpacing = 1.0;
    return layout;
}

-(void)pickFromCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _picker = [[UIImagePickerController alloc] init];
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        _picker.delegate = self;
        _picker.allowsEditing = NO;
        [self shouldHideMaskAndView:YES];
        [self.window.rootViewController presentViewController:_picker animated:YES completion:^{}];
    }
}

-(void)shouldHideMaskAndView:(BOOL)flag
{
    self.hidden = flag;
    _mask.hidden = flag;
}

#pragma mark - Draft support

-(void)alertForDraft
{
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"草稿" message:@"是否保存为草稿?" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存草稿" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveToDraft];
        [self removeViewAnimation];
    }];
    UIAlertAction *unsaveAction = [UIAlertAction actionWithTitle:@"不保存" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self removeViewAnimation];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self resignTextViewAndMask:NO];
    }];
    [alertcontroller addAction:saveAction];
    [alertcontroller addAction:unsaveAction];
    [alertcontroller addAction:cancelAction];
    
    UITabBarController *tbc = (UITabBarController *)self.window.rootViewController;
    UINavigationController *nvc = tbc.selectedViewController;
    UIViewController *currentvc = nvc.viewControllers.firstObject;
    
    [self resignTextViewAndMask:YES];
    
    [currentvc presentViewController:alertcontroller animated:YES completion:^{}];
}

-(void)removeViewAnimation
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        if (_mask)
        {
            _mask.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (finished)
        {
            if (_mask)
            {
                [_mask removeFromSuperview];
                _mask = nil;
            }
            if (_pickedOnes.count > 0)
            {
                [_pickedOnes removeAllObjects];
            }
            _pickedOnes = nil;
            [self removeFromSuperview];
        }
    }];
}

-(void)saveToDraft
{
    //先组成草稿字典
    NSString *url = @"";
    NSMutableArray *images = @[].mutableCopy;
    NSMutableDictionary *params = @{}.mutableCopy;
    
    switch (_flag)
    {
        case 0:
            if (_pickedOnes.count == 1)
            { //一张配图
                url = @"https://api.weibo.com/2/statuses/upload.json";
                [images addObject:_pickedOnes.firstObject];
            }
            if (_pickedOnes.count > 1)
            { //多张配图
                url = @"";
                for (NSData *data in _pickedOnes)
                {
                    [images addObject:data];
                }
            }
            if (!_pickedOnes || _pickedOnes.count == 0)
            {
                url = @"https://api.weibo.com/2/statuses/update.json";
            }
            break;
            
        case 1:
            url = @"https://api.weibo.com/2/comments/create.json";
            [params setObject:_status.idstr forKey:@"id"];
            [params setObject:[_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0" forKey:@"comment_ori"];
            [params setObject:[NSString stringWithFormat:@"@%@:%@", _status.user.screen_name, _status.text] forKey:@"original"];
            break;
            
        case 2:
            url = @"https://api.weibo.com/2/statuses/repost.json";
            [params setObject:_status.idstr forKey:@"id"];
            [params setObject:[_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0" forKey:@"is_comment"];
            [params setObject:[NSString stringWithFormat:@"@%@:%@", _status.user.screen_name, _status.text] forKey:@"original"];
            break;
            
        case 3:
            url = @"https://api.weibo.com/2/comments/reply.json";
            [params setObject:_comment.status.idstr forKey:@"id"];
            [params setObject:_comment.idstr forKey:@"cid"];
            [params setObject:[_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0" forKey:@"comment_ori"];
            [params setObject:[NSString stringWithFormat:@"@%@:%@", _comment.user.screen_name, _comment.text] forKey:@"original"];
            break;
        default:
            break;
    }
    
    NSDate *date = [NSDate date];
    
    NSMutableDictionary *draft = @{@"text": _statusTextView.text,
                                   @"flag": @(_flag),
                                   @"url": url,
                                   @"images": images,
                                   @"params": params,
                                   @"time": [self stringFromDate:date]}.mutableCopy;
    [self saveDraftToPlist:draft];
}

-(void)dropIntoDraftbox:(NSData *)responseData error:(NSError *)error
{
    
}

-(NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEE MMM d HH:mm:ss Z yyyy"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Beijing"]];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_CN"]];
    return [formatter stringFromDate:date];
}

//草稿保存使用plist直接保存草稿字典数据
-(void)saveDraftToPlist:(NSDictionary *)draft
{
    //获取Library/Caches目录
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    
    //将文件名拼在目录后面形成完整文件路径
    NSString *plistPath = [cachesDirectory stringByAppendingPathComponent:filepath];
    
    //将字典数据写入文件
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL flag;
    if (![manager fileExistsAtPath:plistPath])
    { //若plist不存在则创建一个
        BOOL isCreated = [manager createFileAtPath:plistPath contents:nil attributes:nil];
        NSLog(@"创建结果：%@", isCreated? @"成功": @"失败");
        
        NSMutableArray *array = @[].mutableCopy;
        [array addObject:draft];
        NSMutableDictionary *drafts = @{@"draft": array}.mutableCopy;
        
        flag = [drafts writeToFile:plistPath atomically:YES];
        NSLog(@"写入结果：%@", flag? @"成功": @"失败");
    }
    else
    {
        NSMutableDictionary *drafts = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
        NSMutableArray *array = drafts[@"draft"];
        [array addObject:draft];
        flag = [drafts writeToFile:plistPath atomically:YES];
        NSLog(@"写入结果：%@", flag? @"成功": @"失败");
    }
    if (flag)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utils presentNotificationWithText:@"已存入草稿"];
        });
    }
}

#pragma mark - BBPhotoSelectionCollectionViewControllerDelegate

-(void)didFetchedPickedPhotos:(NSMutableArray *)photos
{
    _pickedOnes = photos;
    [self shouldHideMaskAndView:NO];
    [self setNeedsLayout];
    [_collectionView reloadData];
    [_statusTextView becomeFirstResponder];
}

-(void)didCancelPhotoSelection
{
    if (_pickedOnes.count > 0)
    {
        [_pickedOnes removeAllObjects];
    }
    [self shouldHideMaskAndView:NO];
    [_statusTextView becomeFirstResponder];
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"didFinishPickingMediaWithInfo");
    [self shouldHideMaskAndView:NO];
    UIImage *takenImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (!_pickedOnes)
    {
        _pickedOnes = @[].mutableCopy;
    }
    NSData *imageData = UIImageJPEGRepresentation(takenImage, compressionQuality);
    [_pickedOnes addObject:imageData];
    [_picker dismissViewControllerAnimated:YES completion:^{}];
    [self setNeedsLayout];
    [_statusTextView becomeFirstResponder];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePickerControllerDidCancel");
    [self shouldHideMaskAndView:NO];
    [_picker dismissViewControllerAnimated:YES completion:^{}];
    [_statusTextView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate & support

-(void)updateCountLabelWith:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        [_countLabel setText:@"写点什么呢?"];
    }
    else
    {
        [_countLabel setText:[NSString stringWithFormat:@"%ld字", textView.text.length]];
    }
    
    if (textView.text.length == 140)
    {
        [_countLabel setTextColor:[UIColor orangeColor]];
    }
    
    if (textView.text.length > 140)
    {
        [_countLabel setTextColor:[UIColor firebrick]];
    }
    
    if (textView.text.length < 140)
    {
        [_countLabel setTextColor:[UIColor lightTextColor]];
    }
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self updateCountLabelWith:textView];
    
    if (_draft)
    {
        if ([textView.text isEqualToString:_draft.text] || textView.text.length == 0)
        {
            _statusChanged = NO;
        }
        else
        {
            _statusChanged = YES;
        }
    }
    else
    {
        if (textView.text.length > 0)
        {
            _statusChanged = YES;
        }
        else
        {
            _statusChanged = NO;
        }
    }

    if (textView.text.length > 140)
    {
        _sendBtn.enabled = NO;
    }
    else
    {
        _sendBtn.enabled = YES;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateCountLabelWith:textView];
    
    if (_draft)
    {
        if ([textView.text isEqualToString:_draft.text] || textView.text.length == 0)
        {
            _statusChanged = NO;
            _sendBtn.enabled = NO;
        }
        else
        {
            _statusChanged = YES;
            if (textView.text.length > 140)
            {
                _sendBtn.enabled = NO;
            }
            else
            {
                _sendBtn.enabled = YES;
            }
        }
    }
    else
    {
        _sendBtn.enabled = NO;
        if (textView.text.length > 0 && textView.text.length <= 140)
        {
            _statusChanged = YES;
            _sendBtn.enabled = YES;
        }
        else
        {
            _statusChanged = NO;
            _sendBtn.enabled = NO;
        }
    }
}

#pragma mark - UICollectionViewDataSource & Delegate & Support

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _pickedOnes.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //借用PhotoSelectionCollectionViewCell先用着
    [collectionView registerClass:[BBPhotoSelectionCollectionViewCell class] forCellWithReuseIdentifier:reuseCell];
    BBPhotoSelectionCollectionViewCell *cell = (BBPhotoSelectionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:reuseCell forIndexPath:indexPath];
    if (![_pickedOnes[indexPath.item] isEqual:[NSNull null]])
    {
        NSData *imageData = _pickedOnes[indexPath.item];
        UIImage *image = [UIImage imageWithData:imageData];
        [cell.imageView setImage:image];
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIAlertController *alertcontroller = [UIAlertController alertControllerWithTitle:@"移除照片" message:@"是否移除这张照片？" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *removeAction = [UIAlertAction actionWithTitle:@"移除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_pickedOnes removeObjectAtIndex:indexPath.item];
        [self setNeedsLayout];
        [_collectionView reloadData];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_mask setHidden:NO];
            [_statusTextView becomeFirstResponder];
        } completion:^(BOOL finished) {}];
    }];
    [alertcontroller addAction:removeAction];
    [alertcontroller addAction:cancelAction];
    [_mask setHidden:YES];
    [_statusTextView resignFirstResponder];
    [self.window.rootViewController presentViewController:alertcontroller animated:YES completion:^{}];
}

@end