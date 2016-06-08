//
//  newsTableViewCell.h
//  news
//
//  Created by qianfeng on 15/10/7.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface newsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *litpicImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabe;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *lookLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end
