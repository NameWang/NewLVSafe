//
//  NLLoginViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLLoginViewController.h"
#import "NLMapViewController.h"
#import "NLRegistOrForgetViewController.h"
#import <SafariServices/SafariServices.h>

@interface NLLoginViewController ()<UITextFieldDelegate,SFSafariViewControllerDelegate>
{
    AvtionImageView *bgScrollView;
    UIImageView *logoImgView;
    UITextField *numField;
    UITextField *psdField;
    UIButton *loginBtn,*forgetBtn,*privateBtn;
}
@end

@implementation NLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden=YES;
    bgScrollView=[[AvtionImageView alloc] initWithFrame:self.view.bounds];
    bgScrollView.userInteractionEnabled=YES;
    bgScrollView.image=[UIImage imageNamed:@"loginbg"];
   // bgScrollView.backgroundColor=[UIColor colorWithPatternImage:];
    
    [self.view addSubview:bgScrollView];
  
    //
    logoImgView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 100, kScreenWidth, 80)];
    logoImgView.image=[UIImage imageNamed:@"logo"];
    [bgScrollView addSubview:logoImgView];
    //
    numField=[[UITextField alloc] initWithFrame:CGRectMake(40, kScreenHeight-300, kScreenWidth-80, 30)];
    numField.borderStyle= UITextBorderStyleRoundedRect;
    numField.placeholder=@"请输入手机号";
    numField.delegate=self;
    [numField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:(UIControlEventEditingChanged)];
    numField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *left=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    left.font=[UIFont fontWithName:@"iconfont" size:25];
    left.text=@"\U0000e638";
    numField.leftView=left;
    numField.leftViewMode=UITextFieldViewModeAlways;
    [bgScrollView addSubview:numField];
    //
    psdField=[[UITextField alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(numField.frame)+20, kScreenWidth-80, 30)];
    psdField.borderStyle= UITextBorderStyleRoundedRect;
    psdField.placeholder=@"请输入密码";
    psdField.secureTextEntry=YES;
    psdField.delegate=self;
    [psdField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:(UIControlEventEditingChanged)];
    psdField.clearsOnBeginEditing=YES;
    psdField.leftViewMode=UITextFieldViewModeAlways;
    psdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    UILabel *left2=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    left2.font=[UIFont fontWithName:@"iconfont" size:25];
    left2.text=@"\U0000e6a0";
    psdField.leftView=left2;
    [bgScrollView addSubview:psdField];
    //
    loginBtn=[[UIButton alloc] initWithFrame:CGRectMake(40, CGRectGetMaxY(psdField.frame)+20, kScreenWidth-80, 30)];
    UIBezierPath *path=[UIBezierPath bezierPathWithRoundedRect:loginBtn.bounds byRoundingCorners:(UIRectCornerAllCorners) cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = loginBtn.bounds;
    //设置图形样子
    maskLayer.path = path.CGPath;
    loginBtn.layer.mask = maskLayer;
    [loginBtn setTitle:@"立即登录" forState:(UIControlStateNormal)];
    if (numField.text.length==11&&psdField.text.length>5) {
        loginBtn.backgroundColor=kBlueColor;
        [loginBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    }else{
        loginBtn.backgroundColor=[UIColor lightGrayColor];
        [loginBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    }
    [loginBtn addTarget:self action:@selector(loginClick) forControlEvents:(UIControlEventTouchUpInside)];
    [bgScrollView addSubview:loginBtn];
    //
    forgetBtn=[[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetMaxY(loginBtn.frame)+20, 70, 25)];
    [forgetBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [forgetBtn setTitle:@"忘记密码？" forState:(UIControlStateNormal)];
    
    forgetBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [forgetBtn addTarget:self action:@selector(forgetPsd) forControlEvents:(UIControlEventTouchUpInside)];
    [bgScrollView addSubview:forgetBtn];
    //
//    registBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-120, CGRectGetMaxY(loginBtn.frame)+20, 70, 25)];
//    [registBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
//    [registBtn setTitle:@"立即注册" forState:(UIControlStateNormal)];
//    registBtn.titleLabel.font=[UIFont systemFontOfSize:13];
//    [registBtn addTarget:self action:@selector(registMemberShip) forControlEvents:(UIControlEventTouchUpInside)];
//    [bgScrollView addSubview:registBtn];
    //隐私政策
    privateBtn=[[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-120, CGRectGetMaxY(loginBtn.frame)+20, 70, 25)];
    [privateBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    [privateBtn setTitle:@"“隐私政策”" forState:(UIControlStateNormal)];
    privateBtn.titleLabel.font=[UIFont systemFontOfSize:13];
    [privateBtn addTarget:self action:@selector(privateURLClick) forControlEvents:(UIControlEventTouchUpInside)];
    [bgScrollView addSubview:privateBtn];

    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
#pragma mark 隐私政策相关
-(void)privateURLClick{
    
    NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
    SFSafariViewController *safariVC = [[SFSafariViewController alloc] initWithURL:url];
    safariVC.delegate = self;
    
    // 建议
    [self presentViewController:safariVC animated:YES completion:nil];
}


- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully {
    
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [numField resignFirstResponder];
    [psdField resignFirstResponder];
}
-(void)resetFrameWithHeight:(CGFloat)height{
    logoImgView.frame=CGRectMake(0, 100-height, kScreenWidth, 80);
    numField.frame=CGRectMake(40, kScreenHeight-300-height, kScreenWidth-80, 30);
    psdField.frame=CGRectMake(40, CGRectGetMaxY(numField.frame)+20, kScreenWidth-80, 30);
    loginBtn.frame=CGRectMake(40, CGRectGetMaxY(psdField.frame)+20, kScreenWidth-80, 30);
    forgetBtn.frame=CGRectMake(50, CGRectGetMaxY(loginBtn.frame)+20, 70, 25);
    privateBtn.frame=CGRectMake(kScreenWidth-120, CGRectGetMaxY(loginBtn.frame)+20, 70, 25);
}
#pragma mark -键盘监听方法
- (void)keyboardWasShown:(NSNotification *)notification
{
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
   
    CGFloat heigh=bgScrollView.frame.size.height-CGRectGetMaxY(forgetBtn.frame);
    if (heigh>frame.size.height) {
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
          
            [self resetFrameWithHeight:frame.size.height-heigh];
        }];
        
    }
}
- (void)keyboardWillBeHiden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
      
        [self resetFrameWithHeight:0];
    }];

}


#pragma mark textFieldDelegate

-(void)textFieldDidChange:(UITextField*)field{
    if (numField.text.length>11) {
        numField.text=[numField.text substringToIndex:11];
    }
    if (psdField.text.length>15) {
        psdField.text=[psdField.text substringToIndex:15];
    }
    if (numField.text.length==11&&psdField.text.length>=6&&psdField.text.length<=15) {
        loginBtn.backgroundColor=kBlueColor;
        [loginBtn setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    }else{
        loginBtn.backgroundColor=[UIColor lightGrayColor];
        [loginBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    }
   
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField==psdField) {
        loginBtn.backgroundColor=[UIColor lightGrayColor];
        [loginBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
    }
    
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [numField resignFirstResponder];
    [psdField resignFirstResponder];
    return YES;
}

//登录事件
-(void)loginClick{
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] setObject:@{@"uname":@"傻子",@"sign":@"Wish sunshine in your eyes"} forKey:@"UserInfo"];
    UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:[[NLMapViewController alloc]init]];
    
    [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
}
//忘记密码
-(void)forgetPsd{
   
    NLRegistOrForgetViewController *reg=[[NLRegistOrForgetViewController alloc] init];
    reg.type=@"忘记密码？";
    reg.callBackBlock = ^{
        self.navigationController.navigationBar.hidden=YES;
    };
 
    [self.navigationController pushViewController:reg animated:YES];
   
}
////立即注册
//-(void)registMemberShip{
//    self.hidesBottomBarWhenPushed=YES;
//    NLRegistOrForgetViewController *reg=[[NLRegistOrForgetViewController alloc] init];
//    reg.type=@"立即注册";
//    reg.callBackBlock = ^{
//
//    };
//    [self.navigationController pushViewController:reg animated:YES];
//
//}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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