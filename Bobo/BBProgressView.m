//
//  BBProgressView.m
//  Bobo
//
//  Created by Zhouboli on 15/10/28.
//  Copyright © 2015年 Zhouboli. All rights reserved.
//

#import "BBProgressView.h"
#import "UIColor+Custom.h"

@implementation BBProgressView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        _percent = 0.0;
        _width = 0.0;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    [self addArcBackColor];
    [self drawArc];
    [self addCenterBack];
    //[self addCenterLabel];
}

-(void)setPercent:(float)percent
{
    _percent = percent;
    [self setNeedsDisplay];
}

//先绘制大圆饼
-(void)addArcBackColor
{
    CGColorRef color = (_arcBackColor == nil)? [UIColor lightTextColor].CGColor: _arcBackColor.CGColor;
    
    //拿到绘图上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    //确定绘图所在view的大小
    CGSize viewSize = self.bounds.size;
    
    //确定view的中心坐标
    CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
    
    // Draw the slices.
    
    //确定圆形的半径
    CGFloat radius = viewSize.width / 2;
    
    //新建绘图轨迹
    CGContextBeginPath(contextRef);
    
    //确定轨迹起始坐标
    CGContextMoveToPoint(contextRef, center.x, center.y);
    
    //按API描绘轨迹（按照弧形API则以轨迹起始坐标为中心绘制一个圆形区域）
    CGContextAddArc(contextRef, center.x, center.y, radius,0,2*M_PI, 0);
    
    //给轨迹上色
    CGContextSetFillColorWithColor(contextRef, color);
    
    //执行轨迹描绘
    CGContextFillPath(contextRef);
}

- (void)drawArc
{
    if (_percent == 0 || _percent > 1)
    {
        return;
    }
    
    if (_percent == 1)
    {
        //准备好颜色
        CGColorRef color = (_arcFinishColor == nil)? [UIColor blueColor].CGColor: _arcFinishColor.CGColor;
        
        //先拿到绘图上下文
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
        //确定view的大小
        CGSize viewSize = self.bounds.size;
        
        //确定view的中心坐标
        CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
        
        // Draw the slices.
        
        //确定圆形的半径
        CGFloat radius = viewSize.width / 2;
        
        //在绘图区域新建绘图轨迹
        CGContextBeginPath(contextRef);
        
        //确定轨迹初始坐标
        CGContextMoveToPoint(contextRef, center.x, center.y);
        
        //按API进行轨迹描绘
        CGContextAddArc(contextRef, center.x, center.y, radius, 0, 2*M_PI, 0);
        
        //对轨迹上色
        CGContextSetFillColorWithColor(contextRef, color);
        
        //执行绘制轨迹
        CGContextFillPath(contextRef);
    }
    else
    {
        //确定完成角度
        float endAngle = 2*M_PI*_percent;
        
        //确定轨迹颜色
        CGColorRef color = (_arcUnfinishColor == nil) ? [UIColor seaGreen].CGColor : _arcUnfinishColor.CGColor;
        
        //拿到当前绘图上下文
        CGContextRef contextRef = UIGraphicsGetCurrentContext();
        
        //确定绘图所在view的大小
        CGSize viewSize = self.bounds.size;
        
        //确定view的中心坐标
        CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
        
        // Draw the slices.
        
        //确定所需绘制的圆形半径
        CGFloat radius = viewSize.width / 2;
        
        //新建绘图轨迹
        CGContextBeginPath(contextRef);
        
        //确定轨迹起始坐标
        CGContextMoveToPoint(contextRef, center.x, center.y);
        
        //按API进行轨迹描绘
        CGContextAddArc(contextRef, center.x, center.y, radius, 0, endAngle, 0);
        
        //给轨迹上色
        CGContextSetFillColorWithColor(contextRef, color);
        
        //执行轨迹绘制
        CGContextFillPath(contextRef);
    }
}

//绘制小圆饼
-(void)addCenterBack
{
    //确定小圆饼的直径
    float width = (_width == 0)? 5: _width;
    
    //准备好颜色
    CGColorRef color = (_centerColor == nil) ? [UIColor blackColor].CGColor : _centerColor.CGColor;
    
    //拿到当前绘图上下文（画布）
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    //确定绘图所在view的大小
    CGSize viewSize = self.bounds.size;
    
    //确定view的中心坐标
    CGPoint center = CGPointMake(viewSize.width / 2, viewSize.height / 2);
    
    // Draw the slices.
    
    //确定小圆饼的半径
    CGFloat radius = viewSize.width / 2 - width;
    
    //在画布（绘图上下文）上新建绘图轨迹
    CGContextBeginPath(contextRef);
    
    //确定轨迹起始坐标
    CGContextMoveToPoint(contextRef, center.x, center.y);
    
    //按API进行轨迹描绘
    CGContextAddArc(contextRef, center.x, center.y, radius,0,2*M_PI, 0);
    
    //给轨迹上色
    CGContextSetFillColorWithColor(contextRef, color);
    
    //执行绘图
    CGContextFillPath(contextRef);
}

//- (void)addCenterLabel
//{
//    NSString *percent = @"";
//    
//    float fontSize = 14;
//    UIColor *arcColor = [UIColor blueColor];
//    if (_percent == 1)
//    {
//        percent = @"100%";
//        fontSize = 14;
//        arcColor = (_arcFinishColor == nil) ? [UIColor greenColor] : _arcFinishColor;
//        
//    }
//    else if (_percent < 1 && _percent >= 0)
//    {
//        fontSize = 13;
//        arcColor = (_arcUnfinishColor == nil) ? [UIColor blueColor] : _arcUnfinishColor;
//        percent = [NSString stringWithFormat:@"%f",_percent*100];
//    }
//    
//    CGSize viewSize = self.bounds.size;
//    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
//    paragraph.alignment = NSTextAlignmentCenter;
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:fontSize],NSFontAttributeName,arcColor,NSForegroundColorAttributeName, [UIColor clearColor], NSBackgroundColorAttributeName,paragraph,NSParagraphStyleAttributeName,nil];
//    
//    [percent drawInRect:CGRectMake(5, (viewSize.height-fontSize)/2, viewSize.width-10, fontSize)withAttributes:attributes];
//}

@end
