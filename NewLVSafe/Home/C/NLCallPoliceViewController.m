//
//  NLCallPoliceViewController.m
//  NewLVSafe
//
//  Created by 何心晓 on 2018/12/3.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import "NLCallPoliceViewController.h"

@interface NLCallPoliceViewController ()

@end

@implementation NLCallPoliceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"一键报警";
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    UILabel *label1=[UILabel labelWithTitle:@"车辆异常，请向警方求救" frame:CGRectMake(10, 10, kScreenWidth-20, 30) color:[UIColor redColor] size:17 alignment:(NSTextAlignmentCenter) superView:self.view];
     UILabel *label2=[UILabel labelWithTitle:@"谎报警情将可能被处五日以上十日以下拘留" frame:CGRectMake(10, CGRectGetMaxY(label1.frame), kScreenWidth-20, 25) color:[UIColor grayColor] size:14 alignment:(NSTextAlignmentCenter) superView:self.view];
    UILabel *label3=[UILabel labelWithTitle:@"当前位置：\n河南省郑州市中原区金梭路" frame:CGRectMake(10, CGRectGetMaxY(label2.frame)+10, kScreenWidth-20, 60) color:[UIColor blackColor] size:16 alignment:(NSTextAlignmentCenter) superView:self.view];
    label3.numberOfLines=0;
    label3.backgroundColor=[UIColor whiteColor];
    UILabel *label4=[UILabel labelWithTitle:@"点击报警按钮后，会尝试" frame:CGRectMake(10, CGRectGetMaxY(label3.frame), kScreenWidth-20, 30) color:[UIColor blackColor] size:16 alignment:(NSTextAlignmentCenter) superView:self.view];
    UILabel *label5=[UILabel labelWithTitle:@"1、使用短信和电话通知紧急联系人" frame:CGRectMake(10, CGRectGetMaxY(label4.frame), kScreenWidth-20, 25) color:[UIColor grayColor] size:14 alignment:(NSTextAlignmentCenter) superView:self.view];
    UILabel *label6=[UILabel labelWithTitle:@"2、将行程信息根据警方要求提供给警方" frame:CGRectMake(10, CGRectGetMaxY(label5.frame), kScreenWidth-20, 25) color:[UIColor grayColor] size:14 alignment:(NSTextAlignmentCenter) superView:self.view];
    UIButton *callBtn=[UIButton normalBtnWithFrame:CGRectMake(10, CGRectGetMaxY(label6.frame)+15, kScreenWidth-20, 35) title:@"一键报警" size:17 color:[UIColor whiteColor] superView:self.view];
    callBtn.backgroundColor=kBlueColor;
    [callBtn addTarget:self action:@selector(callClick) forControlEvents:(UIControlEventTouchUpInside)];
    
}
-(void)callClick{
    
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
