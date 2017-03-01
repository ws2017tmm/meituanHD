//
//  MTDealCell.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/16.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MTDeal,MTDealCell;

@protocol MTDealCellDelegate <NSObject>

@optional
- (void)dealCellCheckingStateDidChanged:(MTDealCell *)cell;

@end


@interface MTDealCell : UICollectionViewCell

@property (nonatomic, strong) MTDeal *deal;

@property (weak, nonatomic) id <MTDealCellDelegate>delegate;

@end
