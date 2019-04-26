//
//  NickPaintView.h
//  PrinterView
//
//  Created by  Nick on 2018/11/8.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NickPaintView : UIView

@property(nonatomic,assign)CGFloat lineWidth;

@property (nonatomic, strong) UIColor *lineColor;

//清屏
- (void)clear;

//回退
- (void) back;

//橡皮擦
- (void) eraser;

@end
