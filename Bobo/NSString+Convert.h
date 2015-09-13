//
//  NSString+UrlConvert.h
//  Bobo
//
//  Created by Zhouboli on 15/6/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Convert)

+(NSString *)largePictureUrlConvertedFromThumbUrl:(NSString *)url;
+(NSString *)middlePictureUrlConvertedFromThumbUrl:(NSString *)url;
+(NSString *)getNumStrFrom:(NSInteger)num;
+(NSString *)trim:(NSString *)source;
+(NSAttributedString *)markedText:(NSString *)text fontSize:(CGFloat)fontSize;

@end
