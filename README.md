简书地址：https://www.jianshu.com/p/0b7da06101ab

WSL是一款拥有 音乐播放，新闻，壁纸，画板，简易地图，计时器等等功能的小项目，是我自己早期学习时做着玩的，并没上架；UI是自己设计，所以挺吃藕的，粗糙的，没做适配，是在6尺寸下开发的 ,还希望不要嫌弃了O(∩_∩)O哈哈~，接口是抓取安卓壁纸、天天动听、IPadDown新闻的接口！此小项目仅作为学习参考用！下面稍微介绍下此APP的功能模块，有需要的可以去去 [我的github](https://github.com/wslcmk/WSLAPP.git) ,欢迎star！
（gif有点大，有的压缩的失真了，，，，）

0 、启动界面
第一次安装运行会有APP的介绍页面，对于启动的动画，是一个小视频，根据当前的系统时间，会有春夏秋冬四种不同的启动画面。可以看壁纸1效果图。

一、壁纸模块


![壁纸1.gif](http://upload-images.jianshu.io/upload_images/1708447-cae9eabc6c299b54.gif?imageMogr2/auto-orient/strip)
![壁纸2.gif](http://upload-images.jianshu.io/upload_images/1708447-aa83ecfdebd172cd.gif?imageMogr2/auto-orient/strip)

壁纸这块主要是通过应用直接更改系统桌面壁纸和锁屏壁纸，调用的是私有API，iOS10以下才会起作用！

```
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

```


二、新闻模块


![新闻.gif](http://upload-images.jianshu.io/upload_images/1708447-1493b15c9417390c.gif?imageMogr2/auto-orient/strip)

![动画.gif](http://upload-images.jianshu.io/upload_images/1708447-c87aa5a3e1824cfe.gif?imageMogr2/auto-orient/strip)

```
动画主要代码：UITableView的代理方法
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array =  tableView.indexPathsForVisibleRows;
    NSIndexPath *firstIndexPath = array[0];


    //设置anchorPoint
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    //为了防止cell视图移动，重新把cell放回原来的位置
    cell.layer.position = CGPointMake(0, cell.layer.position.y);


    //设置cell 按照z轴旋转90度，注意是弧度
    if (firstIndexPath.row < indexPath.row) {
        cell.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 0, 1.0);
    }else{
        cell.layer.transform = CATransform3DMakeRotation(- M_PI_2, 0, 0, 1.0);
    }


    cell.alpha = 0.5;


    [UIView animateWithDuration:1 animations:^{
        cell.layer.transform = CATransform3DIdentity;
        cell.alpha = 1.0;
    }];

}
```
三、音乐播放器

在线播放，后台播放，批量下载，歌词解析，锁屏歌词，滚动歌词;

2017/6/7更新：由于接口数据发生了改变，可能现在音乐播放器这块儿没法看到效果，我把锁屏效果和歌词解析，滚动显示功能单独抽出来又写了一篇文章和demo，感兴趣可以去我的这篇文章看看 [iOS 音乐播放器之锁屏效果+歌词解析](http://www.jianshu.com/p/35ce7e1076d2)

![音乐.gif](http://upload-images.jianshu.io/upload_images/1708447-688938582d741ccf.gif?imageMogr2/auto-orient/strip)

![锁屏歌词.PNG](http://upload-images.jianshu.io/upload_images/1708447-e445f9fb9e82c659.PNG?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

详情可以参考我之前的文章：
 [iOS 音乐播放器之锁屏效果+歌词解析](http://www.jianshu.com/p/35ce7e1076d2)
[仿简书分享-UIActivityViewController系统原生分享](http://www.jianshu.com/p/b6b44662dfda)
[iOS技术网站和常用软件](http://www.jianshu.com/p/328b98f68665)
[ iOS后台音频播放及锁屏歌词 ](http://www.jianshu.com/p/17133c57d145)
[文字进度](http://www.jianshu.com/p/0f09e8e9f30d)

四、画板

可以调画笔的粗细，深浅，颜色，也可以选择图片涂鸦：
![画板.gif](http://upload-images.jianshu.io/upload_images/1708447-13e545f3bd18b6a8.gif?imageMogr2/auto-orient/strip)

相关文章：[CALayer系列、CGContextRef、UIBezierPath、文本属性Attributes](http://www.jianshu.com/p/d6e090ed542b)、
[画板demo](https://github.com/wslcmk/draw.git)   https://github.com/wslcmk/draw.git

五、更多

这里有简易地图，手电筒，二维码，计分器，最好在真机上跑。

![更多.gif](http://upload-images.jianshu.io/upload_images/1708447-629e966abb35a764.gif?imageMogr2/auto-orient/strip)


![后台定位.png](http://upload-images.jianshu.io/upload_images/1708447-11b6e1f8bd8b33e3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上面的效果需要设置 self.locationManager.allowsBackgroundLocationUpdates = YES;


 [我的github](https://github.com/wslcmk/WSLAPP.git) ,欢迎star！别忘了哦！



![快来赞我啊.gif](http://upload-images.jianshu.io/upload_images/1708447-5ec5b979baec85ae.gif?imageMogr2/auto-orient/strip)


欢迎扫描下方二维码关注——iOS开发进阶之路——微信公众号：iOS2679114653
本公众号是一个iOS开发者们的分享，交流，学习平台，会不定时的发送技术干货，源码,也欢迎大家积极踊跃投稿，(择优上头条) ^_^分享自己开发攻城的过程，心得，相互学习，共同进步，成为攻城狮中的翘楚！

![iOS开发进阶之路.jpg](http://upload-images.jianshu.io/upload_images/1708447-c2471528cadd7c86.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
