//
//  wslRingTableViewCell.h
//  壁纸
//
//  Created by qianfeng on 15/10/12.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wslRingTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *duringLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *favsLabel;

@property(nonatomic,copy) NSString * fid;
@end
