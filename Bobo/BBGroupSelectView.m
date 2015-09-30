//
//  BBGroupSelectView.m
//  Bobo
//
//  Created by Zhouboli on 15/9/30.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBGroupSelectView.h"
#import "AppDelegate.h"
#import "UIColor+Custom.h"

#define bWidth [UIScreen mainScreen].bounds.size.width
#define bHeight [UIScreen mainScreen].bounds.size.height

#define statusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height

@interface BBGroupSelectView () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) UIView *mask;

@end

@implementation BBGroupSelectView

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.alpha = 1.0;
        self.layer.cornerRadius = 8.0;
        [self setFrame:CGRectMake(50, -bHeight/2, bWidth*0.6, bHeight/2)];
        [self initSubViews];
    }
    return self;
}

-(void)initMaskView
{
    if (!_mask) {
        _mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0;
        [_mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped)]];
        
        AppDelegate *delegate = [AppDelegate delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _mask.alpha = 0.5;
        } completion:^(BOOL finished) {}];
    }
}

-(void)initSubViews
{
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.layer.cornerRadius = 8.0;
    _tableView.backgroundColor = [UIColor seaGreen];
    [self addSubview:_tableView];
}

-(void)layoutSubviews
{
    if (!_mask) {
        _mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bWidth, bHeight)];
        _mask.backgroundColor = [UIColor blackColor];
        _mask.alpha = 0.0;
        [_mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewTapped)]];
        
        AppDelegate *delegate = [AppDelegate delegate];
        [delegate.window addSubview:_mask];
        [delegate.window bringSubviewToFront:self];
        
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [_mask setAlpha:0.5];
        } completion:^(BOOL finished) {}];
    }
}

#pragma mark - Actions

-(void)maskViewTapped
{
    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.frame = CGRectMake(50, -bHeight/2, bWidth*0.6, bHeight/2);
        if (_mask) {
            _mask.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if (finished) {
            if (_mask) {
                [_mask removeFromSuperview];
                _mask = nil;
            }
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - UITableViewDataSource & Delegate & Support

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _groups.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor seaGreen];
    [cell.textLabel setTextColor:[UIColor customGray]];
    if (_groups) {
        [cell.textLabel setText:[_groups objectAtIndex:indexPath.row]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate groupView:self didSelectGroupAtIndexPath:indexPath];
}

@end
