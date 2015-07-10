//
//  BBMapViewController.m
//  Bobo
//
//  Created by Zhouboli on 15/7/7.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "BBMapViewController.h"
#import <BaiduMapAPI/BMapKit.h>

#import "BBBaiduCustomPaopaoView.h"
#import "BBUberTableVC.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBMapViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate>

@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKPointAnnotation *curAnnotation;
@property (strong, nonatomic) BMKPinAnnotationView *curPinView;
@property (strong, nonatomic) BMKLocationService *locService;

@property (nonatomic) CGFloat bd_destLat;
@property (nonatomic) CGFloat bd_destLon;

@end

@implementation BBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBaiduMapView];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Available Cars" style:UIBarButtonItemStylePlain target:self action:@selector(checkCarsPressed)];
    self.navigationItem.rightBarButtonItems = @[rightItem];
    [self startBaiduLocationService];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _mapView.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_curAnnotation != nil) {
        [_mapView removeAnnotation:_curAnnotation];
    }
    _mapView.delegate = nil;
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
    self.view = _mapView;
    _mapView.zoomLevel = 13; //3-19
    _mapView.showMapScaleBar = YES;
    _mapView.mapScaleBarPosition = CGPointMake(5, bHeight - self.tabBarController.tabBar.frame.size.height - 25);
}

-(void)startBaiduLocationService
{
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    [_locService startUserLocationService];
}

#pragma mark - BMKLocationServiceDelegate

-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    _curAnnotation.coordinate = userLocation.location.coordinate;
}

#pragma mark - BMKMapViewDelegate

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isEqual:_curAnnotation]) {
        _curPinView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"curAnnotation"];
        _curPinView.pinColor = BMKPinAnnotationColorPurple;
        BBBaiduCustomPaopaoView *baiducpv = [[BBBaiduCustomPaopaoView alloc] init];
        BMKActionPaopaoView *customePaopaoView = [[BMKActionPaopaoView alloc] initWithCustomView:baiducpv];
        _curPinView.paopaoView = customePaopaoView;
        _curPinView.canShowCallout = YES;
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
    [[[UIAlertView alloc] initWithTitle:@"Destination" message:[NSString stringWithFormat:@"You just chose %f, %f as your destination.", coordinate.latitude, coordinate.longitude] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    _bd_destLat = coordinate.latitude;
    _bd_destLon = coordinate.longitude;
}

@end
