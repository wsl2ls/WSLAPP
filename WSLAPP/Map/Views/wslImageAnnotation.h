//
//  wslImageAnnotation.h
//  WSLAPP
//
//  Created by qianfeng on 15/10/16.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface wslImageAnnotation : NSObject<MKAnnotation>
// MKAnnotation 必须实现的3个属性
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;


// 自定义的属性
@property (nonatomic, strong) UIImage *leftImage;
@property (nonatomic, strong) UIImage *rightImage;
@end
