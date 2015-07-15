//
//  BBMapViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/7/7.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMapViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "BBUberTableVC.h"
#import "BBBaiduCustomPaopaoVC.h"
#import "BBAddressTableViewController.h"
#import "BBToolbarVC.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height
#define bTabbarHeight self.tabBarController.tabBar.frame.size.height
#define kBarColor [UIColor colorWithRed:47.f/255 green:79.f/255 blue:79.f/255 alpha:1.f]

@interface BBMapViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BBPaopaoViewDelegate>

@property (strong, nonatomic) BMKMapView *mapView;

@property (strong, nonatomic) BMKPointAnnotation *curAnnotation;
@property (strong, nonatomic) BMKPinAnnotationView *curPinView;

@property (strong, nonatomic) BMKLocationService *locService;

@property (strong, nonatomic) BMKGeoCodeSearch *searcher;
@property (strong, nonatomic) BMKReverseGeoCodeOption *reverseGeoCodeOption;

@property (copy, nonatomic) NSString *curAddress;

@property (strong, nonatomic) BBBaiduCustomPaopaoVC *baiducpvc;
@property (strong, nonatomic) BBAddressTableViewController *atvc;
@property (strong, nonatomic) BBToolbarVC *tbvc;

@property (nonatomic) CGFloat bd_destLat;
@property (nonatomic) CGFloat bd_destLon;

@property (strong, nonatomic) UIImageView *centerPinView;
@property (strong, nonatomic) UIImageView *focusBtnView;

@end

@implementation BBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBaiduMapView];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Available Cars" style:UIBarButtonItemStylePlain target:self action:@selector(checkCarsPressed)];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    
    _searcher = [[BMKGeoCodeSearch alloc] init];
    _reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
    
    _tbvc = [[BBToolbarVC alloc] init];
    _tbvc.view.frame = CGRectMake(0, bHeight - bTabbarHeight * 2, bWidth, bTabbarHeight);
    _tbvc.view.backgroundColor = kBarColor;
    [self.view addSubview:_tbvc.view];
    
    _centerPinView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    _centerPinView.center = self.view.center;
    _centerPinView.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_centerPinView];
    
    _focusBtnView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _focusBtnView.frame = CGRectMake(10, bHeight - bTabbarHeight * 2 - 50, 40, 40);
    _focusBtnView.backgroundColor = [UIColor greenColor];
    _focusBtnView.userInteractionEnabled = YES;
    [_focusBtnView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFocus:)]];
    [self.view addSubview:_focusBtnView];
        
    [self startBaiduLocationService];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mapView.delegate = self;
    _searcher.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (_curAnnotation != nil) {
        [_mapView removeAnnotation:_curAnnotation];
    }
    
    _mapView.delegate = nil;
    _searcher.delegate = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _curAnnotation = [[BMKPointAnnotation alloc] init];
    [_mapView addAnnotation:_curAnnotation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Helpers

-(void)tapFocus:(UITapGestureRecognizer *)tap
{
    NSLog(@"center tapped");
    _mapView.centerCoordinate = _curAnnotation.coordinate;
}

-(void)checkCarsPressed
{
    BBUberTableVC *utvc = [[BBUberTableVC alloc] initWithStyle:UITableViewStyleGrouped];
    utvc.hidesBottomBarWhenPushed = YES;
    utvc.bd_startLat = _curAnnotation.coordinate.latitude;
    utvc.bd_startLon = _curAnnotation.coordinate.longitude;
    utvc.bd_destLat = _bd_destLat;
    utvc.bd_destLon = _bd_destLon;
    [self.navigationController pushViewController:utvc animated:YES];
}

-(void)initBaiduMapView
{
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
    [self.view addSubview:_mapView];
    _mapView.zoomLevel = 15; //3-19
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake(5, bHeight - self.tabBarController.tabBar.frame.size.height - 25);
}

-(void)startBaiduLocationService
{
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    [_locService startUserLocationService];
}

#pragma mark - BBPaopaoViewDelegate

-(void)pushToAddressView
{
    _atvc = [[BBAddressTableViewController alloc] initWithStyle:UITableViewStylePlain];
    _atvc.title = @"Addresses";
    _atvc.tableView.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:_atvc animated:YES];
}

#pragma mark - BMKGeoCodeSearchDelegate

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        _curAddress = result.address;
        _baiducpvc.address = _curAddress;
    } else
    {
        NSLog(@"error: %u", error);
    }
}

#pragma mark - BMKLocationServiceDelegate

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    _curAnnotation.coordinate = userLocation.location.coordinate;
    _reverseGeoCodeOption.reverseGeoPoint = _curAnnotation.coordinate;
    BOOL flag = [_searcher reverseGeoCode:_reverseGeoCodeOption];
    if (!flag) {
        NSLog(@"reverseGeoCode failure, flag = %d", flag);
    }
}

#pragma mark - BMKMapViewDelegate

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isEqual:_curAnnotation]) {
        _baiducpvc = [[BBBaiduCustomPaopaoVC alloc] init];
        _baiducpvc.view.frame = CGRectMake(0, 0, 200, 200);
        _baiducpvc.delegate = self;
        if (!_curAddress) {
            _baiducpvc.addrLbl.text = @"Loading...";
        }
        
        _curPinView = [[BMKPinAnnotationView alloc] initWithAnnotation:_curAnnotation reuseIdentifier:@"curAnnotation"];
        _curPinView.pinColor = BMKPinAnnotationColorPurple;
        _curPinView.paopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:_baiducpvc.view];
        [_curPinView setSelected:YES animated:YES];
        
        return _curPinView;
    }
    
    return nil;
}

-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    if ([view isEqual:_curPinView]) {
        mapView.centerCoordinate = view.annotation.coordinate;
    }
}

- (void)mapview:(BMKMapView *)mapView onLongClick:(CLLocationCoordinate2D)coordinate
{
//    [[[UIAlertView alloc] initWithTitle:@"Destination" message:[NSString stringWithFormat:@"You just chose %f, %f as your destination.", coordinate.latitude, coordinate.longitude] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    _bd_destLat = coordinate.latitude;
    _bd_destLon = coordinate.longitude;
}

@end
