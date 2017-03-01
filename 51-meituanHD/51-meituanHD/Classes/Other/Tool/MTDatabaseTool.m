//
//  MTDatabaseTool.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/22.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTDatabaseTool.h"
#import "FMDB.h"
#import "MTDeal.h"

@interface MTDatabaseTool ()

//@property (strong, nonatomic) NSMutableArray *deals;

@end

@implementation MTDatabaseTool

static FMDatabase *_db;

/**
 *  打开数据库,初始化表
 */
+ (void)initialize {
    
    NSString * path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"data.sqlite"];
    _db = [FMDatabase databaseWithPath:path];
    
    if (![_db open]) return;
    
    //创建表
    //收藏表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_collect_deal(id integer PRIMARY KEY, deal bolb NOT NULL, deal_id text NOT NULL)"];
    //最近浏览记录表
    [_db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_recent_deal(id integer PRIMARY KEY, deal bolb NOT NULL, deal_id text NOT NULL)"];
    
    
}

#pragma mark - 收藏的团购
/**
 *  根据页码返回团购数据
 */
+ (NSArray *)collectDeals:(int)page {
    //每一页显示多少数据
    int pageSize = 18;
    //起始的数据
    int startSize = (page - 1) * pageSize;
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_collect_deal ORDER BY id DESC LIMIT %d,%d;", startSize, pageSize];
    
    NSMutableArray *deals = [NSMutableArray array];
    while (set.next) {
        NSData *data = [set objectForColumnName:@"deal"];
        
        MTDeal *deal = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [deals addObject:deal];
    }
    return deals;
}

/**
 *  收藏的总数
 */
+ (int)collectDealsCount {
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) FROM t_collect_deal"];
    [set next];
    int count = [set intForColumnIndex:0];
    return count;
}

/**
 *  收藏一个团购
 */
+ (void)addCollectDeal:(MTDeal *)deal {
    
    //数据库里只能存二进制数据(模型转二进制数据)
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deal];
    
    [_db executeUpdateWithFormat:@"INSERT INTO t_collect_deal(deal, deal_id) VALUES(%@, %@);", data, deal.deal_id];
}

/**
 *  取消收藏一个团购
 */
+ (void)cancelCollectDeal:(MTDeal *)deal {
    
    [_db executeUpdateWithFormat:@"DELETE FROM t_collect_deal WHERE deal_id = %@",deal.deal_id];
}

/**
 *  判断该团购是否收藏
 */
+ (BOOL)isCollected:(MTDeal *)deal {
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT count(*) FROM t_collect_deal WHERE deal_id = %@",deal.deal_id];
    
    [set next];
    int a = [set intForColumnIndex:0];
    return a == 1;
}

#pragma mark - 浏览记录
/**
 *  根据页码返回最近浏览团购数据
 */
+ (NSArray *)recentDeals:(int)page {
    //每一页显示多少数据
    int pageSize = 18;
    //起始的数据
    int startSize = (page - 1) * pageSize;
    FMResultSet *set = [_db executeQueryWithFormat:@"SELECT * FROM t_recent_deal ORDER BY id DESC LIMIT %d,%d;", startSize, pageSize];
    
    NSMutableArray *deals = [NSMutableArray array];
    while (set.next) {
        NSData *data = [set objectForColumnName:@"deal"];
        
        MTDeal *deal = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [deals addObject:deal];
    }
    return deals;
}

/**
 *  最近游览的总数
 */
+ (int)recentDealsCount {
    FMResultSet *set = [_db executeQuery:@"SELECT count(*) FROM t_recent_deal"];
    [set next];
    int count = [set intForColumnIndex:0];
    return count;
}

/**
 *  最近游览的一个团购
 */
+ (void)addRecentDeal:(MTDeal *)deal {
    //数据库里只能存二进制数据(模型转二进制数据)
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deal];
    
    [_db executeUpdateWithFormat:@"INSERT INTO t_recent_deal(deal, deal_id) VALUES(%@, %@);", data, deal.deal_id];
}

/**
 *  删除一个浏览记录
 */
+ (void)deleteRecentDeal:(MTDeal *)deal {
    
    [_db executeUpdateWithFormat:@"DELETE FROM t_recent_deal WHERE deal_id = %@",deal.deal_id];
}

/**
 *  最近游览记录是否包含刚刚游览的团购
 */
+ (BOOL)recentDealsContainsdeal:(MTDeal *)deal {
    
    FMResultSet *set = [_db executeQuery:@"SELECT * FROM t_recent_deal;"];
    
    BOOL isContain = NO;
    while (set.next) {
        NSData *data = [set objectForColumnName:@"deal"];
        
        MTDeal *currDeal = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        if ([currDeal.deal_id isEqualToString:deal.deal_id]) {
            isContain = YES;
            break;
        }
    }
    return isContain;
}

/**
 *  将该团购放在数据库中的第一个位置(显示在界面的第一个)
 */
+ (void)beginFirstDeal:(MTDeal *)deal {
    [self deleteRecentDeal:deal];
    [self addRecentDeal:deal];
}

@end
