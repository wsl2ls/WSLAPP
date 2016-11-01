//
//  ADView.m
//  01CustomUITableViewCell
//
//  Created by 郝海圣 on 15/9/1.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import "ADView.h"
@interface ADView()<UIScrollViewDelegate>
@end
@implementation ADView

//重写父类方法
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //定制view
        [self customView];
    }
    return self;
}
-(void)customView{
    //创建srcollView 并添加为view的子视图
    UIScrollView *src= [[UIScrollView alloc]initWithFrame:self.bounds];
    //设置分页效果
    src.pagingEnabled = YES;
    //设置tag值
    src.tag = 11;
    //水平位置指示条
    src.showsHorizontalScrollIndicator = NO;
    //回弹
    src.bounces = NO;
    //设置代理
    src.delegate = self;
    [self addSubview:src];
    
    //创建页码显示器
    UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake((self.frame.size.width - 100) / 2, self.frame.size.height-50, 100, 30)];
    pageControl.currentPage = 0;
    pageControl.tag = 10;
    pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    pageControl.pageIndicatorTintColor = [UIColor redColor];
    [self addSubview:pageControl];
}
//刷新数据
-(void)reloadData{
    //获得src
    UIScrollView *src = (id)[self viewWithTag:11];
    
    //根据图片数组的个数创建相同个数的UIImageView
    for (int i = 0; i < self.imageArray.count; i++) {
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
        imageView.image = [UIImage imageNamed:self.imageArray[i]];
        [src addSubview:imageView];
    }
    //设置内容视图的大小
    src.contentSize = CGSizeMake(self.imageArray.count*self.frame.size.width, self.frame.size.height);
    
    //获得page
    UIPageControl *page = (UIPageControl *)[self viewWithTag:10];
    page.numberOfPages = self.imageArray.count;
    
}
#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //偏移量
    CGPoint point = scrollView.contentOffset;
    UIPageControl *page = (UIPageControl *)[self viewWithTag:10];
    //设置当前的page
    page.currentPage = point.x/self.frame.size.width;
}
-(void)removeSub{
    UIPageControl *page = (id)[self viewWithTag:10];
    [page removeFromSuperview];
    UIScrollView *src = (id)[self viewWithTag:11];
    [src removeFromSuperview];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
