//
//  FormBoardViewController.h
//  Gprinter
//
//  Created by 孙锟 on 2018/1/21.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormBoardViewController : UIViewController

@property(nonatomic,assign)BOOL isReadCaches;

@property(nonatomic,strong)NSMutableArray *dataArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
