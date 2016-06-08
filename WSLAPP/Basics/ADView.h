//
//  ADView.h
//  01CustomUITableViewCell
//
//  Created by 郝海圣 on 15/9/1.
//  Copyright (c) 2015年 qianfeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ADView : UIView
@property (nonatomic,retain) NSArray *imageArray;//存储的是图片名称的数组
-(void)reloadData;//刷新数据
-(void)removeSub;
@end
