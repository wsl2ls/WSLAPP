//
//  songPlayViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "songPlayViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AFNetworking.h"
#import "SVPullToRefresh.h"
#import "UIImageView+WebCache.h"
#import "JGProgressHUD.h"
#import <notify.h>

#import "wslAVPlayerManager.h"
#import "SongModel.h"
#import "wslAnalyzer.h"
#import "wslLrcEach.h"

@interface songPlayViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    int isPlaying;
    int _isDownload;
    
}

@property (nonatomic, strong) JGProgressHUD   *progressHUD;

@property (nonatomic, strong) UISlider *slider;
@property(nonatomic, strong) UISlider * volumeSlider;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *nextSongBtn;//下一首
@property (nonatomic, strong) UIButton *previousSongBtn;// 上一首
@property(nonatomic,strong)UIButton * SongListBtn;
@property(nonatomic,strong)UIButton * downloadBtn;
@property(nonatomic,strong)UIButton * volumeBtn;

@property(nonatomic,strong)NSMutableArray * songUrlArray;

// 用于显示进度的Label
@property (nonatomic, strong) UILabel *progressLabel;

// 必须要做成成员变量，为了保证它的生命周期
@property (nonatomic, strong) wslAVPlayerManager *audioPlayer;

@property(nonatomic,strong)NSMutableArray * dataSource;//歌词
@property(nonatomic,strong)NSMutableArray * lrcArray;
@property(nonatomic,strong)UITableView * tableView;

@property(nonatomic,strong)NSMutableArray * songArray;
@property(nonatomic,strong)UIView * lrcView;
@property(nonatomic,assign) int  playIndex;//当前正在播放的曲目
@property(nonatomic,assign) NSInteger currentrow  ;

@property(nonatomic,strong)UITableView * SongListTableView;

@property(nonatomic,strong)UIScrollView * scrllView;
@property(nonatomic,strong)UIImageView * songImage;

@property(nonatomic,strong)UIImageView * lrcImageView;
@property(nonatomic,strong)UITableView * lockScreenTableView;

//用来显示当前正在播放的歌曲名字
@property(nonatomic,strong)UIView* titleV;

@end
//tag 20 -- 22
@implementation songPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //后台播放音频设置
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    // [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    [self setupUI];
    [self addNotification];
    
    [self.audioPlayer  addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    //播放进度
    // 每隔一段时间会调用一次这个指定的Block，相当于这就是一个定时器
    
    [[wslAVPlayerManager shareManager]  addPeriodicTimeObserverForInterval:CMTimeMake(0.1*30, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        // 当前播放的时间
        float  playSeconds = self.audioPlayer.currentTime.value *1.0f / self.audioPlayer.currentTime.timescale;
        int m = playSeconds/60;
        int s =(int) playSeconds%60;
        self.progressLabel.text = [NSString  stringWithFormat:@"%d.%dm",m,s];
        // 总的时间的秒数
        float totalSeconds = (self.audioPlayer.currentItem.duration.value *1.0f / self.audioPlayer.currentItem.duration.timescale);
        
        // 算出当前播放时间占总时间的比例
        self.slider.value = playSeconds / totalSeconds;
        
        UILabel * lrcLabel = (UILabel *)[self.lrcView  viewWithTag:22];
        
        //自动播放下一首
        if (self.slider.value >= 0.99) {
            if(self.playIndex < self.songUrlArray.count-1){
                [self.lrcArray  removeAllObjects];
                self.currentrow = 0;
                [self.tableView reloadData];
                [self.lockScreenTableView reloadData];
                
                [self  nextSongBtnClick];
                lrcLabel.text = @"下一首";
            }else{
                lrcLabel.text = @"当前没有音乐播放";
                [ self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                [self.audioPlayer pause];
                isPlaying= 0;
                return ;
            };
        }
        
        ///*
        //歌词动态显示
        
        for ( int i = (int)(self.lrcArray.count - 1); i >= 0 ;i--) {
            wslLrcEach * lrc = self.lrcArray[i];
            if (lrc.time < playSeconds) {
                lrcLabel.text = lrc.lrc;
                //  NSLog(@"%ld  %@",lrc.time,lrc.lrc);
                self.currentrow = i;
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: self. currentrow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                [self.tableView reloadData];
                [self.lockScreenTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: self. currentrow inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
                [self.lockScreenTableView reloadData];
                break;
            }
        }
        //*/
        
        //显示当前播放的音乐名
        [self showPlayingSongName];
        
        //监听锁屏状态 lock=1则为锁屏状态
        uint64_t locked;
        __block int token = 0;
   notify_register_dispatch("com.apple.springboard.lockstate",&token,dispatch_get_main_queue(),^(int t){
        });
        notify_get_state(token, &locked);
        
        //监听屏幕点亮状态 screenLight=1则为变暗关闭状态
        uint64_t screenLight;
        __block int lightToken = 0;
    notify_register_dispatch("com.apple.springboard.hasBlankedScreen",&lightToken,dispatch_get_main_queue(),^(int t){
        });
        notify_get_state(lightToken, &screenLight);
        
       // NSLog(@"screenLight=%llu locked=%llu",screenLight,locked);
        if (screenLight == 1|| locked == 0) {
            return;
        }
        //锁屏信息
            [self showLockScreenTotaltime:totalSeconds andCurrentTime:playSeconds];
    
    }];
}

//锁屏控制音乐播放事件的通知
- (void)addNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songPlayControl:) name:@"songControlNotification" object:nil];
    
}
- (void)songPlayControl:(NSNotification *)noti{
    
   NSNumber* subtype = noti.userInfo[@"subtype"];
    int type = [subtype intValue];
    switch (type) {
          case UIEventSubtypeRemoteControlNextTrack:
            [self nextSongBtnClick];
            break;
          case UIEventSubtypeRemoteControlPreviousTrack:
            [self previousSongBtnClick];
            break;
          case  UIEventSubtypeRemoteControlPause:
            [self playBtnClick:_playBtn];
            break;
            case  UIEventSubtypeRemoteControlPlay:
            [self playBtnClick:_playBtn];
            break;
        default:
            break;
    }
}

#pragma mark --- 锁屏歌曲信息
- (void)showLockScreenTotaltime:(float)totalTime andCurrentTime:(float)currentTime{
    
    NSMutableDictionary * songDict = [[NSMutableDictionary alloc] init];
    SongModel * songModel = self.songArray[_playIndex];
    //设置歌曲题目
    [songDict setObject:songModel.songName forKey:MPMediaItemPropertyTitle];
    //设置歌手名
    [songDict setObject:songModel.singerName forKey:MPMediaItemPropertyArtist];
    //设置专辑名
    [songDict setObject:songModel.songName forKey:MPMediaItemPropertyAlbumTitle];
    //设置歌曲时长
    [songDict setObject:[NSNumber numberWithDouble:totalTime] forKey:MPMediaItemPropertyPlaybackDuration];
    //设置已经播放时长
    [songDict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    
    if (!_lrcImageView) {
        _lrcImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100,self.view.frame.size.width - 100 + 50)];
        
    }
    [_lrcImageView addSubview:self.lockScreenTableView];
     _lrcImageView.image = _songImage.image;
    
    //获取添加了歌词数据的背景图

    UIGraphicsBeginImageContextWithOptions(_lrcImageView.frame.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [_lrcImageView.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //设置显示的图片
    [songDict setObject:[[MPMediaItemArtwork alloc] initWithImage:img]
             forKey:MPMediaItemPropertyArtwork];
    
    //更新字典
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songDict];
    
}


#pragma mark ----显示正在播放的音乐名字
-(void)showPlayingSongName
{
    if(self.slider.value < 1 && self.songArray.count > 0){
        
        UILabel * titleLabel = self.titleV.subviews[0];
        CGRect  rect = titleLabel.frame;
        static  int speed_x = 10;
        if (rect.origin.x < self.titleV.frame.size.width ) {
            rect.origin.x += speed_x; //x方向增加
        }
        if (rect.origin.x >= self.titleV.frame.size.width) {
            rect.origin.x = -titleLabel.frame.size.width;
        }
        
        titleLabel.frame = rect;
        titleLabel.text = [NSString stringWithFormat:@"正在播放: %@",[[NSUserDefaults  standardUserDefaults]  objectForKey:@"songName"]];
    }
}

#pragma mark  ---  setupUI
-(void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];
    [self createImageView];
    [self.view  addSubview:self.slider];
    [self.view  addSubview:self.progressLabel];
    [self.view  addSubview:self.SongListBtn];
    [self.view  addSubview:self.scrllView];
    [self.view addSubview:self.lrcView];
    [self.view  addSubview:self.volumeBtn];
    [self.view addSubview:self.playBtn];
    [self.view   addSubview:self.nextSongBtn];
    [self.view  addSubview:self.previousSongBtn];
    
    UIBarButtonItem * item1  = [[UIBarButtonItem  alloc] initWithCustomView:self.SongListBtn];
    UIBarButtonItem * item2  = [[UIBarButtonItem alloc] initWithTitle:@"下载" style:UIBarButtonItemStyleDone target:self action:@selector(downloadMp3Clicked:)];
    self.navigationItem.rightBarButtonItems = @[item1,item2];
    
}
#pragma mark --- 创建背景
-(void)createImageView
{
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
    //[UIScreen mainScreen].bounds]
    
    imageView.image = [UIImage imageNamed:@"backgroundImage5.jpg"];
    [self.view addSubview:imageView];
}
#pragma mark - KVO

// 当audioPlayer的status发生变化的时候，会调用这个函数
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 当播放器缓冲好了之后
    if (self.audioPlayer.status == AVPlayerStatusReadyToPlay) {
        NSLog(@"播放器 缓冲好了");
    }
}

#pragma mark --- Getter

-(NSString *)listUrlStr
{
    if (_listUrlStr == nil) {
        _listUrlStr = [[NSString alloc] init];
    }return _listUrlStr;
}
-(UIButton *)playBtn
{
    if (_playBtn == nil) {
        
        _playBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _playBtn.frame = CGRectMake( (self.view.frame.size.width - 50) / 3 + 50 ,self.view.frame.size.height - 70 , 60, 50);
        [_playBtn  setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        _playBtn.tintColor = [UIColor  whiteColor];
        [_playBtn  addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }return _playBtn;
}
-(UIButton *)nextSongBtn
{
    if (_nextSongBtn == nil) {
        _nextSongBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _nextSongBtn.frame = CGRectMake((self.view.frame.size.width - 50) / 3 * 2 + 50, self.view.frame.size.height - 70, 50, 50);
        [_nextSongBtn setImage:[UIImage imageNamed:@"nextMusic"] forState:UIControlStateNormal];
        _nextSongBtn.tintColor = [UIColor whiteColor];
        [_nextSongBtn  addTarget:self action:@selector(nextSongBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextSongBtn;
}

-(UIButton *)previousSongBtn
{
    if (_previousSongBtn == nil) {
        _previousSongBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        _previousSongBtn.frame = CGRectMake(60, self.view.frame.size.height - 70, 50, 50);
        [_previousSongBtn setImage:[UIImage imageNamed:@"aboveMusic"] forState:UIControlStateNormal];
        _previousSongBtn.tintColor = [UIColor whiteColor];
        [_previousSongBtn  addTarget:self action:@selector(previousSongBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previousSongBtn;
}
-(UIButton *)SongListBtn
{
    if (_SongListBtn == nil) {
        _SongListBtn= [UIButton buttonWithType:UIButtonTypeSystem];
        _SongListBtn.frame = CGRectMake(0, 0, 40, 40);
        [_SongListBtn setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        _SongListBtn.tintColor = [UIColor whiteColor];
        [_SongListBtn  addTarget:self action:@selector(listBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        //  [self.view addSubview:_SongListBtn];
    }return _SongListBtn;
}
-(UIButton *)volumeBtn
{
    if (_volumeBtn == nil) {
        _volumeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height - 70, 50, 50)];
        [_volumeBtn  setTitle:@"音量" forState:UIControlStateNormal];
        [_volumeBtn addTarget:self action:@selector(volumeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _volumeBtn;
}
-(UISlider *)slider
{
    if (_slider == nil) {
        _slider = [[UISlider  alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 125, self.view.frame.size.width - 50 - 80, 100)];
        // [_slider setThumbImage:[UIImage imageNamed:@"sliderThumb_small"] forState:UIControlStateNormal];
        [_slider  addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [_slider  addTarget:self action:@selector(sliderTouchLeave:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _slider;
}
-(UISlider *)volumeSlider
{
    
    if (_volumeSlider == nil) {
        _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(50, self.view.frame.size.height - 130,150 , 44)];
        [_volumeSlider  addTarget:self action:@selector(volumeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        //设置当前值
        _volumeSlider.value = 2;
        //设置最大 最小值
        _volumeSlider.maximumValue = 20;
        _volumeSlider.minimumValue = 0;
        [_volumeSlider setThumbTintColor:[UIColor orangeColor]];
        _volumeSlider.minimumTrackTintColor = [UIColor orangeColor];
        _volumeSlider.hidden = YES;
        [self.view  addSubview:_volumeSlider];
    }
    return _volumeSlider;
}
-(UILabel *)progressLabel
{
    if (_progressLabel == nil) {
        
        _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - 85, 50, 20)];
        _progressLabel.textColor = [UIColor blueColor];
        _progressLabel.text = @"0.00m";
    }
    return _progressLabel;
}
-(UIView *)lrcView
{
    if (_lrcView == nil) {
        
        _lrcView = [[UIView alloc] initWithFrame:CGRectMake(50,self.view.frame.size.height - 137, (self.view.frame.size.width - 100), 50)];
        
        _lrcView.backgroundColor = [UIColor blackColor];
        _lrcView.alpha = 0.3;
        
        UILabel * lrcLabel =  [[UILabel alloc] initWithFrame:CGRectMake(20 , 2 , (_lrcView.frame.size.width -  40) , 40)];//(50,2,170,40)
        //lrcLabel.backgroundColor = [UIColor greenColor];
        lrcLabel.tag = 22;
        lrcLabel.textColor = [UIColor greenColor];
        lrcLabel .font= [UIFont systemFontOfSize:16];
        lrcLabel.textAlignment = NSTextAlignmentCenter;
        lrcLabel.adjustsFontSizeToFitWidth = YES;
        lrcLabel.lineBreakMode = NSLineBreakByCharWrapping;
        lrcLabel.numberOfLines = 0;
        [self addPanGesture:self.lrcView];
        [self.lrcView addSubview:lrcLabel];
    }return _lrcView;
}
-(UIImageView *)songImage
{
    if (_songImage == nil) {
        _songImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 100,self.view.frame.size.height - 147 - 100)];
        _songImage.image = [UIImage imageNamed:@"head.png"];
    }return _songImage;
}
#pragma mark ----- 歌词显示的Label可拖动
-(void)addPanGesture:(UIView *)view{
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)];
    [view addGestureRecognizer:pan];
}
-(void)pan:(UIPanGestureRecognizer *)pan{
    //获得偏移量
    CGPoint point = [pan translationInView:pan.view];
    static  CGPoint ce ;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
        {
            //NSLog(@"开始");
            ce = pan.view.center;
        }break;
        case UIGestureRecognizerStateEnded:{
            if (self.lrcView.frame.origin.y < 64) {
                self.navigationController.navigationBar.hidden = YES;
            }else
            {
                self.navigationController.navigationBar.hidden = NO;
            }
            //  NSLog(@"结束");
        }break;
        case UIGestureRecognizerStateChanged:{
            //  NSLog(@"改变");
        }
        default:
            break;
    }
    pan.view.center = CGPointMake(ce.x+point.x, ce.y+point.y);
}

-(UIView *)titleV
{  if(_titleV == nil)
{
    _titleV  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width / 7* 3, 44)];
    _titleV.clipsToBounds = YES;
    UILabel *   titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10, 0, [UIScreen mainScreen].bounds.size.width / 7* 4, 44)];
    // titleLabel.backgroundColor = [UIColor greenColor];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.adjustsFontSizeToFitWidth =NO;
    titleLabel.numberOfLines = 2;
    
    [self.titleV addSubview:titleLabel];
    self.navigationItem.titleView = _titleV;
}
    return _titleV;
}
-(wslAVPlayerManager *)audioPlayer
{
    if (_audioPlayer == nil ) {
        self.audioPlayer = [wslAVPlayerManager shareManager];
    }return _audioPlayer;
}

-(NSMutableArray *)songUrlArray
{
    if (_songUrlArray == nil) {
        _songUrlArray = [[NSMutableArray alloc] init];
    }return _songUrlArray;
}
-(NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }return _dataSource;
}
-(NSMutableArray *)lrcArray
{
    if (_lrcArray == nil) {
        _lrcArray = [[NSMutableArray alloc] init];
    }return _lrcArray;
    
}
-(NSMutableArray *)songArray
{
    if (_songArray ==  nil) {
        _songArray = [[NSMutableArray alloc] init];
    }return _songArray;
}
-(UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 100) * 2, 0, self.view.frame.size.width - 100, self.view.frame.size.height - 147 - 100) style:UITableViewStylePlain];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        label.text = @"歌词";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:20];
        _tableView.tableHeaderView = label;
        _tableView.dataSource = self;
        _tableView.tag = 20;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = NO;
    }return _tableView;
}

- (UITableView *)lockScreenTableView{
    
    if (_lockScreenTableView == nil) {
        _lockScreenTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, self.view.frame.size.width - 50 - 130, self.view.frame.size.width - 100 - 10, 130) style:UITableViewStylePlain];
        _lockScreenTableView.delegate = self;
        _lockScreenTableView.dataSource = self;
        _lockScreenTableView.backgroundColor = [UIColor clearColor];
        _lockScreenTableView.tag = 25;
        _lockScreenTableView.separatorStyle = NO;
    }
    return _lockScreenTableView;
}

-(UITableView *)SongListTableView
{
    if (_SongListTableView == nil) {
        _SongListTableView= [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, 0, self.view.frame.size.width - 100, self.view.frame.size.height - 147 - 100) style:UITableViewStyleGrouped];
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 30)];
        label.text = @"歌曲列表";
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:20];
        _SongListTableView.tableHeaderView = label;
        _SongListTableView.dataSource = self;
        _SongListTableView.tag = 21;
        _SongListTableView.delegate = self;
        _SongListTableView.backgroundColor = [UIColor clearColor];
        _SongListTableView.separatorStyle = NO;
    }return _SongListTableView;
}
-(UIScrollView *)scrllView
{
    
    if (_scrllView == nil) {
        // _scrllView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 100,280, 400)];
        _scrllView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 100,self.view.frame.size.width - 100, self.view.frame.size.height - 147 - 100)];
        _scrllView.backgroundColor = [UIColor clearColor];
        _scrllView.contentSize = CGSizeMake((self.view.frame.size.width - 100) * 3, self.view.frame.size.height - 147 - 100) ;
        [_scrllView  addSubview:self.songImage];
        [_scrllView  addSubview:self.tableView];
        
        [_scrllView   addSubview:self.SongListTableView];
        _scrllView.pagingEnabled = YES;
        _scrllView.contentOffset = CGPointMake(self.view.frame.size.width - 100, 0);
        
    }
    return _scrllView;
}
- (JGProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        _progressHUD.textLabel.text = @"龙哥帮你加载数据...";
    }
    
    return _progressHUD;
}

#pragma mark ---- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{  if(tableView.tag == 20 ||tableView.tag == 25){
    return self.lrcArray.count;}
    return self.songArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIde = @"cellIde";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIde];
    }
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    if (tableView.tag == 20 || tableView.tag == 25) {
        if (self.lrcArray.count == 0) {
            return cell;
        }
        wslLrcEach * lrc = self.lrcArray[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        if (self.currentrow == indexPath.row) {
            cell.textLabel.textColor = [UIColor greenColor];
        }
        else{
            cell.textLabel.textColor = [UIColor grayColor];
            if (tableView.tag == 25) {
                cell.textLabel.textColor = [UIColor whiteColor];
            }
        }
        cell.textLabel.text = lrc.lrc;
        return cell;
    }//歌曲列表tableView的Cell
    if (self.songArray.count == 0) {
        return cell;
    }
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    SongModel * model = self.songArray[indexPath.row];
    cell.textLabel.text = model.songName;
    cell.detailTextLabel.text = model.singerName;
    
    if (self.playIndex == indexPath.row && [[ [NSUserDefaults  standardUserDefaults] objectForKey:@"songName"] isEqualToString:model.songName]) {
        cell.textLabel.textColor = [UIColor greenColor];
    }
    else{
        cell.textLabel.textColor = [UIColor blackColor];
    }
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(tableView.tag == 21 && _isDownload == 0 ){
        
        //反选
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [tableView  reloadData];
        
        self.playIndex = (int)indexPath.row;
        
        SongModel * model = self.songArray[self.playIndex];
        
        [[NSUserDefaults  standardUserDefaults]   setObject: self.songUrlArray[self.playIndex] forKey:@"songUrl"];
        [[NSUserDefaults  standardUserDefaults]   setObject: model.songName forKey:@"songName"];
        
        //同步到磁盘
        [[NSUserDefaults  standardUserDefaults]  synchronize];
        
        AVPlayerItem *  playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString: [ [NSUserDefaults  standardUserDefaults] objectForKey:@"songUrl"]]];
        
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer play];
        [self.lrcArray removeAllObjects];
        //切换歌词
        [self getLrc];
        //切换图片
        [self getSongImage];
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        isPlaying = 1;}
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 25) {
        return 40;
    }
    return 60;
}
#pragma mark --- 触发的事件
-(void)playBtnClick:(id)sender
{
    static  int i = 0;
    if (!isPlaying) {
        if (self.playIndex == 0 && i == 0) {
            // 请求完数据，加载第一首歌
            [[NSUserDefaults  standardUserDefaults]   setObject: self.songUrlArray[self.playIndex] forKey:@"songUrl"];
            i = 1;
            SongModel * model = self.songArray[self.playIndex];
            [[NSUserDefaults  standardUserDefaults]   setObject: model.songName forKey:@"songName"];
            //同步到磁盘
            [[NSUserDefaults  standardUserDefaults]  synchronize];
            
            AVPlayerItem *  playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString: [ [NSUserDefaults  standardUserDefaults] objectForKey:@"songUrl"]]];
            [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
            [self getSongImage];
            [self getLrc];
            [self.SongListTableView reloadData];
        }
        [self.audioPlayer  play];
        isPlaying= 1;
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }else{
        [ self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.audioPlayer pause];
        isPlaying= 0;
        i = 1;
    }
}
-(void)nextSongBtnClick
{
    if(self.playIndex < self.songUrlArray.count - 1)
    {
        self.playIndex ++;
        [[NSUserDefaults  standardUserDefaults]   setObject: self.songUrlArray[self.playIndex] forKey:@"songUrl"];
        SongModel * model = self.songArray[self.playIndex];
        [[NSUserDefaults  standardUserDefaults]   setObject: model.songName forKey:@"songName"];
        //同步到磁盘
        [[NSUserDefaults  standardUserDefaults]  synchronize];
        
        AVPlayerItem *  playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString: [ [NSUserDefaults  standardUserDefaults] objectForKey:@"songUrl"]]];
        
        // 切换播放源
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer  play];
        [self.lrcArray  removeAllObjects];
        //切换歌词
        [self getLrc];
        [self getSongImage];
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        isPlaying = 1;
        [self.SongListTableView reloadData];
    }
    else{
        self.title = @"当前没有播放音乐";
        // [self  playBtnClick:nil];
        [ self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.audioPlayer pause];
        isPlaying= 0;
        
    }
}
-(void)listBtnClick:(id)sender
{
    static int isShow = 1;
    if (isShow == 1) {
        isShow = 0;
        self.SongListTableView.hidden = YES;
        self.lrcView.hidden =YES;
        self.tableView.backgroundView.hidden = YES;
        
    }else{
        isShow = 1;
        self.SongListTableView.hidden = NO;
        self.lrcView.hidden = NO;
        self.tableView.backgroundView.hidden = NO;
    }
}
//摇一摇触发
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{   //如果动作是摇一摇
    if(motion == UIEventSubtypeMotionShake)
    {
        [self clipsScreen];
    }
}
//截屏
-(void)clipsScreen
{
    // 1. 开启图像上下文[必须先开开启上下文再执行第二步，顺序不可改变]
    //UIGraphicsBeginImageContext(self.view.bounds.size);
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0);
    // 2. 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //3.将当前视图图层渲染到当前上下文
    [self.view.layer renderInContext:context];
    // 4. 从当前上下文获取图像
    UIImage *songImage =UIGraphicsGetImageFromCurrentImageContext();
    // 5. //关闭图像上下文
    UIGraphicsEndImageContext();
    
    // 6. 保存图像至相册
    UIImageWriteToSavedPhotosAlbum(songImage,self,@selector (image:didFinishSavingWithError:contextInfo:),nil);
}
#pragma mark 保存完成后调用的方法[格式固定]
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"保存至相册失败" message:   [NSString  stringWithFormat:@"error是%@",error.localizedDescription]delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message: @"保存至相册成功"delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
-(void)previousSongBtnClick
{
    if( self.playIndex > 0)
    {
        self.playIndex --;
        [[NSUserDefaults  standardUserDefaults]   setObject: self.songUrlArray[self.playIndex] forKey:@"songUrl"];
        SongModel * model = self.songArray[self.playIndex];
        [[NSUserDefaults  standardUserDefaults]   setObject: model.songName forKey:@"songName"];
        //同步到磁盘
        [[NSUserDefaults  standardUserDefaults]  synchronize];
        
        AVPlayerItem *  playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString: [ [NSUserDefaults  standardUserDefaults] objectForKey:@"songUrl"]]];
        
        // 切换播放源
        [self.audioPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self.audioPlayer   play];
        [self.lrcArray removeAllObjects];
        //切换歌词
        [self getLrc];
        [self getSongImage];
        [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        isPlaying= 1;
        [self.SongListTableView reloadData];
    }
}
-(void)volumeBtnClicked:(id)sender
{
    static int isHidden = 1;
    if( isHidden == 1 )
    {
        self.volumeSlider.hidden = NO;
        isHidden = 0;
    }
    else
    {
        self.volumeSlider.hidden = YES;
        isHidden = 1;
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.volumeSlider.hidden = YES;
}
-(void)sliderValueChanged:(id)sender
{
    [self.audioPlayer pause];
    CMTime totlaTime = self.audioPlayer.currentItem.duration;
    CMTime currentTime = CMTimeMake(totlaTime.value*self.slider.value, totlaTime.timescale);
    if (totlaTime.value != 0) {
        // 让播放器指针跳到指定的时间
        [self.audioPlayer seekToTime:currentTime completionHandler:nil];
    }
}
-(void)volumeSliderValueChanged:(UISlider *)volumeSlider
{
    self.audioPlayer.volume = volumeSlider.value;
}
// 手指离开Slider
- (void)sliderTouchLeave:(id)sender
{
    [self.audioPlayer play];
    [self getLrc];
    [self getSongImage];
    [self.playBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    isPlaying= 1;
}
#pragma mark ---- 下载
-(void)downloadMp3Clicked:(UIBarButtonItem * )item
{
    UITableView *tab = (UITableView *)[self.view viewWithTag:21];
    //判断是否编辑
    if (tab.isEditing == YES && _isDownload == 1) {
        
        //获得用户选了哪些
        NSArray *array = [tab indexPathsForSelectedRows ];
        if (array.count != 0) {
            
            NSMutableArray * mArray = [[NSMutableArray alloc] init];
            for (NSIndexPath *p in array) {
                SongModel * model = self.songArray[p.row];
                [mArray addObject:model];
            }
            if (mArray.count > 6) {
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"亲,一次下载不要太多哦,慢慢来" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
            }
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:mArray,@"songArray", nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"downloadSongs" object:nil userInfo:dict];
        }
        //现在是编辑状态，进入非编辑状态
        //tableView的编辑状态置为NO
        [tab setEditing:NO animated:YES];
        _isDownload = 0;
        item.title = @"下载";
        
    }else{
        //现在是非编辑状态，进入编辑状态
        //进入多选模式
        tab.allowsMultipleSelectionDuringEditing = YES;
        item.title = @"完成";
        //设置编辑状态为YES
        [tab setEditing:YES animated:YES];
        
        _isDownload = 1;
    }
}

#pragma mark -- Get  LRC
-(void)getLrc
{
    SongModel * model = self.songArray[self.playIndex];
    //    NSString * songname = [mStr componentsSeparatedByString:@"("][0] ;
    NSString * lrcUrlStr = [NSString stringWithFormat:@"http://lp.music.ttpod.com/lrc/down?lrcid=&artist=%@&title=%@(Live)&song_id=%@",model.singerName,model.songName,model.songID];
    //字符串转码
    NSString * urlStr = [ lrcUrlStr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        //        NSLog(@"%@",jsonObj);
        NSDictionary * dict = jsonObj;
        NSString * lrc = dict[@"data"][@"lrc"];
        //   NSLog(@"歌词请求成功");
        //NSLog(@"lrc %@",lrc);
        wslAnalyzer * analyzer = [[wslAnalyzer alloc] init];
        self.lrcArray =   [analyzer analyzerLrcByStr:lrc];
        
        //        NSLog(@"%@",lrc);
        
        UILabel * lrcLabel = (UILabel *)[self.lrcView  viewWithTag:22];
        if(self.lrcArray.count == 0){lrcLabel.text = @"当前木有歌词";};
        [self.tableView reloadData];
        [self.lockScreenTableView reloadData];
        
        // NSLog(@"lrcArray.count  %ld",self.lrcArray.count);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" 歌词 请求错误, 错误信息是%@", error);
    }];
}
#pragma mark --- Get songImage
-(void)getSongImage
{
    SongModel * model = self.songArray[self.playIndex];
    
    NSString * lrcUrlStr = [NSString stringWithFormat:@"http://lp.music.ttpod.com/pic/down?artist=%@",model.singerName];
    //字符串转码
    NSString * urlStr = [ lrcUrlStr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET:urlStr parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        id jsonObj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        NSString * picUrlStr = jsonObj[@"data"][@"singerPic"];
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 300)];
        [imageView sd_setImageWithURL:[NSURL URLWithString: [picUrlStr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        imageView.backgroundColor = [UIColor clearColor];
        //self.tableView.backgroundView = imageView;
        [self.songImage sd_setImageWithURL:[NSURL URLWithString: [picUrlStr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageNamed:@"head.png"]];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" 歌曲图片 请求错误, 错误信息是%@", error);
    }];
    
}
#pragma mark --- GET Songs
-(void)getSongs
{
    // 显示HUD 菊花状等待
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y -= 50;
    [self.progressHUD showInRect:rect inView:self.view animated:YES];
    
    NSString * urlStr = self.listUrlStr;
    NSURL *url = [NSURL URLWithString:[urlStr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //NSLog(@"%@",urlStr);
    // queue 线程队列，[NSOperationQueue mainQueue]主线程队列
    // 这里的意思是，回调的Block，放到主线程里执行
    // completionHandler，异步请求完成后处理的Block
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [self.songUrlArray removeAllObjects];
        [self.songArray removeAllObjects];
        [self.SongListTableView reloadData];
        
        if (connectionError == nil) {
            //    NSLog(@"歌曲请求成功");
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            if(jsonObj[@"songs"] != nil) {
                NSArray * songsArray = jsonObj[@"songs"];
                if(songsArray.count != 0 | songsArray != nil){
                    for (NSDictionary * dict in songsArray) {
                        SongModel * model = [[SongModel alloc] init];
                        model.songName = dict[@"name"];
                        model.singerName = dict[@"singerName"];
                        model.songID = dict[@"songId"];
                        if(dict[@"urlList"] != nil){
                            NSArray * array = dict[@"urlList"];
                            if (array.count == 1) {
                                model.songUrl = array[0][@"url"];
                            }else if(array.count >= 2)
                            {
                                model.songUrl = array[1][@"url"];
                            }
                            if (model.songUrl != nil) {
                                [self.songUrlArray  addObject:model.songUrl];
                                [self.songArray  addObject:model];
                            }
                        } //NSLog(@"%ld",self.songArray.count);
                    }
                }}else
                {  //搜索到的歌曲
                    NSArray * songsArray = jsonObj[@"data"];
                    for (NSDictionary * dict in songsArray)  {
                        SongModel * model = [[SongModel alloc] init];
                        model.songName = dict[@"song_name"];
                        model.singerName = dict[@"singer_name"];
                        model.songID = dict[@"song_id"];
                        if(dict[@"url_list"] != nil)  {
                            NSArray * array = dict[@"url_list"];
                            if (array.count == 1) {
                                model.songUrl = array[0][@"url"];
                            }else if(array.count != 0)
                            {
                                model.songUrl = array[1][@"url"];
                            }
                            if (model.songUrl != nil) {
                                [self.songUrlArray  addObject:model.songUrl];
                                [self.songArray  addObject:model];
                            }
                        }
                    }
                    self.currentPage = 2;
                    [self.SongListTableView.pullToRefreshView stopAnimating];
                }
            //隐藏HUD
            [self.progressHUD dismissAnimated:YES];
            
            if(self.songArray.count != 0){
                [self.SongListTableView  reloadData];
            }else{
                [self downloadDataFaile];};
        }
        else {
            [self downloadDataFaile];
        }
    }];
}
-(void)downloadDataFaile
{
    //隐藏HUD
    [self.progressHUD dismissAnimated:YES];
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"加载失败,请检查网络连接状态" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alertView show];
    
}
-(void)getSearchMoreSongs
{
    NSArray * array= [self.listUrlStr componentsSeparatedByString:@"page=1"];
    NSString * str = [NSString stringWithFormat:@"page=%d",self.currentPage];
    NSString * urlStr = [array componentsJoinedByString:str];
    //如果有特殊字符需要转码
    NSURL *url = [NSURL URLWithString:[urlStr  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (connectionError == nil) {
            //  NSLog(@"歌曲请求成功");
            id jsonObj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            //搜索到的歌曲
            NSArray * songsArray = jsonObj[@"data"];
            for (NSDictionary * dict in songsArray)  {
                SongModel * model = [[SongModel alloc] init];
                model.songName = dict[@"song_name"];
                model.singerName = dict[@"singer_name"];
                model.songID = dict[@"song_id"];
                if(dict[@"url_list"] != nil)  {
                    NSArray * array = dict[@"url_list"];
                    if (array.count == 1) {
                        model.songUrl = array[0][@"url"];
                    }else if(array.count != 0)
                    {
                        model.songUrl = array[1][@"url"];
                    }
                    if (model.songUrl != nil) {
                        [self.songUrlArray  addObject:model.songUrl];
                        [self.songArray  addObject:model];
                    }
                }
            }
            [self.SongListTableView.pullToRefreshView stopAnimating];
            //让加载更多动画停掉
            [self.SongListTableView.infiniteScrollingView  stopAnimating];
            self.currentPage +=1;
            [self.SongListTableView reloadData];
        }
        else {
            //让加载更多动画停掉
            [self.SongListTableView.infiniteScrollingView  stopAnimating];
            [self downloadDataFaile];
        }
    }];
    
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    //隐藏HUD
    [self.progressHUD dismissAnimated:YES];
    
    // [self.audioPlayer pause];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    //取消上一个数据请求
    [NSURLConnection cancelPreviousPerformRequestsWithTarget:self];
    
    __weak songPlayViewController * weakSelf = self;
    if (self.currentPage != 0) {
        //添加下拉刷新控件
        [self.SongListTableView addPullToRefreshWithActionHandler:^{
            [ weakSelf getSongs];
        }];
    }
    if (self.currentPage != 0) {
        [self.SongListTableView.pullToRefreshView setTitle:@"龙哥帮你刷新" forState:SVPullToRefreshStateTriggered];
        // 当滚动到底部的时候会触发block(加载更多)
        [self.SongListTableView addInfiniteScrollingWithActionHandler:^{
            // NSLog(@"加载更多");
            [weakSelf getSearchMoreSongs];
        }];
    }
    [self getSongs];
    self.playIndex = 0;
    
    self.tabBarController.tabBar.hidden = YES;
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
