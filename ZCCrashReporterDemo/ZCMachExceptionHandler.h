//
//  ZCMachExceptionHandler.h
//  ZCCrashReporterDemo
//
//  Created by Cusen on 2016/12/11.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZCMachExceptionHandler : NSObject

+ (instancetype)sharedInstance;

+ (void)registerMachExceptionHandler;

@end
