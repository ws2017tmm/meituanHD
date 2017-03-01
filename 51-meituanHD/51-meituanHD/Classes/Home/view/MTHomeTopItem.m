//
//  MTTopItem.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/8.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTHomeTopItem.h"

@interface MTHomeTopItem ()

@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *iconButton;

@end

@implementation MTHomeTopItem

+ (instancetype)item{
    return [[[NSBundle mainBundle] loadNibNamed:@"MTHomeTopItem" owner:nil options:nil]firstObject];
}

- (void)awakeFromNib {
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)addTarget:(id)target action:(SEL)action {
    [self.iconButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)setMainTitle:(NSString *)mainTitle {
    self.mainTitleLabel.text = mainTitle;
}

- (void)setSubTitle:(NSString *)subtitle {
    
    self.subTitleLabel.text = subtitle;
}

- (void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon {
    [self.iconButton setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [self.iconButton setImage:[UIImage imageNamed:highIcon] forState:UIControlStateHighlighted];
}

@end
