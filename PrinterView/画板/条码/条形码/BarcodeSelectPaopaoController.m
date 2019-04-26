//
//  BarcodeSelectPaopaoController.m
//  Gprinter
//
//  Created by  Nick on 2018/2/23.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "BarcodeSelectPaopaoController.h"

@interface BarcodeSelectPaopaoController ()<UITableViewDelegate,UITableViewDataSource>
{
    
    NSArray *_kindsArray;
    
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BarcodeSelectPaopaoController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    _kindsArray = [NSArray arrayWithObjects:@"EAN8",@"EAN13",@"UPCA",@"ITF",@"CODE39",@"CODE128", nil];
    
    _tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    

    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return _kindsArray.count;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
    UIView *selectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, WIDTH, 60)];
    selectView.backgroundColor = [UIColor colorWithRed:90/255.0 green:174/255.0 blue:204/255.0 alpha:1];
    cell.selectedBackgroundView = selectView;
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MyCell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    
    cell.textLabel.text =  _kindsArray[indexPath.row];
    
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_cb) {
        
        _cb(indexPath.row);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
