//
//  AlertCenter.m
//  Uni-Design
//
//  Created by admin on 16/10/20.
//  Copyright © 2016年  Nick. All rights reserved.
//

#import "AlertCenter.h"

@interface AlertCenter()


@end

@implementation AlertCenter



+(void)ShowAlertWithController:(UIViewController *)vc andTitle:(NSString *)title andMessage:(NSString *)message andCancelTitle:(NSString *)canceltitle andCancelActionBlock:(CancelactionBlock)cancelblock andOtherTitle:(NSString *)othertitle andActionBlock:(ActionBlock)block
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (canceltitle !=nil) {
        UIAlertAction * Cancel = [UIAlertAction actionWithTitle:canceltitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelblock)
            {
                cancelblock();
            }
        }];
        [alert addAction:Cancel];
    }
    
    if (othertitle !=nil) {
        
        UIAlertAction * action = [UIAlertAction actionWithTitle:othertitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (block) {
                block();
            }
        }];
        [alert addAction:action];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alert animated:YES completion:nil];
    });
}


+(void)ShowHaveCancelAlertWithController:(UIViewController *)vc
                                andTitle:(NSString *)title
                              andMessage:(NSString *)message
                       andOneActionTitle:(NSString *)oneactiontitle
                       andOneActionBlock:(CancelactionBlock)oneactionblock
                       andTwoActionTitle:(NSString *)twoactiontitle
                       andTwoActionBlock:(CancelactionBlock)twoactionblock
                    andCancelActionTitle:(NSString *)cancelactiontitle
                    andCancelActionBlock:(ActionBlock)cancelactionblock
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    if (oneactiontitle !=nil)
    {
        UIAlertAction * one = [UIAlertAction actionWithTitle:oneactiontitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (oneactionblock) {
                oneactionblock();
            }
        }];
        [alert addAction:one];
    }
    
    if (twoactiontitle !=nil) {
        UIAlertAction * two = [UIAlertAction actionWithTitle:twoactiontitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (twoactionblock) {
                twoactionblock();
            }
        }];
        [alert addAction:two];
    }
    
    if (cancelactiontitle !=nil) {
        
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:cancelactiontitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (cancelactionblock) {
                cancelactionblock();
            }
        }];
        [alert addAction:cancel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc presentViewController:alert animated:YES completion:nil];
    });
}


@end


