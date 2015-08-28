//
//  BBPhotoSelectionCollectionViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/8/14.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBPhotoSelectionCollectionViewController.h"
#import "BBPhotoSelectionCollectionViewCell.h"
#import "BBPhotoPickerCollectionView.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBPhotoSelectionCollectionViewController ()

@end

@implementation BBPhotoSelectionCollectionViewController

#pragma mark - View Controller Life Cycle

-(void)viewDidLoad
{
    BBPhotoPickerCollectionView *photoPickerCollectionView = [[BBPhotoPickerCollectionView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) collectionViewLayout:self.collectionViewLayout];
    self.view = photoPickerCollectionView;
    [self setupNavigationBarButtonItems];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self shouldHideMaskAndView:YES];
}

#pragma mark - Helpers

-(void)setupNavigationBarButtonItems
{
    UIBarButtonItem *cancelButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonItemPressed:)];
    UIBarButtonItem *confirmButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmButtonItemPressed:)];
    self.navigationItem.leftBarButtonItem = cancelButtonItem;
    self.navigationItem.rightBarButtonItem = confirmButtonItem;
}

-(void)shouldHideMaskAndView:(BOOL)flag
{
    _updateView.hidden = flag;
    _mask.hidden = flag;
}

#pragma mark - UIButtons

-(void)cancelButtonItemPressed:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self shouldHideMaskAndView:NO];
}

-(void)confirmButtonItemPressed:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [self shouldHideMaskAndView:NO];
}

@end
