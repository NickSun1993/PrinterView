//
//  GPPrintModule.h
//  WWTBluetoothPrinting
//
//  Created by admin on 2018/10/26.
//  Copyright © 2018年 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GPPrintModule : NSObject

+(NSData *)GetPrintDataFromBitmapData:(NSData *)bitmapdata xL:(NSInteger)xl xH:(NSInteger)xh yL:(NSInteger)yl yH:(NSInteger)yh;

@end
