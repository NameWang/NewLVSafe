//
//  NLMineBaseViewController.h
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^callBack) (void);
@interface NLMineBaseViewController : UIViewController
@property (nonatomic,copy)callBack callBackBlock;

- (void)addLeftItemWithImageName:(NSString *)imageName;

- (void)addRightItemWithImageName:(NSString *)imageName;

- (void)addLeftItemWithText:(NSString *)text;

- (void)addRightItemWithText:(NSString *)text;

- (void)leftItemAction;
- (void)stopPopGestureRecognizer;
@end

NS_ASSUME_NONNULL_END
