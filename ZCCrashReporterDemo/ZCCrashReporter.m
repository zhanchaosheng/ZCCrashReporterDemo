//
//  ZCCrashReporter.m
//  ZCCrashReporterDemo
//
//  Created by zcs on 2016/12/9.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "ZCCrashReporter.h"
#import "ZCSignalHandler.h"
#import <CrashReporter/CrashReporter.h>
#import "AppDelegate.h"


void UncaughtExceptionHandler(NSException *exception) {
    
    NSArray *arr = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    NSString *contents = [NSString stringWithFormat:@"=============异常崩溃报告=============\nname: %@\nreason: %@\ncallStackSymbols:\n%@",
                     name,reason,[arr componentsJoinedByString:@"\n"]];
    
    // 将异常信息保存至文件
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    filePath = [filePath stringByAppendingPathComponent:@"Exception.txt"];
    [contents writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    // 把异常崩溃信息发送至开发者邮件
    NSMutableString *mailUrl = [NSMutableString string];
    [mailUrl appendString:@"mailto:test@qq.com"];
    [mailUrl appendString:@"?subject=程序异常崩溃，请配合发送异常报告，谢谢合作！"];
    [mailUrl appendFormat:@"&body=%@", contents];
    NSString *mailPath = [mailUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailPath]];
}

@implementation ZCCrashReporter

+ (instancetype)sharedInstance {
    static ZCCrashReporter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZCCrashReporter alloc] init];
    });
    return sharedInstance;
}

#pragma mark - App exception
/**
 设置应用级异常NSException处理入口函数
 */
- (void)setupAppExceptionHandler {
    NSSetUncaughtExceptionHandler (&UncaughtExceptionHandler);
}

- (NSUncaughtExceptionHandler*)getAppExceptionHandler {
    return NSGetUncaughtExceptionHandler();
}


#pragma mark - PLCrashReporter

- (void)setupPLCrashReporter {
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    // Check if we previously crashed
    if ([crashReporter hasPendingCrashReport]) {
        [self handleCrashReport];
    }
    // Enable the Crash Reporter
    if (![crashReporter enableCrashReporterAndReturnError: &error]) {
        NSLog(@"Warning: Could not enable crash reporter: %@", error);
    }
}

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
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (![self hasStoryboardInfo]) {
        appDelegate.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        appDelegate.window.rootViewController = [[UIViewController alloc] init];
    }
    [appDelegate.window makeKeyAndVisible];
    [appDelegate.window.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)hasStoryboardInfo {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIMainStoryboardFile"] != nil ? YES:NO;
}


#pragma mark - Unix signal
/**
 设置Unix信号处理
 */
- (void)setupSignalHandler {
    [ZCSignalHandler registerSignalHandler];
}


#pragma mark - Mach exception
/**
 设置Mach异常处理
 */
- (void)setupMatchExceptionHandler {
    
}

@end
