//
//  wslwallpaperViewController.m
//  壁纸
//
//  Created by qianfeng on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslwallpaperViewController.h"
#import "wslHotViewController.h"
#import "wslCategoryViewController.h"
#import "wslNewViewController.h"
#import "wslPicSearchViewController.h"

@interface wslwallpaperViewController ()<UIPageViewControllerDataSource,UIPageViewControllerDelegate>


@property(nonatomic,strong) NSMutableArray * subVCs;

@property(nonatomic,strong) UIViewController * vc;

@end
//tag  70 --- 80
@implementation wslwallpaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
  }

-(void)setupUI
{
    //下边两个结合去掉navigationBar边的线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    self.navigationController.navigationBar.hidden = YES;
    
    self.navigationItem.title = @"壁纸";
    self.view.backgroundColor = [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    [self.view  addSubview:self.pageViewController.view];
    NSArray * titleArray = @[@"推荐",@"分类",@"最新",@"搜索"];
    for(int i = 0; i < 4; i++){
        UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(i * (self.view.frame.size.width-75)/4 + 75/2.0, 20,  (self.view.frame.size.width-75)/4, 35)];
       // (self.view.frame.size.width-75)/4
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        button.titleLabel.font =  [UIFont fontWithName:@"AvenirNext-Regular" size:22];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.tag = i + 70;
        [button addTarget:self action:@selector(titleClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view  addSubview:button];
        
    }
    
    UIScrollView * scr = [[UIScrollView alloc] initWithFrame:CGRectMake(75/2.0, 55, self.view.frame.size.width-75, 4)];
    scr.showsVerticalScrollIndicator = NO;
    scr.contentSize = CGSizeMake(4 * 75, 4);
    scr.contentOffset = CGPointMake(0, 0);
    scr.backgroundColor = [UIColor clearColor];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0, (self.view.frame.size.width-75)/4, 4)];
    label.tag = 80;
    label.backgroundColor = [UIColor  redColor];
    [scr  addSubview:label];
    
    [self.view  addSubview:scr];

}
#pragma mark  ---- Events Handle
-(void)titleClicked:(UIButton *)btn
{      CATransition *ca = [CATransition animation];
    //设置动画的格式
    ca.type = @"rippleEffect";
    //设置动画的方向
    ca.subtype = @"fromBottom";
    //设置动画的持续时间
    ca.duration = 1;
    [btn.layer addAnimation:ca forKey:nil];
    //判断将要滑动的方向
    if (self.vc.view.tag < btn.tag-70) {
     [self.pageViewController setViewControllers:@[_subVCs[btn.tag-70]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    else{
         [self.pageViewController setViewControllers:@[_subVCs[btn.tag-70]] direction:UIPageViewControllerNavigationDirectionReverse animated:YES completion:nil];
    }
    UILabel * label = (UILabel *)[self.view  viewWithTag:80];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect  rect =  label.frame;
        UIViewController * vc = _subVCs[btn.tag-70];
        rect.origin.x =  vc.view.tag  * (self.view.frame.size.width-75)/4 ;
        label.frame = rect;
    } completion:^(BOOL finished) {
        
    }];
    
    //获得当前页面
    self.vc = _subVCs[btn.tag-70];

    if (self.vc.view.tag != 0) {
       self.tabBarController.tabBar.hidden = YES;
      
   
    }else
    {
        self.tabBarController.tabBar.hidden = NO;
       
    }
}

#pragma mark ---- UIPageViewControllerDataSource,UIPageViewControllerDelegate

// 返回viewController页面的后面的视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (viewController.view.tag < 3) {
        return _subVCs[viewController.view.tag + 1];
    }
    return nil;
}

// 返回viewController页面的前面的视图控制器
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (viewController.view.tag > 0) {
       return self.subVCs[viewController.view.tag - 1];
    }
    return nil;
}

// 即将翻页到pendingViewControllers
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
  
    UIViewController * cv = [pendingViewControllers lastObject];
    self.vc = cv;
}

// 已经完成翻页completed ＝ YES 表示翻到另一个页面，NO表示没有翻到下一个页面
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    
    //previousViewControllers 上一页面
    
   if (completed == YES) {
       UILabel * label = (UILabel *)[self.view  viewWithTag:80];
       [UIView animateWithDuration:0.5 animations:^{
          
           CGRect  rect =  label.frame;
           rect.origin.x =  self.vc.view.tag  * (self.view.frame.size.width-75)/4 ;
           label.frame = rect;
           
       } completion:^(BOOL finished) {
           
       }];
    
        if (self.vc.view.tag != 0) {
          self.tabBarController.tabBar.hidden = YES;
    
       }else
       {
           self.tabBarController.tabBar.hidden = NO;
        
       }
   }
    
}
#pragma mark ---- Getter

-(UIPageViewController *)pageViewController
{
    if (_pageViewController == nil) {
        // 创建页面控制器
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
        _pageViewController.view.frame = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 40);
        [self.view addSubview:_pageViewController.view];
        
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        
        // 实现子页面内容
        
        NSArray * controllersArray = @[[wslHotViewController class],[wslCategoryViewController class],[wslNewViewController class],[wslPicSearchViewController class]];
        
        NSMutableArray * mArray = [NSMutableArray array];
        for (NSInteger i = 0; i < 4; i++) {
            UIViewController * vc = [[controllersArray[i] alloc] init];
            
            vc.view.tag = i;
            [mArray addObject:vc];
        }
        
        self.subVCs = mArray;
        
        // 将页面内容放入页面控制器中显示
        [self.pageViewController setViewControllers:@[self.subVCs[0]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    }
    
    return _pageViewController;
}

-(NSMutableArray *)subVCs
{
    if (_subVCs == nil) {
        _subVCs = [[NSMutableArray alloc] init];
    }return _subVCs;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
       if (self.vc.view.tag == 0) {
    self.tabBarController.tabBar.hidden = NO;
      
    }
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
