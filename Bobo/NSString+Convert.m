//
//  NSString+UrlConvert.m
//  Bobo
//
//  Created by Zhouboli on 15/6/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "NSString+Convert.h"

@implementation NSString (Convert)

+(NSString *)largePictureUrlConvertedFromThumbUrl:(NSString *)url
{
    return [url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
}

+(NSString *)getNumStrFrom:(NSInteger)num
{
    NSString *numStr;
    if (num > 0 && num < 1000) {
        numStr = [NSString stringWithFormat:@"%ld", num];
    }
    if (num > 999 && num < 10000) {
        numStr = [NSString stringWithFormat:@"%dk", (int)num/1000];
    }
    if (num > 9999 && num < 10000 * 100) {
        numStr = [NSString stringWithFormat:@"%.1fw", (float)num/10000];
    }
    if (num >= 10000 * 100) {
        numStr = [NSString stringWithFormat:@"%dm", (int)num/10000*100];
    }
    return numStr;
}

@end
