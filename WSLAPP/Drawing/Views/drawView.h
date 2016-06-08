//
//  drawView.h
//  画画
//
//  Created by qianfeng on 15/10/5.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface drawView : UIView

//线条的颜色透明度(颜色深浅),粗细，颜色
@property(nonatomic,strong) UIColor * lineColor;
@property(nonatomic,strong) NSNumber * lineWidth;
@property(nonatomic,assign) float lineArf;


//清除所有
-(void)cleanAll;
//上一步
-(void)backStep;
//下一步
-(void)nextStep;


@end
