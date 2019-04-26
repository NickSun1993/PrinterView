//
//  QRCodeViewController.h
//  Gprinter
//
//  Created by 孙锟 on 2018/3/1.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^CreateQRcodeFinishTheOption)(NSMutableDictionary *dic);
@interface QRCodeViewController : UIViewController

@property(nonatomic,copy)CreateQRcodeFinishTheOption cb;
@end
