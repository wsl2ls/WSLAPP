//
//  wslCategoryViewController.m
//  壁纸
//
//  Created by 王双龙 on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//
#import "AppDelegate.h"
#import "wslCategoryViewController.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "QFRequestManager.h"

#import "wslCustomCollectionViewCell.h"
#import "wslCategoryDetailViewController.h"
#import "pictureModel.h"

@interface wslCategoryViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSMutableArray * picturesArray;

@end

@implementation wslCategoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

-(void)setupUI
{
    [self.view  addSubview:self.collectionView];
    [self downloadPictureData];
    
}
#pragma mark ---- downloadPictureData
- (void)downloadPictureData
{
    [QFRequestManager requestWithUrl:@"http://service.picasso.adesk.com/v1/wallpaper/category" IsCache:YES Finish:^(NSData *data) {
        id jsonObj  =[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSArray * categoryArray = jsonObj[@"res"][@"category"];
        for (NSDictionary * dict in categoryArray) {
            pictureModel * model = [[pictureModel alloc] init];
            model.imgUrlStr = dict[@"cover"];
            model.categoryName = dict[@"name"];
            model.categoryID = dict[@"id"];
            [self.picturesArray  addObject:model];
        }
        [self.collectionView  reloadData];
    } Failed:^{
        NSLog(@"error ");
    }];
}

#pragma mark  --- UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picturesArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{  
    wslCustomCollectionViewCell * item  = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemID" forIndexPath:indexPath];
    pictureModel * model = self.picturesArray[indexPath.item];
    [item.imageView  sd_setImageWithURL:[NSURL URLWithString:model.imgUrlStr] placeholderImage:[UIImage imageNamed:@"head"]];
    item.textLabel.text = model.categoryName;
    
    
    return item;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    pictureModel * model =  self.picturesArray[indexPath.item];
    wslCategoryDetailViewController * detailVC = [[wslCategoryDetailViewController alloc] init];
    detailVC.categoryID = model.categoryID ;
    detailVC.title = model.categoryName;
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    [dele.rootNavc pushViewController:detailVC animated:YES];
}
#pragma mark ---- Getter
-(UICollectionView *)collectionView
{
    if(_collectionView == nil){
        UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc] init];
        flow.itemSize = CGSizeMake((self.view.frame.size.width - 30) /2.0, 150);
        flow.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,  self.view.frame.size.height - 64 ) collectionViewLayout:flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor =    [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
        _collectionView.scrollEnabled = YES;
        //注册UICollectionViewcell
        [_collectionView  registerNib:[UINib nibWithNibName:@"wslCustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"itemID"];
    }
    return _collectionView;
}
-(NSMutableArray *)picturesArray
{
    if (_picturesArray == nil) {
        _picturesArray = [[NSMutableArray alloc] init];
    }return _picturesArray;
}
-(void)viewDidAppear:(BOOL)animated
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    [super viewDidAppear:animated];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
