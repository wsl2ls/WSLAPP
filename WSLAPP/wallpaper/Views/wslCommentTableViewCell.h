//
//  wslCommentTableViewCell.h
//  壁纸
//
//  Created by qianfeng on 15/10/12.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface wslCommentTableViewCell : UITableViewCell



@property (weak, nonatomic) IBOutlet UILabel *nameLabelk;
@property (weak, nonatomic) IBOutlet UILabel *contetLabel;
@property (weak, nonatomic) IBOutlet UILabel *atimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (weak, nonatomic) IBOutlet UIButton *zanBtn;



@end
