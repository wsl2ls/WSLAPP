//
//  QFURLRequest.h
//  AiXianMian
//
//  Created by PK on 14-1-7.
//  Copyright (c) 2014年 PK. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QFURLRequest : NSObject<NSURLConnectionDataDelegate>{
    NSMutableData* _mData;
}

@property (nonatomic,assign) BOOL isCache;
@property (nonatomic, copy) NSString* url;
@property (nonatomic, copy) void (^finishBlock)(NSData* data);
@property (nonatomic, copy) void (^failedBlock)();

- (void)startRequest;

@end
