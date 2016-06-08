//
//  saoViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/20.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "saoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface saoViewController ()<AVCaptureMetadataOutputObjectsDelegate>//用于处理采集信息的代理
{
    AVCaptureSession * session;//输入输出的中间桥梁
}

@end

@implementation saoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"扫一扫";
    
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasTorch])
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"闪光灯" message:@"你咋木有闪光灯呢亲" delegate:self cancelButtonTitle:@"好吧" otherButtonTitles:nil];
        [alert show];
        return;
    }
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //扫描的处理区域
    output.rectOfInterest=CGRectMake(0.5,0,0.5, 1);
   // [output setRectOfInterest : CGRectMake (( 124 )/ [UIScreen mainScreen].bounds.size.height ,(( [UIScreen mainScreen].bounds.size.width - 220 )/ 2 )/ [UIScreen mainScreen].bounds.size.width , 220 /[UIScreen mainScreen].bounds.size.height , 220 / [UIScreen mainScreen].bounds.size.width)];
    
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //初始化链接对象
    session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:input];
    [session addOutput:output];
    //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    output.metadataObjectTypes=@[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame = CGRectMake(50, 200, [UIScreen mainScreen].bounds.size.width - 100, [UIScreen mainScreen].bounds.size.width - 100);
    //layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];
    //开始捕获
    [session startRunning];
}
#pragma  mark ----    AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [session stopRunning];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex : 0 ];
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:metadataObject.stringValue]];
        
       // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.baidu.com"]];
        
        //输出扫描字符串
        NSLog(@"%@",metadataObject.stringValue);
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   
    self.tabBarController.tabBar.hidden = NO;
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
