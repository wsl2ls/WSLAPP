//
//  QFRequestManager.m
//  AiXianMian
//
//  Created by PK on 14-1-7.
//  Copyright (c) 2014年 PK. All rights reserved.
//

#import "QFRequestManager.h"

@implementation QFRequestManager

+ (void)requestWithUrl:(NSString *)url IsCache:(BOOL)isCache Finish:(void (^)(NSData *))finishBlock Failed:(void (^)())failedBlock{
    QFURLRequest* request = [[QFURLRequest alloc] init];
    request.url = url;
    request.isCache = isCache;
    request.finishBlock = finishBlock;
    request.failedBlock = failedBlock;
    [request startRequest];
}

@end
