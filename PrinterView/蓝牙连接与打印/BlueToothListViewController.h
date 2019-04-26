//
//  BlueToothListViewController.h
//  PrinterView
//
//  Created by  Nick on 2018/10/26.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ConnectSuccessBlock)(NSMutableArray *servicesArray);

@interface BlueToothListViewController : UIViewController

@property(nonatomic,copy)ConnectSuccessBlock cb;

@end
