//
//  shapePaopaoView.h
//  PrinterView
//
//  Created by  Nick on 2018/10/22.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectShapeKindFinishTheOption)(NSInteger index);

@interface shapePaopaoView : UIViewController

@property(nonatomic,copy)SelectShapeKindFinishTheOption cb;

@end
