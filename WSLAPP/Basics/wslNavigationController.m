//
//  wslNavigationController.m
//  SongPlayer
//
//  Created by qianfeng on 15/9/22.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import "wslNavigationController.h"

@interface wslNavigationController ()

@end

@implementation wslNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 把导航控制器的样式的设置，放在这里，每个用到导航控制器的地方，都有同样的样式
    
    // 0, 195, 228
    self.navigationBar.barTintColor = [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    
    // BBI改成白色
    self.navigationBar.tintColor = [UIColor whiteColor];
    // 改变Title的颜色和字体大小
    [self.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [UIFont systemFontOfSize:20]}];
}
// 返回状态栏的颜色，如果界面有导航控制器，这个方法一定要写在导航控制器里
// UIStatusBarStyleLightContent 白色
// UIStatusBarStyleDefault 黑色(默认)
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
