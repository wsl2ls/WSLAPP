//
//  wsldrawViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/15.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "wsldrawViewController.h"
#import "drawView.h"
#import "MyTabBarController.h"

typedef NS_ENUM(NSInteger, Attribute)
{
    NULLL,
    color,
    width,
    alpha,
};


@interface wsldrawViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

{
    UIImage * image;
    Attribute    attribute;
}
@property(nonatomic,strong) drawView * drawV;
@property(nonatomic,strong) UIImageView * backgroundImageView;
@property(nonatomic,strong)  UIImagePickerController  * imagePicker ;

@property(nonatomic,strong)  UIButton * colorBtn;
@property(nonatomic,strong)  UIButton * widthBtn;
@property(nonatomic,strong)  UIButton * arfBtn;
@property(nonatomic,strong)  UIButton * cleanBtn;
//橡皮擦
@property(nonatomic,strong)  UIButton * rubberBtn;
@property(nonatomic,strong)  UIButton * nextBtn;
@property(nonatomic,strong)  UIButton * backBtn;

@property(nonatomic,strong)  UIView * setBtnView;
@property(nonatomic,strong)  UITableView * attributeTableView;
@property(nonatomic,strong)  NSMutableArray * colorsArray;
@property(nonatomic,strong)  NSMutableArray  * widthsArray;
@property(nonatomic,strong)  NSMutableArray  * alphasArray;

@end

@implementation wsldrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}
#pragma mark ---setupUI
-(void)setupUI
{
    
    //为了实现摇一摇
    [self becomeFirstResponder];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"画画";
    [self.view  addSubview:self.backgroundImageView];
    [self.view  addSubview:self.drawV];
    [self.view   addSubview:self.setBtnView];
    
    
    UIBarButtonItem * setItem = [[UIBarButtonItem alloc] initWithTitle:@"设置" style:UIBarButtonItemStyleDone target:self action:@selector(setBtnClick)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStyleDone target:self action:@selector(saveBtnClick)];
    UIBarButtonItem * addPictureItem = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleDone target:self action:@selector(addPictureClicked:)];
    UIBarButtonItem * jianPictureItem = [[UIBarButtonItem alloc] initWithTitle:@"—" style:UIBarButtonItemStyleDone target:self action:@selector(jianPictureClicked:)];
    self.navigationItem.rightBarButtonItems = @[setItem,addPictureItem,jianPictureItem];
    
    [self.view   addSubview:self.attributeTableView];
    
}
#pragma mark ---Help  Methods

#pragma mark ----- Events Handle
-(void)colorBtnClick
{
    static int isBtnHidden = 1;
    self.attributeTableView.scrollsToTop = YES;
    attribute = color;
    [self.attributeTableView  reloadData];
    if (isBtnHidden == 1) {
        self.attributeTableView.hidden = NO;
        isBtnHidden = 0;
    }
    else
    {
        self.attributeTableView.hidden = YES;
        isBtnHidden = 1;
    }
}
-(void)widthChangeBtnClick
{    attribute = width;
    self.attributeTableView.scrollsToTop = YES;
    [self.attributeTableView  reloadData];
    static int  isWidthHiddening  = 1;
    if (isWidthHiddening == 1) {
        self.attributeTableView.hidden = NO;
        isWidthHiddening = 0;
    }else
    {
        self.attributeTableView.hidden = YES;
        isWidthHiddening = 1;
    }
}
-(void)alphaChangeClick
{    attribute = alpha;
    self.attributeTableView.scrollsToTop = YES;
    [self.attributeTableView reloadData];
    static int  isAlphaHiddening  = 1;
    if (isAlphaHiddening == 1) {
        self.attributeTableView.hidden = NO;
        isAlphaHiddening = 0;
    }else
    {
        self.attributeTableView.hidden = YES;
        isAlphaHiddening = 1;
    }
}
-(void)cleanBtnClick:(UIButton *)btn
{
    [self.drawV cleanAll];
}
-(void)rubberBtnClick
{
    static UIColor * lineColor ;
    static  NSNumber  *  lineWidth ;
    static  float lineArf ;
    static int isRubber = 0;
    if (isRubber == 0) {
        lineColor=  self.drawV.lineColor ;
        lineWidth =  self.drawV.lineWidth;
        lineArf =  self.drawV.lineArf;
        self.drawV.lineColor = [UIColor whiteColor];
        self.drawV.lineWidth = [NSNumber numberWithFloat:10.0f];
        self.drawV.lineArf = 1.0f;
        isRubber = 1;
    }else
    {
        self.drawV.lineColor = lineColor;
        self.drawV.lineWidth = lineWidth;
        self.drawV.lineArf = lineArf;
        isRubber = 0;
    }
}
-(void)backBtnClick
{
    [self.drawV  backStep];
}
-(void)nextBtnClick
{
    [self.drawV nextStep];
}
- (void)jianPictureClicked:(id)sender
{
    self.backgroundImageView.image = nil;
      [self.rubberBtn setTitle:@"橡皮" forState:UIControlStateNormal];
}
- (void)addPictureClicked:(id)sender
{
    //照片选择器
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.delegate = self;
    //设置图片的来源，相册还是相机
    //UIImagePickerControllerSourceTypeCamera相机
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum 相册
    //UIImagePickerControllerSourceTypePhotoLibrary图片库
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //弹出照片选择器
     [self presentViewController:self.imagePicker animated:YES completion:nil];
}
//摇一摇触发
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{   //如果动作是摇一摇
    if(motion == UIEventSubtypeMotionShake)
    {
        [self saveBtnClick];
    }
}
-(void)saveBtnClick
{
    //创建一个基于位图的上下文（context）,并将其设置为当前上下文(context)
    UIGraphicsBeginImageContext(self.view.bounds.size);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"提示" message: @"确定要保存至手机相册吗?"delegate:nil cancelButtonTitle:@"取消"otherButtonTitles:@"确定", nil];
    alertView.delegate = self;
    [alertView show];
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if(error) {
        UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"保存至相册失败" message:   [NSString  stringWithFormat:@"error是%@",error.localizedDescription]delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alertView show];
    }else{
    }
}
//#pragma mark UIAlertViewDelegate
//点击按钮触发
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        UIImageWriteToSavedPhotosAlbum(image, self, @selector (image:didFinishSavingWithError:contextInfo:), nil);}
}
-(void)setBtnClick
{
    static int setBtnIsHidden = 1;
    if (setBtnIsHidden == 1) {
        [UIView animateWithDuration:1.0f animations:^{
             self.setBtnView.frame = CGRectMake(self.view.frame.size.width - 50, 64, 50, 350);
        }];
               setBtnIsHidden = 0;
    }else
    {
        [UIView animateWithDuration:1.0f animations:^{
        self.setBtnView.frame = CGRectMake(self.view.frame.size.width - 50, 64, 50, 0);
    }];
        
        self.attributeTableView.hidden = YES;
        setBtnIsHidden = 1;
    }
    
}
#pragma mark ---- UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (attribute) {
        case color:
            return self.colorsArray.count;
            break;
        case width:
            return self.widthsArray.count;
            break;
        case alpha:
            return self.alphasArray.count;
            break;
        default:
            return 0;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIde = @"cellIde";
    UITableViewCell * cell = [tableView  dequeueReusableCellWithIdentifier:cellIde];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIde];
    }
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    switch (attribute) {
        case color:
            cell.backgroundColor = self.colorsArray[indexPath.row];
            cell.textLabel.text = @"";
            break;
        case width:
            cell.textLabel.text = self.widthsArray[indexPath.row];
            cell.backgroundColor = [UIColor clearColor];
            break;
        case alpha:
            cell.textLabel.text = self.alphasArray[indexPath.row];
            cell.backgroundColor = [UIColor clearColor];
            break;
        default:
            break;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView   deselectRowAtIndexPath:indexPath animated:YES];
    switch (attribute) {
        case color:
            self.drawV.lineColor = self.colorsArray[indexPath.row];
            break;
        case width:
            self.drawV.lineWidth = [NSNumber  numberWithInt:[self.widthsArray[indexPath.row] intValue]];
            break;
        case alpha:
            self.drawV.lineArf = [self.alphasArray[indexPath.row] floatValue];
            break;
        default:
            break;
    }
}
#pragma mark --- UIImagePickerControllerdelegate

//选择图片之后的回调的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   // NSLog(@"%@",info);
    UIImage * srcImage = info[@"UIImagePickerControllerOriginalImage"];
    //选择图片之后，作为头像
    self.backgroundImageView.image =srcImage;
    [self.rubberBtn setTitle:@"白色" forState:UIControlStateNormal];
    //让图片选择器返回去
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
}
//用户点击取消
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    //让图片选择器返回去
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark ----Getter
// 画布
-(drawView *)drawV
{
    if (_drawV == nil) {
        _drawV = [[drawView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        _drawV.backgroundColor = [UIColor clearColor];
        [self addDoubleTapGesture:_drawV];
    }return _drawV;
}
-(UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
    }return _backgroundImageView;
}
#pragma mark ----  添加手势
-(void)addDoubleTapGesture:(UIView *)view{
    //创建点击事件
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
    //设置点击次数
    doubleTap.numberOfTapsRequired = 2;
    //给view添加手势
    [view addGestureRecognizer:doubleTap];
}
-(void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    static int isBig = 0;
    if (isBig == 0) {
        
        self.tabBarController.tabBar.hidden = YES;
       
        self.navigationController.navigationBar.hidden = YES;
        isBig = 1;
    }else
    {   self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
        isBig = 0;
    }

}
-(UIButton *)colorBtn
{
    if (_colorBtn == nil) {
        _colorBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [_colorBtn setTitle:@"颜色" forState:UIControlStateNormal];
        _colorBtn.layer.cornerRadius = 25.0;
        _colorBtn.clipsToBounds = YES;
        _colorBtn.backgroundColor = [UIColor orangeColor];
        [_colorBtn addTarget:self action:@selector(colorBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _colorBtn;
}
-(UIButton *)widthBtn
{
    if (_widthBtn == nil){
        _widthBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, 50, 50)];
        [_widthBtn setTitle:@"粗细" forState:UIControlStateNormal];
        _widthBtn.layer.cornerRadius = 25.0;
        _widthBtn.clipsToBounds = YES;
        [_widthBtn addTarget:self action:@selector(widthChangeBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _widthBtn.backgroundColor = [UIColor orangeColor];
    }return _widthBtn;
}
-(UIButton *)arfBtn
{    if(_arfBtn == nil){
    _arfBtn  = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 50, 50)];
    _arfBtn.backgroundColor = [UIColor orangeColor];
    [_arfBtn setTitle:@"透明" forState:UIControlStateNormal];
    _arfBtn.layer.cornerRadius = 25.0;
    _arfBtn.clipsToBounds = YES;
    [_arfBtn addTarget:self action:@selector(alphaChangeClick) forControlEvents:UIControlEventTouchUpInside];
}
    return _arfBtn;
}
-(UIButton *)cleanBtn
{
    if (_cleanBtn == nil) {
        _cleanBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 150, 50, 50)];
        _cleanBtn.backgroundColor = [UIColor  orangeColor];
        _cleanBtn.layer.cornerRadius = 25.0;
        _cleanBtn.clipsToBounds = YES;
        [_cleanBtn setTitle:@"清除" forState:UIControlStateNormal];
        [_cleanBtn addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cleanBtn;
}
-(UIButton *)rubberBtn
{
    
    if (_rubberBtn == nil) {
        _rubberBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 200, 50, 50)];
        _rubberBtn.backgroundColor = [UIColor orangeColor];
        [_rubberBtn setTitle:@"橡皮" forState:UIControlStateNormal];
        _rubberBtn.layer.cornerRadius = 25.0;
        _rubberBtn.clipsToBounds = YES;
        [_rubberBtn  addTarget:self action:@selector(rubberBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }return _rubberBtn;
}
-(UIButton *)backBtn
{
    if (_backBtn == nil) {
        _backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 250, 50, 50)];
        _backBtn.backgroundColor = [UIColor orangeColor];
        [_backBtn setTitle:@"back" forState:UIControlStateNormal];
        _backBtn.layer.cornerRadius = 25.0;
        _backBtn.clipsToBounds = YES;
        [_backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}
-(UIButton *)nextBtn
{
    if (_nextBtn == nil) {
        _nextBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 50, 50)];
        _nextBtn.backgroundColor = [UIColor orangeColor];
        [_nextBtn setTitle:@"next" forState:UIControlStateNormal];
        _nextBtn.layer.cornerRadius = 25.0;
        _nextBtn.clipsToBounds = YES;
        [_nextBtn  addTarget:self action:@selector(nextBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

-(UIView *)setBtnView
{
    if (_setBtnView == nil) {
        _setBtnView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 50, 64, 50, 0)];
        _setBtnView.backgroundColor = [UIColor  clearColor];
        [_setBtnView  addSubview:self.colorBtn];
        [_setBtnView  addSubview:self.widthBtn];
        [_setBtnView  addSubview:self.arfBtn];
        [_setBtnView  addSubview:self.cleanBtn];
        [_setBtnView  addSubview:self.rubberBtn];
        [_setBtnView  addSubview:self.backBtn];
        [_setBtnView  addSubview:self.nextBtn];
        _setBtnView.clipsToBounds = YES;
    }return _setBtnView;
}
-(UITableView *)attributeTableView
{
    if (_attributeTableView == nil) {
        _attributeTableView = [[UITableView alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 100, 64, 50, 350) style:UITableViewStylePlain];
        _attributeTableView.delegate = self;
        _attributeTableView.dataSource = self;
        _attributeTableView.showsVerticalScrollIndicator = NO;
        _attributeTableView.hidden = YES;
    }
    return _attributeTableView;
}
-(NSMutableArray *)colorsArray
{
    if (_colorsArray == nil) {
        NSArray * colorArray = @[[UIColor greenColor],[UIColor blueColor],[UIColor blackColor],[UIColor redColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor cyanColor],[UIColor purpleColor],[UIColor brownColor],[UIColor magentaColor],[UIColor grayColor],[UIColor darkGrayColor]];
        _colorsArray = [[NSMutableArray alloc] initWithArray:colorArray];
        for (int i = 0; i < 70 ; i++) {
            UIColor * color = [UIColor  colorWithRed:arc4random()%256/256.0f green:arc4random()%256/256.0f blue:arc4random()%256/256.0f alpha:1.0];
            [_colorsArray  addObject:color];
        }
    }return _colorsArray;
}
-(NSMutableArray *)widthsArray
{
    if (_widthsArray == nil) {
        _widthsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 100; i++) {
            NSString * widthStr = [NSString stringWithFormat:@"%d",i];
            [_widthsArray  addObject:widthStr];
        }
    }return _widthsArray;
}
-(NSMutableArray *)alphasArray
{
    if (_alphasArray == nil) {
        _alphasArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 11; i++) {
            NSString * alphaStr = [NSString stringWithFormat:@"%.1f",i/10.0f];
            [_alphasArray  addObject:alphaStr];
        }
    }return _alphasArray;
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
