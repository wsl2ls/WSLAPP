//
//  timeViewController.m
//  WSLAPP
//
//  Created by 王双龙 on 15/10/20.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "timeViewController.h"

@interface timeViewController ()
{
        NSTimer * timer;
        int hour,minute,s,_S;
        BOOL isRunning;

}
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *msLabel;
@property (weak, nonatomic) IBOutlet UIButton *startAndStopBtn;
@property (weak, nonatomic) IBOutlet UIButton *resetBtn;
@property (weak, nonatomic) IBOutlet UILabel *bludeLabel;
@property (weak, nonatomic) IBOutlet UILabel *redLabel;

@end

@implementation timeViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationItem.title = @"计时(分)器";
    
    [self addDownSwipGesture:self.redLabel];
    [self  addUPSwipGesture:self.redLabel];
    
    [self addUPSwipGesture:self.bludeLabel];
    [self addDownSwipGesture:self.bludeLabel];
    
    [self   createTimer];
}
#pragma mark ---- 添加手势
-(void)addDownSwipGesture:(UIView *)view{
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swip:)];
    //设置方向  （一个手势只能定义一个方向）
    swip.direction = UISwipeGestureRecognizerDirectionDown;
    
    //视图添加手势
    [view addGestureRecognizer:swip];
}
-(void)addUPSwipGesture:(UIView *)view{
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swip:)];
    //设置方向  （一个手势只能定义一个方向）
    swip.direction = UISwipeGestureRecognizerDirectionUp;
        //视图添加手势
    [view addGestureRecognizer:swip];
}
-(void)swip:(UISwipeGestureRecognizer * )swip
{
    UILabel * label = (UILabel *)swip.view;
    static int r = 0;
    static int b = 0;
    switch (swip.direction) {
        case UISwipeGestureRecognizerDirectionDown:{
            CATransition *ca = [CATransition animation];
            //设置动画的格式
            ca.type = @"rippleEffect";
            //设置动画的方向
            ca.subtype = @"fromBottom";
            //设置动画的持续时间
            ca.duration = 1;
            [label.layer addAnimation:ca forKey:nil];

            if (label.tag == 18) {
                label.text = [NSString stringWithFormat:@"%d",--r];
            }else
            {
                label.text = [NSString stringWithFormat:@"%d",--b];
            }
            
        }
        break;
        case UISwipeGestureRecognizerDirectionUp:{
            CATransition *ca = [CATransition animation];
            //设置动画的格式
            ca.type = @"cube";
            //设置动画的方向
            ca.subtype = @"fromTop";
            //设置动画的持续时间
            ca.duration = 1;
            [label.layer addAnimation:ca forKey:nil];
            
            if (label.tag == 18) {
                label.text = [NSString stringWithFormat:@"%d",++r];
            }else
            {
                
            label.text = [NSString stringWithFormat:@"%d",++b];
            }

        }
        break;
        default:
            break;
    }
    
}

-(void)createTimer
{
    timer = [ NSTimer   scheduledTimerWithTimeInterval: 0.1 target:self selector:@selector(fly) userInfo: nil repeats:YES];
  //  [timer setFireDate:[NSDate  distantFuture]];
    
}
-(void)fly
{
    
    if(isRunning){
    _S++;
    if (_S == 10) {
        _S = 0;
        s++;
        if (s == 60) {
            minute ++;
            s = 0;
            if (minute == 60) {
                minute = 0;
                hour ++;
                
            }
        }
    }
   
    self.timeLabel.text =  [NSString  stringWithFormat:@"%d : %d : %d",hour,minute,s];
    self.msLabel.text  =  [NSString  stringWithFormat:@"%d",_S];
    }
    
    [self time];
    
}
-(void)time
{
    NSDate * date = [NSDate date];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd EEE H:mm:ss"];
    
    self.dateLabel.text = [df stringFromDate:date];
}
#pragma mark ---- Evens Handle

- (IBAction)startAndStopBtnClicked:(id)sender {
    
    if(isRunning )
    {  //现在在运行  我让他停掉
        isRunning = NO;
      //  [timer setFireDate:[NSDate distantFuture]];
        [self.startAndStopBtn setTitle:@"继续" forState:UIControlStateNormal];
    }else
    {   //现在状态没运行   我要让它运行起来
        isRunning = YES;
        
        [timer  setFireDate:[NSDate distantPast]];
        [self.startAndStopBtn setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
}
- (IBAction)resetBtnClicked:(id)sender {
    
    [self.startAndStopBtn  setTitle:@"开始" forState:UIControlStateNormal];
    
      self.timeLabel.text = @"00:00:00";
    self.msLabel.text = @"00";
    hour  = 0;
    minute = 0;
    s = 0;
    _S = 0;
    isRunning = NO;
   // [timer setFireDate:[NSDate distantFuture]];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //使定时器无效
     [timer invalidate];
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
