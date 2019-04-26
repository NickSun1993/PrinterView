//
//  WWTBlueToothModule.m
//  WWTBluetoothPrinting
//
//  Created by admin on 2018/10/25.
//  Copyright © 2018年 admin. All rights reserved.
//

#import "WWTBlueToothModule.h"

#define MAXLENGTH 146   //默认最大写入字符数

@interface WWTBlueToothModule()<CBCentralManagerDelegate,CBPeripheralDelegate>


@property (nonatomic,strong)    CBCentralManager       * BT_CenterManager;      //蓝牙中心管理器
@property (nonatomic,strong)    CBPeripheral           * BT_Peripheral;         //蓝牙外设
@property (nonatomic,strong)    CBCharacteristic       * BT_Characteristic;     //外设服务特性

@property (strong, nonatomic)   NSArray<CBUUID *>      * serviceUUIDs;          //要查找服务的UUID集合
@property (strong, nonatomic)   NSArray<CBUUID *>      * characteristicUUIDs;   //要查找特性的UUID集合

@property (assign, nonatomic)   NSInteger                writeCount;            //写入次数
@property (assign, nonatomic)   NSInteger                responseCount;         //返回次数
@property (assign, nonatomic)   NSInteger                maxLength;             //最大写入字符数

@property (assign, nonatomic)   WWTConnectStatus         connectStatus;         //蓝牙是否正在连接

@property (nonatomic,assign) BOOL stopScanAfterConnect;

@end

static WWTBlueToothModule * instance = nil;

@implementation WWTBlueToothModule

+(instancetype)ShareInstance
{
    return [[self alloc]init];
}

-(instancetype)init
{
    instance = [super init];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        
        NSDictionary * options = @{CBCentralManagerOptionShowPowerAlertKey:@YES};
        _BT_CenterManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue() options:options];
        _maxLength = MAXLENGTH;
        
    });
    
    return instance;
}

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        instance = [super allocWithZone:zone];
    });
    
    return instance;
}

//根据UUIDS搜索对应的蓝牙外设
/*
 *UUIDS为nil时，搜索出全部正在广播的Peripheral
 *UUIDS不为nil时，搜索出能提供这些服务的Peripheral
 */
-(void)ScanForPeripheralWithServiceUUIDs:(NSArray<CBUUID *> *)uuids options:(NSDictionary<NSString *, id> *)options
{
    [_BT_CenterManager scanForPeripheralsWithServices:uuids options:options];
}

//根据UUIDS搜索对应的蓝牙外设
/*
 *UUIDS为nil时，搜索出全部正在广播的Peripheral
 *UUIDS不为nil时，搜索出能提供这些服务的Peripheral
 *DiscoverBlock 一个个的返回搜索到的Peripheral
 */
- (void)scanForPeripheralsWithServiceUUIDs:(NSArray<CBUUID *> *)uuids options:(NSDictionary<NSString *, id> *)options didDiscoverPeripheral:(WWTDiscoverPeripheralBlock)discoverBlock
{
    _discoverPeripheralBlcok = discoverBlock;
    [self ScanForPeripheralWithServiceUUIDs:uuids options:options];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
           connectOptions:(NSDictionary<NSString *,id> *)connectOptions
   stopScanAfterConnected:(BOOL)stop
          servicesOptions:(NSArray<CBUUID *> *)serviceUUIDs
   characteristicsOptions:(NSArray<CBUUID *> *)characteristicUUIDs
            completeBlock:(WWTBLECompletionBlock)completionBlock
{
    _completionBlock = completionBlock;
    _serviceUUIDs = serviceUUIDs;
    _characteristicUUIDs = characteristicUUIDs;
    _stopScanAfterConnect = stop;
    
    if (_BT_Peripheral) {
        [_BT_CenterManager cancelPeripheralConnection:_BT_Peripheral];
    }
    
    [_BT_CenterManager connectPeripheral:peripheral options:connectOptions];
    peripheral.delegate = self;
}

//搜索特定服务内的子服务
- (void)discoverIncludedServices:(NSArray<CBUUID *> *)includedServiceUUIDs forService:(CBService *)service
{
    [_BT_Peripheral discoverIncludedServices:includedServiceUUIDs forService:service];
}

//停止扫描
-(void)StopScan
{
    [_BT_CenterManager stopScan];
    _discoverPeripheralBlcok = nil;
}

//断开与蓝牙服务的连接
-(void)CancelPeripheralConnection
{
    if (_BT_Peripheral) {
        [_BT_CenterManager cancelPeripheralConnection:_BT_Peripheral];
    }
}

//获取服务的某个特性的值
-(void)ReadValueForCharacteristic:(CBCharacteristic *)characteristic
{
    [_BT_Peripheral readValueForCharacteristic:characteristic];
}

//获取服务的某个特性的值
-(void)ReadValueForCharacteristic:(CBCharacteristic *)characteristic completionBlock:(WWTReadValueForCharacteristicBlock)completionblock
{
    _readValueForCharacteristicBlock = completionblock;
    [self ReadValueForCharacteristic:characteristic];
}

//往特性写入数据（传输数据）
-(void)WriteValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic andType:(CBCharacteristicWriteType)type
{
    _writeCount = 0;
    _responseCount = 0;
    if ([_BT_Peripheral respondsToSelector:@selector(maximumWriteValueLengthForType:)]) {
        _maxLength = [_BT_Peripheral maximumWriteValueLengthForType:type];
    }
    if (_maxLength <= 0) {
        [_BT_Peripheral writeValue:data forCharacteristic:characteristic type:type];
        _writeCount ++;
        return;
    }
    
    if (data.length <= _maxLength) {
        [_BT_Peripheral writeValue:data forCharacteristic:characteristic type:type];
        _writeCount ++;
    }
    else
    {
        NSInteger Dataindex = 0;
        for (Dataindex = 0; Dataindex < data.length - _maxLength; Dataindex += _maxLength) {
            NSData * pieceOfData = [data subdataWithRange:NSMakeRange(Dataindex, _maxLength)];
            [_BT_Peripheral writeValue:pieceOfData forCharacteristic:characteristic type:type];
            _writeCount ++;
        }
        NSData * leftData = [data subdataWithRange:NSMakeRange(Dataindex, data.length - Dataindex)];
        if (leftData) {
            [_BT_Peripheral writeValue:leftData forCharacteristic:characteristic type:type];
            _writeCount ++;
        }
    }
}

//往特性写入数据（传输数据）
-(void)WriteValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic andType:(CBCharacteristicWriteType)type completionBlock:(WWTWriteValueForCharacteristicBlock)completionblock
{
    _writeValueForCharacteristicBlock = completionblock;
    [self WriteValue:data forCharacteristic:characteristic andType:type];
}

-(void)ReadValueForDescriptor:(CBDescriptor *)descriptor
{
    [_BT_Peripheral readValueForDescriptor:descriptor];
}

-(void)ReadValueForDescriptor:(CBDescriptor *)descriptor CompletionBlock:(WWTReadValueForDescriptorBlock)completionBlock
{
    _readValueForDescriptorBlock = completionBlock;
    [self ReadValueForDescriptor:descriptor];
}

- (void)WriteValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor
{
    [_BT_Peripheral writeValue:data forDescriptor:descriptor];
}

- (void)writeValue:(NSData *)data forDescriptor:(CBDescriptor *)descriptor CompletionBlock:(WWTWriteValueForDescriptorBlock)completionBlock
{
    _writeValueForDescriptorBlock = completionBlock;
    [self WriteValue:data forDescriptor:descriptor];
}

-(void)GetRSSICompletionBlock:(WWTGetRSSIBlock)completionBlock
{
    _getRSSIBlock = completionBlock;
    [_BT_Peripheral readRSSI];
}

-(void)GetConnectStatusBlock:(WWTGetConnectionStatusBlock)completionBlock
{
    _getConnectionStatusBlock = completionBlock;
    if (_getConnectionStatusBlock) {
        _getConnectionStatusBlock(_connectStatus);
    }
}

#pragma mark - CBCentralManagerDelegate

/*
 *Central状态更新时触发
 */
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kCentralManagerStateUpdateNoticiation object:@{@"central":central}];
    
    if (_stateUpdateBlock) {
        _stateUpdateBlock(central);
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (_discoverPeripheralBlcok) {
        _discoverPeripheralBlcok(central, peripheral, advertisementData, RSSI);
    }
}


-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    _BT_Peripheral = peripheral;
    _connectStatus = BETConnecting;
    
    if (_stopScanAfterConnect) {
        [_BT_CenterManager stopScan];
    }
    if (_discoverServicesBlock) {
        _discoverServicesBlock(peripheral, peripheral.services, nil);
    }
    if (_completionBlock) {
        _completionBlock(WWTOptionStageConnection, peripheral, nil, nil, nil);
    }
    if (_getConnectionStatusBlock) {
        _getConnectionStatusBlock(_connectStatus);
    }
    [_BT_Peripheral discoverServices:_serviceUUIDs];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    if (_discoverServicesBlock) {
        _discoverServicesBlock(peripheral, peripheral.services,error);
    }
    
    if (_completionBlock) {
        _completionBlock(WWTOptionStageConnection,peripheral,nil,nil,error);
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    _BT_Peripheral = nil;
    _connectStatus = BETDisconnect;
    if (_getConnectionStatusBlock) {
        _getConnectionStatusBlock(_connectStatus);
    }
    
    NSLog(@"断开连接");
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        if (_completionBlock) {
            _completionBlock(WWTOptionStageSeekServices, peripheral, nil, nil, error);
        }
        return;
    }
    
    if (_completionBlock) {
        _completionBlock(WWTOptionStageSeekServices, peripheral, nil, nil, nil);
    }
    
    for (CBService * service in peripheral.services) {
        [_BT_Peripheral discoverCharacteristics:_characteristicUUIDs forService:service];
    }
    
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        if (_discoverdIncludedServicesBlock) {
            _discoverdIncludedServicesBlock(peripheral, service, nil, error);
        }
        return;
    }
    
    if (_discoverdIncludedServicesBlock) {
        _discoverdIncludedServicesBlock(peripheral, service, service.includedServices, error);
    }
    
}

#pragma mark ---------------- 服务特性的代理 --------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    if (error) {
        if (_completionBlock) {
            _completionBlock(WWTOptionStageSeekCharacteristics,peripheral,service,nil,error);
        }
        return;
    }
    
    if (_discoverCharacteristicsBlock) {
        _discoverCharacteristicsBlock(peripheral,service,service.characteristics,nil);
    }
    
    if (_completionBlock) {
        _completionBlock(WWTOptionStageSeekCharacteristics,peripheral,service,nil,nil);
    }
    
    for (CBCharacteristic *character in service.characteristics) {
        [_BT_Peripheral discoverDescriptorsForCharacteristic:character];
        [_BT_Peripheral readValueForCharacteristic:character];
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        if (_notifyCharacteristicBlock) {
            _notifyCharacteristicBlock(peripheral,characteristic,error);
        }
        return;
    }
    if (_notifyCharacteristicBlock) {
        _notifyCharacteristicBlock(peripheral,characteristic,nil);
    }
}

// 读取特性中的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        if (_readValueForCharacteristicBlock) {
            _readValueForCharacteristicBlock(characteristic,nil,error);
        }
        return;
    }
    
    
    NSData *data = characteristic.value;
    
    if (_readValueForCharacteristicBlock) {
        _readValueForCharacteristicBlock(characteristic,data,nil);
    }
}

#pragma mark ---------------- 发现服务特性描述的代理 ------------------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        if (_completionBlock) {
            _completionBlock(WWTOptionStageSeekdescriptors,peripheral,nil,characteristic,error);
        }
        return;
    }
    
    if (_completionBlock) {
        _completionBlock(WWTOptionStageSeekdescriptors,peripheral,nil,characteristic,nil);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    if (error) {
        if (_readValueForDescriptorBlock) {
            _readValueForDescriptorBlock(descriptor,nil,error);
        }
        return;
    }
    
    NSData *data = descriptor.value;
    if (_readValueForDescriptorBlock) {
        _readValueForDescriptorBlock(descriptor,data,nil);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error
{
    if (error) {
        if (_writeValueForDescriptorBlock) {
            _writeValueForDescriptorBlock(descriptor, error);
        }
        return;
    }
    
    if (_writeValueForDescriptorBlock) {
        _writeValueForDescriptorBlock(descriptor, nil);
    }
}

#pragma mark ---------------- 写入数据的回调 --------------------
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (!_writeValueForCharacteristicBlock) {
        return;
    }
    
    _responseCount ++;
    if (_writeCount != _responseCount) {
        return;
    }
    
    _writeValueForCharacteristicBlock(characteristic,error);
}

#pragma mark ---------------- 获取信号之后的回调 ------------------

# if  __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_8_0
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    if (_getRSSIBlock) {
        _getRSSIBlock(peripheral,peripheral.RSSI,error);
    }
}
#else
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    if (_getRSSIBlock) {
        _getRSSIBlock(peripheral,RSSI,error);
    }
}
#endif

@end
