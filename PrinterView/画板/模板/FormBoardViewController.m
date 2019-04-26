//
//  FormBoardViewController.m
//  Gprinter
//
//  Created by 孙锟 on 2018/1/21.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "FormBoardViewController.h"


#import "AppDelegate.h"


@interface FormBoardViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *cachesView;
@property (weak, nonatomic) IBOutlet UIView *downloadingView;
@property (weak, nonatomic) IBOutlet UIImageView *cachesImageview;
@property (weak, nonatomic) IBOutlet UIImageView *downloadingImageView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *myActivityView;

@end

@implementation FormBoardViewController

-(NSMutableArray *)dataArray
{
    if (!_dataArray)
    {
    
        _dataArray = [[NSMutableArray alloc]init];
    
    }
 
    return _dataArray;
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    if (_isReadCaches)
    {
        
         [self CachesTap];
        
        _downloadingView.hidden = YES;
    
    }
    else
    {
    
        [self CachesTap];
        
        UITapGestureRecognizer *tapCaches = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CachesTap)];
        
        [_cachesView addGestureRecognizer:tapCaches];
        
        UITapGestureRecognizer *tapDownloading = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(DownloadingTap)];

        [_downloadingView addGestureRecognizer:tapDownloading];
        
    }

}
-(void)CachesTap
{
    [self.dataArray removeAllObjects];
    

    _downloadingImageView.hidden = YES;
  
    _cachesImageview.hidden = NO;
  
     NSString *path = [NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath];
    
    // 要列出来的目录
    
    NSFileManager *myFileManager=[NSFileManager defaultManager];
    
    NSDirectoryEnumerator *myDirectoryEnumerator;
    
    myDirectoryEnumerator=[myFileManager enumeratorAtPath:path];
    
    //列举目录内容，可以遍历子目录
    
    NSLog(@"用enumeratorAtPath:显示目录%@的内容：",path);
    
    while((path=[myDirectoryEnumerator nextObject])!=nil)
    {
        
        [self.dataArray addObject:path];
        
    }
    
    [_tableView reloadData];
    
}

-(void)DownloadingTap
{
   
    [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示！" andMessage:@"该功能还未开放哦！敬请期待" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];

}



-(void)hideActivityAction
{
    
    [_myActivityView stopAnimating];
    
}

-(void)downLoadingPlistFromFTP
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

  return self.dataArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (WIDTH<375) {
        
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        [cell.textLabel adjustsFontSizeToFitWidth];
    }
   
    
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
    }
    
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 60)];
    
    selectView.backgroundColor = [UIColor colorWithRed:90/255.0 green:174/255.0 blue:204/255.0 alpha:1];
    
    cell.selectedBackgroundView = selectView;

    UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
    
    longPressGesture.minimumPressDuration=1.5f;//设置长按 时间
    
    [cell addGestureRecognizer:longPressGesture];
    
    NSString *Name = self.dataArray[indexPath.row];
    
    NSArray *array = [Name componentsSeparatedByString:@"."];

    cell.textLabel.text = [array firstObject];
    
    cell.textLabel.textColor = [UIColor darkTextColor];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

-(void)cellLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    
    
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        //成为第一响应者，需重写该方法
        [self becomeFirstResponder];
        
        CGPoint location = [longRecognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        //可以得到此时你点击的哪一行
        //在此添加你想要完成的功能
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            
    
            [AlertCenter ShowAlertWithController:self andTitle:@"删除保存的内容" andMessage:@"您确定要删除该模板吗？" andCancelTitle:@"取消" andCancelActionBlock:nil andOtherTitle:@"确定" andActionBlock:^{
                
                NSFileManager* fileManager=[NSFileManager defaultManager];
                
                NSString *name = self.dataArray[indexPath.row];
                
                NSString *path = [NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath];
                
                NSString *plistPath = [path stringByAppendingPathComponent:name];
                
                if ([fileManager removeItemAtPath:plistPath error:nil]) {
                    
                    [self CachesTap];
                    
                }
           
            }];
            
        }];
        
        UIAlertAction *readAction = [UIAlertAction actionWithTitle:@"发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSFileManager* fileManager=[NSFileManager defaultManager];
            NSString *name = self.dataArray[indexPath.row];
            
            NSString *path = [NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath];
            
            NSString *plistPath = [path stringByAppendingPathComponent:name];
            
            NSData *fileData = [fileManager contentsAtPath:plistPath];
            
            //在这里呢 如果想分享图片 就把图片添加进去  文字什么的通上
            NSArray *activityItems = @[fileData];
            UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
            //不出现在活动项目
            activityVC.excludedActivityTypes = @[UIActivityTypePrint, UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll];
            [self presentViewController:activityVC animated:YES completion:nil];
            // 分享之后的回调
            activityVC.completionWithItemsHandler = ^(UIActivityType  _Nullable activityType, BOOL completed, NSArray * _Nullable returnedItems, NSError * _Nullable activityError) {
                if (completed) {
                    NSLog(@"completed");
                    //分享 成功
                } else  {
                    NSLog(@"cancled");
                    //分享 取消
                }
            };
            
        }];
        
        UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [actionSheet addAction:saveAction];
        
        [actionSheet addAction:readAction];
        
        [actionSheet addAction:cancleAction];
        
        [self presentViewController:actionSheet animated:YES completion:nil];
        
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 60;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *name = self.dataArray[indexPath.row];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath];
    
    NSString *plistPath = [path stringByAppendingPathComponent:name];

    NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    NSLog(@"Dic = %@",dic);

    [SettingsSETObj ToSetCurrentPlistWithValue:dic[@"OptionalCommand"][@"Size"][@"width"]andKey:@"Printer_lable_width"];

    [SettingsSETObj ToSetCurrentPlistWithValue:dic[@"OptionalCommand"][@"Size"][@"height"]andKey:@"Printer_lable_height"];
    
    NSArray *path2 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [path2 objectAtIndex:0];
    
    NSString *MyPrinterViewPath = [documentsPath stringByAppendingPathComponent:@"MyPrinterViewPList.plist"];
    
    [dic writeToFile:MyPrinterViewPath atomically:YES];
    
    AppDelegate *dele = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    PrinterViewController *formBoardCtl =  dele.PrinterCtl;
    
    [formBoardCtl RefreshPrinterViewWithNewPlist];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
