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

- (void)setupAppExceptionHandler;
- (NSUncaughtExceptionHandler*)getAppExceptionHandler;

- (void)setupPLCrashReporter;

- (void)setupSignalHandler;
@end
