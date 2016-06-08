//
//  wslAVPlayerManager.h
//  SongPlayer
//
//  Created by qianfeng on 15/10/5.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface wslAVPlayerManager : AVPlayer
+ (instancetype)shareManager;
@end
