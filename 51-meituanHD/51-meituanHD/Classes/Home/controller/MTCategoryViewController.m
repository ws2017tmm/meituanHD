//
//  MTCategoryControllerViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/9.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTCategoryViewController.h"
#import "MTHomeDropdown.h"
#import "MTModelDataTool.h"
#import "MTCategory.h"
#import "UIView+Extension.h"

@interface MTCategoryViewController ()<MTHomeDropdownDataSource,MTHomeDropdownDelegate>

/**
 *  分类数据
 */
@property (strong, nonatomic) NSArray *categories;

@end


@implementation MTCategoryViewController

- (NSArray *)categories {
    if (!_categories) {
        _categories = [MTModelDataTool categories];
    }
    return _categories;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MTHomeDropdown *dropdown = [MTHomeDropdown dropdown];
    dropdown.dataSource = self;
    dropdown.delegate = self;
    self.view = dropdown;
    
    // 设置控制器view在popover中的尺寸
    self.preferredContentSize = dropdown.size;
    
}

#pragma mark - MTHomeDropdownDataSource

/**
 *  主表有多少行
 */
- (NSInteger)numberOfRowsInMainTableOfHomeDropdown:(MTHomeDropdown *)dropdown {
    
    return self.categories.count;
}

/**
 *  主表每个indexPath对应的cell
 */
- (MTHomeDropdownMainCell *)homeDropdown:(MTHomeDropdown *)dropdown originalCell:(MTHomeDropdownMainCell *)cell proposedCellForRowAtMainTableIndexPath:(NSIndexPath *)indexPath {
    
    MTCategory *category = self.categories[indexPath.row];
    cell.textLabel.text = category.name;
    cell.imageView.image = [UIImage imageNamed:category.small_icon];
    cell.imageView.highlightedImage = [UIImage imageNamed:category.small_highlighted_icon];
    
    return cell;
}

/**
 *  返回字表的数据
 */
- (NSArray *)homeDropdown:(MTHomeDropdown *)dropdown subTableDataOfMainTableIndexPath:(NSIndexPath *)indexPath {
    
    MTCategory *category = self.categories[indexPath.row];
    return category.subcategories;
}

#pragma mark - MTHomeDropdownDelegate

/**
 *  点击主表
 */
- (void)homeDropdown:(MTHomeDropdown *)dropdown didSelectRowInMainTableAtIndexPath:(NSIndexPath *)indexPath {
    MTCategory *category = self.categories[indexPath.row];
    if (category.subcategories.count == 0) { //子表没有数据发出通知
        NSDictionary *dict = @{MTSelectCategory : category};
        [MTNotificationCenter postNotificationName:MTCategoryDidChangedNotification object:nil userInfo:dict];
    }
}

/**
 *  点击子表
 */
- (void)homeDropdown:(MTHomeDropdown *)dropdown didSelectRowInSubTableAtIndexPath:(NSIndexPath *)subIndexPath inMainTableIndexPath:(NSIndexPath *)mainIndexPath {
    MTCategory *mainCategory = self.categories[mainIndexPath.row];
    MTCategory *subCategory = mainCategory.subcategories[subIndexPath.row];
    NSDictionary *dict = @{MTSelectCategory : mainCategory, MTSelectSubCategoryName : subCategory};
    [MTNotificationCenter postNotificationName:MTCategoryDidChangedNotification object:nil userInfo:dict];
    
}





@end
