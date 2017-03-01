//
//  MTDealCell.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/16.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTDealCell.h"
#import "MTDeal.h"
#import "UIImageView+WebCache.h"


@interface MTDealCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *listPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *purchaseCountLabel;
/**
 属性名不能以new开头
 */
@property (weak, nonatomic) IBOutlet UIImageView *dealNewView;

@property (weak, nonatomic) IBOutlet UIButton *coverButton;

- (IBAction)coverButtonDidClick:(UIButton *)button;

@property (weak, nonatomic) IBOutlet UIImageView *checkView;

@end


@implementation MTDealCell

//- (void)awakeFromNib {
//    [super awakeFromNib];
//    
//    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg_dealcell"]];
//}

- (void)setDeal:(MTDeal *)deal {
    _deal = deal;
//    self.coverButton.alpha = 1;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:deal.image_url] placeholderImage:[UIImage imageNamed:@"placeholder_deal"]];
    self.titleLabel.text = deal.title;
    self.descLabel.text = deal.desc;
    
    // 购买数
    self.purchaseCountLabel.text = [NSString stringWithFormat:@"已售%d", deal.purchase_count];
    
    // 现价
    self.currentPriceLabel.text = [NSString stringWithFormat:@"¥ %@", deal.current_price];
    NSUInteger dotLoc = [self.currentPriceLabel.text rangeOfString:@"."].location;
    if (dotLoc != NSNotFound) {
        // 超过2位小数
        if (self.currentPriceLabel.text.length - dotLoc > 3) {
            self.currentPriceLabel.text = [self.currentPriceLabel.text substringToIndex:dotLoc + 3];
        }
    }
    
    // 原价
    self.listPriceLabel.text = [NSString stringWithFormat:@"¥ %@", deal.list_price];
    
    // 是否显示新单图片
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat= @"yyyy-MM-dd";
    NSString *nowStr = [fmt stringFromDate:[NSDate date]];
    
    // 隐藏: 发布日期 < 今天
    self.dealNewView.hidden = ([deal.publish_date compare:nowStr] == NSOrderedAscending);
    
    // 根据模型属性来控制cover的显示和隐藏
    self.coverButton.hidden = !deal.isEditing;
    
    // 根据模型属性来控制打钩的显示和隐藏
    self.checkView.hidden = !deal.isChecking;
}

- (void)drawRect:(CGRect)rect
{
    // 平铺
    //    [[UIImage imageNamed:@"bg_dealcell"] drawAsPatternInRect:rect];
    // 拉伸
    [[UIImage imageNamed:@"bg_dealcell"] drawInRect:rect];
}

- (IBAction)coverButtonDidClick:(UIButton *)button {
    //设置模型
    self.deal.checking = !self.deal.isChecking;
    
    // 直接修改状态
    self.checkView.hidden = !self.checkView.isHidden;
    
    if ([self.delegate respondsToSelector:@selector(dealCellCheckingStateDidChanged:)]) {
        [self.delegate dealCellCheckingStateDidChanged:self];
    }
}

@end
