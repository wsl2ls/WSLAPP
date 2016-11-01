//
//  wslPicSearchViewController.m
//  壁纸
//
//  Created by 王双龙 on 15/10/11.
//  Copyright (c) 2015年 WSL. All rights reserved.
//
/*
 遇到的问题   请求的ring类型是acc.mp4格式的，Avplayer播放不了，我就直接把它下载下来后，改变它的后缀名为mp3 ,,再播放，还有就是当我用模态化方式跳转页面时，pageViewController 的坐标发生了改变,改为导航控制器跳转后正常了
 
 */

#import "AppDelegate.h"

#import "wslPicSearchViewController.h"
#import "AFNetworking.h"
#import <AVFoundation/AVFoundation.h>

#import "wslRingTableViewCell.h"
#import "wslCustomTableViewCell.h"
#import "ringModel.h"
#import "wslpicMoreViewController.h"
#import "wslRingsMoreViewController.h"

#import "wslVideoPlayerView.h"

@interface wslPicSearchViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) AVPlayer * audioPlayer;
@property(nonatomic,strong) AVPlayer * videoPlayer;

@property(nonatomic,strong) UITextField * seacherTF;
@property(nonatomic,strong) UITableView * tableView;

@property(nonatomic,strong) NSMutableArray * picturesArray;
@property(nonatomic,strong) NSMutableArray * picIdArr;

@property(nonatomic,strong) NSMutableArray * ringsArray;

@end

@implementation wslPicSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self    setupUI];
    [self addObserverForAVPlayer];
}
-(void)setupUI
{
    self.view.backgroundColor =   [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    [self.view  addSubview:self.seacherTF];
    [self.view  addSubview:self.tableView];
    wslVideoPlayerView *videoView = [[wslVideoPlayerView alloc] initWithFrame:CGRectMake(0 ,40, self.view.frame.size.width, self.view.frame.size.height-64) player:self.videoPlayer];
    videoView.tag = 76;
    videoView.backgroundColor = [UIColor clearColor];
     [self.view  addSubview:videoView];
}
- (void)addObserverForAVPlayer
{
    // 如果不想Block对一个对象强引用，就用__weak来修饰这个变量
    __weak wslPicSearchViewController *weakSelf = self;
    
    [self.videoPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1*3, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // 当前播放的时间
        float playSeconds = self.videoPlayer.currentTime.value *1.0f / self.videoPlayer.currentTime.timescale;
        // 总的时间的秒数
        float totalSeconds = (self.videoPlayer.currentItem.duration.value *1.0f / self.videoPlayer.currentItem.duration.timescale);
        if (playSeconds >= totalSeconds- 0.001) {
            static int i = 0;
            i++;
            if (i < 20) {
                 NSURL * url = [[NSBundle    mainBundle]URLForResource:@"zou.mp4" withExtension:nil];
                AVPlayerItem *playerItem =  [AVPlayerItem playerItemWithURL:url];
                [weakSelf.videoPlayer  replaceCurrentItemWithPlayerItem:playerItem];
                [weakSelf.videoPlayer play];
            }else{[weakSelf.videoPlayer pause]; }
        }
    }];
}

#pragma mark ---请求picture数据 和Rings
-(void)downloadData
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    NSString * urlStr = [NSString stringWithFormat:@"http://so.picasso.adesk.com/v1/search/all/resource/%@?version=148&channel=UCshangdian&adult=false",self.seacherTF.text];
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [self.picturesArray removeAllObjects];
        [self.ringsArray  removeAllObjects];
        
        NSArray * searchArray = responseObject[@"res"][@"search"];
        NSArray * picArr = searchArray[1][@"items"];
        for (NSDictionary * dict in picArr) {
            [self.picIdArr   addObject:dict[@"id"]];
            [self.picturesArray  addObject:dict[@"img"]];
        }
        NSArray * ringArr = searchArray[2][@"items"];
        for (NSDictionary * dict in ringArr) {
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
        [self isOrNotHaveData];
        [self.tableView reloadData];
        
} failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error);
    }];
}
-(void)isOrNotHaveData
{
    if (self.picturesArray.count != 0 || self.ringsArray.count != 0) {
        wslVideoPlayerView *videoView = (wslVideoPlayerView *)[self.view viewWithTag:76];
        videoView.hidden = YES;
        [self.videoPlayer pause];
    }
    
    if (self.picturesArray.count == 0 && self.ringsArray.count != 0) {
        [self showAlertView:@"没有搜索到对应的壁纸"];
    }
    if (self.ringsArray.count == 0 && self.picturesArray.count != 0) {
         [self showAlertView:@"没有搜索到对应的铃声"];
    }
    if (self.ringsArray.count == 0 && self.picturesArray.count == 0 ) {
        wslVideoPlayerView *videoView = (wslVideoPlayerView *)[self.view viewWithTag:76];
        videoView.hidden = NO;
        [self.videoPlayer play];
        [self.view  bringSubviewToFront:videoView];
         [self showAlertView:@"没有搜索到对应的铃声和壁纸"];
    }

}
-(void)showAlertView:(NSString *)str
{
   UIAlertView *  alertview = [[UIAlertView alloc] initWithTitle:@"提示" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    [alertview show];

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
            NSLog(@"缓冲失败，错误是%@", error);
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

#pragma mark ---- Events  Handle
-(void)searchBtnClicked:(UIButton *)btn
{
    [self.seacherTF endEditing:YES];
  //  if (self.seacherTF.text.length != 0) {
        [self downloadData];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.seacherTF endEditing:YES];
}
#pragma mark ---- UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 && self.picturesArray.count != 0){
        return 1;
    }else{
        return self.ringsArray.count;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        wslCustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"picCell"];
        cell.picturesArray = self.picturesArray;
        cell.picIdArr = self.picIdArr;
        [cell reloadData];
        return cell;
    }else
    {
        wslRingTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"ringCell" forIndexPath:indexPath];
        ringModel * model = self.ringsArray[indexPath.row];
        cell.nameLabel.text = model.name;
        cell.favsLabel.text = model.favs;
        int  size;
        if (model.size != nil) {
           size =  [model.size  intValue];
        }
        cell.sizeLabel.text = [NSString stringWithFormat:@"%.1fKB",size/1024.0f];
         cell.duringLabel.text = model.during;
        cell.fid = model.fid;
        cell.authorLabel.text = model.author;
        return cell;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{     if(indexPath.section == 0){
    if (self.picturesArray.count % 2 == 0) {
     return self.picturesArray.count / 2 * 150 +self.picturesArray.count / 2 * 10;
     }
    return self.picturesArray.count / 2 * 150 + 150 +self.picturesArray.count / 2 * 10 + 10;
    
}else{
    return 100;   }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self downloadRings:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   // NSLog(@"%@",[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES)lastObject]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(self.picturesArray.count != 0){
    UIView * view  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UIButton * button = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, 4, 50, 40)];
    [button setTitle:@"更多" forState:UIControlStateNormal];
        [button  setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal ];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 4, 50, 40)];
        label.textColor = [UIColor whiteColor];
    if (section == 0) {
         [button addTarget:self action:@selector(morePicsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        label.text = @"壁纸";
    }else
    {    [button addTarget:self action:@selector(moreRingsBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
         label.text = @"铃声";
    }
    [view  addSubview:button];
    [view  addSubview:label];
        return view;}
    return nil;
}
#pragma mark ----- More  Events
-(void)morePicsBtnClicked:(id)sender
{
    wslpicMoreViewController * picsMore = [[wslpicMoreViewController alloc] init];
      picsMore.TFtext = self.seacherTF.text;
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    [dele.rootNavc pushViewController:picsMore animated:YES];

}
-(void)moreRingsBtnClicked:(id)sender
{
    
    wslRingsMoreViewController * ringsMore = [[wslRingsMoreViewController alloc] init];
    ringsMore.TFtext = self.seacherTF.text;
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    [dele.rootNavc pushViewController:ringsMore animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
#pragma mark ---- Getter
-(UITableView *)tableView
{  self.automaticallyAdjustsScrollViewInsets = NO;
    if (_tableView == nil) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height-64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor =   [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
        _tableView.separatorStyle =YES;
        [_tableView registerClass:[wslCustomTableViewCell class] forCellReuseIdentifier:@"picCell"];
        [_tableView  registerNib:[UINib nibWithNibName:@"wslRingTableViewCell" bundle:nil] forCellReuseIdentifier:@"ringCell"];
        
    }return _tableView;
}
-(UITextField *)seacherTF
{
    if (_seacherTF == nil) {
        _seacherTF = [[UITextField  alloc] initWithFrame:CGRectMake(5, 7, (self.view.frame.size.width - 40), 30)];
        _seacherTF.backgroundColor = [UIColor whiteColor];
     _seacherTF.placeholder = @"请输入关键字";
        _seacherTF.clearButtonMode =  UITextFieldViewModeWhileEditing;
        _seacherTF.borderStyle =  UITextBorderStyleRoundedRect;

        
        UIButton * searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(45 + (self.view.frame.size.width - 90) + 10, 7,30,30)];
       // [searchBtn  setTitle:@"搜索" forState:UIControlStateNormal];
        [searchBtn  setImage:[UIImage imageNamed:@"search"] forState:UIControlStateNormal];
        searchBtn.tintColor = [UIColor greenColor];
        [searchBtn  addTarget:self action:@selector(searchBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        _seacherTF.keyboardType = UIKeyboardTypeDefault;
        [self.view  addSubview:searchBtn];
      
    }return _seacherTF;
}
-(AVPlayer *)audioPlayer
{
    if (_audioPlayer == nil) {
        _audioPlayer = [[AVPlayer alloc] init];;
    }
    return _audioPlayer;
}
-(AVPlayer *)videoPlayer
{
    if (_videoPlayer == nil) {
        
       NSURL * _playItemUrl = [[NSBundle    mainBundle]URLForResource:@"zou.mp4" withExtension:nil];
        AVPlayerItem  *  playerItem = [AVPlayerItem playerItemWithURL:_playItemUrl];
        _videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        
    }return _videoPlayer;
}

-( NSMutableArray *)picturesArray
{
    if (_picturesArray == nil) {
        _picturesArray = [[NSMutableArray alloc] init];
    }
    return _picturesArray;
}
-(NSMutableArray *)picIdArr
{
    if (_picIdArr == nil) {
        _picIdArr = [[NSMutableArray alloc] init];
    }return _picIdArr;
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
    [self.audioPlayer pause];
    [self.videoPlayer pause];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.videoPlayer play];
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
