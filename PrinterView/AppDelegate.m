//
//  AppDelegate.m
//  PrinterView
//
//  Created by  Nick on 2018/10/18.
//  Copyright © 2018年  Nick. All rights reserved.
//

#import "AppDelegate.h"
#import "PrinterViewController.h"



@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.PrinterCtl = [[PrinterViewController alloc]init];
    
    self.window.rootViewController = [[UINavigationController alloc]initWithRootViewController:self.PrinterCtl];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"notFirst"])
    {
        
        [USERDEFAULT setValue:[NSNumber numberWithBool:YES] forKey:@"notFirst"];

        //获取路径对象
        
//        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//
//        NSString *documentsPath = [path objectAtIndex:0];
//
//        NSString *MyPrinterViewPath = [documentsPath stringByAppendingPathComponent:@"MyPrinterViewPList.plist"];
        [self toCreatePlistPath];
        
    }
    
    return YES;
    
}


-(void)toCreatePlistPath
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //创建目录
    /**
     *  第一个参数: 目录路径
     *  第二个参数:是否创建中间目录
     *  第三个参数: 文件属性
     *  第四个参数: 出错处理
     */
    
    BOOL isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath]];
    if (isExist)
    {
        NSLog(@"目录已经存在");
    }
    else
    {
        NSError *myError = nil;
        BOOL ret = [fileManager createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@",[PrinterToolsObj GetMyCachePath],PlistPath] withIntermediateDirectories:YES attributes:nil error:&myError];
        if (ret)
        {
            NSLog(@"NSHomeDirectory = %@",NSHomeDirectory());
            
            NSLog(@"目录创建成功");
            
        }
        else
        {
            NSLog(@"Error = %@",myError);
            
            NSLog(@"目录创建失败");
        }
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self.PrinterCtl saveChangesToPlistWhenAppToBacgroundOrEndEditing];
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(){
        
        //程序在10分钟内未被系统关闭或者强制关闭，则程序会调用此代码块，可以在这里做一些保存或者清理工作
        
        [self.PrinterCtl saveChangesToPlistWhenAppToBacgroundOrEndEditing];
        
        NSLog(@"saveChangesToPlistWhenAppToBacground");
        
        NSLog(@"程序关闭");
        
    }];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"PrinterView"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
