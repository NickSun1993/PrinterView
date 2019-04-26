//
//  WWTBlueToothModule.h
//  WWTBluetoothPrinting
//
//  Created by admin on 2018/10/25.
//  Copyright © 2018年 admin. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "WWTBlueToothConst.h"



@interface WWTBlueToothModule : NSObject

#pragma mark - properties
/* 蓝牙模块状态改变的回调 */
@property (copy, nonatomic) WWTStateUpdateBlock                        stateUpdateBlock;
/* 发现一个蓝牙外设的回调 */
@property (copy, nonatomic) WWTDiscoverPeripheralBlock                 discoverPeripheralBlcok;
/* 连接外设完成的回调 */
//@property (copy, nonatomic) WWTConnectPeripheralBlock                  connectPeripheralBlock;
/* 发现服务的回调 */
@property (copy, nonatomic) WWTDiscoveredServicesBlock                 discoverServicesBlock;
/* 发现服务中的特性的回调 */
@property (copy, nonatomic) WWTDiscoverCharacteristicsBlock            discoverCharacteristicsBlock;
/* 特性值更新的回调 */
@property (copy, nonatomic) WWTNotifyCharacteristicBlock               notifyCharacteristicBlock;
/* 发现服务中的子服务的回调 */
@property (copy, nonatomic) WWTDiscoveredIncludedServicesBlock         discoverdIncludedServicesBlock;
/* 发现特性的描述的回调 */
//@property (copy, nonatomic) WWTDiscoverDescriptorsBlock                discoverDescriptorsBlock;
/* 操作完成的统一回调 */
@property (copy, nonatomic) WWTBLECompletionBlock                      completionBlock;
/* 获取特性值的回调 */
@property (copy, nonatomic) WWTReadValueForCharacteristicBlock         readValueForCharacteristicBlock;
/* 往特性中写值的回调 */
@property (copy, nonatomic) WWTWriteValueForCharacteristicBlock        writeValueForCharacteristicBlock;
/* 获取描述值的回调 */
@property (copy, nonatomic) WWTReadValueForDescriptorBlock             readValueForDescriptorBlock;
/* 往描述中写值的回调 */
@property (copy, nonatomic) WWTWriteValueForDescriptorBlock            writeValueForDescriptorBlock;
/* 获取外设信号值的回调 */
@property (copy, nonatomic) WWTGetRSSIBlock                            getRSSIBlock;
/* 获取蓝牙连接的状态 */
@property (copy, nonatomic) WWTGetConnectionStatusBlock                getConnectionStatusBlock;




+(instancetype)ShareInstance;


//根据UUIDS搜索对应的蓝牙外设
/*
 *UUIDS为nil时，搜索出全部正在广播的Peripheral
 *UUIDS不为nil时，搜索出能提供这些服务的Peripheral
 */
-(void)ScanForPeripheralWithServiceUUIDs:(NSArray<CBUUID *> *)uuids options:(NSDictionary<NSString *, id> *)options;


//根据UUIDS搜索对应的蓝牙外设
/*
 *UUIDS为nil时，搜索出全部正在广播的Peripheral
 *UUIDS不为nil时，搜索出能提供这些服务的Peripheral
 *DiscoverBlock 一个个的返回搜索到的Peripheral
 */
- (void)scanForPeripheralsWithServiceUUIDs:(NSArray<CBUUID *> *)uuids options:(NSDictionary<NSString *, id> *)options didDiscoverPeripheral:(WWTDiscoverPeripheralBlock)discoverBlock;

/**
 *  连接某个蓝牙外设，并查询服务，特性，特性描述
 *
 *  @param peripheral          要连接的蓝牙外设
 *  @param connectOptions      连接的配置参数
 *  @param stop                连接成功后是否停止搜索蓝牙外设
 *  @param serviceUUIDs        要搜索的服务UUID
 *  @param characteristicUUIDs 要搜索的特性UUID
 *  @param completionBlock     操作执行完的回调
 */
- (void)connectPeripheral:(CBPeripheral *)peripheral
           connectOptions:(NSDictionary<NSString *,id> *)connectOptions
   stopScanAfterConnected:(BOOL)stop
          servicesOptions:(NSArray<CBUUID *> *)serviceUUIDs
   characteristicsOptions:(NSArray<CBUUID *> *)characteristicUUIDs
            completeBlock:(WWTBLECompletionBlock)completionBlock;


//搜索特定服务内的子服务
- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service;


//停止扫描
-(void)StopScan;


//断开与蓝牙服务的连接
-(void)CancelPeripheralConnection;


//获取服务的某个特性的值
-(void)ReadValueForCharacteristic:(CBCharacteristic *)characteristic;


//获取服务的某个特性的值
-(void)ReadValueForCharacteristic:(CBCharacteristic *)characteristic completionBlock:(WWTReadValueForCharacteristicBlock)completionblock;


//往特性写入数据（传输数据）
-(void)WriteValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic andType:(CBCharacteristicWriteType)type;


//往特性写入数据（传输数据）
-(void)WriteValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic andType:(CBCharacteristicWriteType)type completionBlock:(WWTWriteValueForCharacteristicBlock)completionblock;


//获取描述的值
-(void)ReadValueForDescriptor:(CBDescriptor *)descriptor;


//获取描述的值并回调
-(void)ReadValueForDescriptor:(CBDescriptor *)descriptor CompletionBlock:(WWTReadValueForDescriptorBlock)completionBlock;


//将值写入描述中
- (void)WriteValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor;


//将值写入描述中并回调
- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor CompletionBlock:(WWTWriteValueForDescriptorBlock)completionBlock;


//获取蓝牙信号量，并回调
-(void)GetRSSICompletionBlock:(WWTGetRSSIBlock)completionBlock;


//获取蓝牙连接状态，并回调
-(void)GetConnectStatusBlock:(WWTGetConnectionStatusBlock)completionBlock;


@end
