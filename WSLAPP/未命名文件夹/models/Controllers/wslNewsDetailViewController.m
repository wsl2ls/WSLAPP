//
//  wslNewsDetailViewController.m
//  news
//
//  Created by qianfeng on 15/10/8.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslNewsDetailViewController.h"
#import "JGProgressHUD.h"

@interface wslNewsDetailViewController ()<UIWebViewDelegate,UIGestureRecognizerDelegate,NSURLSessionDelegate,UIScrollViewDelegate>
{
    UIWebView *webView;
}

@property (nonatomic, strong) JGProgressHUD   *progressHUD;

@end

@implementation wslNewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithTitle:@"后退" style:UIBarButtonItemStyleDone target:self action:@selector(goBack)];
    UIBarButtonItem *forwardItem = [[UIBarButtonItem alloc] initWithTitle:@"前进" style:UIBarButtonItemStyleDone target:self action:@selector(goForward)];
    self.navigationItem.rightBarButtonItems = @[backItem,forwardItem];
    
      [self setupUI];
    
    // 显示HUD 菊花状等待
    CGRect rect = [[UIScreen mainScreen] bounds];
    rect.origin.y -= 50;
    [self.progressHUD showInRect:rect inView:self.view animated:YES];
}

-(void)goBack
{
     [webView goBack];
}
-(void)goForward
{
    [webView goForward];
}

-(void)setupUI
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64 )];
    webView.userInteractionEnabled = YES;
    webView.backgroundColor=[UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    webView.dataDetectorTypes = UIDataDetectorTypeLink;
    NSURLRequest *request=[[NSURLRequest alloc]initWithURL:[NSURL URLWithString:self.linkUrlString]];
    [webView goBack];
    [webView goForward];
    webView.delegate = self;
    webView.backgroundColor=[UIColor clearColor];
    webView.opaque=YES;//这句话很重要，webView是否是不透明的，no为透明 在webView下添加个imageView展示图片就可以了
    webView.scalesPageToFit = YES;
    [webView loadRequest:request];
    [self.view addSubview:webView];
    
    
    UIScrollView * scr = [webView subviews][0];
    scr.delegate = self;
    scr.contentOffset = CGPointMake(0, 100);
    
    
    UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    //longPress.delegate = self;
    [webView addGestureRecognizer:longPress];
}

- (void)longPressed:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }
    
    CGPoint touchPoint = [recognizer locationInView:webView];
    
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y];
    NSString *urlToSave = [webView stringByEvaluatingJavaScriptFromString:imgURL];
    
    if (urlToSave.length == 0) {
        return;
    }
    
    [self shouwImageOptionsWithUrl:urlToSave];
}

- (void)shouwImageOptionsWithUrl:(NSString *)Imageurl{
    
    UIAlertController *alart = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定保存到相册？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self saveImageToDiskWithUrl:Imageurl];
    }];
    
    [alart addAction:action2];
    [alart addAction:action1];
   
    [self presentViewController:alart animated:YES completion:nil];
   
}
- (void)saveImageToDiskWithUrl:(NSString *)imageUrl
{
    NSURL *url = [NSURL URLWithString:imageUrl];
    
    NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue new]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:30.0];
    
    NSURLSessionDownloadTask  *task = [session downloadTaskWithRequest:imgRequest completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            return ;
        }
        
        NSData * imageData = [NSData dataWithContentsOfURL:location];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIImage * image = [UIImage imageWithData:imageData];
            
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        });   
    }];
    
    [task resume];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    UIAlertController *alart;
    if (error) {
        alart = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存失败" preferredStyle:UIAlertControllerStyleAlert];
    }else{
         alart = [UIAlertController alertControllerWithTitle:@"提示" message:@"保存成功" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    [self presentViewController:alart animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [alart dismissViewControllerAnimated:YES completion:nil];
                });
        
    }];

    
}



#pragma mark  ---- UIWebViewDelegate
//webView加载完成回调
- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    //隐藏HUD
    [self.progressHUD dismissAnimated:YES];
    
    self.navigationItem.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    NSLog(@"webView.contentOffset.y %f",scrollView.contentOffset.y);
    
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
    
    UIScrollView * scr = [webView subviews][0];
    scr.delegate = self;
    scr.contentOffset = CGPointMake(0, 0);
 
}

- (JGProgressHUD *)progressHUD
{
    if (_progressHUD == nil) {
        _progressHUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleLight];
        _progressHUD.textLabel.text = @"龙哥帮你加载数据...";
    }
    return _progressHUD;
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
    [webView stopLoading];
    
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
