//
//  MTModelDataTool.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/11.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTCategory,MTDeal;

@interface MTModelDataTool : NSObject

/**
 *  返回344个城市
 */
+ (NSArray *)cities;

/**
 *  返回所有的分类数据
 */
+ (NSArray *)categories;

/**
 *  根据团购返回该团购的分类类型
 */
+ (MTCategory *)categoryWithDeal:(MTDeal *)deal;

/**
 *  返回所有的排序数据
 */
+ (NSArray *)sorts;

@end
