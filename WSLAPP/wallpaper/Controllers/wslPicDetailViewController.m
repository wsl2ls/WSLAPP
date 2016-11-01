//
//  wslPicDetailViewController.m
//  壁纸
//
//  Created by 王双龙 on 15/10/12.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wslPicDetailViewController.h"
#import "wslCommentTableViewCell.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UMSocial.h"

#import "UIImage+ZJWallPaper.h"
#import "picDetailModel.h"

typedef enum {
    ImageActionAsHomeScreen = 0,
    ImageActionAsLockScreen,
    ImageActionAsBoth,
    ImageActionAsPhoto
}ImageAction;

@interface wslPicDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UMSocialUIDelegate,UIActionSheetDelegate>

@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) UIImageView * imageView;

@property(nonatomic,strong) NSMutableArray * dataSource;
@property(nonatomic, strong) UIActionSheet *sheet;
@end

@implementation wslPicDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self  setupUI];
   }
-(void)setupUI
{
    [self  downloadData];
    self.view.backgroundColor =   [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
    [self.view  addSubview:self.imageView];
    [self.view   addSubview:self.tableView];
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]  initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(setting:) ];
    UIBarButtonItem * shareItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStyleDone target:self action:@selector(shareClicked:)];
    
    self.navigationItem.rightBarButtonItems = @[saveItem ,shareItem];
    
}
-(void)shareClicked:(id)sender
{
   // [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeMusic url:@"http://sc1.111ttt.com/2015/1/04/25/97251325272.mp3"];
    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeVideo url:@"http://kobe.sina.com.cn"];
    [UMSocialSnsService presentSnsIconSheetView :self appKey:@"507fcab25270157b37000010" shareText:@"来自WSLAPP的分享：科比_布莱恩特(Kobe_Bryant)_中文官方网站 http://kobe.sina.com.cn" shareImage:_imageView.image shareToSnsNames:@[UMShareToSina, UMShareToQQ,UMShareToRenren,UMShareToQzone,UMShareToTencent,UMShareToWechatTimeline,UMShareToDouban,UMShareToEmail,UMShareToSms,UMShareToEmail] delegate:self];
    
}

-(void)setting:(id)sender
{   [self.imageView.image zj_saveToPhotos];
    [self.sheet showInView:self.view];
    
}
-(void)downloadData
{
    AFHTTPSessionManager * manager = [AFHTTPSessionManager manager];
    
    NSString * urlStr = [NSString stringWithFormat:@"http://service.picasso.adesk.com/v2/wallpaper/wallpaper/%@/comment",self.imgID];
    
    [manager GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSArray * commentsArr =  responseObject[@"res"][@"comment"];
        for (NSDictionary * dict in commentsArr) {
            picDetailModel * model = [[picDetailModel alloc] init];
            model.content = dict[@"content"];
//            if (dict[@"user"] !=  NULL) {
//            model.name = dict[@"user"][@"name"];
//            model.avatar = dict[@"user"][@"avatar"];
//        }
            double atime = [dict[@"atime"] doubleValue];
            NSDate * date = [NSDate dateWithTimeIntervalSince1970:atime];
            NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
            NSString * dateStr = [dateFormatter stringFromDate:date];
            model.atime = dateStr;
            model.size =[NSString  stringWithFormat:@"%@",dict[@"size"] ] ;
            [self.dataSource  addObject:model];
        }
        [self.tableView   reloadData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error %@",error);
    }];

}

#pragma mark ---- Getter
-(UITableView *)tableView
{
    if (_tableView == nil) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height-66) style:UITableViewStyleGrouped];
        _tableView.backgroundColor =   [UIColor colorWithRed:255/255.0f green:192/255.0f blue:0/255.0f alpha:1.0f];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableHeaderView = self.imageView;
        [self addRightSwipGesture:_tableView];
        [_tableView registerNib:[UINib nibWithNibName:@"wslCommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellID"];
    }
    
    return _tableView;
    
}
-(UIImageView *)imageView
{
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/3 + 50)];
        _imageView.userInteractionEnabled = YES;
         [_imageView    sd_setImageWithURL:[NSURL URLWithString:self.imgUrlStr] placeholderImage:[UIImage imageNamed:@"head"]];
        [self  addDoubleTapGesture:_imageView];
    }return _imageView;
}

-(UIActionSheet *)sheet
{
 if (_sheet == nil) {
    _sheet =  [[UIActionSheet alloc] initWithTitle:@"设置壁纸" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil   otherButtonTitles:@"设为桌面壁纸",@"设为锁屏壁纸",@"设为锁屏和桌面壁纸",@"保存到照片库", nil];
 }
    return _sheet;
}

#pragma mark ----  添加手势
-(void)addDoubleTapGesture:(UIView *)view{
    //创建点击事件
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    //设置点击次数
    doubleTap.numberOfTapsRequired = 1;
    //给view添加手势
    [view addGestureRecognizer:doubleTap];
}
//添加手势返回上一界面
-(void)addRightSwipGesture:(UIView *)view{
    UISwipeGestureRecognizer *swip = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swip:)];
    swip.direction = UISwipeGestureRecognizerDirectionRight;
    [view addGestureRecognizer:swip];
}
#pragma mark ----- 手势事件
-(void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    static int  isBig = 0;
    if (isBig == 0) {
    UIImageView * imageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 66, self.view.frame.size.width, self.view.frame.size.height - 66)];
        imageV.tag = 79;
        imageV.contentMode = UIViewContentModeScaleToFill;
        imageV.backgroundColor = [UIColor brownColor];
    UIImageView * tapImgView = (UIImageView *)doubleTap.view;
       imageV.image = tapImgView.image;
        imageV.userInteractionEnabled = YES;
        imageV.contentMode = UIViewContentModeScaleAspectFit;
        [self addDoubleTapGesture:imageV];
        
        [self.view  addSubview:imageV];
        isBig = 1;
    }else
    {
        UIImageView * bigView = (UIImageView *)[self.view  viewWithTag:79];
        [bigView removeFromSuperview];
        isBig = 0;
    }
}
-(void)swip:(UISwipeGestureRecognizer *)swipe
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }return _dataSource;
}
#pragma mark  UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex)
    {
        case ImageActionAsHomeScreen:
        {
            [self.imageView.image zj_saveAsHomeScreen];
        }
            break;
        case ImageActionAsLockScreen:
        {
            [self.imageView.image zj_saveAsLockScreen];
        }
            break;
        case ImageActionAsBoth:
        {
            
            [self.imageView.image zj_saveAsHomeScreenAndLockScreen];
            
        }
            break;
        case ImageActionAsPhoto:
        {
            [self.imageView.image zj_saveToPhotos];
        }
            break;
        default:
            break;
    }
}


#pragma mark ---- UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.dataSource.count == 0){
    return 1;}
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    wslCommentTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    
    if (self.dataSource.count == 0) {
        cell.contetLabel.text = @"暂无评论";
        cell.zanBtn.hidden = YES;
        return cell;
    }

    picDetailModel * model = self.dataSource[indexPath.row];
    cell.contetLabel.text = model.content;
   [cell.imageV sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"head"]];
    cell.nameLabelk.text = model.name;
    cell.sizeLabel.text = model.size;
    cell.atimeLabel.text = model.atime;
    cell.zanBtn.hidden = NO;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 5,80, 40)];
    label.text = @"热门评论";
    label.textColor = [UIColor whiteColor];
    [view  addSubview:label];
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
  
    self.tabBarController.tabBar.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = YES;
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
