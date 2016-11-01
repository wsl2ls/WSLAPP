//
//  imageScrView.m
//  SongPlayer
//
//  Created by 王双龙 on 15/9/22.
//  Copyright (c) 2015年 王双龙. All rights reserved.
//

#import "imageScrView.h"
#import "UIImageView+WebCache.h"
#import "wslSongMainViewController.h"
#import "songPlayViewController.h"

@interface imageScrView ()
{
      NSInteger _currentPage;
    UIImageView * _imageview;
}
@end

@implementation imageScrView

-(id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self  customView];
    }return self;
}
-(void)customView
{
    UIScrollView * src = [[UIScrollView alloc] initWithFrame:self.bounds];
    src.pagingEnabled = YES;
    src.tag = 23;
    src.showsHorizontalScrollIndicator = NO;
    src.backgroundColor = [UIColor colorWithRed:0/255.0f green:195/255.0f blue:228/255.0f alpha:1.0f];
    src.contentOffset = CGPointMake(self.frame.size.width, 0);
    src.delegate = self;
    [self addSubview:src];
    
    UIPageControl * pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.frame.size.width-100, self.frame.size.height-10, 70,10 )];
    pageControl.currentPage = 0;
    pageControl.tag = 24;
    _currentPage = 1;
    pageControl.currentPage = _currentPage -1  ;
    pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    pageControl.pageIndicatorTintColor = [UIColor redColor];
    [self addSubview:pageControl];
    
    _imageview = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
    _imageview.image = [UIImage imageNamed:@"head"];
    [src addSubview:_imageview];
}
-(void)reloadData
{
    [_imageview  removeFromSuperview];
    UIScrollView * src = (id)[self  viewWithTag:23];
    if(self.imageArray.count != 0){
    [self.imageArray  insertObject:[self.imageArray lastObject] atIndex:0];
    [self.imageArray  addObject:self.imageArray[1]];
     }
    for (int i = 0; i < self.imageArray.count; i++) {
        UIImageView * imageview = [[UIImageView alloc] initWithFrame:CGRectMake(i*self.frame.size.width, 0, self.frame.size.width, self.frame.size.height)];
       [imageview sd_setImageWithURL:[NSURL  URLWithString:self.imageArray[i]]  placeholderImage:[UIImage imageNamed:@"head"]];
        imageview.tag = 30+i;
        //添加手势
        UITapGestureRecognizer * tap =   [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        [imageview addGestureRecognizer:tap];
        
        imageview.userInteractionEnabled = YES;
        [src addSubview:imageview];
    }
    src.contentSize = CGSizeMake(self.imageArray.count*self.frame.size.width, self.frame.size.height);
    UIPageControl * page = (UIPageControl *)[self viewWithTag:24];
    page.numberOfPages = self.imageArray.count-2;
}
-(void)tap:(UITapGestureRecognizer *)tap
{    UIImageView * imageView = (UIImageView *)tap.view;
    if (_delegate  && [_delegate  respondsToSelector:@selector(imageScrToViewControllerWithIndex:)]) {
        [_delegate  imageScrToViewControllerWithIndex:imageView.tag-31];
    }else
    {
        NSLog(@"没有设置代理，或没有代理方法");
    }
}

#pragma mark UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint point = scrollView.contentOffset;
    if (point.x == 0) {
        point.x = self.frame.size.width * (self.imageArray.count - 2);
    }
    else if (point.x == self.frame.size.width * (self.imageArray.count - 1) )
    {
        point.x = self.frame.size.width;
    }
    UIPageControl * page = (UIPageControl *)[self viewWithTag:24];
   _currentPage = point.x/self.frame.size.width;
    scrollView.contentOffset = point;
    page.currentPage = _currentPage -1 ;
}
-(NSMutableArray *)imageArray
{
    if (_imageArray == nil) {
        _imageArray = [[NSMutableArray alloc] init];
    }return _imageArray;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
