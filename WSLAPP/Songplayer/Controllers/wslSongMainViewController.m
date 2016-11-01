//
//  wslSongMainViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslSongMainViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "JGProgressHUD.h"
#import "songPlayVCManager.h"
#import "imageScrView.h"
#import "haiBaoModel.h"
#import "CustomCollectionViewCell.h"
#import "geDanModel.h"

#import "downloadShareViewController.h"

@interface wslSongMainViewController ()<UIScrollViewDelegate,imageScrViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSInteger currentPage ;
}
@property(nonatomic,strong)UICollectionView * geDanCollectionView;
@property (nonatomic, strong) JGProgressHUD   *progressHUD;
@property (nonatomic, strong) UIButton * toTopBtn ;
@property(nonatomic,strong)NSMutableArray * geDanArray;

@property(nonatomic,strong)NSMutableArray * dataSource;
@property(nonatomic,strong) imageScrView * scr;
@property(nonatomic,strong)NSMutableArray * haiBaoArray;

@property(nonatomic,strong)UITextField * searchTF;


@end

@implementation wslSongMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    currentPage = 1;
    [self setUI];
    
    downloadShareViewController * downManager = [downloadShareViewController shareManager];
    
    [self   downloadData];
    [self downloadGeDan];

}

#pragma mark --- Events Handle

-(void)searchClicked:(id)sender
{  static int searching = 1;
    if (searching == 1) {
        self.navigationItem.titleView = self.searchTF;
        searching = 0;
    }else{
        self.navigationItem.titleView = nil;
        self.navigationItem.title = @"开心听歌,享受生活";
        searching = 1;
       songPlayVCManager * vc = [songPlayVCManager shareManager];
        NSString * urlStr = [NSString stringWithFormat:@"http://so.ard.iyyin.com/s/song_with_out?q=%@&page=1&size=12",self.searchTF.text ];
        vc.listUrlStr = urlStr;
        vc.currentPage = 1;
        if(![self.searchTF.text isEqualToString:@""]){
            CATransition *caAinimation = [CATransition animation];
            caAinimation.type = @"cameraIrisHollow";
            caAinimation.subtype = @"fromTop";
            caAinimation.duration = 1;
            [self.view.superview.layer addAnimation:caAinimation forKey:nil];
            [self.navigationController  pushViewController:vc animated:YES];}
    }
    
}
-(void)downloadManagerClicked:(id)sender
{
    downloadShareViewController * down = [downloadShareViewController shareManager];
    
    [self.navigationController pushViewController:down animated:YES];
}


#pragma mark --- SetUI
-(void)setUI
{
    self.navigationItem.title = @"开心听歌,享受生活";
    self.view.backgroundColor =[UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];

    //下边两个结合去掉navigationBar边的线
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchClicked:)];
    
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 50)];
    [button addTarget:self action:@selector(downloadManagerClicked:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"下载管理" forState:UIControlStateNormal];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    UIBarButtonItem * downloadItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = downloadItem;
    
    __weak wslSongMainViewController* weakSelf = self;
   
    [self.view  addSubview:self.geDanCollectionView];
     [self.view  addSubview:self.toTopBtn];
    // 显示HUD
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y -= 50;
    [self.progressHUD showInRect:rect inView:self.view animated:YES];
    
    //添加下拉刷新控件
    [self.geDanCollectionView addPullToRefreshWithActionHandler:^{
        [weakSelf  downloadData];
        [weakSelf downloadGeDan];
    }];
    [self.geDanCollectionView.pullToRefreshView setTitle:@"下拉刷新" forState:SVPullToRefreshStateTriggered];
    [self.geDanCollectionView.pullToRefreshView setTitle:@"龙哥正在帮你努力加载..." forState:SVPullToRefreshStateLoading];
    [self.geDanCollectionView.pullToRefreshView setTitle:@"刷新完成,感谢龙哥我啊" forState:SVPullToRefreshStateStopped];
    
    // 当滚动到底部的时候会触发block(加载更多)
    [self.geDanCollectionView addInfiniteScrollingWithActionHandler:^{
        // NSLog(@"加载更多");
        [weakSelf downloadGeDan];
    }];
    
}
#pragma mark  ---- 请求海报数据
-(void)downloadData
{
       AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 不要把AFNetworking的操作，放到异步线程中，因为，AFNetworking内部已经实现了一个异步线程去下载数据了
    // 回调的Block是在主线程里执行的
    [manager GET:@"http://api.dongting.com/frontpage/frontpage?f=f3030&s=s200&v=v8.2.0.2015091115&version=0" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        [self.scr.imageArray removeAllObjects];
        [self.haiBaoArray   removeAllObjects];

        NSArray * pictureArray = jsonObj[@"data"];
        NSMutableArray * dataArray = pictureArray[0][@"data"];
        for (int i = 0; i < dataArray.count ; i++) {
            NSDictionary * dict = dataArray[i];
            if(dict == nil){
               break;
            }
            haiBaoModel * picModel = [[haiBaoModel alloc] init];
            picModel.ID = dict[@"action"][@"value"];
            picModel.type =  [NSString stringWithFormat:@"%@",dict[@"action"][@"type"]];
            picModel.picUrl = dict[@"picUrl"];
            if([picModel.type isEqualToString:@"5"]){
                [self.scr.imageArray  addObject:dict[@"picUrl"]];
                [self.haiBaoArray   addObject: picModel];}
        }
        [self.scr reloadData];
        //NSLog(@"self.scr.imageArray.count %ld",self.scr.imageArray.count);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"请求数据失败，error  %@", error);
    }];
}
#pragma mark ----请求歌单数据
-(void)downloadGeDan
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString * urlStr = [NSString  stringWithFormat:@"http://so.ard.iyyin.com/s/songlist?uid=A000004569119F&f=f3030&app=ttpod&hid=3787684455379018&alf=alf702006&net=2&size=10&v=v8.2.0.2015091115&utdid=U3A0zA3Rrr0DAHVzSeAi%%2B5t3&s=s200&page=%ld&%@",currentPage,@"q=tag%3A%E6%9C%80%E7%83%AD&imsi=460030819789075&tid=0"];
    
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        NSArray * array = jsonObj[@"data"];
        for (NSDictionary * dict in array) {
            geDanModel * model = [[geDanModel alloc] init];
            model.ID = dict[@"_id"];
            model.title = dict[@"title"];
            model.picUrl = dict[@"pic_url"];
            [self.geDanArray  addObject:model];
        }
        
        //让下拉刷新的控件停掉
        [self.geDanCollectionView.pullToRefreshView stopAnimating];
        [self updateRefreshInfo];
        //让加载更多动画停掉
        [self.geDanCollectionView.infiniteScrollingView  stopAnimating];
        //隐藏HUD
        [self.progressHUD dismissAnimated:YES];
        currentPage +=1;
        [self.geDanCollectionView reloadData];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //隐藏HUD
        [self.progressHUD dismissAnimated:YES];
        
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"请求失败" message:   [NSString  stringWithFormat:@"加载歌单失败 error是%@",error.localizedDescription]delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
}];
    
}
- (void)updateRefreshInfo
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSString *dateStr = [NSString stringWithFormat:@"最后更新时间: %@", [formatter stringFromDate:date]];
    
    [self.geDanCollectionView.pullToRefreshView setSubtitle:dateStr forState:SVPullToRefreshStateAll];
}

#pragma mark  --- UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.geDanArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{    //取队列中取可复用的cell,如果没有就去注册
    CustomCollectionViewCell * cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"Item" forIndexPath:indexPath];
    geDanModel * model = self.geDanArray[indexPath.item];
    [cell.imageView  sd_setImageWithURL:[NSURL URLWithString:model.picUrl] placeholderImage:[UIImage imageNamed:@"head"]];
    cell.titleLabel.text = model.title;
 
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    songPlayVCManager * vc = [songPlayVCManager shareManager];
    geDanModel * model = self.geDanArray[indexPath.item];
    NSString * urlStr = [NSString stringWithFormat:@"http://api.songlist.ttpod.com/songlists/%@?%@",model.ID,@"f=3030&os=4.1.2&alf=702006&imei=A000004569119F&from=android&resolution=480x800&net=2&api_version=1.0&agent=none&v=v8.2.0.2015091115&utdid=U3A0zA3Rrr0DAHVzSeAi%2B5t3&address=%E5%8C%97%E4%BA%AC%E5%B8%82%E6%98%8C%E5%B9%B3%E5%8C%BA%E8%80%81%E7%89%9B%E6%B9%BE%E8%B7%AF&longitude=116.251656&user_id=0&latitude=40.113224&language=zh"];
    vc.listUrlStr = urlStr;
    [self.navigationController pushViewController:vc animated:YES];
    
}
//返回头视图
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = [collectionView
dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CELLID" forIndexPath:indexPath];
    
    [view addSubview:self.scr];
    if (self.scr.imageArray.count == 0) {
        [self.scr removeFromSuperview];
    }
    return view;
}
//返回头视图的高度,宽度
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    
    if (self.scr.imageArray.count == 0) {
        return CGSizeMake(self.view.frame.size.width, 0);
    }
    return CGSizeMake(self.view.frame.size.width, 200);
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


#pragma mark ----imageScrViewDelegate
-(void)imageScrToViewControllerWithIndex:(NSInteger)index
{
    songPlayVCManager * vc = [songPlayVCManager shareManager];
    haiBaoModel * model =  self.haiBaoArray[index];
    if ([model.type  isEqualToString:@"5"]) {
        
        vc.listUrlStr =[NSString  stringWithFormat:@"http://api.songlist.ttpod.com/songlists/%@?%@",model.ID,@"f=3030&os=4.1.2&alf=702006&imei=A000004569119F&from=android&resolution=480x800&net=2&api_version=1.0&agent=none&v=v8.2.0.2015091115&utdid=U3A0zA3Rrr0DAHVzSeAi%2B5t3&address=%E5%8C%97%E4%BA%AC%E5%B8%82%E6%98%8C%E5%B9%B3%E5%8C%BA%E8%80%81%E7%89%9B%E6%B9%BE%E8%B7%AF&longitude=116.25149&user_id=0&latitude=40.113384&language=zh"];
        
        // NSLog(@"%@",model.ID);
        [self.navigationController  pushViewController:vc animated:YES];
    }else
    {
        NSLog(@"接下来是要跳转到类型为1的页面");
    }
}
#pragma mark --- Getter
-(imageScrView *)scr
{   if(_scr == nil){
    self.automaticallyAdjustsScrollViewInsets = NO;
    _scr = [[imageScrView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
    _scr.delegate = self;
    _scr.backgroundColor = [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];
}
    return _scr;
}
-(UIButton *)toTopBtn
{
    if (_toTopBtn == nil) {
        
        _toTopBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 100, 75, 55)];
        [_toTopBtn setTitle:@"返回顶部" forState:UIControlStateNormal];
        [_toTopBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_toTopBtn  addTarget:self action:@selector(scrollToTopClick) forControlEvents:UIControlEventTouchUpInside];
        _toTopBtn.hidden =YES;
        
    }return _toTopBtn;
}
-(void)scrollToTopClick
{
    self.geDanCollectionView.contentOffset = CGPointMake(0, 0) ;
    self.toTopBtn.hidden = YES;
}

-(UICollectionView *)geDanCollectionView
{
    if(_geDanCollectionView == nil){
        UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc] init];
         flow.itemSize = CGSizeMake(([UIScreen mainScreen].bounds.size.width- 30) /2.0f , 150);
        flow.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        
        self.automaticallyAdjustsScrollViewInsets = NO;
        _geDanCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width , [UIScreen mainScreen].bounds.size.height-64) collectionViewLayout:flow];
        _geDanCollectionView.delegate = self;
        _geDanCollectionView.dataSource = self;
        _geDanCollectionView.backgroundColor =  [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];
        
        //注册UICollectionViewcell
        UINib * nib = [UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil];
        //注册头视图
        [_geDanCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CELLID"];
        [_geDanCollectionView registerNib:nib forCellWithReuseIdentifier:@"Item"];
    }
    return _geDanCollectionView;
}
- (UITextField *)searchTF
{
    if ( _searchTF == nil) {
        _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(100, 300, 180, 40)];
        _searchTF.backgroundColor  = [UIColor clearColor];
        self.searchTF.placeholder = @"请输入歌手名或歌曲名";
        _searchTF.font = [UIFont systemFontOfSize:20];
        _searchTF.textColor = [UIColor whiteColor];
        _searchTF.borderStyle = UITextBorderStyleRoundedRect;
        _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTF.returnKeyType = UIReturnKeyDone;
        _searchTF.keyboardType = UIKeyboardTypeDefault;
    }return _searchTF;
}
- (JGProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        _progressHUD.textLabel.text = @"龙哥帮你加载数据...";
    }
    
    return _progressHUD;
}

-(NSMutableArray *)geDanArray
{
    if (_geDanArray == nil) {
        _geDanArray = [[NSMutableArray alloc] init];
    }return _geDanArray;
}
-(NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }return _dataSource;
}
-(NSMutableArray *)haiBaoArray
{
    if (_haiBaoArray == nil) {
        _haiBaoArray = [[NSMutableArray alloc] init];
    }return _haiBaoArray;
}

-(void)viewWillAppear:(BOOL)animated
{
   
    [super viewWillAppear:animated];
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
