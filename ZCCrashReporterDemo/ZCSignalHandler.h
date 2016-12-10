//
//  ZCSignalHandler.h
//  ZCCrashReporterDemo
//
//  Created by Cusen on 2016/12/10.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCSignalHandler : NSObject


+ (instancetype)sharedInstance;

/**
 注册捕获信号的方法
 */
+ (void)registerSignalHandler;

@end
