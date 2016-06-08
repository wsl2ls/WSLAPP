//
//  wslAVPlayerManager.m
//  SongPlayer
//
//  Created by qianfeng on 15/10/5.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import "wslAVPlayerManager.h"

@implementation wslAVPlayerManager
+ (instancetype)shareManager
{
    // 这种是线程安全的
    static wslAVPlayerManager *manager;
    
    static dispatch_once_t token;
    
    // 这个函数，能保证后面的block只会被执行一次
    dispatch_once(&token, ^{
        manager = [[wslAVPlayerManager alloc] init];
    });
    
    return manager;
}
@end
