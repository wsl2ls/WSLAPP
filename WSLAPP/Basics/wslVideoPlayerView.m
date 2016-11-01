//
//  wslVideoPlayerView.m
//  壁纸
//
//  Created by 王双龙 on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslVideoPlayerView.h"

@implementation wslVideoPlayerView

// 重写这个方法，告诉系统，这个View的Layer不是普通的Layer，而是用于播放视频的Layer
+ (Class)layerClass
{ //  [AVPlayerLayer class] * playLay ;
//    playLay
    return [AVPlayerLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player
{
    if (self = [super initWithFrame:frame]) {
        self.player = player;
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame URL:(NSURL *)url
{
    if (self = [super initWithFrame:frame]) {
        AVPlayer *player = [AVPlayer playerWithURL:url];
        self.player = player;
    }
    return self;
}


#pragma mark - Setter & Getter

// AVPlayerLayer 有一个播放器，对播放器的取值和设值，都传递给AVPlayerLayer
- (void)setPlayer:(AVPlayer *)player
{
    
    
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    playerLayer.videoGravity =  AVLayerVideoGravityResize;
    playerLayer.player = player;
}

- (AVPlayer *)player
{
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    return playerLayer.player;
}


@end
