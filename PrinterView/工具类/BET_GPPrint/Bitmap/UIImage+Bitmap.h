//
//  UIImage+Bitmap.h
//  HLBluetoothDemo
//
//  Created by Harvey on 16/5/3.
//  Copyright © 2016年 Halley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,BitPixels) {
    BPAlpha = 0,
    BPBlue = 1,
    BPGreen = 2,
    BPRed = 3
};

typedef void (^BitmapDataBlock)(NSData * bitmapData,NSInteger xL,NSInteger xH,NSInteger yL,NSInteger yH);

@interface UIImage (Bitmap)

//将图片直接转为特定尺寸的点阵图
//并以Data的形式返回
//若输入的长宽比与原图不同，则可能造成图片的拉伸或压缩
//-(NSData *)bitmapDataWithWidth:(NSInteger)width Height:(NSInteger)height;
-(void)bitmapDataWithWidth:(NSInteger)width Height:(NSInteger)height BitmapDataBlock:(BitmapDataBlock)bitmapdataBlock;

//将图片转为特定尺寸
//以UIImage的形式返回
//若输入的长宽比与原图不同，则可能造成图片的拉伸或压缩
-(UIImage*)scaleImageWithWidth:(NSInteger)width Height:(NSInteger)height;


-(NSInteger)getImagexL;


-(NSInteger)getImagexH;


-(NSInteger)getImageyL;


-(NSInteger)getImageyH;

@end
