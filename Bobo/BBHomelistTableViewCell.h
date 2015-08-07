//
//  BBHomelistTableViewCell.h
//  Bobo
//
//  Created by Zhouboli on 15/6/12.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "StatusModel.h"
#import "Status.h"

@protocol BBImageBrowserProtocol <NSObject>

@required
-(void)setImageBrowserWithImageUrls:(NSMutableArray *)urls andTappedViewTag:(NSInteger)tag;

@end

@interface BBHomelistTableViewCell : UITableViewCell

@property (weak, nonatomic) id <BBImageBrowserProtocol> delegate;

@property (nonatomic) CGFloat height;
@property (strong, nonatomic) Status *status;

//status
@property (strong, nonatomic) UILabel *postBodyLbl;
@property (strong, nonatomic) UILabel *nicknameLbl;
@property (strong, nonatomic) UILabel *postTimeLbl;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) NSMutableArray *statusImgViews;

//repost status
@property (strong, nonatomic) UIView *repostView;
@property (strong, nonatomic) UILabel *repostLbl;
@property (strong, nonatomic) NSMutableArray *imgViews;

@end
