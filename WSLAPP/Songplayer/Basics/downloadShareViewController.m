//
//  downloadShareViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/22.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "downloadShareViewController.h"

@interface downloadShareViewController ()

@end

@implementation downloadShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
+ (instancetype)shareManager
{
    // 这种是线程安全的
    static downloadShareViewController *manager;
    
    static dispatch_once_t token;
    
    // 这个函数，能保证后面的block只会被执行一次
    dispatch_once(&token, ^{
        manager = [[downloadShareViewController alloc] init];
    });
    
    return manager;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
