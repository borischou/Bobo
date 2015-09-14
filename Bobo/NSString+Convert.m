//
//  NSString+UrlConvert.m
//  Bobo
//
//  Created by Zhouboli on 15/6/28.
//  Copyright (c) 2015年 Zhouboli. All rights reserved.
//

#import "NSString+Convert.h"
#import "UIColor+Custom.h"
#import <UIKit/UIKit.h>
#import "Utils.h"

#define bTextFontSize 14.0
#define markColor [UIColor colorWithRed:105.0/255 green:90.0/255 blue:205.0/255 alpha:1.0]

@implementation NSString (Convert)

+(NSString *)largePictureUrlConvertedFromThumbUrl:(NSString *)url
{
    return [url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"large"];
}

+(NSString *)middlePictureUrlConvertedFromThumbUrl:(NSString *)url
{
    return [url stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
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

+(NSString *)trim:(NSString *)source
{
    NSString *text = nil;
    
    NSScanner *scanner = [NSScanner scannerWithString:source];
    while (scanner.isAtEnd == NO) {
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&text];
        source = [source stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>", text] withString:@""];
    }
    
    NSString *regEx = @"<([^>]*)>";
    source = [source stringByReplacingOccurrencesOfString:regEx withString:@""];
    
    return source;
}

+(NSAttributedString *)markedText:(NSString *)text fontSize:(CGFloat)fontSize fontColor:(UIColor *)color
{
    NSString *pattern = @"(@([\\w-]+[\\w-]*))|((https?://((\\w)+).((\\w)+))+/(\\w)+)|(#[^#]+#)";
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:2.0];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    NSDictionary *genericAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:fontSize],
                                        NSForegroundColorAttributeName: color,
                                        NSParagraphStyleAttributeName: paragraphStyle};
    [attributedString setAttributes:genericAttributes range:NSMakeRange(0, text.length)];
    
    NSDictionary *markAttributes = @{NSForegroundColorAttributeName: markColor};
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    [regex enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        NSLog(@"%@\n", [text substringWithRange:result.range]);
        [attributedString addAttributes:markAttributes range:result.range];
    }];
    
    return attributedString.copy;
}

@end
