//
//  NLChangePWDViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/25.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLChangePWDViewController.h"
#import "NLLoginViewController.h"
@interface NLChangePWDViewController ()<UITextFieldDelegate>
{
    NSString *messTitle;

    UITextField *numField;
    UITextField *passField,*confirmField;
    UIButton *loginBtn;
    AFHTTPSessionManager *manager;
  NSDictionary *userInfo;
    UIActivityIndicatorView *active;
}

@end

@implementation NLChangePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"设置密码";
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    manager=[AFHTTPSessionManager manager];
    manager.responseSerializer=[AFHTTPResponseSerializer serializer];
      userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
     numField=[[UITextField alloc] initWithFrame:CGRectMake(0, 10, kScreenWidth, 40)];
    numField.placeholder=@"请输入您的原密码";
    
    numField.font=[UIFont systemFontOfSize:15];
    numField.clearButtonMode=UITextFieldViewModeWhileEditing;
    UIView *leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    leftView.backgroundColor=[UIColor whiteColor];
    numField.leftView=leftView;
    numField.leftViewMode=UITextFieldViewModeAlways;
    numField.delegate=self;
    numField.backgroundColor=[UIColor whiteColor];
    numField.keyboardType = UIKeyboardTypeDefault;
    numField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [numField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.view addSubview:numField];
    //
    passField=[[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(numField.frame), kScreenWidth, 40)];
    passField.placeholder=@"请输入6-15位数字或字母密码";
    passField.secureTextEntry=YES;
    passField.font=[UIFont systemFontOfSize:15];
    passField.clearButtonMode=UITextFieldViewModeWhileEditing;
    UIView *lView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    lView.backgroundColor=[UIColor whiteColor];
    passField.leftView=lView;
    passField.leftViewMode=UITextFieldViewModeAlways;
    passField.delegate=self;
    passField.keyboardType = UIKeyboardTypeDefault;
    passField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [passField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    passField.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:passField];
    //
    confirmField=[[UITextField alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(passField.frame), kScreenWidth, 40)];
    confirmField.placeholder=@"确认您的新密码";
    confirmField.secureTextEntry=YES;
    confirmField.font=[UIFont systemFontOfSize:15];
    confirmField.clearButtonMode=UITextFieldViewModeWhileEditing;
    UIView *lView2=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 15, 20)];
    lView2.backgroundColor=[UIColor whiteColor];
    confirmField.leftView=lView2;
    confirmField.leftViewMode=UITextFieldViewModeAlways;
    confirmField.delegate=self;
    confirmField.keyboardType = UIKeyboardTypeDefault;
    confirmField.layer.borderColor=[UIColor lightGrayColor].CGColor;
    [confirmField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    confirmField.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:confirmField];
    //
   
    //
    loginBtn=[[UIButton alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(confirmField.frame)+30, kScreenWidth-20, 40)];
    loginBtn.backgroundColor=[UIColor grayColor];
    
    loginBtn.layer.masksToBounds=YES;
    loginBtn.layer.cornerRadius=5;
    loginBtn.userInteractionEnabled=NO;
    
    [loginBtn setTitle:@"确认" forState:UIControlStateNormal];
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
    [passField resignFirstResponder];
    [confirmField resignFirstResponder];

}

-(void)loginClick{//注册
    if (numField.text.length>0&&passField.text.length>0&&confirmField.text.length>0&&[passField.text isEqualToString:confirmField.text]) {
        [MBProgressHUD showMessag:@"修改中···" toView:self.view];
        //        参数:phone 手机号
        //        password 密码
        //        newPwd 新密码
        NSDictionary *info1=@{@"phone":userInfo[@"phone"],@"password":[DHHleper md5String:numField.text],@"newPwd":[DHHleper md5String:confirmField.text],@"usertype":@"2"};
        [manager POST:kChangePWDURL parameters:info1 progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
                if (resInfo) {
                    NSString *state=resInfo[@"result"];
                    if (state.integerValue==200) {
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        
                        UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"修改密码" message:@"密码修改成功！请重新登录！" preferredStyle:(UIAlertControllerStyleAlert)];
                        UIAlertAction *ok=[UIAlertAction actionWithTitle:@"确定" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"UserInfo"];
                            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"isLogin"];
                            UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:[[NLLoginViewController alloc]init]];
                            
                            [[UIApplication sharedApplication].keyWindow setRootViewController:nav];
                        }];
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                    }else{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        [MBProgressHUD showError:@"修改失败" toView:nil];
                    }
                    
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [MBProgressHUD showError:@"数据格式错误" toView:nil];
                }
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [MBProgressHUD showError:@"服务器无响应" toView:nil];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
        }];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [MBProgressHUD showError:@"请输入正确的密码" toView:nil];
    }
}

- (void)textFieldDidChange:(UITextField *)textField{
    //    if (numField.text.length<numberOfPhone) {
    //        timerBtn.userInteractionEnabled=NO;
    //        timerBtn.backgroundColor=[UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
    //    }
    //
  
    //    if (numField.text.length > numberOfPhone) {
    //        numField.text = [numField.text substringToIndex:numberOfPhone];
    //    }
    if (passField.text.length>0&&numField.text.length>0&&confirmField.text.length>0&&[passField.text isEqualToString:confirmField.text]) {
        loginBtn.userInteractionEnabled=YES;
        loginBtn.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"blue"]];
        
    }else{
        loginBtn.userInteractionEnabled=NO;
        loginBtn.backgroundColor=[UIColor grayColor];
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
