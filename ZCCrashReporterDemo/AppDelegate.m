//
//  AppDelegate.m
//  ZCCrashReporterDemo
//
//  Created by zcs on 2016/12/9.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "AppDelegate.h"
#import "ZCCrashReporter.h"
#import <CrashReporter/CrashReporter.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    //[ZCCrashReporter setDefaultHandler];
    
    BOOL bCrash = YES;
    
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    // Check if we previously crashed
    if ([crashReporter hasPendingCrashReport]) {
        [self handleCrashReport];
        bCrash = NO;
    }
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error]) {
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
    }
    
    
    // Crash
    if (bCrash) {
        NSArray *array = [NSArray arrayWithObject:@"there is only one objective in this arary,call index one, app will crash and throw an exception!"];
        NSLog(@"%@", [array objectAtIndex:1]);
    }
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

#pragma mark - PLCrashReporter

- (void) handleCrashReport {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSData *crashData;
    NSError *error;
    
    // Try loading the crash report
    crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
    if (crashData) {
        // We could send the report from here, but we'll just print out
        // some debugging info instead
        PLCrashReport *report = [[PLCrashReport alloc] initWithData: crashData error: &error];
        NSString *crashContents;
        if (report) {
            crashContents = [NSString stringWithFormat:@"Time: %@\n", report.systemInfo.timestamp];
            crashContents = [crashContents stringByAppendingFormat:@"signal %@ (code %@, address=0x%" PRIx64 ")\n", report.signalInfo.name,report.signalInfo.code, report.signalInfo.address];
            crashContents = [crashContents stringByAppendingFormat:@"exception name: %@\nexception reason: %@",report.exceptionInfo.exceptionName, report.exceptionInfo.exceptionReason];
        }
        else {
            crashContents = [NSString stringWithFormat:@"Could not parse crash report"];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Crash"
                                                                                 message:crashContents
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                             }];
        [alertController addAction:cancelAction];
        [self presentAlertViewController:alertController];
    }
    else {
        NSLog(@"Could not load crash report: %@", error);
    }
    
    // Purge the report
    [crashReporter purgePendingCrashReport];
    return;
}

- (void)presentAlertViewController:(UIAlertController *)alertController {
    if (![self hasStoryboardInfo]) {
        self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        self.window.rootViewController = [[UIViewController alloc] init];
    }
    [self.window makeKeyAndVisible];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)hasStoryboardInfo {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIMainStoryboardFile"] != nil ? YES:NO;
}

@end
