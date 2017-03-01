//
//  MTDatabaseTool.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/22.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTDeal;

@interface MTDatabaseTool : NSObject

/**
 *  根据页码返回团购数据
 */
+ (NSArray *)collectDeals:(int)page;

/**
 *  收藏的总数
 */
+ (int)collectDealsCount;

/**
 *  收藏一个团购
 */
+ (void)addCollectDeal:(MTDeal *)deal;

/**
 *  取消收藏一个团购
 */
+ (void)cancelCollectDeal:(MTDeal *)deal;

/**
 *  判断该团购是否收藏
 */
+ (BOOL)isCollected:(MTDeal *)deal;


/**
 *  根据页码返回最近浏览团购数据
 */
+ (NSArray *)recentDeals:(int)page;

/**
 *  最近游览的总数
 */
+ (int)recentDealsCount;

/**
 *  最近游览的一个团购
 */
+ (void)addRecentDeal:(MTDeal *)deal;

/**
 *  删除一个浏览记录
 */
+ (void)deleteRecentDeal:(MTDeal *)deal;

/**
 *  最近游览记录是否包含刚刚游览的团购
 */
+ (BOOL)recentDealsContainsdeal:(MTDeal *)deal;

/**
 *  将该团购放在数据库中的第一个位置(显示在界面的第一个)
 */
+ (void)beginFirstDeal:(MTDeal *)deal;

@end
