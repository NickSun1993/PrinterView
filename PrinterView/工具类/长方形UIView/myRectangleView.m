//
//  myRectangleView.m
//  Gprinter
//
//  Created by  Nick on 2018/3/5.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "myRectangleView.h"

@implementation myRectangleView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{

    //将rect添加到图形上下文中
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextAddRect(context, CGRectMake(8, 8, self.bounds.size.width-16, self.bounds.size.height-16));
    //设定颜色
    [[UIColor clearColor] setFill];
    [[UIColor blackColor] setStroke];
    CGContextSetLineWidth(context, _lineWidth);
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

@end
