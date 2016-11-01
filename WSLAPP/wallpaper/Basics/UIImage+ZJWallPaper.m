//
//  UIImage+ZJWallPaper.m
//  ZJWallPaperDemo
//
//  Created by onebyte on 15/7/17.
//  Copyright (c) 2015年 onebyte. All rights reserved.
//

#import "UIImage+ZJWallPaper.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface UIImage ()

@end

@implementation UIImage (ZJWallPaper)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
/*!
 *  保存为桌面壁纸和锁屏壁纸
 */
- (void)zj_saveAsHomeScreenAndLockScreen
{
    [self.zj_wallPaperVC performSelector:@selector(setImageAsHomeScreenAndLockScreenClicked:) withObject:nil];
}

/*!
 *  保存为桌面壁纸
 */
- (void)zj_saveAsHomeScreen
{
    [self.zj_wallPaperVC performSelector:@selector(setImageAsHomeScreenClicked:) withObject:nil];
    
}

/*!
 *  保存为锁屏壁纸
 */
- (void)zj_saveAsLockScreen
{
    [self.zj_wallPaperVC performSelector:@selector(setImageAsLockScreenClicked:) withObject:nil];
}

/*!
 *  保存到照片库
 */
- (void)zj_saveToPhotos
{
    UIImageWriteToSavedPhotosAlbum(self, nil,nil, NULL);
}

#pragma clang diagnostic pop

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (id)zj_wallPaperVC
{
    Class wallPaperClass = NSClassFromString(@"PLStaticWallpaperImageViewController");
    id wallPaperInstance = [[wallPaperClass alloc] performSelector:NSSelectorFromString(@"initWithUIImage:") withObject:self];
    [wallPaperInstance setValue:@(YES) forKeyPath:@"allowsEditing"];
    [wallPaperInstance  setValue:@(YES) forKeyPath:@"saveWallpaperData"];
    
    return wallPaperInstance;
}
#pragma clang diagnostic pop


@end
