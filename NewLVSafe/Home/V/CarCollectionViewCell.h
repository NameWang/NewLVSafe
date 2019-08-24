//
//  CarCollectionViewCell.h
//  NewLVSafe
//
//  Created by 何心晓 on 2018/11/30.
//  Copyright © 2018 Runkuyun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CarCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

NS_ASSUME_NONNULL_END
