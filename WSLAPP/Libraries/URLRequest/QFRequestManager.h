//
//  QFRequestManager.h
//  AiXianMian
//
//  Created by PK on 14-1-7.
//  Copyright (c) 2014年 PK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QFURLRequest.h"

@interface QFRequestManager : NSObject

+ (void)requestWithUrl:(NSString*)url IsCache:(BOOL)isCache Finish:(void(^)(NSData* data))finishBlock Failed:(void(^)())failedBlock;

@end
