//
//  wslNewsViewController.m
//  news
//
//  Created by qianfeng on 15/10/7.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#pragma mark ---遇到的小问题
/*
1.请求的URL 参数没有Page, 当加载更多时，只有让count 变化，但同时请求数据时会把所有的数据重新加载一遍，（浪费流量），这时当我把以前的数据清空后，加载更多时，我只能上滑一下，必须等它加载出来以后，才能在上滑，否则会崩，这是因为当我第二次滑得时候，我把之前还正在请求的数据清空了，造成了newsTableview加载空的数组。
   最后我用不清空数据的方法，解决第二次上滑崩溃的问题，但流量的浪费问题还未解决。
 2.动画冲突问题
*/

#import "wslNewsViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "SVPullToRefresh.h"
#import "JGProgressHUD.h"
#import "QFRequestManager.h"

#import "newsTableViewCell.h"
#import "newsModel.h"
#import "wslNewsDetailViewController.h"

//tag 40 --- 60
@interface wslNewsViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSString * _category_ids ;
    NSArray * _idArray;
    int  _count ;
    int _isSwipOrClick;
}
@property (nonatomic, strong) JGProgressHUD   *progressHUD;

@property(nonatomic,strong) UIScrollView * titleScroll;

@property(nonatomic,strong) UITableView * newsTableView;
@property(nonatomic,strong)  NSMutableArray * newsDataSource;
@property(nonatomic,strong) UIButton * toTopBtn;
@end

@implementation wslNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:191/255.0f blue:145/255.0f alpha:1.0f];
    self.navigationItem.title = @"新闻";
    [self setupUI];
    
    [self  downloadData];

}
#pragma mark --- setupUI
-(void)setupUI
{
    //下边两个结合去掉navigationBar边的线
        [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    
    _count = 16;
      _category_ids = @"0";
    //避免强强循环引用self --> block -->self
    __weak wslNewsViewController * weakSelf = self;
    [self.newsTableView addPullToRefreshWithActionHandler:^{
        [weakSelf downloadData];
    }];
    [self.newsTableView.pullToRefreshView setTitle:@"老龙王帮你下拉刷新" forState:SVPullToRefreshStateTriggered];
    [self.newsTableView.pullToRefreshView setTitle:@"正在努力加载中..." forState:SVPullToRefreshStateLoading];
    [self.newsTableView.pullToRefreshView setTitle:@"刷新完成了😄" forState:SVPullToRefreshStateStopped];
    // 当滚动到底部的时候会触发block(加载更多)
    [self.newsTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf downloadData];
    }];

    [self.newsTableView  registerNib:[UINib nibWithNibName:@"newsTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
    [self.view   addSubview:self.titleScroll];
    [self.view   addSubview:self.newsTableView];
    [self.view  addSubview:self.toTopBtn];
    
}
#pragma mark ---- downloadNewsData
-(void)downloadData
{
    // 显示HUD 菊花状等待
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y -= 50;
    [self.progressHUD showInRect:rect inView:self.view animated:YES];
    
    NSString * urlStr = [NSString stringWithFormat:@"http://api.ipadown.com/apple-news-client/news.list.php?category_ids=%@&max_id=0&count=%d",_category_ids,_count];
    
    [QFRequestManager requestWithUrl:urlStr IsCache:YES Finish:^(NSData *data) {
        NSArray *  jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        for (int i = (int)jsonObj.count - 16; i < jsonObj.count ; i++) {
            NSDictionary * dict = jsonObj[i];
            newsModel * model = [[newsModel alloc] init];
            model.desc = dict[@"desc"];
            model.link = dict[@"link"];
            
            model.litpic = dict[@"litpic"];
            model.litpic_2 = dict[@"litpic_2"];
            model. news_id = dict[@"news_id"];
            model.pubDate = dict[@"pubDate"];
            model.tags = dict[@"tags"];
            model.title = dict[@"title"];
            model.views = dict[@"views"];
            model.writer = dict[@"writer"];
            [self.newsDataSource  addObject:model];
        }
        
        //让下拉刷新的控件停掉
        [self.newsTableView.pullToRefreshView stopAnimating];
        [self updateRefreshInfo];
        //让加载更多动画停掉
        [self.newsTableView.infiniteScrollingView  stopAnimating];
        //隐藏HUD
        [self.progressHUD dismissAnimated:YES];
        
        [self.newsTableView reloadData];
        self.newsTableView.separatorStyle = YES;
        _count += 16;
       //        NSLog(@"%@",jsonObj);
    } Failed:^{
        [self.newsTableView.pullToRefreshView stopAnimating];
        [self updateRefreshInfo];
        //让加载更多动画停掉
        [self.newsTableView.infiniteScrollingView  stopAnimating];
        //隐藏HUD
        [self.progressHUD dismissAnimated:YES];
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败,请检查网络连接状态" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }];
}
- (void)updateRefreshInfo
{
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    
    NSString *dateStr = [NSString stringWithFormat:@"龙哥帮你最后更新时间: %@", [formatter stringFromDate:date]];
    
    [self.newsTableView.pullToRefreshView setSubtitle:dateStr forState:SVPullToRefreshStateAll];
}
#pragma mark ----  Events Handle
-(void)newsBtnClick:(UIButton *)btn
{
    //结束之前的数据请求
    [QFRequestManager cancelPreviousPerformRequestsWithTarget:self];
    
    static NSInteger  tag = 40 ;
    UIButton * lastBtn = (UIButton *)[self.view  viewWithTag:tag];
    [lastBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //解决点的是同一个按钮的事件
    if(btn.tag == tag){
     [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
      }
    
    if (btn.tag != tag) {
        [btn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        tag = btn.tag;
    }
    _category_ids = _idArray[btn.tag - 40] ;
    _count = 16;
    [self.newsDataSource  removeAllObjects];
    if(_isSwipOrClick == 0){
        
    CATransition *caAinimation = [CATransition animation];
    //设置动画的格式
    caAinimation.type = @"rippleEffect";
    //设置动画的方向
    caAinimation.subtype = @"fromTop";
    //设置动画的持续时间
    caAinimation.duration = 1;
        [self.view.superview.layer addAnimation:caAinimation forKey:nil];}
    [self scrollToTop:nil];
    [self  downloadData];
}
-(void)scrollToTop:(UIButton *)sender
{
    self.newsTableView.contentOffset = CGPointMake(0, 0);
    self.newsTableView.scrollsToTop = YES;
    sender.hidden = YES;
}
//轻扫事件
-(void)swip:( UISwipeGestureRecognizer *)swip
{    _isSwipOrClick = 1;
      CGPoint  point = self.titleScroll.contentOffset;
      if (swip.direction == UISwipeGestureRecognizerDirectionLeft) {
          
          //找出当前_category_ids
        int j ;
        for (int i = 0; i < _idArray.count; i++) {
            if ([_idArray[i] isEqualToString: _category_ids]) {
                 j = i;
                break;
            }
        }
          //titleScroll跟着滑动
          if (40+j+1 >= 47) {
              point.x =  50 * 7;
              self.titleScroll.contentOffset = point;
          }
          if(40+j+1 >= 51){
              point.x = 10* 50+4 * 100 - 375 ;
              self.titleScroll.contentOffset = point;
          }
          //跳到下一个_category_ids
        if (40+j+1 <= 40 + _idArray.count-1) {
        UIButton * btn = (UIButton *)[self.view viewWithTag:40+j+1];
            CATransition *caAinimation = [CATransition animation];
            //设置动画的格式
            caAinimation.type = @"cube";
            //设置动画的方向
            caAinimation.subtype = @"fromRight";
            //设置动画的持续时间
            caAinimation.duration = 1.5;
            [self.view.superview.layer addAnimation:caAinimation forKey:nil];
        [self newsBtnClick:btn];
            _isSwipOrClick = 0;
        }
    }
    if (swip.direction == UISwipeGestureRecognizerDirectionRight) {
      
        int j ;
       for (int i = 0; i < _idArray.count; i++) {
            if ([_idArray[i] isEqualToString: _category_ids]) {
                j = i;
                break;
            }
        }
        //titleScroll跟着滑动
        if (40+ j - 1 <= 54) {
            point.x = 10* 50+4 * 100 - 375 ;
            self.titleScroll.contentOffset = point;
        }
        if(40+j-1 <= 51){
            point.x = 50 * 7 ;
            self.titleScroll.contentOffset = point;
        }
        if (40+j-1 <= 46) {
            point.x =  0;
            self.titleScroll.contentOffset = point;
        }

        if (40+j-1>= 40) {
       UIButton * btn = (UIButton *)[self.view viewWithTag:40+j-1];
            CATransition *caAinimation = [CATransition animation];
            //设置动画的格式
            caAinimation.type = @"cube";
            //设置动画的方向
            caAinimation.subtype = @"fromLeft";
            //设置动画的持续时间
            caAinimation.duration = 1.5;
            [self.view.superview.layer addAnimation:caAinimation forKey:nil];
           [self newsBtnClick:btn];
             _isSwipOrClick = 0;
        }
    }
}
#pragma  mark ---- UItableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.newsDataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    newsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    if (self.newsDataSource.count != 0) {
    newsModel * model = self.newsDataSource[indexPath.row];
    if (indexPath.row % 2 == 0) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0/255.0f green:191/255.0f blue:145/255.0f alpha:0.5f];
    }else
    {
        cell.contentView.backgroundColor = [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:0.5f];
    }
    [cell.litpicImageView sd_setImageWithURL:[NSURL URLWithString:model.litpic] placeholderImage:[UIImage imageNamed:@"head"]];
    cell.timeLabel.text = model.pubDate;
    cell.lookLabel.text = model.views;
    cell.titleLabe.text = model.title;
    cell.descLabel.text = model.desc;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{   [tableView  deselectRowAtIndexPath:indexPath animated:YES];
    if(self.newsDataSource.count > indexPath.row){
    newsModel * model = self.newsDataSource[indexPath.row];
    wslNewsDetailViewController * newsDetailV = [[wslNewsDetailViewController alloc] init];
    
    newsDetailV.linkUrlString = model.link;
        [self.navigationController pushViewController:newsDetailV animated:YES];}
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint  point  = scrollView.contentOffset;
    if ( point.y > self.view.frame.size.height- 158) {
        self.toTopBtn.hidden = NO;
}else
   {
        self.toTopBtn.hidden = YES;
        
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}
#pragma mark  ----  Getter

//给newsTableView添加清扫手势
-(void)addLeftSwipGesture:(UIView *)view{
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swip:)];
    //设置方向  （一个手势只能定义一个方向）
    swip.direction = UISwipeGestureRecognizerDirectionLeft;
    //视图添加手势
    [view addGestureRecognizer:swip];
}
-(void)addRightSwipGesture:(UIView *)view{
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swip];
}

-(UIScrollView *)titleScroll
{
    NSArray * titleArray = @[@"全部", @"头条",@"快讯", @"游戏", @"应用",@"业界", @"Jobs",@"库克",@"炫配",@"活动",@"ipone技巧",@"iPad技巧",@"Mac技巧",@"iTunes技巧"];
    _idArray = @[@"0",@"9999",@"1",@"11",@"1967",@"4",@"43",@"2634",@"3",@"8",@"6",@"5",@"230",@"12"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_titleScroll == nil) {
        _titleScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width,50)];
        _titleScroll.contentSize = CGSizeMake(10* 50+4 * 100, 50);
        _titleScroll.showsHorizontalScrollIndicator = NO;
        _titleScroll.pagingEnabled = NO;
        _titleScroll.bounces = NO;
            for (int i = 0; i < _idArray.count ; i++) {
                UIButton * button =  [[UIButton alloc] init];
            if(i >= 10){
                button.frame = CGRectMake((i-10) * 100 + 10* 50 , 0, 100, 50);
            }else
            {
                button.frame = CGRectMake(i * 50, 0, 50, 50);
            }
            button.backgroundColor = [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];
                if (i == 0) {
                   [button setTitleColor:[UIColor greenColor]forState:UIControlStateNormal];
                }else{
                      [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                }
            [button setTitle:titleArray[i] forState:UIControlStateNormal];
                button.titleLabel.font = [UIFont systemFontOfSize:20];
            button.tag = 40 + i;
                [button  addTarget:self action:@selector(newsBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            [_titleScroll  addSubview:button];
                
    }
    }return _titleScroll;
}
-(UITableView *)newsTableView
{
    if (_newsTableView == nil) {
        _newsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 114, self.view.frame.size.width, self.view.frame.size.height- 158) style:UITableViewStylePlain];
        _newsTableView.backgroundColor = [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];
        _newsTableView.dataSource = self;
        _newsTableView.delegate = self;
        _newsTableView.separatorStyle = NO;
        [self  addLeftSwipGesture:_newsTableView];
        [self  addRightSwipGesture:_newsTableView];
       // self.tabBarController.tabBar.hidden = YES;
    }
    return _newsTableView;
}
-(UIButton *)toTopBtn
{
    if (_toTopBtn == nil) {
        
       _toTopBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 100, 75, 55)];
        [_toTopBtn setTitle:@"返回顶部" forState:UIControlStateNormal];
        [_toTopBtn setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_toTopBtn  addTarget:self action:@selector(scrollToTop:) forControlEvents:UIControlEventTouchUpInside];
        _toTopBtn.hidden = YES;

    }return _toTopBtn;
}
-(NSMutableArray *)newsDataSource
{
    if (_newsDataSource == nil) {
        _newsDataSource = [[NSMutableArray alloc] init];
    }return _newsDataSource;
}
- (JGProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        _progressHUD.textLabel.text = @"龙哥帮你加载数据...";
    }
    
    return _progressHUD;
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
