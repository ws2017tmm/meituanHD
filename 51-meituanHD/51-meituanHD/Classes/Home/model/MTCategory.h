//
//  MTCategory.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/9.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTCategory : NSObject

/** 类别的名称 */
@property (nonatomic, copy) NSString *name;

/** 子类别:里面都是字符串(子类别的名称) */
@property (nonatomic, strong) NSArray *subcategories;

/** 显示在下拉菜单的小图标 */
@property (nonatomic, copy) NSString *small_highlighted_icon;
@property (nonatomic, copy) NSString *small_icon;

/** 显示在导航栏顶部的大图标 */
@property (nonatomic, copy) NSString *highlighted_icon;
@property (nonatomic, copy) NSString *icon;

/** 显示在地图上的图标 */
@property (nonatomic, copy) NSString *map_icon;

@end
