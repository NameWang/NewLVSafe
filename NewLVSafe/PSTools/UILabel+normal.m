//
//  UILabel+normal.m
//  NewLVSafe
//
//  Created by 何心晓 on 2018/12/3.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import "UILabel+normal.h"

@implementation UILabel (normal)
+(UILabel *)labelWithTitle:(NSString *)title frame:(CGRect)frame color:(UIColor *)color size:(CGFloat)size alignment:(NSTextAlignment)ment superView:(UIView *)view{
    UILabel *label=[[UILabel alloc] initWithFrame:frame];
    label.text=title;
    label.textColor=color;
    label.textAlignment=ment;
    label.font=[UIFont systemFontOfSize:size];
    [view addSubview:label];
    return label;
}
@end
