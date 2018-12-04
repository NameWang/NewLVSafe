//
//  FeedBackTableViewCell.h
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/30.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FeedBackTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

NS_ASSUME_NONNULL_END
