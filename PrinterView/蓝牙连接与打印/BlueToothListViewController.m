//
//  BlueToothListViewController.m
//  PrinterView
//
//  Created by  Nick on 2018/10/26.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import "BlueToothListViewController.h"
#import "WWTBlueToothModule.h"
#import "GPPrintModule.h"

@interface BlueToothListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)NSMutableArray *deviceArray;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BlueToothListViewController

-(NSMutableArray *)deviceArray
{
    if (!_deviceArray)
    {
        _deviceArray = [[NSMutableArray alloc]init];
        
    }
    return _deviceArray;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"蓝牙连接";
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    [self startScaning];
}

- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}
-(void)startScaning
{
    NSLog(@"A test !");
    
    WWTBlueToothModule * BLE = [WWTBlueToothModule ShareInstance];
    
    BLE.stateUpdateBlock = ^(CBCentralManager *central)
    {
        switch (central.state)
        {
            case CBManagerStateUnknown:
                //@"未知状态"
                NSLog(@"未知状态");
                
                break;
            case CBManagerStatePoweredOn:
                
//              蓝牙已打开，可使用
//              @[[CBUUID UUIDWithString:@"E7810A71-73AE-499D-8C15-FAA9AEF0C3F2"]]
               [[WWTBlueToothModule ShareInstance]ScanForPeripheralWithServiceUUIDs:nil options:nil];
               break;
                
            case CBManagerStateResetting:
                
                //@"蓝牙正在重置"
                NSLog(@"蓝牙正在重置");
                
                break;
            
            case CBManagerStatePoweredOff:
                
                //@"蓝牙可用，未打开"
                NSLog(@"蓝牙可用，未打开");
                [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"请打开您设备的蓝牙以连接打印机" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                
                break;
                
            case CBManagerStateUnsupported:
                
                //@"不支持蓝牙"
                NSLog(@"不支持蓝牙");
                
                break;
            case CBManagerStateUnauthorized:
                //@"程序未授权"
                
                NSLog(@"程序未授权");
                
                [AlertCenter ShowAlertWithController:self andTitle:@"温馨提示" andMessage:@"程序没有权限使用您设备的蓝牙，请在设置中打开App访问蓝牙的权限！" andCancelTitle:@"好的" andCancelActionBlock:nil andOtherTitle:nil andActionBlock:nil];
                
                break;
                
            default:
                break;
        }
    };
    
    BLE.discoverPeripheralBlcok = ^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        NSLog(@"%@",central);
        
        NSLog(@"%@",peripheral);
        
        NSLog(@"%@",RSSI);
        
        if (peripheral.name.length <= 0)
        {
            return;
        }
        if (self.deviceArray.count == 0)
        {
           
            NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
            [self.deviceArray addObject:dict];
        
        } else {
            BOOL isExist = NO;
            for (int i = 0; i < self.deviceArray.count; i++)
            {
                NSDictionary *dict = [self.deviceArray objectAtIndex:i];
                CBPeripheral *per = dict[@"peripheral"];
                if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString])
                {
                    isExist = YES;
                    NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                    [_deviceArray replaceObjectAtIndex:i withObject:dict];
                }
            
            }
        
            if (!isExist)
            {
                NSDictionary *dict = @{@"peripheral":peripheral, @"RSSI":RSSI};
                [self.deviceArray addObject:dict];
            }
        }
    
        NSLog(@"deviceArray = %@",_deviceArray);
        
        [self.tableView reloadData];
        
        //返回各种peripheral
        //self.peripheral = peripheral;
    };
    
}

#pragma Mark- UITableDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.deviceArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"deviceId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    NSDictionary *dict = [self.deviceArray objectAtIndex:indexPath.row];
    CBPeripheral *peripherral = dict[@"peripheral"];
    cell.textLabel.text = [NSString stringWithFormat:@"名称:%@",peripherral.name];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"信号强度:%@",dict[@"RSSI"]];
    if (peripherral.state == CBPeripheralStateConnected)
    {
   
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

    }
    else
    {
    
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //连接蓝牙
    /* connectPeripheral       要连接的外设 */
    /* connectOptions          连接选项 */
    /* stopScanAfterConnected  连接后是否停止扫描 */
    /* servicesOptions         服务选项 */
    /* characteristicsOptions  特性选项 */
    /* completeBlock           回调 */
    WWTBlueToothModule * BLE = [WWTBlueToothModule ShareInstance];
    NSDictionary *selectDic = [self.deviceArray objectAtIndex:indexPath.row];
    NSLog(@"selectDic = %@",selectDic);
    CBPeripheral *peripheral = selectDic[@"peripheral"];
     [BLE connectPeripheral:peripheral
     connectOptions:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}
     stopScanAfterConnected:YES
     servicesOptions:nil
     characteristicsOptions:nil
     completeBlock:^(WWTOptionStage stage, CBPeripheral *peripheral, CBService *service, CBCharacteristic *character, NSError *error)
     {
     switch (stage)
     {
     case  WWTOptionStageConnection:
     {
     
     if (error)
     {
     //@"连接失败"
         NSLog(@"连接失败");
     }
     else
     {
     //@"连接成功"
        NSLog(@"连接成功");
     }
     break;
     }
     case WWTOptionStageSeekServices:
     {
     
     if (error)
     {
     //@"查找服务失败"
         NSLog(@"查找服务失败");
     } else {
     //@"查找服务成功"
         NSLog(@"查找服务成功");
         
         NSMutableArray *serviceArray = [[NSMutableArray alloc]initWithArray:peripheral.services];
         
         if (_cb) {
             
             _cb(serviceArray);
         }

         [self.navigationController popViewControllerAnimated:YES];
     }
         
     break;
     }
     case WWTOptionStageSeekCharacteristics:
     {
     // 该block会返回多次，每一个服务返回一次
     if (error)
     {
     //@"查找特性失败"
        NSLog(@"查找特性失败");
     }
     else
     {
     //@"查找特性成功"
         NSLog(@"查找特性成功");
     }
     break;
     }
     case WWTOptionStageSeekdescriptors:
     {
     // 该block会返回多次，每一个特性返回一次
     
     if (error)
     {
     //NSLog(@"查找特性的描述失败");
         NSLog(@"查找特性的描述失败");
     }
     else
     {
     //NSLog(@"查找特性的描述成功");
         NSLog(@"查找特性的描述成功");
     }
     break;
         
     }
        
     default:
    {
        NSLog(@"Default !");
    }
    
     break;
             
    }
    }];
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
