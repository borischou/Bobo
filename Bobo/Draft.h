//
//  Draft.h
//  Bobo
//
//  Created by Zhouboli on 15/10/16.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DraftType) {
    DraftTypeOriginal,
    DraftTypeRepost,
    DraftTypeReply,
    DraftTypeComment
};

@interface Draft : NSObject

@property (strong, nonatomic) NSArray *images; //发送微博时的图片(NSData)
@property (strong, nonatomic) NSDictionary *params; //发送所需参数
@property (copy, nonatomic) NSString *text; //草稿文字
@property (copy, nonatomic) NSString *time; //草稿撰写时间
@property (copy, nonatomic) NSString *url; //发送目标的url
@property (nonatomic) NSInteger draftType; //草稿类型
@property (nonatomic) float height; //提前计算好所需的cell高度

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;
-(NSDictionary *)convertToDictionary;

@end
