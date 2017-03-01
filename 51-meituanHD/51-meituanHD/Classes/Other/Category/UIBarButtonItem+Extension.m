//
//  UIBarButtonItem+Extension.m
//  sinaWeibo
//
//  Created by XSUNT45 on 16/3/30.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"

@implementation UIBarButtonItem (Extension)

+ (UIBarButtonItem *)itemWithTarget:(id)target action:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    
    btn.size = btn.currentImage.size;
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}

@end
