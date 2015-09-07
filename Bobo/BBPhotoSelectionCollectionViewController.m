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

@property (strong, nonatomic) BBPhotoPickerCollectionView *photoPickerCollectionView;

@end

@implementation BBPhotoSelectionCollectionViewController

#pragma mark - View Controller Life Cycle

-(void)viewDidLoad
{
    _photoPickerCollectionView = [[BBPhotoPickerCollectionView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight) collectionViewLayout:self.collectionViewLayout];
    self.view = _photoPickerCollectionView;
    self.edgesForExtendedLayout = UIRectEdgeNone;
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
    [_updateView.statusTextView becomeFirstResponder];
}

-(void)confirmButtonItemPressed:(UIBarButtonItem *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    _updateView.pickedOnes = _photoPickerCollectionView.pickedOnes;
    [self shouldHideMaskAndView:NO];
    [_updateView.statusTextView becomeFirstResponder];
    [_updateView setNeedsLayout];
}

@end