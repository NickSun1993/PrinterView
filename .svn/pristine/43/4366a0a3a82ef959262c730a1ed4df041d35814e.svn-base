//
//  myOvalView.m
//  Gprinter
//
//  Created by  Nick on 2018/3/6.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "myOvalView.h"

@implementation myOvalView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
    
        self.backgroundColor = [UIColor clearColor];
        
    }
    
    return self;
}


-(void)drawRect:(CGRect)rect
{
    //获取当前的上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect aRect= CGRectMake(5,5, rect.size.width-10, rect.size.height-10);
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0);
    
    CGContextSetLineWidth(context, _lineWidth);
    
    CGContextAddEllipseInRect(context, aRect); //椭圆
    
    CGContextDrawPath(context, kCGPathStroke);
    
}

@end
