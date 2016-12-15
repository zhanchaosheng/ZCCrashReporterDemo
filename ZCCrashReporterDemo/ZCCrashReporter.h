//
//  ZCCrashReporter.h
//  ZCCrashReporterDemo
//
//  Created by zcs on 2016/12/9.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCCrashReporter : NSObject

+ (instancetype)sharedInstance;

/**
 设置应用级异常NSException处理入口函数
 */
- (void)setupAppExceptionHandler;
- (NSUncaughtExceptionHandler*)getAppExceptionHandler;

/**
 设置Unix信号处理
 */
- (void)setupSignalHandler;

/**
 设置Mach异常处理
 */
- (void)setupMatchExceptionHandler;

/**
 使用开源异常捕获框架PLCrashReporter
 */
- (void)setupPLCrashReporter;

/**
 获取运行时堆栈信息
 @return 运行时堆栈信息
 */
- (NSString *)getRuntimeStackInfo;
@end
