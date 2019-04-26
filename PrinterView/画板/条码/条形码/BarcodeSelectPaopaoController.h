//
//  BarcodeSelectPaopaoController.h
//  Gprinter
//
//  Created by  Nick on 2018/2/23.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectBarcodeFinishTheOption)(NSInteger index);
@interface BarcodeSelectPaopaoController : UIViewController
@property(nonatomic,copy)SelectBarcodeFinishTheOption cb;

@end
