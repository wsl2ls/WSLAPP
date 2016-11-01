//
//  wslAnalyzer.h
//  歌词解析1
//
//  Created by 王双龙 on 15/8/1.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SongModel.h"

@interface wslAnalyzer : NSObject

@property(nonatomic,strong)NSMutableArray * lrcArray;
-(NSMutableArray *)analyzerLrcByStr:(NSString *)str;


@end
