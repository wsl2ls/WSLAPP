//
//  wslRootViewController.m
//  wslProject
//
//  Created by 王双龙 on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "AppDelegate.h"

#import "wslRootViewController.h"
#import "wslGuide1ViewController.h"
#import "ADView.h"
#import "MyTabBarController.h"

@interface wslRootViewController ()
@property(nonatomic,strong) wslGuide1ViewController * guid1Vc;
@property(nonatomic,strong) MyTabBarController * tabBarC;
@end

@implementation wslRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addViewController:self.guid1Vc];
     // GCD封装的几秒之后执行的方法
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:2 animations:^{
            
            if ([self isFirstStartApp] == NO) {
                [self guide];
            }else{
            }

        } completion:^(BOOL finished) {
      [self removeViewController:self.guid1Vc];
        }];
    });
}
//判断是否是第一次启动程序
-(BOOL)isFirstStartApp{
    NSUserDefaults *s = [NSUserDefaults standardUserDefaults];
    
    //读取的是 上一次用户第几次启动程序
    NSNumber *tag = [s objectForKey:@"First"];
    if (tag.intValue >= 1) {
        //用户启动过程序
        //写入新的值（获取旧的tag值,加1后写入磁盘）
        int i = tag.intValue;
        i++;
        [s setObject:[NSNumber numberWithInt:i] forKey:@"First"];
        [s synchronize];
        
        AppDelegate *appDe = [UIApplication sharedApplication].delegate;
        appDe.window.rootViewController = self.tabBarC;
        appDe.rootNavc = self.tabBarC.viewControllers[0];

        return YES;
        
    }else{
        //用户第一次启动程序
        [s setObject:[NSNumber numberWithInt:1] forKey:@"First"];
        [s synchronize];//一定要同步到磁盘
        return NO;
    }
}
-(void)guide{
    NSArray *guideArray = @[@"guid1",@"guid2",@"guid3",@"guid4"];
    
    ADView *ad = [[ADView alloc]initWithFrame:self.view.bounds];
    ad.imageArray = guideArray;
    ad.tag = 876;
    [ad reloadData];
    
    [self.view addSubview:ad];
    
    UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200) / 2, self.view.frame.size.height - 200, 200, 50)];
    button.backgroundColor =[UIColor orangeColor];
    button.alpha = 0.7;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [button  setTitle:@"点我开启你的美好之旅哦^_^" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(removeFromMy:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
}
-(void)removeFromMy:(UIButton *)btn{
    ADView  *ad = (ADView *)[self.view viewWithTag:876];
    [ad removeSub];
    [ad removeFromSuperview];
    [btn removeFromSuperview];
    
    AppDelegate *appDe = [UIApplication sharedApplication].delegate;
    appDe.window.rootViewController = self.tabBarC;
    appDe.rootNavc = self.tabBarC.viewControllers[0];
    
}

#pragma mark - Helper Methods
     
- (void)addViewController:(UIViewController *)viewController
    {
        // 给当前的ViewController添加另一个ViewController
        // 1.添加对应的View
        [self.view addSubview:viewController.view];
        // 2.把对应的ViewController作为self的ChildViewController
        [self addChildViewController:viewController];
        // 3.让添加进来的ChildViewController调用didMoveToParentViewController方法
        [viewController didMoveToParentViewController:self];
        
        // 修改添加到进来的ViewController的View的Frame
        viewController.view.frame = self.view.bounds;
        
        // 添加约束
        NSDictionary *views = @{@"childView": viewController.view, @"parentView": self.view};
        NSArray *hContraints =
        [NSLayoutConstraint constraintsWithVisualFormat:
         @"H:|[childView]|" options:0 metrics:nil views:views];
        NSArray *vContratins =
        [NSLayoutConstraint constraintsWithVisualFormat:
         @"V:|[childView]|" options:0 metrics:nil views:views];
        
        [self.view addConstraints:hContraints];
        [self.view addConstraints:vContratins];
    }
     
     - (void)removeViewController:(UIViewController *)viewController
    {
        // 把一个ChildViewController从ParentViewController移除掉
        
        // 1.先把ViewController的View移
        [viewController.view removeFromSuperview];
        // 2.让viewController先调用willMoveToParentViewController这个方法
        [viewController willMoveToParentViewController:nil];
        // 3.把ViewController从ParentViewController移除掉
        [viewController removeFromParentViewController];
    }
#pragma mark ---- Getter
-(wslGuide1ViewController * )guid1Vc
{
    if(_guid1Vc == nil)
    {
        _guid1Vc = [[wslGuide1ViewController alloc] init];
        _guid1Vc.view.backgroundColor = [UIColor clearColor];
    }
    return _guid1Vc;
}
  -(MyTabBarController *)tabBarC
{
    if (_tabBarC == nil) {
        _tabBarC = [[MyTabBarController alloc] init];
    }return _tabBarC;
}
 - (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
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
