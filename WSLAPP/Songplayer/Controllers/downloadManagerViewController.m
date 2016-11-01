//
//  downloadManagerViewController.m
//  WSLAPP
//
//  Created by 王双龙 on 15/10/22.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "downloadManagerViewController.h"
#import "downloadTableViewCell.h"
#import "SongModel.h"
#import "AFNetworking.h"


#define  WSLLibraryDirectory  [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]  stringByAppendingPathComponent:@"Songs"]

@interface downloadManagerViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
@property(nonatomic,strong) UITableView * downloadingTaV;
@property(nonatomic,strong) NSMutableArray * dataSourceData;
@property(nonatomic,strong) NSMutableArray * indexPathArray;
@end

@implementation downloadManagerViewController
-(id)init{
    self = [super init];
    if (self) {
        [self registerNotificaiton];
        _dataSourceData = [[NSMutableArray alloc] init];
        _indexPathArray = [[NSMutableArray alloc] init];
    }
    return self;
}

 - (void)registerNotificaiton
{
    //增加观察者
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifi:) name:@"downloadSongs" object:nil];
   
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title  = @"歌曲下载管理";
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.downloadingTaV  reloadData];
}

-(void)notifi:(NSNotification *)noti{
    NSDictionary * dict = noti.userInfo;
      NSArray * array = dict[@"songArray"];
       [self.dataSourceData  addObjectsFromArray:array];
   NSLog(@"通知来了");
    
}
-(void)setupUI
{
    [self.view addSubview:self.downloadingTaV];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"多选删除" style:UIBarButtonItemStyleDone target:self action:@selector(multdeleteClicked:)];
}
-(void)multdeleteClicked:(UIBarButtonItem * )btn
{
   self.downloadingTaV.allowsMultipleSelectionDuringEditing = NO;
    if (self.downloadingTaV.isEditing) {
        //现在是编辑状态，点击后进入非编辑状态
        [self.downloadingTaV setEditing:NO animated:YES];
        //修改按钮的文字
        btn.title = @"多选删除";
         self.navigationItem.rightBarButtonItems = @[btn];
         }else{
            //进入多选模式
        self.downloadingTaV.allowsMultipleSelectionDuringEditing = YES;
            
        //现在非编辑状态，点击后进入编辑状态
        [self.downloadingTaV setEditing:YES animated:YES];
             //加一个删除按钮
             UIBarButtonItem *deleteItem = [[UIBarButtonItem alloc]initWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(deleteOnClik:)];
             //改变多选删除按钮显示文字
             btn.title = @"完成";
             self.navigationItem.rightBarButtonItems = @[btn,deleteItem];
    }
}
//点击删除按钮触发的方法
-(void)deleteOnClik:(UIBarButtonItem *)btn{
    
    NSArray *array = [self.downloadingTaV indexPathsForSelectedRows ];
    
    NSArray *sortArray =[array sortedArrayUsingSelector:@selector(compare:)];
    
    for (NSInteger i = sortArray.count-1; i >= 0; i--) {
        NSIndexPath * p = sortArray[i];
        [self.dataSourceData removeObjectAtIndex:p.row];
    }
    [self.downloadingTaV deleteRowsAtIndexPaths:sortArray withRowAnimation:UITableViewRowAnimationBottom];
    //重新刷数据（dataSourece和delegate的协议重新执行一遍）
    [self.downloadingTaV reloadData];
}

#pragma mark ---- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{      return self.dataSourceData.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    downloadTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellIde" forIndexPath:indexPath];
    SongModel * model = self.dataSourceData[indexPath.row];

    cell.songNameLabel.text = [NSString stringWithFormat:@"%@.mp3",model.songName];
    cell.songUrlStr = model.songUrl ;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:0/255.0f green:191/255.0f blue:145/255.0f alpha:0.5f];
    //如果有进程在下载，就不能执行downloadSong，因为这样会在原有进程的基础上，重新alloc个operation，造成混乱
    if (cell.operation == nil ) {
        [cell downloadSong];
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle ==  UITableViewCellEditingStyleDelete) {
        [self.dataSourceData  removeObjectAtIndex:indexPath.row];
    
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
               [tableView reloadData];
    }
}
#pragma mark ---- Getter
-(UITableView *)downloadingTaV
{    self.automaticallyAdjustsScrollViewInsets = NO;
    if (_downloadingTaV == nil) {
        _downloadingTaV = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64)];
        _downloadingTaV.delegate = self;
        _downloadingTaV.dataSource = self;
        _downloadingTaV.backgroundColor = [UIColor colorWithRed:0/255.0f green:191/255.0f blue:145/255.0f alpha:0.5f];
        [_downloadingTaV registerNib:[UINib nibWithNibName:@"downloadTableViewCell" bundle:nil] forCellReuseIdentifier:@"cellIde"];
        
    }return _downloadingTaV;
}
- (void) viewWillAppear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = YES;
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
