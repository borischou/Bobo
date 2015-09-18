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
#import "WeiboSDK.h"
#import "BBPhotoSelectionCollectionViewController.h"
#import "BBStatusDetailViewController.h"
#import "BBNotificationView.h"
#import "UIColor+Custom.h"

#define uSmallGap 5
#define uBigGap 10
#define uBtnHeight 20
#define uBtnWidth 50
#define uImgHeight 60
#define uImgWidth uImgHeight

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define bBGColor [UIColor colorWithRed:59.f/255 green:59.f/255 blue:59.f/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

static CGFloat imageQuality = 0.7;

@interface BBUpdateStatusView () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, BBPhotoSelectionCollectionViewControllerDelegate> {
    int _flag; //0-发微博; 1-写评论; 2-转发; 3-回复评论
}

@property (strong, nonatomic) BBKeyboardInputAccessoryView *keyboardInputView;
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
        } completion:^(BOOL finished) {
            
        }];
    }
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"取消" withBackgroundColor:nil andTintColor:nil];
    [_cancelBtn setBackgroundColor:[UIColor firebrick]];
    [_cancelBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"发送" withBackgroundColor:nil andTintColor:nil];
    [_sendBtn setBackgroundColor:[UIColor dodgerBlue]];
    [_sendBtn setTitleColor:[UIColor mintCream] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateDisabled];
    [_sendBtn addTarget:self action:@selector(sendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    _sendBtn.enabled = NO;
    [self addSubview:_sendBtn];
    
    _nameLabel = [[UILabel alloc] init];
    _nameLabel.textColor = [UIColor lightTextColor];
    _nameLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_nameLabel];
    
    _statusTextView = [[UITextView alloc] initWithFrame:CGRectZero];
    _statusTextView.textColor = [UIColor lightTextColor];
    _statusTextView.backgroundColor = bBGColor;
    _statusTextView.delegate = self;
    [self addSubview:_statusTextView];
    
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
    [_statusTextView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight)];
    
    if (_pickedOnes.count > 0) {
        [_imageView setFrame:CGRectMake(uBigGap, uBigGap*2+uBtnHeight+self.frame.size.height-3*uBigGap-uBtnHeight-uSmallGap-uBtnHeight-uImgHeight+uSmallGap, uImgWidth, uImgHeight)];
        _imageView.image = [_pickedOnes firstObject];
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
        } completion:^(BOOL finished) {
            
        }];
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
    BBNotificationView *notificationView = [[BBNotificationView alloc] initWithNotification:text];
    //notificationView.notificationLabel.text = text;
    AppDelegate *delegate = [AppDelegate delegate];
    [delegate.window addSubview:notificationView];
    [delegate.window bringSubviewToFront:notificationView];
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [notificationView setFrame:CGRectMake(0, 0, bWidth, 2*statusBarHeight)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [notificationView setFrame:CGRectMake(0, -2*statusBarHeight, bWidth, 2*statusBarHeight)];
        } completion:^(BOOL finished) {
            [notificationView removeFromSuperview];
        }];
    }];
}

-(void)refreshComments
{
//    NSLog(@"SELF!!!!!!!!!: %@", self);
//    if ([self.window.rootViewController isKindOfClass:[SWRevealViewController class]]) {
//        SWRevealViewController *rvc = (SWRevealViewController *)self.window.rootViewController;
//        UITabBarController *tbc = (UITabBarController *)rvc.frontViewController;
//        UINavigationController *nvc = (UINavigationController *)tbc.selectedViewController;
//        if ([nvc.viewControllers count] >= 2) {
//            if ([nvc.viewControllers[1] isKindOfClass:[BBStatusDetailViewController class]]) {
//                BBStatusDetailViewController *sdtvc = (BBStatusDetailViewController *)nvc.viewControllers[1];
//                [sdtvc.tableView.header beginRefreshing];
//            }
//        }
//    }
}

-(void)sendButtonPressed:(UIButton *)sender
{
//    AppDelegate *delegate = [AppDelegate delegate];
//    if (!delegate.isLoggedIn) {
//        [[[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
//    } else {
    ACAccount *weiboAccount = [[AppDelegate delegate] defaultAccount];
    NSDictionary *params = nil;
    switch (_flag) {
        case 0: //发微博
            {
                if (_pickedOnes.count > 0) { //有配图
                    UIImage *firstImage = [[_pickedOnes firstObject] copy];
                    NSData *imgData = UIImageJPEGRepresentation(firstImage, imageQuality);
                    WBImageObject *imgObject = [WBImageObject object];
                    imgObject.imageData = imgData;
                    
                    params = @{@"status": _statusTextView.text, @"pic": imgData};
                    [Utils weiboPostRequestWithAccount:weiboAccount URL:@"statuses/upload.json" parameters:params completionHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
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
                    
//                        [WBHttpRequest requestForShareAStatus:_statusTextView.text contatinsAPicture:imgObject orPictureUrl:nil withAccessToken:delegate.wbToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                            NSString *notificationText = nil;
//                            if (!error) {
//                                NSLog(@"发布成功。");
//                                notificationText = @"微博发布成功";
//                            } else {
//                                NSLog(@"发布失败：%@", error);
//                                notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
//                            }
//                            [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                        }];
                } else { //无配图
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
                    
//                    [Utils genericWeiboRequestWithAccount:weiboAccount URL:@"statuses/upload_url_text.json" SLRequestHTTPMethod:SLRequestMethodPOST parameters:@{@"status": _statusTextView.text} completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                        NSString *notificationText = @"微博发布成功";
//                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                        
//                    } completionBlockWithFailure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                        NSString *notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
//                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                    }];
                    
//                        [WBHttpRequest requestForShareAStatus:_statusTextView.text contatinsAPicture:nil orPictureUrl:nil withAccessToken:delegate.wbToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                            NSString *notificationText = nil;
//                            if (!error) {
//                                NSLog(@"发布成功。");
//                                notificationText = @"微博发布成功";
//                            } else {
//                                NSLog(@"发布失败：%@", error);
//                                notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
//                            }
//                            [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                        }];
                }
            }
            break;
        case 1: //写评论
            {
                params = @{@"comment": _statusTextView.text,
                           @"id": _idStr,
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
                
//                    NSDictionary *params = @{@"access_token": delegate.wbToken,
//                                             @"comment": _statusTextView.text,
//                                             @"id": _idStr,
//                                             @"comment_ori": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
//
//                    NSString *url = [bWeiboDomain stringByAppendingString:@"comments/create.json"];
//                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                        NSString *notificationText = nil;
//                        if (!error) {
//                            NSLog(@"评论成功。");
//                            notificationText = @"评论发布成功";
//                        }
//                        else
//                        {
//                            NSLog(@"评论失败：%@", error);
//                            notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
//                        }
//                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                    }];
            }
            break;
        case 2: //转发微博
            {
                params = @{@"status": _statusTextView.text,
                           @"id": _idStr,
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
//                    NSDictionary *params = @{@"access_token": delegate.wbToken,
//                                             @"status": _statusTextView.text,
//                                             @"id": _idStr,
//                                             @"is_comment": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
//                    
//                    NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/repost.json"];
//                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                        NSString *notificationText = nil;
//                        if (!error) {
//                            NSLog(@"转发成功。");
//                            notificationText = @"转发发布成功";
//                        }
//                        else
//                        {
//                            NSLog(@"转发失败：%@", error);
//                            notificationText = [NSString stringWithFormat:@"转发发布失败: %@", error];
//                        }
//                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                    }];
            }
            break;
        case 3: //回复评论
            {
                params = @{@"comment": _statusTextView.text,
                           @"id": _idStr,
                           @"cid": _cidStr,
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

//                    NSDictionary *params = @{@"access_token": delegate.wbToken,
//                                             @"comment": _statusTextView.text,
//                                             @"id": _idStr,
//                                             @"cid": _cidStr,
//                                             @"comment_ori": [_todoLabel.textColor isEqual:[UIColor greenColor]]? @"1": @"0"};
//
//                    NSString *url = [bWeiboDomain stringByAppendingString:@"comments/reply.json"];
//                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
//                        NSString *notificationText = nil;
//                        if (!error) {
//                            NSLog(@"评论成功。");
//                            notificationText = @"评论发布成功";
//                        }
//                        else
//                        {
//                            NSLog(@"评论失败：%@", error);
//                            notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
//                        }
//                        [self callbackForUpdateCompletionWithNotificationText:notificationText];
//                    }];
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
    [_pickedOnes addObject:takenImage];
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
    if (textView.text.length == 0 || textView.text.length >= 140) {
        _sendBtn.enabled = NO;
    } else {
        _sendBtn.enabled = YES;
    }
}

@end