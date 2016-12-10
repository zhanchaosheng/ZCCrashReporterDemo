//
//  ZCSignalHandler.m
//  ZCCrashReporterDemo
//
//  Created by Cusen on 2016/12/10.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "ZCSignalHandler.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4; // 调用堆栈中需要跳过的帧数
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5; // 获取调用堆栈中的帧数

volatile int32_t UncaughtExceptionCount = 0; //当前处理的异常个数
volatile int32_t UncaughtExceptionMaximum = 10; //最大能够处理的异常个数


//捕获信号后的回调函数
void HandleSignalException(int signal);


@interface ZCSignalHandler () {
    BOOL isDismissed;
}

@end

@implementation ZCSignalHandler

+ (instancetype)sharedInstance {
    static ZCSignalHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZCSignalHandler alloc] init];
    });
    return sharedInstance;
}

/**
 注册信号处理函数
 Signal信号的类型:
 SIGABRT--程序中止命令中止信号
 SIGALRM--程序超时信号
 SIGFPE--程序浮点异常信号
 SIGILL--程序非法指令信号
 SIGHUP--程序终端中止信号
 SIGINT--程序键盘中断信号
 SIGKILL--程序结束接收中止信号
 SIGTERM--程序kill中止信号
 SIGSTOP--程序键盘中止信号
 SIGSEGV--程序无效内存中止信号
 SIGBUS--程序内存字节未对齐中止信号
 SIGPIPE--程序Socket发送失败中止信号
 */
+ (void)registerSignalHandler {
    //注册程序由于abort()函数调用发生的程序中止信号
    signal(SIGABRT, HandleSignalException);
    //注册程序由于非法指令产生的程序中止信号
    signal(SIGILL, HandleSignalException);
    //注册程序由于无效内存的引用导致的程序中止信号
    signal(SIGSEGV, HandleSignalException);
    //注册程序由于浮点数异常导致的程序中止信号
    signal(SIGFPE, HandleSignalException);
    //注册程序由于内存地址未对齐导致的程序中止信号
    signal(SIGBUS, HandleSignalException);
    //程序通过端口发送消息失败导致的程序中止信号
    signal(SIGPIPE, HandleSignalException);
}

+ (NSArray *)backtrace {
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount + UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

+ (NSString *)getAppInfo {
    NSString *appInfo = [NSString stringWithFormat:@"App : %@ %@(%@)\nDevice : %@\nOS Version : %@ %@\nUDID : %@\n",
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                         [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                         [UIDevice currentDevice].model,
                         [UIDevice currentDevice].systemName,
                         [UIDevice currentDevice].systemVersion,
                         [UIDevice currentDevice].identifierForVendor];
    NSLog(@"Crash!!!! %@", appInfo);
    return appInfo;
}

//处理异常用到的方法
- (void)handleException:(NSException *)exception
{
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"程序出现问题啦"
                                                        message:@"崩溃信息"
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:nil];
    [alertView show];
    //当接收到异常处理消息时，让程序开始runloop，防止程序死亡
    while (!isDismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
        }
    }
    //当点击弹出视图的Cancel按钮哦,isDimissed ＝ YES,上边的循环跳出
    CFRelease(allModes);
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    //因为这个弹出视图只有一个Cancel按钮，所以直接进行修改isDimsmissed这个变量了
    isDismissed = YES;
}

@end


void HandleSignalException(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum) {
        return;
    }
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]
                                                                       forKey:@"Signal"];
    NSArray *callStack = [ZCSignalHandler backtrace];
    [userInfo setObject:callStack forKey:@"CallStack"];
    NSString *appInfo = [ZCSignalHandler getAppInfo];
    [userInfo setObject:appInfo forKey:@"AppInfo"];
    
    NSException *ex = [NSException exceptionWithName:@"SignalException"
                                              reason:[NSString stringWithFormat:@"Signal %d was raised.\n",signal]
                                            userInfo:userInfo];
    
    [[ZCSignalHandler sharedInstance] performSelectorOnMainThread:@selector(handleException:)
                                                       withObject:ex
                                                    waitUntilDone:YES];
}
