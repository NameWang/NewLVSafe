//
//  PSChangeInfoViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLChangeInfoViewController.h"

@interface NLChangeInfoViewController ()
{
    BOOL isLogin;
    UILabel *typeLable;
    UITextView *textView;
    UIButton *okBtn;
    NSDictionary *userInfo;
}
@end

@implementation NLChangeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"修改信息";
    isLogin=[[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"] boolValue];
    if (isLogin) {
        userInfo=[[NSUserDefaults standardUserDefaults] objectForKey:@"UserInfo"];
        
    }
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    typeLable=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 30)];
    typeLable.text=self.type;
    typeLable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:typeLable];
    textView=[[UITextView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(typeLable.frame), kScreenWidth-20, 150)];
    if ([self.type isEqualToString:@"家庭住址"]) {
        textView.text=userInfo[@"homeadd"];
    }else{
        textView.text=userInfo[@"hometele"];
    }
    [self.view addSubview:textView];
    okBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(textView.frame)+30, kScreenWidth-20, 30*kScale)];
    okBtn.backgroundColor=kBlueColor;
    //绘制曲线路径
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:okBtn.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(15, 15)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc]init];
    //设置大小
    maskLayer.frame = okBtn.bounds;
    //设置图形样子
    maskLayer.path = maskPath.CGPath;
    okBtn.layer.mask = maskLayer;
    [okBtn setTitle:@"修改" forState:(UIControlStateNormal)];
    [okBtn addTarget:self action:@selector(okClick) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:okBtn];
    
}
-(void)okClick{
    
    if (textView.text.length>0) {
        NSDictionary *param;
        okBtn.userInteractionEnabled=NO;
        [textView resignFirstResponder];
        __weak UIButton *weakBtn=okBtn;
        [MBProgressHUD showMessag:@"修改中···" toView:self.view];
        AFHTTPSessionManager *manager=[AFHTTPSessionManager manager];
        manager.responseSerializer=[AFHTTPResponseSerializer serializer];
        if ([self.type isEqualToString:@"家庭住址"]) {
            param=@{@"id":userInfo[@"id"],@"userid":userInfo[@"userid"],@"homeadd":textView.text,@"hometele":@""};
        }else{
            param=@{@"id":userInfo[@"id"],@"userid":userInfo[@"userid"],@"homeadd":@"",@"hometele":textView.text};
        }
        
        [manager POST:kChangeUserInfoURL parameters:param progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (responseObject) {
                NSDictionary *resInfo=[NSJSONSerialization JSONObjectWithData:responseObject options:(NSJSONReadingMutableContainers) error:nil];
                if (resInfo) {
                    NSString *state=resInfo[@"result"];
                    if (state.integerValue==200) {
                        NSMutableDictionary *resDic=[NSMutableDictionary dictionaryWithDictionary:self->userInfo];
                        if ([self.type isEqualToString:@"家庭住址"]) {
                            [resDic setValue:self->textView.text forKey:@"homeadd"];
                            [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)resDic forKey:@"UserInfo"];
                        }else{
                            [resDic setValue:self->textView.text forKey:@"hometele"];
                            [[NSUserDefaults standardUserDefaults] setObject:(NSDictionary*)resDic forKey:@"UserInfo"];
                        }
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        weakBtn.userInteractionEnabled=YES;
                        [MBProgressHUD showSuccess:@"修改成功"];
                    }else{
                        [MBProgressHUD hideHUDForView:self.view animated:YES];
                        weakBtn.userInteractionEnabled=YES;
                        [MBProgressHUD showError:@"修改失败" toView:nil];
                    }
                    
                }else{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    weakBtn.userInteractionEnabled=YES;
                    [MBProgressHUD showError:@"数据格式错误" toView:nil];
                }
            }else{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                weakBtn.userInteractionEnabled=YES;
                [MBProgressHUD showError:@"服务器无响应" toView:nil];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            weakBtn.userInteractionEnabled=YES;
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [MBProgressHUD showError:@"网络错误，请检查网络是否正常" toView:nil];
        }];
        
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [textView  resignFirstResponder];
}
-(void)dealloc{
    DLog(@"修改信息释放");
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
