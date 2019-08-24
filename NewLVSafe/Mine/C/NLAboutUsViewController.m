//
//  NLAboutUsViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLAboutUsViewController.h"

@interface NLAboutUsViewController ()

@end

@implementation NLAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"关于我们";
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    UIImageView *logoImgView=[[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x-35, 40, 70, 70)];
    logoImgView.image=[UIImage imageNamed:@"icon"];
    [self.view addSubview:logoImgView];
    UILabel *versionLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(logoImgView.frame)+50, kScreenWidth-100, 20)];
    versionLabel.textColor=[UIColor grayColor];
    versionLabel.textAlignment=NSTextAlignmentCenter;
    versionLabel.font=[UIFont systemFontOfSize:11*kScale];
    versionLabel.text=@"版本号：V1.0.0";
    [self.view addSubview:versionLabel];
    AvtionImageView *contactView=[[AvtionImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(versionLabel.frame)+40, kScreenWidth, 30*kScale)];
    contactView.backgroundColor=[UIColor whiteColor];
    [contactView addTarget:self action:@selector(contactUS)];
    [self.view addSubview:contactView];
    UILabel *titLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, 2, 80*kScale, 26*kScale)];
    titLabel.text=@"联系客服";
    titLabel.font=[UIFont systemFontOfSize:15*kScale];
    titLabel.userInteractionEnabled=YES;
    [contactView addSubview:titLabel];
    UILabel *numLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-120*kScale-15, 2, 120*kScale, 26*kScale)];
    numLabel.text=@"15555557954";
    numLabel.textAlignment=NSTextAlignmentRight;
    numLabel.textColor=[UIColor grayColor];
    numLabel.font=[UIFont systemFontOfSize:13*kScale];
    numLabel.userInteractionEnabled=YES;
    [contactView addSubview:numLabel];
    UILabel *copyRight=[[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight-30*kScale-kiPhoneX_Bottom_Height-64, kScreenWidth, 20*kScale)];
    copyRight.textAlignment=NSTextAlignmentCenter;
    copyRight.font=[UIFont systemFontOfSize:12*kScale];
    copyRight.text=@"政放车卫士";
    [self.view addSubview:copyRight];
}
-(void)contactUS{
    NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",@"13393732159"];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
          [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
  
    
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
