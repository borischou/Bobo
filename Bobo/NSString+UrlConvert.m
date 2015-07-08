//
//  NSString+UrlConvert.m
//  Bobo
//
//  Created by Zhouboli on 15/6/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "NSString+UrlConvert.h"

@implementation NSString (UrlConvert)

+(NSString *)largePictureUrlConvertedFromThumbUrl:(NSString *)url
{
    return [url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
}

@end
