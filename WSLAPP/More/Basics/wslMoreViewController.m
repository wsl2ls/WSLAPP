//
//  wslMoreViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/20.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "AppDelegate.h"
#import "wslMoreViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "SDImageCache.h"

#import "saoViewController.h"
#import "wslMapViewController.h"
#import "timeViewController.h"
#import "my2WeiMaViewController.h"

@interface wslMoreViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView  * _imageView;
}
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSMutableArray * dataSource;

@end

@implementation wslMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"小工具";
    [self setupUI];
}

-(void)setupUI
{   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(exitApplication)];
    
    [self.view  addSubview:self.tableView];
}

#pragma mark ---- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   static NSString * cellIde = @"cellIde";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIde];
    }
    if (indexPath.row == 3) {
        
         UISwitch * s = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 5, 300, 200)];
        s.on = NO;
        [s addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventValueChanged];
        [cell.contentView addSubview:s];
    }
    else
    {
        if (indexPath.row == 5 || indexPath.row == 6) {
            cell.detailTextLabel.text = [NSString stringWithFormat:@"缓存 %.2fM",[self cacheFileSize]];
            if (indexPath.row == 6) {
                cell.detailTextLabel.text = @"版本号1.0";
            }
        }else{
        cell.accessoryType =  UITableViewCellAccessoryDisclosureIndicator;
        }
    }

    cell.textLabel.text = self.dataSource[indexPath.row];
    //cell.backgroundColor = [UIColor greenColor];
    return cell;
}
-(void)onClick:(UISwitch *)s{
    
    if (s.on ) {
        AVCaptureDevice *device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch])
        {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOn];
            [device unlockForConfiguration];
        }else
        {
            UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"闪光灯" message:@"你咋木有闪光灯呢亲" delegate:self cancelButtonTitle:@"好吧" otherButtonTitles:nil];
            [alert show];
        }
    }
    else{
        AVCaptureDevice *device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch])
        {
            [device lockForConfiguration:nil];
            [device setTorchMode:AVCaptureTorchModeOff];
            [device unlockForConfiguration];
        }else
        {
            s.on = NO;
        }
    }
}
#pragma mark ---- Getter
- (UITableView *)tableView
{
    if (_tableView == nil) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height- 64 - 49 ) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        
        _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreHead"]];
        _imageView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 3 + 20);
        _imageView.userInteractionEnabled = YES;
        UIButton * titleBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 50) / 2, self.view.frame.size.height / 3 + 20 - 50, 50, 50)];
       [ titleBtn setImage:[UIImage imageNamed:@"mingren"] forState:UIControlStateNormal];
        [titleBtn  addTarget:self action:@selector(showWelcome:) forControlEvents:UIControlEventTouchUpInside];
        titleBtn.layer.cornerRadius = 25;
        titleBtn.clipsToBounds = YES;
        [_imageView addSubview:titleBtn];
        
        _tableView.tableHeaderView = _imageView;
        
        NSArray * array = @[@"简易地图",@"扫一扫",@"我的二维码",@"手电筒",@"计时(分)器",@"清除缓存",@"版本信息"];
        self.dataSource = [NSMutableArray arrayWithArray:array];
        
    }return _tableView;
}
-(void)showWelcome:(id)sender
{
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 250) / 2, self.view.frame.size.height / 3 + 20 - 100, 250, 50)];
      label.text = @"就是你,来一起开启我们的忍者之路吧!";
    label.textColor = [UIColor whiteColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.backgroundColor = [UIColor clearColor];
    [_imageView  addSubview:label];
    
    // GCD封装的几秒之后执行的方法
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:6.0f animations:^{
            label.transform = CGAffineTransformMakeScale(0.1,0.1);
            } completion:^(BOOL finished) {
                [label removeFromSuperview];
        }];
    });
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
            [self toMap];
            break;
        case 1:
            [self toSaoYiSao];
            break;
        case 2:
            [self toMy2WM];
            break;
        case 4:
            [self toTime];
            break;
        case 5:
            [self toCleanCache:indexPath];
            break;
        default:
            break;
    }
}
-(void)toMap
{
    wslMapViewController * map = [[wslMapViewController alloc] init];
    [self.navigationController pushViewController:map animated:YES];
}
-(void)toSaoYiSao
{
    saoViewController * sao = [[saoViewController alloc] init];
     [self.navigationController pushViewController:sao animated:NO];
}
-(void)toTime
{
    timeViewController * time = [[timeViewController alloc] init];
    [self.navigationController pushViewController:time animated:YES];
}
-(void)toMy2WM
{
    my2WeiMaViewController * my = [[my2WeiMaViewController alloc] init];
    [self.navigationController pushViewController:my animated:YES];
}
//退出应用程序
- (void)exitApplication {
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    UIWindow *window = app.window;
    
    [UIView animateWithDuration:1.0f animations:^{
         window.alpha = 0;
        self.tabBarController.tabBar.frame = CGRectMake(0, 0, 0, self.tabBarController.tabBar.bounds.size.height);
        app.window.frame = CGRectMake(0, 0, 0, window.bounds.size.height);
    } completion:^(BOOL finished) {
        //退出
        exit(0);
   }];
}
#pragma mark ----  清理缓存
-(void)toCleanCache:(NSIndexPath *)indexPath
{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp"];
    
    NSString *cacheRingsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"cacheRings"];
     NSString *cachesPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"Caches"];
    NSString * songPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"Songs"];
  
    [self clearCache:cacheRingsPath];
    [self clearCache:cachesPath];
    [self clearCache:path];
    [self folderSizeAtPath:songPath];

    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
}
//返回缓存的大小
- (float)cacheFileSize
{
    NSString* path = [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp"];
    NSString *cacheRingsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"cacheRings"];
    NSString * songPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"Songs"];
 // SDImageCache 的缓存位置
   // NSString *cachesPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"Caches"];
 //   NSLog(@"%@",path);
    return  [self folderSizeAtPath:cacheRingsPath]  + [self folderSizeAtPath:path] + [self folderSizeAtPath:songPath]+[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
    
}

//计算单个文件大小
- (float)fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}
//计算目录大小
-(float)folderSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize +=[self fileSizeAtPath:absolutePath];
        }
        //SDWebImage框架自身计算缓存的实现
     //   folderSize+=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
        return folderSize;
    }
    return 0;
}
- (void)clearCache:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    [[SDImageCache sharedImageCache] cleanDisk];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSIndexPath * indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    self.tabBarController.tabBar.hidden = NO;
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
