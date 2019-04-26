//
//  PrinterToolsObj.m
//  PrinterView
//
//  Created by  Nick on 2018/10/19.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import "PrinterToolsObj.h"

@implementation PrinterToolsObj

+(CGSize)getMyLabelFont:(NSString *)currentString andFontSize:(NSInteger)currentFontSize andText:(NSString *)inputString
{
    
    CGSize strSize=CGSizeMake(WIDTH-16,500);
    
    //需跟lable字体大小一直，否则会显示不全等问题
    NSDictionary *attr = @{NSFontAttributeName:[UIFont fontWithName:currentString size:currentFontSize]};
    
    CGSize titleSize=[inputString boundingRectWithSize:strSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    return titleSize;
    
}


+(NSString *)GetMyCachePath
{

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
    
}

+(void)toCreatePlistPath
{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建目录
    /**
     *  第一个参数: 目录路径
     *  第二个参数:是否创建中间目录
     *  第三个参数: 文件属性
     *  第四个参数: 出错处理
     */
    BOOL isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath]];
    if (isExist)
    {
        NSLog(@"目录已经存在");
    }
    else
    {
        NSError *myError = nil;
        BOOL ret = [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath] withIntermediateDirectories:YES attributes:nil error:&myError];
        if (ret)
        {
            NSLog(@"NSHomeDirectory = %@",NSHomeDirectory());
            
            NSLog(@"目录创建成功");
            
        }
        else
        {
            NSLog(@"Error = %@",myError);
            
            NSLog(@"目录创建失败");
        }
    }
    
}

//动态计算高宽

+(CGSize)GetLabelSize:(NSString *)inputString andFont:(UIFont *)font
{
    CGSize strSize=CGSizeMake(WIDTH-16,500);
    
  //需跟lable字体大小一直，否则会显示不全等问题
    NSDictionary *attr = @{NSFontAttributeName:font};
    
    CGSize titleSize=[inputString boundingRectWithSize:strSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;

    return titleSize;

}

+(CGSize)getMyLabelSize:(NSString *)inputString
{
    BOOL isHeavy = [USERDEFAULT boolForKey:@"IsTextHeavy"];
    
    NSString *currentString;
    
    if (isHeavy)
    {
        currentString = [USERDEFAULT stringForKey:@"CurrentHeavyFont"];
    }
    else
    {
        currentString = [USERDEFAULT stringForKey:@"CurrentNormalFont"];
    
    }
    
    NSInteger currentFontSize = [USERDEFAULT integerForKey:@"CurrentFontSize"];
    CGSize strSize=CGSizeMake(WIDTH-16,500);
    //需跟lable字体大小一直，否则会显示不全等问题
    NSDictionary *attr = @{NSFontAttributeName:[UIFont fontWithName:currentString size:currentFontSize]};
    
    CGSize titleSize=[inputString boundingRectWithSize:strSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    
    return titleSize;
  
}

@end
