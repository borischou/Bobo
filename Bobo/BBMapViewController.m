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

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

@interface BBMapViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate>

@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKPointAnnotation *curAnnotation;
@property (strong, nonatomic) BMKPinAnnotationView *curPinView;
@property (strong, nonatomic) BMKLocationService *locService;

@end

@implementation BBMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBaiduMapView];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
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
    _curAnnotation.title = @"Test";
}

#pragma mark - BMKMapViewDelegate

-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isEqual:_curAnnotation]) {
        _curPinView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"curAnnotation"];
        _curPinView.pinColor = BMKPinAnnotationColorPurple;
        BBBaiduCustomPaopaoView *baiducpv = [[BBBaiduCustomPaopaoView alloc] initWithFrame:CGRectMake(0, 0, 200, 100)];
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

@end
