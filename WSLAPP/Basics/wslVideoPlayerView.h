//
//  wslVideoPlayerView.h
//  壁纸
//
//  Created by qianfeng on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface wslVideoPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;

- (instancetype)initWithFrame:(CGRect)frame player:(AVPlayer *)player;
- (instancetype)initWithFrame:(CGRect)frame URL:(NSURL *)url;

@end
