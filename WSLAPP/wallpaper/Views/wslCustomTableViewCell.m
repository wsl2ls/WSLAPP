//
//  wslCustomTableViewCell.m
//  壁纸
//
//  Created by 王双龙 on 15/10/10.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "AppDelegate.h"

#import "wslCustomTableViewCell.h"
#import "wslCustomCollectionViewCell.h"
#import "wslPicDetailViewController.h"
#import "UIImageView+WebCache.h"

@interface wslCustomTableViewCell ()

@property (nonatomic,strong) UICollectionView *collectionView;

@property(nonatomic,strong) NSMutableArray * imagesArray;

@end


@implementation wslCustomTableViewCell

- (void)awakeFromNib {
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self customCell];
    }return self;
}

-(void)customCell
{
   [self.contentView  addSubview:self.collectionView];
}

-(UICollectionView *)collectionView
{
    if(_collectionView == nil){
        UICollectionViewFlowLayout * flow = [[UICollectionViewFlowLayout alloc] init];
        flow.itemSize = CGSizeMake(( [UIScreen mainScreen].bounds.size.width - 30) / 2.0f, 150);
        flow.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300) collectionViewLayout:flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor =    [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
        _collectionView.scrollEnabled = NO;
        //注册UICollectionViewcell
        [_collectionView  registerNib:[UINib nibWithNibName:@"wslCustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"itemID"];
    }
    return _collectionView;
}

-(void)reloadData
{
    if (self.picturesArray.count > 4 ) {
    self.collectionView.frame = CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, self.picturesArray.count / 2  * 150 +150 +50) ;
        
    }
    if(self.picturesArray.count > 10){
    self.collectionView.frame = CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.width, self.picturesArray.count / 2  * 150 +300 ) ; }
        [self.collectionView  reloadData];
}

#pragma mark  --- UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.picturesArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{    
    wslCustomCollectionViewCell * item  = [collectionView dequeueReusableCellWithReuseIdentifier:@"itemID" forIndexPath:indexPath];
            [item.imageView  sd_setImageWithURL:[NSURL URLWithString:self.picturesArray[indexPath.item]] placeholderImage:[UIImage imageNamed:@"head"]];
    
    return item;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    wslPicDetailViewController * picDetailVc = [[wslPicDetailViewController alloc] init];
    AppDelegate * dele = [UIApplication sharedApplication].delegate;
    picDetailVc.imgUrlStr = self.picturesArray[indexPath.row];
    picDetailVc.imgID = self.picIdArr[indexPath.row];
    [dele.rootNavc pushViewController:picDetailVc animated:YES];
    

}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
