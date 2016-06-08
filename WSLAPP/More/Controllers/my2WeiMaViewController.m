//
//  my2WeiMaViewController.m
//  WSLAPP
//
//  Created by qianfeng on 15/10/21.
//  Copyright (c) 2015年 WSL. All rights reserved.
//

#import "my2WeiMaViewController.h"
#import "QRCodeGenerator.h"

@interface my2WeiMaViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation my2WeiMaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (IBAction)btnClicked:(id)sender {
    self.imageView.image = nil;
    self.label.hidden = YES;
    UIImage *img = [QRCodeGenerator qrImageForString:self.textField.text imageSize:200];
    self.imageView.image = img;
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
