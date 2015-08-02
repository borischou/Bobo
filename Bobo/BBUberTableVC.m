//
//  BBUberTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/25.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIImageView+WebCache.h>
#import "UberKit.h"

#import "BBUberTableVC.h"
#import "BBUberCarTableViewCell.h"

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

#define uClientId @"STJy0P2hQ9zHmB4riaPdztaMNB05keCI"
#define uServerToken @"RCtJKHWI1lZGNGrXxPQLyQ6hY1YlpmPSb7jvwrA_"
#define uSecret @"9npu802FdBxpd9BtFYcGy6621FxMTzFWUM_FXZUc"
#define uAppName @"bober"

#define uAuthUrl @"https://login.uber.com/oauth/authorize"
#define uAccessTokenUrl @"https://login.uber.com/oauth/token"
#define uRedirectUrl @"bobo://oauth/callback" //redirect back to Bobo iOS app from Safari website

@interface BBUberTableVC () <UberKitDelegate, CLLocationManagerDelegate>

//@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSMutableArray *estimatedPrices;
@property (strong, nonatomic) NSMutableArray *estimatedTimes;
@property (strong, nonatomic) NSArray *activities;
@property (copy, nonatomic) NSString *accessToken;
@property (strong, nonatomic) UberPromotion *promotion;
@property (strong, nonatomic) UberProfile *profile;
@property (strong, nonatomic) UberRequest *request;
@property (strong, nonatomic) UberEstimate *estimate;
@property (strong, nonatomic) UberReceipt *receipt;
@property (strong, nonatomic) UberMap *map;

@end

@implementation BBUberTableVC

#pragma mark - Lazy boys

-(NSMutableArray *)products
{
    if (!_products) {
        _products = @[].mutableCopy;
    }
    return _products;
}

-(NSMutableArray *)estimatedPrices
{
    if (!_estimatedPrices) {
        _estimatedPrices = @[].mutableCopy;
    }
    return _estimatedPrices;
}

-(NSMutableArray *)estimatedTimes
{
    if (!_estimatedTimes) {
        _estimatedTimes = @[].mutableCopy;
    }
    return _estimatedTimes;
}

-(UberPromotion *)promotion
{
    if (!_promotion) {
        _promotion = [[UberPromotion alloc] init];
    }
    return _promotion;
}

-(UberProfile *)profile
{
    if (!_profile) {
        _profile = [[UberProfile alloc] init];
    }
    return _profile;
}

-(UberRequest *)request
{
    if (!_request) {
        _request = [[UberRequest alloc] init];
    }
    return _request;
}

-(UberEstimate *)estimate
{
    if (!_estimate) {
        _estimate = [[UberEstimate alloc] init];
    }
    return _estimate;
}

-(UberReceipt *)receipt
{
    if (!_receipt) {
        _receipt = [[UberReceipt alloc] init];
    }
    return _receipt;
}

-(UberMap *)map
{
    if (!_map) {
        _map = [[UberMap alloc] init];
    }
    return _map;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bBGColor;
    [self setNavBarBtn];
    
//    [self setupLocationService];
    [self callClientAuthenticationMethods];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Helpers

-(void)fetchUserProfile
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getUserProfileWithCompletionHandler:^(UberProfile *profile, NSURLResponse *response, NSError *error) {
            if (!error) {
                self.profile = profile;
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"My Profile" message:[NSString stringWithFormat:@"response: %@\nProfile object: %@\nFirst name: %@\nLast name: %@\nEmail: %@\nPicture URL: %@\nPromotion code: %@\nUUID: %@", response, profile, profile.first_name, profile.last_name, profile.email, profile.picture, profile.promo_code, profile.uuid] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                });
            } else NSLog(@"error: %@", error);
        }];
    });
}

-(void)fetchUserActivityOfVersion11
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getUserActivityWithCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error) {
            self.activities = resultsArray;
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"My Activities" message:[NSString stringWithFormat:@"There are %ld activities", [resultsArray count]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            });
        }];
    });
}

-(void)setNavBarBtn
{
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIBarButtonItem *rightItem_4 = [[UIBarButtonItem alloc] initWithTitle:@"Status" style:UIBarButtonItemStylePlain target:self action:@selector(statusPressed)];
    
    UIBarButtonItem *rightItem_3 = [[UIBarButtonItem alloc] initWithTitle:@"Uber Cars" style:UIBarButtonItemStylePlain target:self action:@selector(uberCarPressed)];
    
    UIBarButtonItem *rightItem_2 = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginBtnPressed)];
    
    //UIBarButtonItem *rightItem_0 = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(profileBtnPressed)];
    
    //UIBarButtonItem *rightItem_1 = [[UIBarButtonItem alloc] initWithTitle:@"Open Uber" style:UIBarButtonItemStylePlain target:self action:@selector(openUberApp)];
    
    //[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPressed)],
    
    self.navigationItem.rightBarButtonItems = @[rightItem_3,
                                                rightItem_4,
                                                [[UIBarButtonItem alloc] initWithTitle:@"Estimate" style:UIBarButtonItemStylePlain target:self action:@selector(estimatePressed)],
                                                rightItem_2,
                                                [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(mapPressed)],
                                                [[UIBarButtonItem alloc] initWithTitle:@"Receipt" style:UIBarButtonItemStylePlain target:self action:@selector(receiptPressed)]];
}

-(void)receiptPressed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getReceiptForRequestId:_request.request_id withCompletionHandler:^(UberReceipt *receiptResult, NSURLResponse *response, NSError *error) {
            _receipt = receiptResult;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Receipt" message:[NSString stringWithFormat:@"request_id: %@\ncharges count: %ld, surge_charge:\nname: %@\namount: %f\ntype: %@\ncharge_adjustments count: %ld\nnormal_fare: %f\nsubtotal: %f\ntotal_charged: %f\ntotal_owed: %f\ncurrency_code: %@\nduration: %@\ndistance: %@\ndistance_label: %@\nresponse: %@\nerror: %@", receiptResult.request_id, [receiptResult.charges count], receiptResult.surge_charge.name, receiptResult.surge_charge.amount, receiptResult.surge_charge.type, [receiptResult.charge_adjustments count], receiptResult.normal_fare, receiptResult.subtotal, receiptResult.total_charged, receiptResult.total_owed, receiptResult.currency_code, receiptResult.duration, receiptResult.distance, receiptResult.distance_label, response, error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
}

-(void)mapPressed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getMapForRequestId:_request.request_id withCompletionHandler:^(UberMap *mapResult, NSURLResponse *response, NSError *error) {
            _map = mapResult;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Map" message:[NSString stringWithFormat:@"request_id: %@\nmap href: %@", mapResult.request_id, mapResult.href] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
}

-(void)cancelPressed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] cancelRequestForId:_request.request_id withCompletionHandler:^(NSURLResponse *response, NSError *error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Cancel" message:[NSString stringWithFormat:@"Response: %ld", httpResponse.statusCode] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
}

-(void)estimatePressed
{
    CLLocation *start = [[CLLocation alloc] initWithLatitude:_bd_startLat longitude:_bd_startLon];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:_bd_destLat longitude:_bd_destLon];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getRequestEstimateWithProductId:_request.request_id andStartLocation:start endLocation:end withCompletionHandler:^(UberEstimate *estimateResult, NSURLResponse *response, NSError *error) {
            _estimate = estimateResult;
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Estimate Info" message:[NSString stringWithFormat:@"Price:\nsurge_confirmation_href: %@\n", estimateResult.price.surge_confirmation_href] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
    
}

-(void)statusPressed
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[UberKit sharedInstance] getDetailsFromRequestId:_request.request_id withCompletionHandler:^(UberRequest *requestResult, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"Uber Response" message:[NSString stringWithFormat:@"UberResponse:\nrequest_id: %@\nstatus: %@\neta: %ld\nsurge_multiplier: %f\nvehicle:\nmake: %@\nmodel: %@\nlicense_plate: %@\ndriver:\nphone_number: %@\nname: %@\nrating: %f\nlocation:\nlat: %f lon: %f bearing: %ld\nresponse: %@\nerror: %@", requestResult.request_id, requestResult.status, requestResult.eta, requestResult.surge_multiplier, requestResult.vehicle.make, requestResult.vehicle.model, requestResult.vehicle.license_plate, requestResult.driver.phone_number, requestResult.driver.name, requestResult.driver.rating, requestResult.location.latitude, requestResult.location.longitude, requestResult.location.bearing, response, error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
}

-(void)setUberAuthParams
{
    [[UberKit sharedInstance] setClientID:uClientId];
    [[UberKit sharedInstance] setClientSecret:uSecret];
    [[UberKit sharedInstance] setRedirectURL:uRedirectUrl];
    [[UberKit sharedInstance] setApplicationName:uAppName];
    [[UberKit sharedInstance] setServerToken:uServerToken];
    
    UberKit *uberKit = [UberKit sharedInstance];
    uberKit.delegate = self;
    [uberKit startLogin];
}

//-(void)setupLocationService
//{
//    if ([CLLocationManager locationServicesEnabled]) {
//        _locationManager = [[CLLocationManager alloc] init];
//        _locationManager.delegate = self;
//        _locationManager.distanceFilter = kCLDistanceFilterNone;
//        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//        [_locationManager requestAlwaysAuthorization];
//        [_locationManager startUpdatingLocation];
//    }
//}

-(void)callClientAuthenticationMethods
{
    UberKit *uberKit = [[UberKit alloc] initWithServerToken:uServerToken];
    
    CLLocation *start = [[CLLocation alloc] initWithLatitude:_bd_startLat longitude:_bd_startLon];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:_bd_destLat longitude:_bd_destLon];
    
    [uberKit getProductsForLocation:start withCompletionHandler:^(NSArray *resultsArray, NSURLResponse *response, NSError *error) {
        if(!error)
        {
            NSLog(@"Product response: %@", response);
            NSLog(@"Product count: %ld", [resultsArray count]);
            if ([resultsArray count]) {
                for (UberProduct *product in resultsArray) {
                    NSLog(@"Product description: %@\nProduct id: %@", product.product_description, product.product_id);
                    [self.products addObject:product];
                }
            }
        }
        else
        {
            NSLog(@"Error %@", error);
        }
    }];
    
    [uberKit getTimeForProductArrivalWithLocation:start withCompletionHandler:^(NSArray *times, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             NSLog(@"Time response: %@", response);
             NSLog(@"Time count: %ld", [times count]);
             if ([times count]) {
                 for (UberTime *time in times) {
                     NSLog(@"Time estimate: %f", time.estimate);
                     [self.estimatedTimes addObject:time];
                 }
             }
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
    
    [uberKit getPriceForTripWithStartLocation:start endLocation:end  withCompletionHandler:^(NSArray *prices, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             NSLog(@"Price response: %@", response);
             NSLog(@"Price count: %ld", [prices count]);
             if ([prices count]) {
                 for (UberPrice *price in prices) {
                     NSLog(@"Price low estimate: %i and Price high estimate: %i", price.lowEstimate, price.highEstimate);
                     [self.estimatedPrices addObject:price];
                 }
             }
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
    
    [uberKit getPromotionForLocation:start endLocation:end withCompletionHandler:^(UberPromotion *promotion, NSURLResponse *response, NSError *error)
     {
         if(!error)
         {
             NSLog(@"Promotion - %@", promotion.localized_value);
             self.promotion = promotion;
         }
         else
         {
             NSLog(@"Error %@", error);
         }
     }];
}

-(void)loginBtnPressed
{
    [self setUberAuthParams];
}

-(void)profileBtnPressed
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"My Profile" message:[NSString stringWithFormat:@"First name: %@\nLast name: %@\nEmail: %@\nPicture URL: %@\nUUID: %@", self.profile.first_name, self.profile.last_name, self.profile.email, self.profile.picture, self.profile.uuid] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)uberCarPressed
{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:@"access_token"];
    if (token) {
        _accessToken = token;
        [[UberKit sharedInstance] setAuthTokenWith:token];
        [self fetchUserProfile];
    }
    [self.tableView reloadData];
}

-(void)openUberApp
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"uber://"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"uber://"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://uber.com"]];
    }
}

#pragma mark - UberKitDelegate

-(void)uberKit:(UberKit *)uberKit didReceiveAccessToken:(NSString *)accessToken
{
    NSLog(@"Received access token: %@", accessToken);
    _accessToken = accessToken;
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:@"access_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self fetchUserProfile];
    [self fetchUserActivityOfVersion11];
}

-(void)uberKit:(UberKit *)uberKit loginFailedWithError:(NSError *)error
{
    NSLog(@"Failed with error: %@", error);
}

//#pragma mark - CLLocationManagerDelegate
//
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
//{
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Current Location" message:[NSString stringWithFormat:@"Latitude: %f\nLongitude: %f", [[locations lastObject] coordinate].latitude, [[locations lastObject] coordinate].longitude] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alertView show];
//    [manager stopUpdatingLocation];
//}
//
//-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
//{
//    NSLog(@"Location error: %@", error);
//}

#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[BBUberCarTableViewCell class] forCellReuseIdentifier:@"uber"];;
    BBUberCarTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uber" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UberProduct *product = _products[indexPath.section];
    UberPrice *price = _estimatedPrices[indexPath.section];
    UberTime *time = _estimatedTimes[indexPath.section];
    
    [cell.carImgView sd_setImageWithURL:[NSURL URLWithString:product.image] placeholderImage:[UIImage imageNamed:@"iconfont-uber"]];
    cell.carType.text = product.display_name;
    cell.estimatePrice.text = [NSString stringWithFormat:@"Est price: %@", price.estimate];
    cell.estimateDuration.text = [NSString stringWithFormat:@"Est time: %.2f", time.estimate];
    cell.distance.text = [NSString stringWithFormat:@"Est distance: %.2f", price.distance];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (0 == [self.products count]) {
            [[[UIAlertView alloc] initWithTitle:@"Car Unavailable" message:@"There is no available car right now, please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        UberProduct *product = [self.products objectAtIndex:indexPath.row];
        NSDictionary *parameters = @{@"product_id": product.product_id, @"start_latitude": @(39.912789), @"start_longitude": @(116.453022), @"end_latitude": @(39.914457), @"end_longitude": @(116.453791), @"surge_confirmation_id": [NSNull null]};
        
        [[UberKit sharedInstance] getResponseFromRequestWithParameters:parameters withCompletionHandler:^(UberRequest *requestResult, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _request = requestResult;
                NSLog(@"got result");
                [[[UIAlertView alloc] initWithTitle:@"Uber Response" message:[NSString stringWithFormat:@"UberResponse:\nrequest_id: %@\nstatus: %@\neta: %ld\nsurge_multiplier: %f\nvehicle:\nmake: %@\nmodel: %@\nlicense_plate: %@\ndriver:\nphone_number: %@\nname: %@\nrating: %f\nlocation:\nlat: %f lon: %f bearing: %ld\nresponse: %@\nerror: %@", requestResult.request_id, requestResult.status, requestResult.eta, requestResult.surge_multiplier, requestResult.vehicle.make, requestResult.vehicle.model, requestResult.vehicle.license_plate, requestResult.driver.phone_number, requestResult.driver.name, requestResult.driver.rating, requestResult.location.latitude, requestResult.location.longitude, requestResult.location.bearing, response, error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            });
        }];
    });
}

@end
