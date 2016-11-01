//
//  songPlayViewController.h
//  WSLAPP
//
//  Created by 王双龙 on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface songPlayViewController : UIViewController

@property(nonatomic,copy)NSString * listUrlStr;
//用于来表示搜索的页数
@property(nonatomic,assign) int currentPage;

@end
