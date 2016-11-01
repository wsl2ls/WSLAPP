//
//  wslMapViewController.m
//  WSLAPP
//
//  Created by 王双龙 on 15/10/16.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslMapViewController.h"
#import <MapKit/MapKit.h>
#import "wslImageAnnotation.h"

#define SYSTEM_VERSION_LESS_THAN(v) ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

@interface wslMapViewController ()<CLLocationManagerDelegate, MKMapViewDelegate,UITextFieldDelegate>

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) MKCoordinateRegion currentRegion;

@property(nonatomic,strong)UITextField * searchTF;

@end

@implementation wslMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
    [self setupMapView];
    [self startLocation];
}
#pragma mark ----setUI
-(void)setUI
{
    //为了实现摇一摇
    [self becomeFirstResponder];
    
    UIBarButtonItem * rItem1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(searchBarBtnClicked:)];
    self.navigationItem.title = @"简易地图";
    UIBarButtonItem * item1 = [[UIBarButtonItem alloc] initWithTitle:@"截屏" style:UIBarButtonItemStylePlain target:self action:@selector(clipsScreen)];
    UIBarButtonItem  *backitem= [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(backToVC:)];
    UIBarButtonItem * rItem2 = [[UIBarButtonItem alloc] initWithTitle:@"导航" style:UIBarButtonItemStylePlain target:self action:@selector(daohang:)];
    self.navigationItem.leftBarButtonItems = @[backitem,rItem2];
    self.navigationItem.rightBarButtonItems = @[rItem1,item1];
}
-(void)backToVC:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - Helper Methods

- (void)setupMapView
{
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64)];
    
    // MKMapTypeSatellite  卫星地图
    // MKMapTypeHybrid
    self.mapView.mapType = MKMapTypeStandard;
    self.mapView.delegate = self;
    
    //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
    self.mapView.userTrackingMode=MKUserTrackingModeFollow;
    
    [self.view addSubview:self.mapView];
}

- (void)startLocation
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //  定位频率,每隔多少米定位一次
    // 距离过滤器，移动了几米之后，才会触发定位的代理函数
    self.locationManager.distanceFilter = 50;
    
    // 定位的精度，越精确，耗电量越高
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;//导航
    
    self.locationManager.delegate = self;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] > 8.0) {
        
        // info.plist -> NSLocationWhenInUseUsageDescription
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Event Handlers
//摇一摇触发
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{   //如果动作是摇一摇
    if(motion == UIEventSubtypeMotionShake)
    {  //调用截屏方法
        [self clipsScreen];
    }
}
-(void)searchBarBtnClicked:(UIBarButtonItem *)sender
{  static int searching = 1;
    if (searching == 1) {
        self.navigationItem.titleView = self.searchTF;
        searching = 0;
    }else{
        searching = 1;
        self.navigationItem.titleView = nil;
        self.navigationItem.title = @"简易地图";
        if(![self.searchTF.text isEqualToString:@""]){
            [self search:self.searchTF.text];
        }
    }
}
-(void)clipsScreen
{
    // 1. 开启图像上下文[必须先开开启上下文再执行第二步，顺序不可改变]
    UIGraphicsBeginImageContext(self.view.bounds.size);
    // 2. 获取上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    //3.将当前视图图层渲染到当前上下文
    [self.view.layer renderInContext:context];
    // 4. 从当前上下文获取图像
    UIImage *mapImage =UIGraphicsGetImageFromCurrentImageContext();
    // 5. //关闭图像上下文
    UIGraphicsEndImageContext();
    
    // 6. 保存图像至相册
    UIImageWriteToSavedPhotosAlbum(mapImage,self,@selector (image:didFinishSavingWithError:contextInfo:),nil);
    
}
#pragma mark 保存完成后调用的方法[格式固定]
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"保存至相册失败" message:   [NSString  stringWithFormat:@"error是%@",error.localizedDescription]delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }else{
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:nil message: @"保存至相册成功"delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }
}
-(void)daohang:(id)sender
{
    if (SYSTEM_VERSION_LESS_THAN(@"6.0")) {
        // ios6以下，调用google map
        //    NSString *urlString = [[NSString alloc] initWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f&dirfl=d",_start.latitude,_start.longitude,_end.latitude,_end.longitude];
        
        NSString * urlString = @"http://maps.google.com/maps?";
        NSURL *aURL = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:aURL];
        
    } else { // 直接调用ios自己带的apple map
        
        [MKMapItem openMapsWithItems:[NSArray arrayWithObjects: nil]
                       launchOptions:[NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeDriving, [NSNumber numberWithBool:YES], nil]
                                                                 forKeys:[NSArray arrayWithObjects:MKLaunchOptionsDirectionsModeKey, MKLaunchOptionsShowsTrafficKey, nil]]];
    }    
}
- (void)search:(NSString *)something
{
    // 热点搜索
    
    // 搜索请求
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    
    // 搜索关键字
    request.naturalLanguageQuery = something;
    
    // 搜索的范围
    request.region = self.currentRegion;
    
    // 用于搜索的类
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    // 开始搜索(异步)
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error == nil) {
            
            // 先清空掉原本的标注
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            // mapItems搜索结果集
            // NSLog(@"%@", response.mapItems);
            for (MKMapItem *item in response.mapItems) {
                
                
                // 标注(大头针)的模型
                wslImageAnnotation *imageAnn = [[wslImageAnnotation alloc] init];
                // item.placemark 位置信息
                imageAnn.coordinate = item.placemark.location.coordinate;
                imageAnn.title = item.name;
                imageAnn.subtitle = item.phoneNumber;
                
                imageAnn.leftImage = [UIImage imageNamed:@"location@2x"];
                imageAnn.rightImage = [UIImage imageNamed:@"head"];
                // 添加标注
                [self.mapView addAnnotation:imageAnn];
            }
        }
        else {
            NSLog(@"%@", error);
        }
    }];
}

#pragma mark - CLLocationManagerDelegate
// 定位成功之后的回调方法，只要位置改变，就会调用这个方法
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // 保存当前位置
    self.currentLocation = [locations lastObject];
    //[self.locationManager stopUpdatingLocation];
    self.mapView.showsUserLocation = YES;
    
    self.currentRegion = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.02, 0.03));
    
    [self.mapView setRegion:self.currentRegion animated:YES];
    
}


#pragma mark - MKMapViewDelegate

// 标注的View显示的代理方法(类似于TableView中CellForRow的方法)
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if (![annotation isKindOfClass:[wslImageAnnotation class]]) {
        return nil;
    }
    
    // 标注的复用
    MKAnnotationView *annView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Ann"];
    if (annView == nil) {
        annView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Ann"];
    }
    
    annView.image = [UIImage imageNamed:@"location@2x.png"];
    
    // 点击标注，显示气泡
    annView.canShowCallout = YES;
    
    wslImageAnnotation *imageAnn = annotation;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    imageView.image = imageAnn.leftImage;
    annView.leftCalloutAccessoryView = imageView;
    
    UIImageView *rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    rightImageView.image = imageAnn.rightImage;
    annView.rightCalloutAccessoryView = rightImageView;
    
    return annView;
}

#pragma mark - Getter

-(UITextField *)searchTF
{
    if ( _searchTF == nil) {
        _searchTF = [[UITextField alloc] initWithFrame:CGRectMake(100, 300, 200, 40)];
        _searchTF.backgroundColor  = [UIColor clearColor];
        self.searchTF.placeholder = @"请输入地名,地铁,KTV...";
        _searchTF.font = [UIFont systemFontOfSize:20];
        _searchTF.textColor = [UIColor blackColor];
        _searchTF.delegate = self;
        _searchTF.borderStyle = UITextBorderStyleRoundedRect;
        _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchTF.returnKeyType = UIReturnKeyDone;
    }return _searchTF;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.locationManager stopUpdatingLocation];
    self.tabBarController.tabBar.hidden = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];self.tabBarController.tabBar.hidden = YES;
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
