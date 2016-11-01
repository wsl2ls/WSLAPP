//
//  SongModel.h
//  SongPlayer
//
//  Created by 王双龙 on 15/9/21.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SongModel : NSObject
@property(nonatomic,copy) NSString * songName;
@property(nonatomic,copy)  NSString * singerName;
@property(nonatomic,copy) NSString * songUrl;
@property(nonatomic,copy)NSString * songID;
@property(nonatomic,copy)NSString * localPath;
@end
