//
//  NLChangeInfoViewController.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLChangeInfoViewController.h"
#import "XMTextView.h"
#import "UITextView+XMExtension.h"
@interface NLChangeInfoViewController ()
{
    UILabel *typeLable;
    UITextView *textView;
    UIButton *okBtn;
}
@end

@implementation NLChangeInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"修改信息";
    self.view.backgroundColor=kBGWhiteColor;
    [self addLeftItemWithImageName:@"leftbackicon_white_titlebar_24x24_@2x"];
    typeLable=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, 120, 30)];
    typeLable.text=self.type;
    typeLable.backgroundColor=[UIColor clearColor];
    [self.view addSubview:typeLable];
   
    textView = [[UITextView alloc] init];
  
    textView.frame = CGRectMake(15, CGRectGetMaxY(typeLable.frame)+5, kScreenWidth-30, 200);
    textView.placeholder = @"请输入修改信息";
    textView.placeholderColor = [UIColor grayColor];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:textView];
    okBtn=[[UIButton alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(textView.frame)+30, kScreenWidth-20, 30)];
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
    // 键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHiden:) name:UIKeyboardWillHideNotification object:nil];
}
-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [textView resignFirstResponder];
    
}
-(void)resetFrameWithHeight:(CGFloat)height{
    textView.frame = CGRectMake(15, CGRectGetMaxY(typeLable.frame)+5, kScreenWidth-30, 200-height);
    okBtn.frame=CGRectMake(10, CGRectGetMaxY(textView.frame)+30, kScreenWidth-20, 30);
}
#pragma mark -键盘监听方法
- (void)keyboardWasShown:(NSNotification *)notification
{
    // 获取键盘的高度
    CGRect frame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGFloat heigh=kScreenHeight-kiPhoneX_Bottom_Height-CGRectGetMaxY(okBtn.frame)-84;
    if (heigh>frame.size.height) {
        
    }else{
        [UIView animateWithDuration:0.5 animations:^{
            
            [self resetFrameWithHeight:frame.size.height-heigh];
        }];
        
    }
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [textView resignFirstResponder];
}
- (void)keyboardWillBeHiden:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        
        [self resetFrameWithHeight:0];
    }];
    
}
-(void)okClick{
    
    
}
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
