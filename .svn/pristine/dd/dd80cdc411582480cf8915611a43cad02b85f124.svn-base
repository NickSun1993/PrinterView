//
//  SettingsSetObject.h
//  Gprinter
//
//  Created by 孙锟 on 2018/2/19.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsSetObject : NSObject

@property(nonatomic,strong)NSMutableDictionary * PlistDic;

+ (instancetype)sharedInstance;

-(NSMutableDictionary *)GetSettingsDictionaryWithName:(NSString *)name;

-(NSMutableDictionary *)GetCurrentSettingsDictionary;

-(NSNumber *)GetCurrentPlistNumberWithKey:(NSString *)key;


-(void)ToSetCurrentPlistWithValue:(NSNumber *)value andKey:(NSString *)key;

-(void)ToRetCurrentPlist;

@end
