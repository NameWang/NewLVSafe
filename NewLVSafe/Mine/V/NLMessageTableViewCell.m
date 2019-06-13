//
//  NLMessageTableViewCell.m
//  PeopleSafity
//
//  Created by 何心晓 on 2018/10/23.
//  Copyright © 2018年 Runkuyun. All rights reserved.
//

#import "NLMessageTableViewCell.h"

@implementation NLMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor=[UIColor whiteColor];
    self.warnLabel.layer.masksToBounds=YES;
    self.warnLabel.layer.cornerRadius=4;
}
-(void)showDataWithModel:(NLMessageModel *)model{
    self.titLabel.text=model.title;
    self.timeLabel.text=model.pushtime;
    self.bodyLabel.text=model.content;
    self.bodyLabel.numberOfLines=0;
    CGFloat height=[DHHleper textHeightFromTextString:model.content width:kScreenWidth-65 fontSize:15];
    CGRect frame0=self.bodyLabel.frame;
    frame0.size.height=height;
    self.bodyLabel.frame=frame0;
    if (model.state.integerValue==0) {//未读
        self.warnLabel.hidden=NO;
    }else{
        self.warnLabel.hidden=YES;
    }
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
