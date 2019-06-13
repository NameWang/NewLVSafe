//
//  CarCollectionViewCell.m
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/30.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import "CarCollectionViewCell.h"

@implementation CarCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.carBtn setTitle:@"\U0000e8c5" forState:(UIControlStateNormal)];
    self.carBtn.titleLabel.font=[UIFont fontWithName:@"iconfont" size:25];
    [self.carBtn setTitleColor:[UIColor grayColor] forState:(UIControlStateNormal)];
}
-(void)showcarlist:(choseBolck)choseBolck{
    self.choseBolck=choseBolck;
}
- (IBAction)carClick:(UIButton *)sender {
    if (self.choseBolck) {
        self.choseBolck();
    }
}
@end
