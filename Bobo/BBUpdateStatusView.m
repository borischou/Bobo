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

@interface BBUpdateStatusView () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BBPhotoSelectionCollectionViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate> {
    int _flag; //0-发微博; 1-写评论; 2-转发; 3-回复评论
}

@property (strong, nonatomic) BBKeyboardInputAccessoryView *keyboardInputView;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIView *mask;
@property (strong, nonatomic) UIImagePickerController *picker;

@end

@implementation BBUpdateStatusView

-(instancetype)initWithFlag:(int)flag
{
    self = [super init];
    if (self) {
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
    
    if (!_mask) {
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
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor lightTextColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
    
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
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.clipsToBounds = YES;
    [self addSubview:_imageView];
    
    if (_flag == 0) { //发微博
        _keyboardInputView = [[BBKeyboardInputAccessoryView alloc] init];
        _statusTextView.inputAccessoryView = _keyboardInputView;
        [_keyboardInputView.addPictureBtn addTarget:self action:@selector(addPictureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_keyboardInputView.callCameraBtn addTarget:self action:@selector(callCameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    else //评论转发无法使用图片上传功能
    {
        _statusTextView.inputAccessoryView = nil;
        _todoLabel = [[UILabel alloc] initWithFrame:CGRectMake(uBigGap, self.frame.size.height-uBigGap-uBtnHeight, self.frame.size.width, uBtnHeight)];
        _todoLabel.textColor = [UIColor lightTextColor];
        _todoLabel.font = [UIFont systemFontOfSize:14.0];
        _todoLabel.userInteractionEnabled = YES;
        [_todoLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(todoLabelTapped)]];
        [self addSubview:_todoLabel];
        if (_flag == 1 || _flag == 3) { // 写评论(1)或回复评论(3)
            _todoLabel.text = @"同时发微博";
        }
        if (_flag == 2) { //转发(2)
            _todoLabel.text = @"评论给作者";
        }
    }
}

-(void)layoutSubviews
{
    //铺文本输入框
    if (_flag == 0) { //发微博时不考虑下方标签
        NSInteger num = _pickedOnes.count;
        if (num == 0) {
            [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
            [_collectionView setFrame:CGRectZero];
        }
        if (num == 1) { //单图
            [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
            [_collectionView setFrame:CGRectZero];
            [_imageView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight+self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight+uSmallGap, uImgWidth, uImgHeight)];
            NSData *imageData = _pickedOnes.firstObject;
            UIImage *image = [UIImage imageWithData:imageData];
            [_imageView setImage:image];
        }
        if (num > 1) { //多图
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
    } else {
        [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
        [_collectionView setFrame:CGRectZero];
    }
    
    if (!_mask) {
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
    if ([_todoLabel.textColor isEqual:[UIColor lightTextColor]]) {
        [_todoLabel setTextColor:[UIColor greenColor]];
    } else {
        [_todoLabel setTextColor:[UIColor lightTextColor]];
    }
}

-(void)cancelButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        if (_mask) {
            _mask.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            if (_mask) {
                [_mask removeFromSuperview];
                _mask = nil;
            }
            if (_pickedOnes.count > 0) {
                [_pickedOnes removeAllObjects];
            }
            _pickedOnes = nil;
            [self removeFromSuperview];
        }
    }];
}

-(void)callbackForUpdateCompletionWithNotificationText:(NSString *)text
{
    [self refreshComments];
    if (_pickedOnes.count > 0) {
        [_pickedOnes removeAllObjects];
    }
    [Utils presentNotificationWithText:text];
}

-(void)refreshComments
{
    //Post成功后刷新评论区以显示发表的评论
}

-(void)sendButtonPressed:(UIButton *)sender
{
    ACAccount *weiboAccount = [[AppDelegate delegate] defaultAccount];
    NSDictionary *params = nil;
    switch (_flag) {
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
                            notificationText = @"微博发布成功";
                        } else {
                            NSLog(@"发布失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
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
                        if (!error) {
                            NSLog(@"发布成功。");
                            notificationText = @"微博发布成功";
                        } else {
                            NSLog(@"发布失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
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
                params = @{@"comment": _statusTextView.text,
                           @"id": _status.idstr,
                           @"comment_ori": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"comments/create.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error) {
                        NSLog(@"发布成功。");
                        notificationText = @"评论发布成功";
                    }
                    if (error) {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
                    });
                }];
            }
            break;
        case 2: //转发微博
            {
                params = @{@"status": _statusTextView.text,
                           @"id": _status.idstr,
                           @"is_comment": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"statuses/repost.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error) {
                        notificationText = @"转发发布成功";
                    } else {
                        NSLog(@"发布失败：%@", error);
                        notificationText = [NSString stringWithFormat:@"转发发布失败: %@", error];
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
                    });
                }];
            }
            break;
        case 3: //回复评论
            {
                params = @{@"comment": _statusTextView.text,
                           @"id": _comment.status.idstr,
                           @"cid": _comment.idstr,
                           @"comment_ori": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
                [Utils weiboPostRequestWithAccount:weiboAccount URL:@"comments/reply.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *notificationText = nil;
                    if (!error) {
                        NSLog(@"response: %@", urlResponse);
                        notificationText = @"评论发布成功";
                    } else {
                        NSLog(@"发布失败：%@", error);
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
        if (_mask) {
            _mask.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            if (_mask) {
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
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
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
    if (_pickedOnes.count > 0) {
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
    if (!_pickedOnes) {
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

#pragma mark - UITextViewDelegate

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >= 140) {
        _sendBtn.enabled = NO;
    } else {
        _sendBtn.enabled = YES;
    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    _sendBtn.enabled = YES;
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
    if (![_pickedOnes[indexPath.item] isEqual:[NSNull null]]) {
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