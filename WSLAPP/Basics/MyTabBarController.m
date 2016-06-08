//
//  MyTabBarController.m
//  wslProject
//
//  Created by qianfeng on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "MyTabBarController.h"
#import "wslNavigationController.h"
#import "wslwallpaperViewController.h"
#import "wslNewsViewController.h"
#import "wslSongMainViewController.h"
#import "wsldrawViewController.h"
#import "wslMoreViewController.h"

@interface MyTabBarController ()

@end

@implementation MyTabBarController

-(instancetype)init
{
    if (self = [super init]) {
        [self createTabBar];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tabBar.translucent = YES;
    NSMutableArray * vcs = [NSMutableArray array];
    NSArray * vcClass = @[[wslwallpaperViewController class], [wslNewsViewController class], [wslSongMainViewController class], [wsldrawViewController class], [wslMoreViewController class]];
    for (NSInteger i = 0; i < 5; i++) {
        UIViewController * vc = [[vcClass[i] alloc] init];
        wslNavigationController * nvc = [[wslNavigationController alloc] initWithRootViewController:vc];
        [vcs  addObject:nvc];
        
    }
    self.viewControllers = vcs;
}
-(void)createTabBar
{
    NSArray * titles = @[@"壁纸",@"新闻",@"音乐",@"画板",@"更多"];
    for (int i = 0; i < 5; i++) {
            CGRect  frame = CGRectMake( i * self.tabBar.frame.size.width / 5,0,self.tabBar.frame.size.width / 5, self.tabBar.frame.size.height);
        UIButton * button = [[UIButton alloc] initWithFrame: frame];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        if (i == 0) {
            [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        }else
        {
             [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
        button.tag = 200+ i;
       
        [button  addTarget:self action:@selector(selectedVC:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabBar  addSubview:button];
    }
 
 }
-(void)selectedVC:(UIButton *)btn
{
    CATransition *ca = [CATransition animation];
    //设置动画的格式
    ca.type = @"rippleEffect";
    //设置动画的方向
    ca.subtype = @"fromBottom";
    //设置动画的持续时间
    ca.duration = 1;
    [btn.layer addAnimation:ca forKey:nil];
    for ( int i = 0; i < 5; i++) {
        if (btn.tag == 200 + i) {
            
        }else{
            UIButton * button = (UIButton *)[self.view  viewWithTag:200+i];
            [button  setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        }
    }
    [btn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    self.selectedIndex = btn.tag - 200;
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
