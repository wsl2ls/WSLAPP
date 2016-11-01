//
//  downloadTableViewCell.m
//  WSLAPP
//
//  Created by 王双龙 on 15/10/22.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "downloadTableViewCell.h"
#import "AFNetworking.h"
#import "SongModel.h"

#define  WSLLibraryDirectory  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"Songs"]

@interface downloadTableViewCell ()

@end

@implementation downloadTableViewCell

- (void)awakeFromNib {

}
- (IBAction)startOrStopBtnClicked:(id)sender {
    UIButton * button = (UIButton *)sender;
    if (!self.operation.isPaused) {
        [self.operation pause];
        [button  setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else
    {
        [self.operation resume];
          [button  setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}
-(void)downloadSong
{
    self.statusImageView.layer.cornerRadius = 20.0f;
    self.statusImageView.clipsToBounds = YES;
    NSString *downloadUrl = self.songUrlStr;
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:WSLLibraryDirectory]) {
     [[NSFileManager defaultManager]  createDirectoryAtPath:WSLLibraryDirectory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *downloadPath = [WSLLibraryDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp3",self.songNameLabel.text]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadUrl]];
//    //如果存在就删除原来的
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:downloadPath error:nil];
        self.progressView.progress = 0;
        self.progressLabel.text = @"00.0%";
        self.currentSizeLabel.text  = @"0M/0M";
    }
    //检查文件是否已经下载了一部分
    unsigned long long downloadedBytes = 0;
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]) {
        //获取已下载的文件长度
        downloadedBytes = [self fileSizeForPath:downloadPath];
        if (downloadedBytes > 0) {
            NSMutableURLRequest *mutableURLRequest = [request mutableCopy];
            NSString *requestRange = [NSString stringWithFormat:@"bytes=%llu-", downloadedBytes];
            [mutableURLRequest setValue:requestRange forHTTPHeaderField:@"Range"];
            request = mutableURLRequest;
        }
    }
    //不使用缓存，避免断点续传出现问题
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    //下载请求
    self.operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        //下载路径
    self.operation.outputStream = [NSOutputStream outputStreamToFileAtPath:downloadPath append:YES];
    
    __weak downloadTableViewCell * weakSelf = self;
    
    //下载进度回调
    [self.operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        //下载进度
        float progress = ((float)totalBytesRead + downloadedBytes) / (totalBytesExpectedToRead + downloadedBytes);
        if (progress > 1) {
            return ;
        }
        weakSelf.progressView.progress = progress;
        weakSelf.progressLabel.text = [NSString stringWithFormat:@"%.1f%%",progress*100];
        
        weakSelf.currentSizeLabel.text = [NSString stringWithFormat:@"%.2fM/%.2fM",(float)(totalBytesRead + downloadedBytes)/1024/1024,(float)(totalBytesExpectedToRead + downloadedBytes)/1024/1024];
        
}];
    //成功和失败回调
    [self.operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
          [weakSelf.startOrStopBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        weakSelf.startOrStopBtn.enabled = NO;
        weakSelf.statusImageView.image = [UIImage imageNamed:@"duihao.jpg"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         [weakSelf.startOrStopBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        weakSelf.startOrStopBtn.enabled = NO;
         weakSelf.statusImageView.image = [UIImage imageNamed:@"cuowu.png"];
        NSLog(@"ERROR : %@",error);
    }];
    
        [self.operation start];
    
//    AFHTTPRequestOperationManager * manager = [AFHTTPRequestOperationManager manager];
//    manager.operationQueue.operations  = ;
    
}
//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
