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

#define uSmallGap 5
#define uBigGap 10
#define uBtnHeight 20
#define uBtnWidth 50

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

#define bWeiboDomain @"https://api.weibo.com/2/"

@interface BBUpdateStatusView () <UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIImagePickerController *picker;
@property (strong, nonatomic) BBKeyboardInputAccessoryView *keyboardInputView;
@property (strong, nonatomic) UIView *mask;

@end

@implementation BBUpdateStatusView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        [self setupViewLayout];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewLayout];
    }
    return self;
}

-(instancetype)initWithFlag:(int)flag
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        _flag = flag;
        [self setupViewLayout];
    }
    return self;
}

-(instancetype)initWithFlag:(int)flag maskView:(UIView *)mask
{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        _flag = flag;
        _mask = mask;
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
    
    _statusTextView = [[UITextView alloc] init];
    _statusTextView.textColor = [UIColor lightTextColor];
    _statusTextView.backgroundColor = bBGColor;
    _statusTextView.delegate = self;
    [self addSubview:_statusTextView];

    _keyboardInputView = [[BBKeyboardInputAccessoryView alloc] init];
    [_keyboardInputView.addPictureBtn addTarget:self action:@selector(addPictureButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_keyboardInputView.callCameraBtn addTarget:self action:@selector(callCameraButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_flag == 0) { //发微博
        _statusTextView.inputAccessoryView = _keyboardInputView;
    }
    else //评论转发无法使用图片上传功能
    {
        _statusTextView.inputAccessoryView = nil;
    }
    
    [_cancelBtn setFrame:CGRectMake(uBigGap, uBigGap, uBtnWidth, uBtnHeight)];
    [_sendBtn setFrame:CGRectMake(self.frame.size.width-uBigGap-uBtnWidth, uBigGap, uBtnWidth, uBtnHeight)];
    [_nameLabel setFrame:CGRectMake(0, 0, self.frame.size.width/2, uBtnHeight)];
    [_nameLabel setCenter:CGPointMake(self.frame.size.width/2, uSmallGap+uBtnHeight/2)];
}

-(void)layoutSubviews
{
    _statusTextView.frame = CGRectMake(uBigGap, uBigGap*2+uBtnHeight, self.frame.size.width-2*uBigGap, self.frame.size.height-3*uBigGap-uBtnHeight);
}

#pragma mark - UIButtons

-(void)cancelButtonPressed:(UIButton *)sender
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
        _mask.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            _mask = nil;
            [_mask removeFromSuperview];
            [self removeFromSuperview];
        }
    }];
}

-(void)sendButtonPressed:(UIButton *)sender
{
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (!delegate.isLoggedIn) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"未登录" message:@"Please log in first." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        switch (_flag) {
            case 0: //发微博
                {
                    [WBHttpRequest requestForShareAStatus:_statusTextView.text contatinsAPicture:nil orPictureUrl:nil withAccessToken:delegate.wbToken andOtherProperties:nil queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        NSLog(@"result: %@", result);
                        
                    }];
                }
                break;
            case 1: //写评论
                {
                    NSMutableDictionary *params = @{}.mutableCopy;
                    [params setObject:delegate.wbToken forKey:@"access_token"];
                    [params setObject:_idStr forKey:@"id"];
                    [params setObject:_statusTextView.text forKey:@"comment"];
                    NSString *url = [bWeiboDomain stringByAppendingString:@"comments/create.json"];
                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"评论成功。");
                        }
                        else
                        {
                            NSLog(@"评论失败：%@", error);
                        }
                    }];
                }
                break;
            case 2: //转发微博
                {
                    NSMutableDictionary *params = @{}.mutableCopy;
                    [params setObject:delegate.wbToken forKey:@"access_token"];
                    [params setObject:_idStr forKey:@"id"];
                    [params setObject:_statusTextView.text forKey:@"status"];
                    NSString *url = [bWeiboDomain stringByAppendingString:@"statuses/repost.json"];
                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"转发成功。");
                        }
                        else
                        {
                            NSLog(@"转发失败：%@", error);
                        }
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
                    NSString *url = [bWeiboDomain stringByAppendingString:@"comments/reply.json"];
                    [WBHttpRequest requestWithURL:url httpMethod:@"POST" params:params queue:nil withCompletionHandler:^(WBHttpRequest *httpRequest, id result, NSError *error) {
                        if (!error) {
                            NSLog(@"评论成功。");
                        }
                        else
                        {
                            NSLog(@"评论失败：%@", error);
                        }
                    }];
                }
                break;
        }
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.frame = CGRectMake(uSmallGap, -bHeight/2, bWidth-2*uSmallGap, bHeight/2);
            _mask.alpha = 0;
        } completion:^(BOOL finished) {
            if (finished) {
                if ([self.window.rootViewController isKindOfClass:[SWRevealViewController class]]) {
                    SWRevealViewController *rvc = (SWRevealViewController *)self.window.rootViewController;
                    UITabBarController *tbc = (UITabBarController *)rvc.frontViewController;
                    UINavigationController *nvc = (UINavigationController *)tbc.selectedViewController;
                    if ([nvc.viewControllers count] >= 2) {
                        BBStatusDetailViewController *sdtvc = (BBStatusDetailViewController *)nvc.viewControllers[1];
                        [sdtvc.tableView.header beginRefreshing];
                    }
                }
                _mask = nil; //引用计数减一
                [_mask removeFromSuperview];
                [self removeFromSuperview];
            }
        }];
    }
    
}

-(void)addPictureButtonPressed:(UIButton *)sender
{
    [self.statusTextView resignFirstResponder];
    BBPhotoSelectionCollectionViewController *photoSelectionCollectionViewController = [[BBPhotoSelectionCollectionViewController alloc] initWithCollectionViewLayout:[self getFlowLayout]];
    photoSelectionCollectionViewController.layout = [self getFlowLayout];
    UINavigationController *uinvc = [[UINavigationController alloc] initWithRootViewController:photoSelectionCollectionViewController];
    [self.window.rootViewController presentViewController:uinvc animated:YES completion:nil];
}

-(void)callCameraButtonPressed:(UIButton *)sender
{
    [self.statusTextView resignFirstResponder];
    [self pickFromCamera];
}

-(UICollectionViewFlowLayout *)getFlowLayout
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
        _picker.allowsEditing = YES;
        [self.window.rootViewController presentViewController:_picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"didFinishPickingMediaWithInfo");
    [_picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"imagePickerControllerDidCancel");
    [_picker dismissViewControllerAnimated:YES completion:^{
        
    }];
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