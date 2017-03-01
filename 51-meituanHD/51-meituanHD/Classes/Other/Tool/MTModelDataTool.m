//
//  MTModelDataTool.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/11.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTModelDataTool.h"
#import "MTCity.h"
#import "MTCategory.h"
#import "MJExtension.h"
#import "MTSort.h"
#import "MTDeal.h"


@implementation MTModelDataTool

static NSArray *_cities;
+ (NSArray *)cities
{
    if (_cities == nil) {
        _cities = [MTCity objectArrayWithFilename:@"cities.plist"];;
    }
    return _cities;
}

static NSArray *_categories;
+ (NSArray *)categories
{
    if (_categories == nil) {
        _categories = [MTCategory objectArrayWithFilename:@"categories.plist"];;
    }
    return _categories;
}

/**
 *  根据团购返回该团购的分类类型
 */
+ (MTCategory *)categoryWithDeal:(MTDeal *)deal {
    NSArray *categories = [self categories];
    NSString *cName = [deal.categories firstObject];
    for (MTCategory *c in categories) {
        if ([c.name isEqualToString:cName]) return c;
        if ([c.subcategories containsObject:cName]) return c;
    }
    NSLog(@"cName = %@",cName);
    return nil;
}

static NSArray *_sorts;
+ (NSArray *)sorts
{
    if (_sorts == nil) {
        _sorts = [MTSort objectArrayWithFilename:@"sorts.plist"];;
    }
    return _sorts;
}


@end
