//
//  wslGuide1ViewController.m
//  wslProject
//
//  Created by qianfeng on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslGuide1ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "wslVideoPlayerView.h"


@interface wslGuide1ViewController ()
{
    wslVideoPlayerView *videoView;
}
@property(nonatomic,strong) AVPlayer * videoPlayer;
@end

@implementation wslGuide1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
-(void)setupUI
{
    videoView = [[wslVideoPlayerView alloc] initWithFrame:CGRectMake(0 ,0, self.view.frame.size.width, self.view.frame.size.height) player:self.videoPlayer];
    videoView.backgroundColor = [UIColor clearColor];
    [self.view  addSubview:videoView];
}
-(AVPlayer *)videoPlayer
{
    if (_videoPlayer == nil) {
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MM-dd"];
        NSString * dateStr  = [dateFormatter stringFromDate:[NSDate date]];
        NSRange range = {0,2};
        NSString  *month = [dateStr substringWithRange:range];
        NSLog(@"%@月",month);
        NSURL * _url;
        if ([month intValue] >= 3 && [month intValue] <= 5) {
            _url = [[NSBundle    mainBundle]URLForResource:@"spring.mp4" withExtension:nil];
        }
        if ([month intValue] >= 6 && [month intValue] <= 8)
        {
            _url = [[NSBundle    mainBundle]URLForResource:@"summer.mp4" withExtension:nil];
        }
        if ([month intValue] >= 9 && [month intValue] <= 11)
        {
            _url = [[NSBundle    mainBundle]URLForResource:@"autumn.mp4" withExtension:nil];
        }
        if ([month intValue] == 12  || [month intValue] <= 2) {
            _url = [[NSBundle    mainBundle]URLForResource:@"winter.mp4" withExtension:nil];
        }

        AVPlayerItem  *  playerItem = [AVPlayerItem playerItemWithURL:_url];
        _videoPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [_videoPlayer play];
    }return _videoPlayer;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [videoView removeFromSuperview];
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
