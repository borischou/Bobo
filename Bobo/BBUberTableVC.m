//
//  BBUberTableVC.m
//  Bobo
//
//  Created by Zhouboli on 15/6/25.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UberKit.h>

#import "BBUberTableVC.h"
#import "UberRequest.h"

#define bBGColor [UIColor colorWithRed:0 green:128.f/255 blue:128.0/255 alpha:1.f]

#define uClientId @"STJy0P2hQ9zHmB4riaPdztaMNB05keCI"
#define uServerToken @"RCtJKHWI1lZGNGrXxPQLyQ6hY1YlpmPSb7jvwrA_"
#define uSecret @"9npu802FdBxpd9BtFYcGy6621FxMTzFWUM_FXZUc"
#define uAppName @"bober"

#define uAuthUrl @"https://login.uber.com/oauth/authorize"
#define uAccessTokenUrl @"https://login.uber.com/oauth/token"
#define uRedirectUrl @"bobo://oauth/callback" //redirect back to Bobo iOS app from Safari website

@interface BBUberTableVC () <UberKitDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSMutableArray *estimatedPrices;
@property (strong, nonatomic) NSMutableArray *estimatedTimes;
@property (strong, nonatomic) NSArray *activities;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) UberPromotion *promotion;
@property (strong, nonatomic) UberProfile *profile;

@end

@implementation BBUberTableVC

@synthesize locationManager;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = bBGColor;
    [self setNavBarBtn];
    
    [self setupLocationService];
    [self callClientAuthenticationMethods];
    self.tableView.rowHeight = 240;
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
    
    UIBarButtonItem *rightItem_2 = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStylePlain target:self action:@selector(loginBtnPressed)];
    
    UIBarButtonItem *rightItem_3 = [[UIBarButtonItem alloc] initWithTitle:@"Uber Cars" style:UIBarButtonItemStylePlain target:self action:@selector(uberCarPressed)];
    
    //self.navigationItem.leftBarButtonItems = @[leftItem, leftItem_second];
    
    UIBarButtonItem *rightItem_0 = [[UIBarButtonItem alloc] initWithTitle:@"Profile" style:UIBarButtonItemStylePlain target:self action:@selector(profileBtnPressed)];
    
    UIBarButtonItem *rightItem_1 = [[UIBarButtonItem alloc] initWithTitle:@"Open Uber" style:UIBarButtonItemStylePlain target:self action:@selector(openUberApp)];
    
    self.navigationItem.rightBarButtonItems = @[rightItem_0, rightItem_1, rightItem_2, rightItem_3];
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

-(void)setupLocationService
{
    if ([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager requestAlwaysAuthorization];
        [locationManager startUpdatingLocation];
    }
}

-(void)callClientAuthenticationMethods
{
    UberKit *uberKit = [[UberKit alloc] initWithServerToken:uServerToken];
    CGFloat sLatitude = 39.912789, sLongitude = 116.453022;
    CGFloat eLatitude = 39.914457, eLongitude = 116.453791;
    CLLocation *start = [[CLLocation alloc] initWithLatitude:sLatitude longitude:sLongitude];
    CLLocation *end = [[CLLocation alloc] initWithLatitude:eLatitude longitude:eLongitude];
    
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

#pragma mark - CLLocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Current Location" message:[NSString stringWithFormat:@"Latitude: %f\nLongitude: %f", [[locations lastObject] coordinate].latitude, [[locations lastObject] coordinate].longitude] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [manager stopUpdatingLocation];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location error: %@", error);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.estimatedPrices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"uber"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"uber" forIndexPath:indexPath];
    cell.contentView.backgroundColor = bBGColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.numberOfLines = 20;
    cell.textLabel.font = [UIFont systemFontOfSize:12.f];
    cell.textLabel.backgroundColor = bBGColor;
    cell.textLabel.textColor = [UIColor whiteColor];

    if (4 == [self.products count] && 4 == [self.estimatedPrices count] && 4 == [self.estimatedTimes count]) {
        UberProduct *product = [self.products objectAtIndex:indexPath.row];
        UberPrice *price  = [self.estimatedPrices objectAtIndex:indexPath.row];
        UberTime *time = [self.estimatedTimes objectAtIndex:indexPath.row];
        cell.textLabel.text = [NSString stringWithFormat:@"Promotion:\ntext: %@ localized_value: %@ type: %@\n\nProduct:\nproduct_id: %@\nproduct_description: %@ display_name: %@ capacity: %i image\n\nPrice:\ncurrencyCode: %@ estimate: %@\nlowEstimate: %i highEstimate: %i\nsurgeMultiplier: %f duration: %i distance: %f\n\nTime:\nestimate: %f", self.promotion.text, self.promotion.localized_value, self.promotion.type, product.product_id, product.product_description, product.display_name, product.capacity, price.currencyCode, price.estimate, price.lowEstimate, price.highEstimate, price.surgeMultiplier, price.duration, price.distance, time.estimate];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UberProduct *product = [self.products objectAtIndex:indexPath.row];
        UberRequest *request = [[UberRequest alloc] init];
        request.parameters = @{@"product_id": product.product_id, @"start_latitude": @(39.912789), @"start_longitude": @(116.453022), @"end_latitude": @(39.914457), @"end_longitude": @(116.453791), @"surge_confirmation_id": [NSNull null]};
        request.accessToken = _accessToken;
        [request getResponseFromRequestWithCompletionHandler:^(NSDictionary *uberResponse, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Uber Response" message:[NSString stringWithFormat:@"UberResponse:\nrequest_id: %@\nstatus: %@\neta: %ld\nsurge_multiplier: %f\nvehicle: %@\ndriver: %@\nlocation: %@\nresponse: %@\nerror: %@", uberResponse[@"request_id"], uberResponse[@"status"], [uberResponse[@"eta"] integerValue], [uberResponse[@"surge_multiplier"] floatValue], uberResponse[@"vehicle"], uberResponse[@"driver"], uberResponse[@"location"], response, error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
            });
        }];
    });
}

@end
