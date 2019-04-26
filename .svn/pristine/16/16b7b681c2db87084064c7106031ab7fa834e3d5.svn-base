//
//  AlertCenter.h
//  Uni-Design
//
//  Created by admin on 16/10/20.
//  Copyright © 2016年  Nick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ActionBlock)();
typedef void(^CancelactionBlock)();
@interface AlertCenter : NSObject




+(void)ShowAlertWithController:(UIViewController *)vc andTitle:(NSString *)title andMessage:(NSString *)message andCancelTitle:(NSString *)canceltitle andCancelActionBlock:(CancelactionBlock)cancelblock andOtherTitle:(NSString *)othertitle andActionBlock:(ActionBlock)block;


+(void)ShowHaveCancelAlertWithController:(UIViewController *)vc
                                andTitle:(NSString *)title
                              andMessage:(NSString *)message
                       andOneActionTitle:(NSString *)oneactiontitle
                       andOneActionBlock:(CancelactionBlock)oneactionblock
                       andTwoActionTitle:(NSString *)twoactiontitle
                       andTwoActionBlock:(CancelactionBlock)twoactionblock
                    andCancelActionTitle:(NSString *)cancelactiontitle
                    andCancelActionBlock:(ActionBlock)cancelactionblock;
@end
