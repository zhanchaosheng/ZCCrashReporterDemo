//
//  ViewController.m
//  ZCCrashReporterDemo
//
//  Created by zcs on 2016/12/9.
//  Copyright © 2016年 zcs. All rights reserved.
//

#import "ViewController.h"

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
    NSArray *array = [NSArray arrayWithObject:@"there is only one objective in this arary,call index one, app will crash and throw an exception!"];
    
    NSLog(@"%@", [array objectAtIndex:1]);
}


@end
