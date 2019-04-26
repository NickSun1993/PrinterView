//
//  SettingsSetObject.m
//  Gprinter
//
//  Created by 孙锟 on 2018/2/19.
//  Copyright © 2018年 Gprinter. All rights reserved.
//

#import "SettingsSetObject.h"
static SettingsSetObject * instance = nil;

@implementation SettingsSetObject
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
    
}

-(NSMutableDictionary *)GetSettingsDictionaryWithName:(NSString *)name
{
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path1 = [pathArray objectAtIndex:0];
    NSString *plistPath = [path1 stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist",name]];
    
    self.PlistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    
    //获取多语言字典成功后再将语言写入USERDEFAULT

    return self.PlistDic;
    
    
}

-(NSMutableDictionary *)GetCurrentSettingsDictionary
{
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path1 = [pathArray objectAtIndex:0];
    NSString *plistPath = [path1 stringByAppendingPathComponent:@"SettingsPList.plist"];
    
    self.PlistDic = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
        
    return self.PlistDic;
}

-(NSNumber *)GetCurrentPlistNumberWithKey:(NSString *)key
{
    

    [self GetSettingsDictionaryWithName:@"SettingsPList"];

    NSNumber *number = [self.PlistDic valueForKey:key];

    return number;
    
}

-(void)ToSetCurrentPlistWithValue:(NSNumber *)value andKey:(NSString *)key
{
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path1 = [pathArray objectAtIndex:0];
    NSString *plistPath = [path1 stringByAppendingPathComponent:@"SettingsPList.plist"];
    
    self.PlistDic= [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    //设置属性值,没有的数据就新建，已有的数据就修改。
    [self.PlistDic setObject:value forKey:key];
    //写入文件

    [self.PlistDic writeToFile:plistPath atomically:YES];
   
}

-(void)ToRetCurrentPlist
{
    
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path1 = [pathArray objectAtIndex:0];
    NSString *plistPath = [path1 stringByAppendingPathComponent:@"OriginalSettingsPList.plist"];
    NSString *currentPath =[path1 stringByAppendingPathComponent:@"SettingsPList.plist"];
    self.PlistDic= [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    [self.PlistDic writeToFile:currentPath atomically:YES];
    
}
@end
