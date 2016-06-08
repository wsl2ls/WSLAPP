//
//  wslwallpaperViewController.h
//  壁纸
//
//  Created by qianfeng on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wslwallpaperViewController : UIViewController

@property(nonatomic,strong)UIPageViewController * pageViewController;
-(void)titleClicked:(UIButton *)btn;
@end
