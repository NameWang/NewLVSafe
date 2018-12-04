//
//  NLFindCarTableViewCell.h
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/24.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLFindCarModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface NLFindCarTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UILabel *carNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *lostTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
-(void)showDataWithModel:(NLFindCarModel*)model;
@end

NS_ASSUME_NONNULL_END
