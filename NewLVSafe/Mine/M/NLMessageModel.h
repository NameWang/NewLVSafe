//
//  NLMessageModel.h
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NLMessageModel : NSObject
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *pushtime;
@property(nonatomic,copy)NSString *title;


@end

NS_ASSUME_NONNULL_END
