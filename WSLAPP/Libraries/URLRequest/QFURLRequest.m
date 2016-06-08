//
//  QFURLRequest.m
//  AiXianMian
//
//  Created by PK on 14-1-7.
//  Copyright (c) 2014年 PK. All rights reserved.
//

#import "QFURLRequest.h"
#import "NSString+Hashing.h"
#import "AppDelegate.h"

@implementation QFURLRequest

- (id)init{
    if (self = [super init]) {
        _mData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)startRequest{
 
    //缓存
    if (self.isCache) {
        //使用缓存
        NSString* path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/%@",[self.url MD5Hash]];
        NSFileManager* manager = [NSFileManager defaultManager];
        //文件存在
        if ([manager fileExistsAtPath:path]) {
            NSData* data = [NSData dataWithContentsOfFile:path];
            self.finishBlock(data);
            return;
        }
    }
    
    //开始请求
    NSURL* url = [NSURL URLWithString:self.url];
    NSURLRequest* request = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
   
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [_mData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

    //写缓存
    if (self.isCache) {
        NSString* path = [NSHomeDirectory() stringByAppendingFormat:@"/tmp/%@",[self.url MD5Hash]];
        [_mData writeToFile:path atomically:YES];
    }
    
    self.finishBlock(_mData);
   
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.failedBlock();

}





@end
