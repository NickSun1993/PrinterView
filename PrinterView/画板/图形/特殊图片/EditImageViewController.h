//
//  EditImageViewController.h
//  Gprinter
//
//  Created by  Nick on 2018/2/23.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SelectImageFinishTheOption)(UIImage *image);

@interface EditImageViewController : UIViewController

@property(nonatomic,copy)SelectImageFinishTheOption cb;

@end
