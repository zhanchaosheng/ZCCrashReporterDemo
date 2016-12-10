//
//  AppDelegate.m
//  ZCCrashReporterDemo
//
//  Created by zcs on 2016/12/9.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "AppDelegate.h"
#import "ZCCrashReporter.h"

@interface AppDelegate ()
@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //[self testTryCatch];

    [[ZCCrashReporter sharedInstance] setupAppExceptionHandler];
    
    // PLCrashReporter
    //[[ZCCrashReporter sharedInstance] setupPLCrashReporter];
    
    //[[ZCCrashReporter sharedInstance] setupSignalHandler];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - private

- (void)testTryCatch {
    @try {
        NSLog(@"1");
        [self tryTwo];
    }
    @catch (NSException *exception) {
        NSLog(@"2");
        //NSLog(@"%s\n%@", __FUNCTION__, exception);
    }
    @finally {
        //我一定会执行
        NSLog(@"3");
    }
    // 这里一定会执行
    NSLog(@"4");
}

- (void)tryTwo {
    @try {
        NSLog(@"5");
        NSString *str = @"abc";
        [str substringFromIndex:111]; // 程序到这里会崩
    }
    @catch (NSException *exception) {
        NSLog(@"6");
        @throw exception; // 抛出异常，即由上一级处理
        NSLog(@"7");
        //NSLog(@"%s\n%@", __FUNCTION__, exception);
    }
    @finally {
        // 我一定会执行
        NSLog(@"8");
    }
    
    // 如果抛出异常，那么这段代码则不会执行
    NSLog(@"9");
}

@end
