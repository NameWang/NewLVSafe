//
//  CarCollectionViewCell.h
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/30.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^choseBolck) (void);
@interface CarCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *carBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
- (IBAction)carClick:(UIButton *)sender;
@property (copy,nonatomic)choseBolck choseBolck;
-(void)showcarlist:(choseBolck)choseBolck;
@end

NS_ASSUME_NONNULL_END
