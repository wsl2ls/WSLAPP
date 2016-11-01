//
//  imageScrView.h
//  SongPlayer
//
//  Created by 王双龙 on 15/9/22.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol imageScrViewDelegate <NSObject>

-(void)imageScrToViewControllerWithIndex:(NSInteger) index;

@end

@interface imageScrView : UIView <UIScrollViewDelegate>
@property(nonatomic,strong)NSMutableArray * imageArray;

@property(nonatomic,weak)id<imageScrViewDelegate>delegate;
-(void)reloadData;
@end
