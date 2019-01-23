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
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
-(void)showDataWithModel:(NLMessageModel*)model;
@property (weak, nonatomic) IBOutlet UILabel *titLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *warnLabel;

@end

NS_ASSUME_NONNULL_END
