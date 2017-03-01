//
//  MTTopItem.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/8.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTHomeTopItem : UIView

+ (instancetype)item;

/**
 *  设置点击的监听器
 *
 *  @param target 监听器
 *  @param action 监听方法
 */
- (void)addTarget:(id)target action:(SEL)action;

- (void)setMainTitle:(NSString *)mainTitle;
- (void)setSubTitle:(NSString *)subtitle;
- (void)setIcon:(NSString *)icon highIcon:(NSString *)highIcon;

@end
