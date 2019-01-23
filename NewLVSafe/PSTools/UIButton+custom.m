//
//  UIButton+custom.m
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/29.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import "UIButton+custom.h"

@implementation UIButton (custom)
+(UIButton *)iconButtonWithFrame:(CGRect)frame title:(NSString *)title size:(CGFloat)size color:(UIColor *)color  superView:(UIView *)superView{
    UIButton *btn=[[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font=[UIFont fontWithName:@"iconfont" size:size];
    [btn setTitle:title forState:(UIControlStateNormal)];
    [btn setTitleColor:color forState:(UIControlStateNormal)];
   
    [superView addSubview:btn];
    return btn;
}
+(UIButton *)normalBtnWithFrame:(CGRect)frame title:(NSString *)title size:(CGFloat)size color:(UIColor *)color superView:(UIView *)superView{
    UIButton *btn=[[UIButton alloc] initWithFrame:frame];
    btn.titleLabel.font=[UIFont systemFontOfSize:size];
    [btn setTitle:title forState:(UIControlStateNormal)];
    [btn setTitleColor:color forState:(UIControlStateNormal)];
 
    [superView addSubview:btn];
    return btn;
}
+(UIButton *)oneIconFontBtnWithFirst:(NSString *)str1 second:(NSString *)str2 titleColor:(UIColor *)color size1:(CGFloat)size1 size2:(CGFloat)size2 frame:(CGRect)frame superView:(UIView *)superView{
    UIButton *button=[[UIButton alloc] initWithFrame:frame];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",str1,str2]];
    NSRange range1 = [[str string] rangeOfString:str1];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT"size:size1] range:range1];
    NSRange range2 = [[str string] rangeOfString:str2];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"iconfont" size:size2] range:range2];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range2];
    [button setAttributedTitle:str forState:(UIControlStateNormal)];
    [button setTitleColor:color forState:(UIControlStateNormal)];
    [superView addSubview:button];
    return button;
}
+(UIButton *)secondIconFontBtnWithFirst:(NSString *)str1 second:(NSString *)str2 titleColor:(UIColor *)color size1:(CGFloat)size1 size2:(CGFloat)size2 frame:(CGRect)frame superView:(UIView *)superView{
    UIButton *button=[[UIButton alloc] initWithFrame:frame];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",str1,str2]];
    NSRange range1 = [[str string] rangeOfString:str2];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"ArialMT"size:size2] range:range1];
    NSRange range2 = [[str string] rangeOfString:str1];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"iconfont" size:size1] range:range2];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range2];
    [button setAttributedTitle:str forState:(UIControlStateNormal)];
    button.titleLabel.lineBreakMode=0;
    button.titleLabel.textAlignment=NSTextAlignmentCenter;
    [button setTitleColor:color forState:(UIControlStateNormal)];
    [superView addSubview:button];
    return button;
}
@end
