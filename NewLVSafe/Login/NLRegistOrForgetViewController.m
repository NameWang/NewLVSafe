//
//  PSRegistOrForgetViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/25.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLRegistOrForgetViewController.h"
#import <SafariServices/SafariServices.h>
#import "NLChangePWDViewController.h"

@interface NLRegistOrForgetViewController ()<SFSafariViewControllerDelegate>
{
    
    UITextField *numField,*checkField,*pwdField;
    UIButton *loginBtn,*forgetBtn,*timerBtn,*privateBtn;
    AFHTTPSessionManager *manager;
    NSTimer *_timer;
    int timeDown;
    
}

@end

@implementation NLRegistOrForgetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=self.type;
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
    timeDown=0;
    //
    
    numField=[[UITextField alloc] initWithFrame:CGRectMake(0, 10+kiPhoneX_Top_Height, kScreenWidth, 40)];
    numField.placeholder=@"请输入您的手机号码";
    numField.font=[UIFont systemFontOfSize:15];
    numField.clearButtonMode=UITextFieldViewModeWhileEditing;
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    leftView.backgroundColor=[UIColor whiteColor];
    numField.leftView=leftView;
    numField.leftViewMode=UITextFieldViewModeAlways;
    
    numField.backgroundColor=[UIColor whiteColor];
    numField.keyboardType = UIKeyboardTypeNumberPad;
    numField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [numField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:numField];
    //
    
    checkField=[[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(numField.frame), kScreenWidth*0.7, 40)];
    checkField.placeholder=@"请输入验证码";
    checkField.font=[UIFont systemFontOfSize:15];
    checkField.clearButtonMode=UITextFieldViewModeWhileEditing;
    UIView *lView1=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    lView1.backgroundColor=[UIColor whiteColor];
    checkField.leftView=lView1;
    checkField.leftViewMode=UITextFieldViewModeAlways;
    
    checkField.keyboardType = UIKeyboardTypeNumberPad;
    checkField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [checkField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    checkField.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:checkField];
    //
    timerBtn=[UIButton buttonWithType:(UIButtonTypeCustom)];
    timerBtn.layer.masksToBounds=YES;
    timerBtn.layer.cornerRadius=5;
    timerBtn.frame=CGRectMake(kScreenWidth*0.7,  CGRectGetMaxY(numField.frame), kScreenWidth*0.3, 40);
    timerBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [timerBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [timerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [timerBtn addTarget:self action:@selector(takePassWord:) forControlEvents:UIControlEventTouchUpInside];
    timerBtn.userInteractionEnabled=NO;
    timerBtn.backgroundColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
    [self.view addSubview:timerBtn];
    //
    pwdField=[[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(checkField.frame), kScreenWidth, 40)];
    pwdField.placeholder=@"请输入新的密码(6-15位字母,数字)";
    pwdField.secureTextEntry=YES;
    pwdField.font=[UIFont systemFontOfSize:15];
    pwdField.clearButtonMode=UITextFieldViewModeWhileEditing;
    UIView *leftView4=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    leftView4.backgroundColor=[UIColor whiteColor];
    pwdField.leftView=leftView4;
    pwdField.leftViewMode=UITextFieldViewModeAlways;
    
    pwdField.backgroundColor=[UIColor whiteColor];
    pwdField.keyboardType = UIKeyboardTypeDefault;
    pwdField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [pwdField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:pwdField];
    
    //
    loginBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(pwdField.frame)+30, kScreenWidth-20, 40)];
    loginBtn.backgroundColor=[UIColor grayColor];
    
    loginBtn.layer.masksToBounds=YES;
    loginBtn.layer.cornerRadius=5;
    loginBtn.userInteractionEnabled=NO;
    if ([self.type isEqualToString:@"忘记密码？"]) {
        [loginBtn setTitle:@"重置密码" forState:UIControlStateNormal];
    }else{
        [loginBtn setTitle:@"注册" forState:UIControlStateNormal];
        //隐私政策
        privateBtn=[[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginBtn.frame)+10, kScreenWidth, 25)];
        [privateBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
        [privateBtn setTitle:@"阅读“隐私政策”" forState:(UIControlStateNormal)];
        privateBtn.titleLabel.font=[UIFont systemFontOfSize:11];
        [privateBtn addTarget:self action:@selector(privateURLClick) forControlEvents:(UIControlEventTouchUpInside)];
        [self.view addSubview:privateBtn];
    }
    
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginBtn.titleLabel.font=[UIFont systemFontOfSize:17];
    [loginBtn addTarget:self  action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginBtn];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [numField resignFirstResponder];
    
    [checkField resignFirstResponder];
}
-(void)takePassWord:(UIButton*)btn{
    
    if (numField.text.length==11) {
        
        timerBtn.userInteractionEnabled=NO;
        //        401 手机号为空
        //        402 该用户不存在
        //        403 验证码已发送，三分钟之后再点击
        //        柳会鹏  13:43:52
        //        400 验证码发送失败
        //        柳会鹏  13:43:58
        //        200 发送成功
        
        NSDictionary *info1=@{@"phone":numField.text};
        [manager GET:kGetCodeURL parameters:info1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                
                NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                NSString *state=resInfo[@"result"];
                if (state.integerValue==200) {
                    //定时器启动
                    self->timeDown=59;
                    self->_timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
                    //[MBProgressHUD showSuccess:@"验证码已发送"];
                }else if(state.integerValue==401){
                    self->timerBtn.userInteractionEnabled=YES;
                    [MBProgressHUD showError:@"手机号为空" toView:nil];
                }else if(state.integerValue==402){
                    self->timerBtn.userInteractionEnabled=YES;
                    [MBProgressHUD showError:@"该用户不存在" toView:nil];
                }else if(state.integerValue==403){
                    self->timerBtn.userInteractionEnabled=YES;
                    [MBProgressHUD showError:@"验证码已发送，三分钟之后再点击" toView:nil];
                }else{
                    self->timerBtn.userInteractionEnabled=YES;
                    
                    [MBProgressHUD showError:@"请求失败" toView:nil];
                }
                
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            self->timerBtn.userInteractionEnabled=YES;
            NSString *mess=@"请求失败,请检查您的网络是否正常";
            
            [MBProgressHUD showError:mess toView:nil];
            
        }];
        
    }else{
        [MBProgressHUD showError:@"手机号不正确" toView:nil];
        
    }
    
}
-(void)timerRun{
    if(timeDown>0)
    {
        [timerBtn setUserInteractionEnabled:NO];
        timerBtn.backgroundColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
        int sec = ((timeDown%(24*3600))%3600)%60;
        [timerBtn setTitle:[NSString stringWithFormat:@"已发送(%d)s",sec] forState:UIControlStateNormal];
        
    }
    else
    {
        [timerBtn setUserInteractionEnabled:YES];
        timerBtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
        [timerBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        
        [_timer invalidate];
        
    }
    timeDown -=1;
}
-(void)loginClick{//
    
    if (numField.text.length==11&&checkField.text.length==6&&pwdField.text.length>5&&pwdField.text.length<16) {
        [MBProgressHUD showMessag:@"请求中···" toView:self.view];
        //        参数：code 验证码
        //        password 密码
        //        phone 手机号
        //        *  401 手机号为空
        //        *  402 密码为空
        //        *  403 验证码为空
        //        *  404 该用户不存在
        //        *  405 手机验证码输入错误
        //        *  200 成功
        NSDictionary *info1=@{@"code":checkField.text,@"password":[DHHleper md5String:pwdField.text],@"phone":numField.text};
        [manager POST:kFindPWDURL parameters:info1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                
                NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (resInfo) {
                    NSString *state=resInfo[@"result"];
                    if (state.integerValue==200) {//成功
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showSuccess:@"您的密码已重置"];
                        self.callBackBlock();
                        [self.navigationController popViewControllerAnimated:YES];
                    }else if(state.integerValue==404){
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showError:@"该用户不存在" toView:nil];
                    }else if(state.integerValue==405){
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showError:@"验证码错误" toView:nil];
                    }else {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showError:@"修改失败" toView:nil];
                    }
                }else{
                    [MBProgressHUD showError:@"格式错误" toView:nil];
                }
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSString *mess=@"请求失败,请检查您的网络是否正常";
            //
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:mess toView:nil];
            
        }];
        
        
    }else{
        [MBProgressHUD showError:@"输入格式不正确" toView:nil];
    }
}

- (void)textFieldDidChange:(UITextField *)textField{
    //    if (numField.text.length<numberOfPhone) {
    //        timerBtn.userInteractionEnabled=NO;
    //        timerBtn.backgroundColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
    //    }
    //
    if (numField.text.length>=11) {
        if (timeDown==0) {
            timerBtn.userInteractionEnabled=YES;
            timerBtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
        }
        
    }else{
        timerBtn.userInteractionEnabled=NO;
        timerBtn.backgroundColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
    }
    if (numField.text.length > 11) {
        numField.text = [numField.text substringToIndex:11];
    }
    if (checkField.text.length==6&&numField.text.length==11&&pwdField.text.length>5&&pwdField.text.length<16) {
        loginBtn.userInteractionEnabled=YES;
        loginBtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
        
    }else{
        loginBtn.userInteractionEnabled=NO;
        loginBtn.backgroundColor=[UIColor grayColor];
    }
    if (checkField.text.length>6) {
        checkField.text=[checkField.text substringToIndex:6];
    }
    if (pwdField.text.length>15) {
        checkField.text=[checkField.text substringToIndex:15];
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [numField resignFirstResponder];
    [checkField resignFirstResponder];
    [pwdField resignFirstResponder];
}
#pragma mark 隐私政策相关
-(void)privateURLClick{
    
    NSURL *url = [NSURL URLWithString:@"http://47.94.228.184:2443/htm/index3.html"];
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

@end
