//
//  UILabel+normal.h
//  NewLVSafe
//
//  Created by 何心晓 on 2018/12/3.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UILabel (normal)
+(UILabel*)labelWithTitle:(NSString*)title frame:(CGRect)frame color:(UIColor*)color size:(CGFloat)size alignment:(NSTextAlignment)ment superView:(UIView*)view;
@end

NS_ASSUME_NONNULL_END
