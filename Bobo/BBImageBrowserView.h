//
//  BBImageBrowserView.h
//  Bobo
//
//  Created by Zhouboli on 15/6/25.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBImageBrowserView : UIView

-(instancetype)initWithFrame:(CGRect)frame withImageUrls:(NSMutableArray *)urls andImageTag:(NSInteger)tag;

@end
