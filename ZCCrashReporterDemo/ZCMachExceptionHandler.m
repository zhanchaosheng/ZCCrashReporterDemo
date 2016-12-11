//
//  ZCMachExceptionHandler.m
//  ZCCrashReporterDemo
//
//  Created by Cusen on 2016/12/11.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "ZCMachExceptionHandler.h"

#import <mach/mach.h>
#import <mach/port.h>
#import <mach/exception.h>
#import <mach/exception_types.h>
#import <mach/task.h>
#import <mach/thread_status.h>
#import <stdio.h>
#import <pthread/pthread.h>

mach_port_t gExceptionPort = 0;

static void *ExceptionHandler(void *ignored)
{
    mach_msg_return_t rc;
    printf("--------->Exc handler listening\n");
    
    // 异常消息，直接取自于mach/exc.defs文件
    typedef struct {
        mach_msg_header_t Head;
        mach_msg_body_t msgh_body;
        mach_msg_port_descriptor_t thread;
        mach_msg_port_descriptor_t task;
        NDR_record_t NDR;
        exception_type_t exception;
        mach_msg_type_number_t codeCnt;
        integer_t code[2];
        int flavor;
        mach_msg_type_number_t old_stateCnt;
        natural_t old_state[144];
    } Request;
    
    Request exc;
    for(;;) {
        // 消息循环，一直阻塞，直到收到一条消息，而且必须是一条异常消息，其他消息也不会到达异常端口
        rc = mach_msg(&exc.Head,
                      MACH_RCV_MSG | MACH_RCV_LARGE,
                      0,
                      sizeof(Request),
                      gExceptionPort,
                      MACH_MSG_TIMEOUT_NONE,
                      MACH_PORT_NULL);
        
        if(rc != MACH_MSG_SUCCESS) {
            return 0;
        };
        
        // 通常情况下要调用exc_server或其他函数，不过在此简单地展示消息内容
        printf("--------->Got Message %d. Exception:%d Flavor:%d. Code %d/%d. State count is %d\n",
               exc.Head.msgh_id,
               exc.exception,
               exc.flavor,
               exc.code[0],
               exc.code[1],
               exc.old_stateCnt);
        
        exit(1);
    }
}

static void CatchMACHExceptions()
{
    kern_return_t rc = 0;
    
    // 这里只是监控了异常读写，也可以设置监控所有异常EXC_MASK_ALL，实际使用时需要根据需要进行修改
    exception_mask_t excMask = EXC_MASK_BAD_ACCESS;
    
    // 创建异常端口
    rc = mach_port_allocate(mach_task_self(),
                            MACH_PORT_RIGHT_RECEIVE,
                            &gExceptionPort);
    if (rc != KERN_SUCCESS) {
        fprintf(stderr, "------->Fail to allocate exception port\n");
        return;
    }
    
    // 申请set_exception_ports的权限，调用port_insert_right允许MAKE_SEND，set_exception_ports要求这个权限
    rc = mach_port_insert_right(mach_task_self(),
                                gExceptionPort,
                                gExceptionPort,
                                MACH_MSG_TYPE_MAKE_SEND);
    if (rc != KERN_SUCCESS) {
        fprintf(stderr, "-------->Fail to insert right");
        return;
    }
    
    // 设置目标任务的异常端口：task下所有线程异常都会发送到该异常端口
    rc = task_set_exception_ports(mach_task_self(),
                                  excMask,
                                  gExceptionPort,
                                  EXCEPTION_DEFAULT,
                                  MACHINE_THREAD_STATE);
    if (rc != KERN_SUCCESS) {
        fprintf(stderr, "-------->Fail to  set exception\n");
        return;
    }
    
    // 设置某线程的异常端口
//    rc = thread_set_exception_ports(mach_thread_self(),
//                                    excMask,
//                                    gExceptionPort,
//                                    EXCEPTION_DEFAULT,
//                                    MACHINE_THREAD_STATE);
//    if (rc != KERN_SUCCESS) {
//        fprintf(stderr, "-------->Fail to  set exception\n");
//        return;
//    }
    
    // 到此，如果在异常端口上没有活动的接收程序，异常消息会永远地挂在这个端口上，导致程序被挂起
    // 异常处理可以有同一个程序中的另一个线程来完成，不过也可以在另一个程序中实现异常处理。
    // 使用mach_msg在异常端口上创建一个活动的监听者
    
    // 创建异常处理线程，线程入口函数中循环等待异常消息
    pthread_t thread;
    pthread_create(&thread, NULL, ExceptionHandler, NULL);
}

@interface ZCMachExceptionHandler()
@end

@implementation ZCMachExceptionHandler

+ (instancetype)sharedInstance {
    static ZCMachExceptionHandler *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[ZCMachExceptionHandler alloc] init];
    });
    return sharedInstance;
}

+ (void)registerMachExceptionHandler {
    CatchMACHExceptions();
}

@end
