//
//  SelectFontViewController.h
//  Gprinter
//
//  Created by  Nick on 2018/3/6.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^SelectFontFinished)(NSString *fontName);

@interface SelectFontViewController : UIViewController

@property(nonatomic,copy)SelectFontFinished cb;

@end
