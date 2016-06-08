//
//  newsModel.h
//  news
//
//  Created by qianfeng on 15/10/7.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface newsModel : NSObject

@property(nonatomic,copy) NSString * desc;
@property(nonatomic,copy) NSString * link;
@property(nonatomic,copy) NSString * litpic;
@property(nonatomic,copy) NSString * litpic_2;
@property(nonatomic,copy) NSString * news_id;
@property(nonatomic,copy) NSString * pubDate;
@property(nonatomic,copy) NSString * tags;
@property(nonatomic,copy) NSString * title;
@property(nonatomic,copy) NSString * views;
@property(nonatomic,copy) NSString * writer;

@end
