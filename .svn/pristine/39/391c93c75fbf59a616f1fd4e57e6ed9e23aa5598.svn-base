//
//  WWTBlueToothUseDemo.m
//  Created by admin on 2018/10/25.
//  Copyright © 2018年 admin. All rights reserved.

    /*****************************/
   /*                           */
  /*  若使用中出现BUG请联系王伟涛！ */
 /*                           */
/*****************************/

/*
     WWTBlueToothModule * BLE = [WWTBlueToothModule ShareInstance];
 */

//查看蓝牙状态
/*
    BLE.stateUpdateBlock = ^(CBCentralManager *central) {
        switch (central.state) {
            case CBManagerStateUnknown:
                //@"未知状态"
                break;
            case CBManagerStatePoweredOn:
                //蓝牙已打开，可使用
 
                //[[WWTBlueToothModule ShareInstance]ScanForPeripheralWithServiceUUIDs:nil options:nil];
 
                break;
            case CBManagerStateResetting:
                //@"蓝牙正在重置"
                break;
            case CBManagerStatePoweredOff:
                //@"蓝牙可用，未打开"
                break;
            case CBManagerStateUnsupported:
                //@"不支持蓝牙"
                break;
            case CBManagerStateUnauthorized:
                //@"程序未授权"
                break;
            default:
                break;
        }
    };
 */


/*
     BLE.discoverPeripheralBlcok = ^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
    
        //返回各种peripheral
        //self.peripheral = peripheral;
 
     };
 */


//连接蓝牙
/* connectPeripheral       要连接的外设 */
/* connectOptions          连接选项 */
/* stopScanAfterConnected  连接后是否停止扫描 */
/* servicesOptions         服务选项 */
/* characteristicsOptions  特性选项 */
/* completeBlock           回调 */
/*
     [BLE connectPeripheral:nil
             connectOptions:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}
     stopScanAfterConnected:YES
            servicesOptions:nil
     characteristicsOptions:nil
              completeBlock:^(WWTOptionStage stage, CBPeripheral *peripheral, CBService *service, CBCharacteristic *character, NSError *error)
     {
         switch (stage) {
             case WWTOptionStageConnection:
             {
                 if (error) {
                     //@"连接失败"
                 } else {
                     //@"连接成功"
                 }
                 break;
             }
             case WWTOptionStageSeekServices:
             {
                 if (error) {
                     //@"查找服务失败"
                 } else {
                     //@"查找服务成功"
                 }
                 break;
             }
             case WWTOptionStageSeekCharacteristics:
             {
                 // 该block会返回多次，每一个服务返回一次
                 if (error) {
                     //@"查找特性失败"
                 } else {
                     //@"查找特性成功"
                 }
                 break;
             }
             case WWTOptionStageSeekdescriptors:
             {
                 // 该block会返回多次，每一个特性返回一次
                 if (error) {
                     //NSLog(@"查找特性的描述失败");
                 } else {
                     //NSLog(@"查找特性的描述成功");
                 }
                 break;
             }
             default:
                 break;
         }
     }];
*/

//读取特性
/*
    [BLE ReadValueForCharacteristic:nil completionBlock:^(CBCharacteristic *characteristic, NSData *value, NSError *error) {
    
    }];
 */


//往特性内写值
/*
    [BLE WriteValue:nil forCharacteristic:nil andType:nil completionBlock:^(CBCharacteristic *characteristic, NSError *error) {
    
    }];
 */
