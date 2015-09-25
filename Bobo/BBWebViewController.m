//
//  BBWKWebViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/9/24.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBWebViewController.h"
#import <WebKit/WebKit.h>

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBWebViewController ()

@end

@implementation BBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WKWebView *webview = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
    self.view = webview;
    [webview loadRequest:_request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"BBWKWebViewController received memory warning.");
}

@end
