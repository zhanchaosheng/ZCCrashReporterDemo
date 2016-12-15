//
//  ViewController.m
//  ZCCrashReporterDemo
//
//  Created by zcs on 2016/12/9.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "ViewController.h"
#import "ZCCrashReporter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)crashBtnClicked:(UIButton *)sender {
//    NSArray *array = [NSArray arrayWithObject:@"there is only one objective in this arary,call index one, app will crash and throw an exception!"];
//    
//    NSLog(@"%@", [array objectAtIndex:1]);
    char *nullPtr = NULL;
    nullPtr[0] = 1;
}

- (IBAction)getRuntimeStackInfo:(UIButton *)sender {
    NSString *report = [[ZCCrashReporter sharedInstance] getRuntimeStackInfo];
    if (report.length > 0) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
            filePath = [filePath stringByAppendingPathComponent:@"RuntimeStackInfo.crash"];
            [report writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        });
    }
}

@end
