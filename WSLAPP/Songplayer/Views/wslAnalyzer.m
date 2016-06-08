//
//  wslAnalyzer.m
//  歌词解析1
//
//  Created by qianfeng on 15/8/1.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import "wslAnalyzer.h"
#import "wslLrcEach.h"
#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import"songPlayViewController.h"

@implementation wslAnalyzer

-(NSMutableArray *)lrcArray
{
    if (_lrcArray == nil) {
        _lrcArray = [[NSMutableArray alloc] init];
    }return _lrcArray;
}

-(NSMutableArray *)analyzerLrcByStr:(NSString *)str
{
     [self     analyzerLrc:str];
     return self.lrcArray;
}

-(void)analyzerLrc:(NSString *)lrcConnect
{
    
    NSArray *  lrcConnectArray = [lrcConnect   componentsSeparatedByString:@"\n"];
    
    NSMutableArray    *  lrcConnectArray1 =[[NSMutableArray  alloc] initWithArray: lrcConnectArray ];
    
    for (NSUInteger i = 0;  i < [lrcConnectArray1  count]  ;i++ ) {
        if ([lrcConnectArray1[i]   length] == 0 ) {
            [lrcConnectArray1  removeObjectAtIndex:i];
            i--;
        }
    }
    
  //  NSMutableArray * realLrcArray = [self  deleteNoUseInfo:lrcConnectArray1];
    [self    analyzerEachLrc:lrcConnectArray1];
    
}
-(NSMutableArray *)deleteNoUseInfo:(NSMutableArray *)lrcmArray
{
    for (NSUInteger i = 0; i < [lrcmArray count] ; i++)
    {
        unichar  ch = [lrcmArray[i] characterAtIndex:1];
        if(!isnumber(ch)){
            [lrcmArray removeObjectAtIndex:i];
            i--;
        }
    }
    return lrcmArray;
}

-(void)analyzerEachLrc:(NSMutableArray *)lrcConnectArray
{
    for (NSUInteger i = 0;  i < [lrcConnectArray  count] ;  i++) {
        
        
        NSArray * eachLrcArray = [lrcConnectArray[i]   componentsSeparatedByString:@"]"];
        
        NSString * lrc = [eachLrcArray  lastObject];
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
          [df  setDateFormat:@"[mm:ss.SS"];
        
        NSDate * date1 = [df  dateFromString:eachLrcArray[0] ];
        NSDate *date2 = [df dateFromString:@"[00:00.00"];
        NSTimeInterval  interval1 = [date1  timeIntervalSince1970];
        NSTimeInterval  interval2 = [date2  timeIntervalSince1970];
        interval1 -= interval2;
        if (interval1 < 0) {
            interval1 *= -1;
        }
      //  NSString * str = eachLrcArray[1];
      //  if (str.length != 0) {
             wslLrcEach   * eachLrc = [[wslLrcEach alloc] init];
        eachLrc.lrc = lrc;
        eachLrc.time =  interval1;
        [self.lrcArray addObject:eachLrc];
      //  }
    }
}



@end
