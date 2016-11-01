//
//  downloadTableViewCell.h
//  WSLAPP
//
//  Created by 王双龙 on 15/10/22.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"

@interface downloadTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *startOrStopBtn;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UILabel *currentSizeLabel;

@property(nonatomic,copy) NSString * songUrlStr;

@property(nonatomic,strong) NSMutableArray * songArray;

@property(nonatomic,strong)
AFHTTPRequestOperation * operation;

-(void)downloadSong;

@end
