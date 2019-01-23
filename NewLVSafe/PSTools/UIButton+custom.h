//
//  UIButton+custom.h
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/29.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (custom)
+(UIButton*)iconButtonWithFrame:(CGRect)frame title:(NSString*)title size:(CGFloat)size color:(UIColor*)color superView:(UIView*)superView;
+(UIButton*)normalBtnWithFrame:(CGRect)frame title:(NSString*)title size:(CGFloat)size color:(UIColor*)color  superView:(UIView*)superView;
+(UIButton*)secondIconFontBtnWithFirst:(NSString*)str1 second:(NSString*)str2 titleColor:(UIColor*)color size1:(CGFloat)size1 size2:(CGFloat)size2 frame:(CGRect)frame superView:(UIView*)superView;
+(UIButton*)oneIconFontBtnWithFirst:(NSString*)str1 second:(NSString*)str2 titleColor:(UIColor*)color size1:(CGFloat)size1 size2:(CGFloat)size2 frame:(CGRect)frame superView:(UIView*)superView;
@end

NS_ASSUME_NONNULL_END
