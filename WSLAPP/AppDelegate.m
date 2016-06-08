//
//  AppDelegate.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/14.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "AppDelegate.h"
#import "wslRootViewController.h"
#import "wslNavigationController.h"
#import "UMSocial.h"
#import "UMSocialQQHandler.h"
#import "UMSocialWechatHandler.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIWindow * window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.backgroundColor =  [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    self.window = window;
    [self.window makeKeyAndVisible];
    
    //让app支持接受远程控制事件
    //设置app支持接受远程控制事件，其实就是在dock中可以显示应用程序图标，同时点击该图片时，打开app
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    

    
    // iOS8以上版本注册通知权限
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil]];
    }

    wslRootViewController * rootVc = [[wslRootViewController alloc] init];
    
    // 设置友盟的Key
    [UMSocialData setAppKey:@"507fcab25270157b37000010"];
    
  
    //设置分享到QQ/Qzone的应用Id，和分享url 链接
    [UMSocialQQHandler setQQWithAppId:@"1104927471" appKey:@"DCM5IBTYED0HpxTZ" url:@"http://www.henau.edu.cn"];
    //设置支持没有客户端情况下使用SSO授权
    [UMSocialQQHandler setSupportWebView:YES];
    
    //设置微信AppId、appSecret，分享url
    [UMSocialWechatHandler setWXAppId:@"wxd930ea5d5a258f4f" appSecret:@"db426a9829e4b49a0dcac7b4162da6b6" url:@"http://www.henau.edu.cn"];
    
    
    //[UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ, UMShareToQzone, UMShareToWechatSession, UMShareToWechatTimeline]];
    
    self.window.rootViewController = rootVc;

     NSLog(@"bundle %@",[NSBundle mainBundle].bundleIdentifier );
    
    return YES;
    
}

//处理后台传递给我们的信息，用于音乐
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    
    if (event.type == UIEventTypeRemoteControl) {
     
        NSLog(@"%ld",event.subtype);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"songControlNotification" object:self userInfo:@{@"subtype":@(event.subtype)}];
        
        /*
         
         subtype中的枚举便是点击这些控制键后传递给我们的消息，我们可以根据这些消息在app内做逻辑处理。枚举如下，其中只有100之后的在音频控制中对我们有效：
         
         typedef NS_ENUM(NSInteger, UIEventSubtype) {
         
            // available in iPhone OS 3.0
            UIEventSubtypeNone                              = 0,
            // for UIEventTypeMotion, available in iPhone OS 3.0
            UIEventSubtypeMotionShake                       = 1,
            //这之后的是我们需要关注的枚举信息
            // for UIEventTypeRemoteControl, available in iOS 4.0
            //点击播放按钮或者耳机线控中间那个按钮
            UIEventSubtypeRemoteControlPlay                 = 100,
            //点击暂停按钮
            UIEventSubtypeRemoteControlPause                = 101,
            //点击停止按钮
            UIEventSubtypeRemoteControlStop                 = 102,
            //点击播放与暂停开关按钮(iphone抽屉中使用这个)
            UIEventSubtypeRemoteControlTogglePlayPause      = 103,
            //点击下一曲按钮或者耳机中间按钮两下
            UIEventSubtypeRemoteControlNextTrack            = 104,
            //点击上一曲按钮或者耳机中间按钮三下
            UIEventSubtypeRemoteControlPreviousTrack        = 105,
            //快退开始 点击耳机中间按钮三下不放开
            UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
            //快退结束 耳机快退控制松开后
            UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
            //开始快进 耳机中间按钮两下不放开
            UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
            //快进结束 耳机快进操作松开后
            UIEventSubtypeRemoteControlEndSeekingForward    = 109,
        };
     */
        
    }
}


#pragma mark - 第三方登录回调方法

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return  [UMSocialSnsService handleOpenURL:url];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
    
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
