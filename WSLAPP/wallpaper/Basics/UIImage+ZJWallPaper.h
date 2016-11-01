//
//  UIImage+ZJWallPaper.h
//  ZJWallPaperDemo
//
//  Created by onebyte on 15/7/17.
//  Copyright (c) 2015年 onebyte. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ZJWallPaper)

/*!
 *  保存为桌面壁纸和锁屏壁纸
 */
- (void)zj_saveAsHomeScreenAndLockScreen;

/*!
 *  保存为桌面壁纸
 */
- (void)zj_saveAsHomeScreen;

/*!
 *  保存为锁屏壁纸
 */
- (void)zj_saveAsLockScreen;

/*!
 *  保存到照片库
 */
- (void)zj_saveToPhotos;

@end
