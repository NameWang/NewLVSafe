//
//  NLMessageTableViewCell.h
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLMessageModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NLMessageTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
-(void)showDataWithModel:(NLMessageModel*)model;
@end

NS_ASSUME_NONNULL_END
