//
//  barCodePaopaoView.h
//  PrinterView
//
//  Created by  Nick on 2018/10/19.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectBarcodeKindFinishTheOption)(NSInteger index);

@interface barCodePaopaoView : UIViewController

@property(nonatomic,copy)SelectBarcodeKindFinishTheOption cb;

@end
