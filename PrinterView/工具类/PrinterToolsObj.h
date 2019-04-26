//
//  PrinterToolsObj.h
//  PrinterView
//
//  Created by  Nick on 2018/10/19.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PrinterToolsObj : NSObject

+(CGSize)getMyLabelFont:(NSString *)currentString andFontSize:(NSInteger)currentFontSize andText:(NSString *)inputString;

+(NSString *)GetMyCachePath;

+(void)toCreatePlistPath;

//动态计算高宽
+(CGSize)getMyLabelSize:(NSString *)inputString;

+(CGSize)GetLabelSize:(NSString *)inputString andFont:(UIFont *)font;


@end
