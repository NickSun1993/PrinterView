//
//  PrinterViewController.h
//  PrinterView
//
//  Created by  Nick on 2018/10/18.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrinterViewController : UIViewController

//App进入后台时保存/退出画板编辑界面，保存当前画板的内容
-(void)saveChangesToPlistWhenAppToBacgroundOrEndEditing;

//重置画板，清屏，删除当前画板所有内容
-(void)toResetMyCurrentPlist;

//获取当前画板内容，并生成图片
- (UIImage *)PreViewMakeImageWithMyPrinterView;

//选取模板，将模板内容在画板呈现
-(void)RefreshPrinterViewWithNewPlist;

@end
