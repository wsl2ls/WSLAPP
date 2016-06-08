//
//  wslRingsMoreViewController.m
//  壁纸
//
//  Created by qianfeng on 15/10/12.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslRingsMoreViewController.h"
#import "AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import "SVPullToRefresh.h"
#import "JGProgressHUD.h"

#import "wslRingTableViewCell.h"
#import "ringModel.h"

@interface wslRingsMoreViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    
    int _skip;
    
}
@property(nonatomic,strong) AVPlayer * audioPlayer;
@property (nonatomic, strong) JGProgressHUD   *progressHUD;
@property (nonatomic, strong) UIButton * toTopBtn ;
@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSMutableArray * ringsArray;

@end

@implementation wslRingsMoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self downloadData];
    
    // NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject]);
    
}
-(void)setupUI
{   _skip = 30;
    self.view.backgroundColor =   [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    [self.view  addSubview:self.tableView];
    [self.view  addSubview:self.toTopBtn];
    //避免强强循环引用self --> block -->self
    __weak wslRingsMoreViewController * weakSelf = self;
    [self.tableView addPullToRefreshWithActionHandler:^{
        [weakSelf downloadData];
    }];
    [self.tableView.pullToRefreshView setTitle:@"正在努力加载中..." forState:SVPullToRefreshStateLoading];

    // 当滚动到底部的时候会触发block(加载更多)
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf downloadMoreRings];
    }];

    // 显示HUD 菊花状等待
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y -= 50;
    [self.progressHUD showInRect:rect inView:self.view animated:YES];
    
}
-(void)downloadData
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString * urlStr = [NSString stringWithFormat:@"http://so.picasso.adesk.com/v1/search/ring/resource/%@?adult=false&first=1&limit=30&channel=UCshangdian",self.TFtext];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
           [self.ringsArray  removeAllObjects];
        NSArray * ringsArray = responseObject[@"res"][@"ring"];
        for (int i = 0; i < ringsArray.count; i++) {
            NSDictionary * dict = ringsArray[i];
            
            ringModel * model = [[ringModel alloc] init];
            model.favs =  [NSString stringWithFormat:@"%@",dict[@"favs"]] ;
            NSString * duringStr =[NSString stringWithFormat:@"%@",dict[@"during"]];
            int during;
            if ( duringStr.length != 0) {
                during = [duringStr  intValue];
            }
            if (during >= 60) {
                int ss = during % 60;
                int mm = during / 60;
                model.during =  [NSString stringWithFormat:@"%d:%d",mm,ss] ;
            }else
            {
                model.during =  [NSString stringWithFormat:@"00:%d",during] ;
            }
            model.size  =  [NSString stringWithFormat:@"%@",dict[@"size"]] ;
            model.fid = dict[@"fid"];
            model.name = dict[@"name"];
            model.author = dict[@"author"];
            [self.ringsArray  addObject:model];
        }
        
        //让下拉刷新的控件停掉
        [self.tableView.pullToRefreshView stopAnimating];
        //隐藏HUD
        [self.progressHUD dismissAnimated:YES];

        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error);
    }];
    
}
-(void)downloadMoreRings
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString * urlStr = [NSString stringWithFormat:@"http://so.picasso.adesk.com/v1/search/ring/resource/%@?adult=false&first=0&skip=%d&limit=30&channel=UCshangdian",self.TFtext,_skip];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray * ringsArray = responseObject[@"res"][@"ring"];
        for (int i = 0; i < ringsArray.count; i++) {
            NSDictionary * dict = ringsArray[i];
            
            ringModel * model = [[ringModel alloc] init];
            model.favs =  [NSString stringWithFormat:@"%@",dict[@"favs"]] ;
            NSString * duringStr =[NSString stringWithFormat:@"%@",dict[@"during"]];
            int during;
            if ( duringStr.length != 0) {
                during = [duringStr  intValue];
            }
            if (during >= 60) {
                int ss = during % 60;
                int mm = during / 60;
                model.during =  [NSString stringWithFormat:@"%d:%d",mm,ss] ;
            }else
            {
                model.during =  [NSString stringWithFormat:@"00:%d",during] ;
            }
            model.size  =  [NSString stringWithFormat:@"%@",dict[@"size"]] ;
            model.fid = dict[@"fid"];
            model.name = dict[@"name"];
            model.author = dict[@"author"];
            [self.ringsArray  addObject:model];
        }
        
        //让下拉刷新的控件停掉
        [self.tableView.pullToRefreshView stopAnimating];
        //让加载更多动画停掉
        [self.tableView.infiniteScrollingView  stopAnimating];
        
        [self.tableView reloadData];
        _skip += 30;
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error);
    }];
    
}
#pragma mark ---- 缓冲播放Rings
-(void)downloadRings:(NSInteger)index
{
    
    ringModel * model = self.ringsArray[index];
    
    NSString *RingsPath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"cacheRings"];
    
    //把音乐名字作为存储的MP3的名字
    NSString * RingPath = [RingsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",model.name]];
    
    NSFileManager * fm = [NSFileManager defaultManager];
    //如果存在就直接播放，
    if([fm fileExistsAtPath:RingPath]){
        AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:RingPath]];
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer play];
        return;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:model.fid]];
    NSProgress *progress = nil;
    
    NSURLSessionDownloadTask *task = [manager downloadTaskWithRequest:request progress:&progress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        // targetPath 系统缓存文件的URL
        // 这里需要把我们目标的URL返回给AFNetworking
        
        if (![fm fileExistsAtPath:RingsPath]) {
            //创建Rings文件夹
            [fm createDirectoryAtPath:RingsPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        if([fm fileExistsAtPath:RingPath])
        {
            [fm removeItemAtPath:RingPath error:nil];
        }
        return [NSURL fileURLWithPath:RingPath];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if (error) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"缓冲失败，请检查网络连接！" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
        else {
            AVPlayerItem * playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:RingPath]];
            [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
            [self.audioPlayer play];
            NSLog(@"缓冲成功");
        }
    }];
    [task resume];
    
}
#pragma mark ---- UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return self.ringsArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
            wslRingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ringCell" forIndexPath:indexPath];
        ringModel * model = self.ringsArray[indexPath.row];
        cell.nameLabel.text = model.name;
        cell.favsLabel.text = model.favs;
        int  size = [model.size  intValue];
        cell.sizeLabel.text = [NSString stringWithFormat:@"%.1fKB",size/1024.0f];
        cell.duringLabel.text = model.during;
       cell.authorLabel.text = model.author;
        cell.fid = model.fid;
        
        return cell;
 
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;   
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.audioPlayer pause];
    //缓冲
    [self downloadRings:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint  point  = scrollView.contentOffset;
    if ( point.y > self.view.frame.size.height- 158) {
        self.toTopBtn.hidden = NO;
    }else
    {
        self.toTopBtn.hidden = YES;
    }
}

#pragma mark ---- Getter
- (JGProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        _progressHUD.textLabel.text = @"甭捉急啊,正加载数据中...";
    }
    
    return _progressHUD;
}

-(UITableView *)tableView
{  self.automaticallyAdjustsScrollViewInsets = NO;
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor =   [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
        _tableView.separatorStyle =YES;
        [_tableView  registerNib:[UINib nibWithNibName:@"wslRingTableViewCell" bundle:nil] forCellReuseIdentifier:@"ringCell"];
        
    }return _tableView;
}
-(UIButton *)toTopBtn
{
    if (_toTopBtn == nil) {
        
        _toTopBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 75, 75, 55)];
        [_toTopBtn setTitle:@"返回顶部" forState:UIControlStateNormal];
        [_toTopBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_toTopBtn  addTarget:self action:@selector(scrollToTopClick) forControlEvents:UIControlEventTouchUpInside];
        _toTopBtn.hidden =YES;
        
    }return _toTopBtn;
}
-(void)scrollToTopClick
{
    self.tableView.contentOffset = CGPointMake(0, 0) ;
    self.toTopBtn.hidden = YES;
}

-(AVPlayer *)audioPlayer
{
    if (_audioPlayer == nil) {
        _audioPlayer = [[AVPlayer alloc] init];;
    }
    return _audioPlayer;
}
-(NSMutableArray *)ringsArray
{
    if (_ringsArray == nil) {
        _ringsArray = [[NSMutableArray alloc] init];
    }return _ringsArray;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
      self.navigationController.navigationBar.hidden = YES;
    [self.audioPlayer pause];
}
-(void)viewWillAppear:(BOOL)animated
{  [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
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
