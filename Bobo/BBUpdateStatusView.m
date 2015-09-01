//
//  BBUpdateStatusView.m
//  Bobo
//
//  Created by Zhouboli on 15/8/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>
#import "BBUpdateStatusView.h"
#import "UIButton+Bobtn.h"
#import "BBKeyboardInputAccessoryView.h"
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "BBPhotoSelectionCollectionViewController.h"
#import "BBStatusDetailViewController.h"

#import "BBNotificationView.h"

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

@interface BBUpdateStatusView () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
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
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _mask.alpha = 0.5;
        } completion:^(BOOL finished) {
            
        }];
    }
    
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"取消" withBackgroundColor:nil andTintColor:nil];
    [_cancelBtn setTitleColor:[UIColor lightTextColor] forState:UIControlStateNormal];
    [_cancelBtn addTarget:self action:@selector(cancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancelBtn];
    
    _sendBtn = [[UIButton alloc] initWithFrame:CGRectZero andTitle:@"发送" withBackgroundColor:nil andTintColor:nil];
    [_sendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_sendBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
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
    _imageView.backgroundColor = [UIColor redColor];
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
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
            [_pickedStatuses removeAllObjects];
            [_pickedOnes removeAllObjects];
            [self removeFromSuperview];
        }
    }];
}

-(void)callbackForUpdateCompletionWithNotificationView:(BBNotificationView *)view text:(NSString *)text
{
    view.notificationLabel.text = text;
    
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [view setFrame:CGRectMake(0, 0, bWidth, 2*statusBarHeight)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [view setFrame:CGRectMake(0, -2*statusBarHeight, bWidth, 2*statusBarHeight)];
        } completion:^(BOOL finished) {
            [view removeFromSuperview];
        }];
    }];
}

-(void)sendButtonPressed:(UIButton *)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        BBNotificationView *notificationView = [[BBNotificationView alloc] init];
        AppDelegate *delegate = [AppDelegate delegate];
        [delegate.window addSubview:notificationView];
        __block NSString *notificationText = nil;
        switch (_flag) {
            case 0: //发微博
                {
                    if (_pickedOnes.count > 0) { //有配图
                        NSData *imgData = UIImageJPEGRepresentation([_pickedOnes firstObject], 1.0);
                        WBImageObject *imgObject = [WBImageObject object];
                        imgObject.imageData = imgData;
                        [WBHttpRequest requestForShareAStatus:_statusTextView.text contatinsAPicture:imgObject orPictureUrl:nil withAccessToken:delegate.wbToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                            if (!error) {
                                NSLog(@"发布成功。");
                                notificationText = @"微博发布成功";
                            } else {
                                NSLog(@"发布失败：%@", error);
                                notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
                            }
                            [self callbackForUpdateCompletionWithNotificationView:notificationView text:notificationText];
                        }];
                    } else { //无配图
                        [WBHttpRequest requestForShareAStatus:_statusTextView.text contatinsAPicture:nil orPictureUrl:nil withAccessToken:delegate.wbToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                            if (!error) {
                                NSLog(@"发布成功。");
                                notificationText = @"微博发布成功";
                            } else {
                                NSLog(@"发布失败：%@", error);
                                notificationText = [NSString stringWithFormat:@"微博发布失败: %@", error];
                            }
                            [self callbackForUpdateCompletionWithNotificationView:notificationView text:notificationText];
                        }];
                    }
                    
                }
                break;
            case 1: //写评论
                {
                    NSMutableDictionary *params = @{}.mutableCopy;
                    [params setObject:delegate.wbToken forKey:@"access_token"];
                    [params setObject:_idStr forKey:@"id"];
                    [params setObject:_statusTextView.text forKey:@"comment"];
                    if ([_todoLabel.textColor isEqual:[UIColor greenColor]]) {
                        [params setObject:@"1" forKey:@"comment_ori"];
                    } else {
                        [params setObject:@"0" forKey:@"comment_ori"];
                    }
                    NSString *url = [bWeiboDomain stringByAppendingString:@"comments/create.json"];
                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"评论成功。");
                            notificationText = @"评论发布成功";
                        }
                        else
                        {
                            NSLog(@"评论失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                        }
                        [self callbackForUpdateCompletionWithNotificationView:notificationView text:notificationText];
                    }];
                }
                break;
            case 2: //转发微博
                {
                    NSMutableDictionary *params = @{}.mutableCopy;
                    [params setObject:delegate.wbToken forKey:@"access_token"];
                    [params setObject:_idStr forKey:@"id"];
                    [params setObject:_statusTextView.text forKey:@"status"];
                    if ([_todoLabel.textColor isEqual:[UIColor greenColor]]) {
                        [params setObject:@"1" forKey:@"is_comment"];
                    } else {
                        [params setObject:@"0" forKey:@"is_comment"];
                    }
                    NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/repost.json"];
                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"转发成功。");
                            notificationText = @"转发发布成功";
                        }
                        else
                        {
                            NSLog(@"转发失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"转发发布失败: %@", error];
                        }
                        [self callbackForUpdateCompletionWithNotificationView:notificationView text:notificationText];
                    }];
                }
                break;
            case 3: //回复评论
                {
                    NSMutableDictionary *params = @{}.mutableCopy;
                    [params setObject:delegate.wbToken forKey:@"access_token"];
                    [params setObject:_idStr forKey:@"id"];
                    [params setObject:_cidStr forKey:@"cid"];
                    [params setObject:_statusTextView.text forKey:@"comment"];
                    if ([_todoLabel.textColor isEqual:[UIColor greenColor]]) {
                        [params setObject:@"1" forKey:@"comment_ori"];
                    } else {
                        [params setObject:@"0" forKey:@"comment_ori"];
                    }
                    NSString *url = [bWeiboDomain stringByAppendingString:@"comments/reply.json"];
                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"评论成功。");
                            notificationText = @"评论发布成功";
                        }
                        else
                        {
                            NSLog(@"评论失败：%@", error);
                            notificationText = [NSString stringWithFormat:@"评论发布失败: %@", error];
                        }
                        [self callbackForUpdateCompletionWithNotificationView:notificationView text:notificationText];
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
                if ([self.window.rootViewController isKindOfClass:[SWRevealViewController class]]) {
                    SWRevealViewController *rvc = (SWRevealViewController *)self.window.rootViewController;
                    UITabBarController *tbc = (UITabBarController *)rvc.frontViewController;
                    UINavigationController *nvc = (UINavigationController *)tbc.selectedViewController;
                    if ([nvc.viewControllers count] >= 2) {
                        if ([nvc.viewControllers[1] isKindOfClass:[BBStatusDetailViewController class]]) {
                            BBStatusDetailViewController *sdtvc = (BBStatusDetailViewController *)nvc.viewControllers[1];
                            [sdtvc.tableView.header beginRefreshing];
                        }
                    }
                }
                if (_mask) {
                    [_mask removeFromSuperview];
                    _mask = nil; //引用计数减一
                }
                [self removeFromSuperview];
            }
        }];
    }
    
}

-(void)addPictureButtonPressed:(UIButton *)sender
{
    [self.statusTextView resignFirstResponder];
    BBPhotoSelectionCollectionViewController *photoSelectionCollectionViewController = [[BBPhotoSelectionCollectionViewController alloc] initWithCollectionViewLayout:[self flowLayout]];
    photoSelectionCollectionViewController.mask = _mask;
    photoSelectionCollectionViewController.updateView = self;
    UINavigationController *uinvc = [[UINavigationController alloc] initWithRootViewController:photoSelectionCollectionViewController];
    [self.window.rootViewController presentViewController:uinvc animated:YES completion:nil];
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
        [self.window.rootViewController presentViewController:_picker animated:YES completion:nil];
    }
}

-(void)shouldHideMaskAndView:(BOOL)flag
{
    self.hidden = flag;
    _mask.hidden = flag;
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
    [_picker dismissViewControllerAnimated:YES completion:nil];
    [self setNeedsLayout];
    [_statusTextView becomeFirstResponder];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePickerControllerDidCancel");
    [self shouldHideMaskAndView:NO];
    [_picker dismissViewControllerAnimated:YES completion:nil];
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