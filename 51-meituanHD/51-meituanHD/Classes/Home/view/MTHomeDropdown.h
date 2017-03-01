//
//  MTHomeDropdown.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/8.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTHomeDropdownMainCell.h"

@class MTHomeDropdown,MTHomeDropdownMainCell;

/**
 *  数据源
 */
@protocol MTHomeDropdownDataSource <NSObject>

@required

/**
 *  下拉菜单的主表有多少行
 *
 *  @param dropdown 下拉菜单
 *
 *  @return 一共多少行
 */
- (NSInteger)numberOfRowsInMainTableOfHomeDropdown:(MTHomeDropdown *)dropdown;


/**
 *  每个主表cell显示什么
 *
 *  @param dropdown  下拉菜单
 *  @param cell      原来的cell
 *  @param indexPath 期望得到的cell(赋值数据后的cell)
 *
 *  @return 每个cell显示什么
 */
- (MTHomeDropdownMainCell *)homeDropdown:(MTHomeDropdown *)dropdown originalCell:(MTHomeDropdownMainCell*)cell proposedCellForRowAtMainTableIndexPath:(NSIndexPath *)indexPath;

/**
 *  下拉菜单的子表数据
 *
 *  @param dropdown  下拉菜单
 *  @param indexPath 主表的indexPath
 *
 *  @return 子表的数据
 */
- (NSArray *)homeDropdown:(MTHomeDropdown *)dropdown subTableDataOfMainTableIndexPath:(NSIndexPath *)indexPath;

@end

/**
 *  代理
 */
@protocol MTHomeDropdownDelegate <NSObject>

@optional

/**
 *  点击主表的cell
 *
 *  @param dropdown  下拉菜单
 *  @param indexPath 主表的indexPath
 */
- (void)homeDropdown:(MTHomeDropdown *)dropdown didSelectRowInMainTableAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  点击子表的cell
 *
 *  @param dropdown      下拉菜单
 *  @param subIndexPath  子表的indexPath
 *  @param mainIndexPath 主表的indexPath
 */
- (void)homeDropdown:(MTHomeDropdown *)dropdown didSelectRowInSubTableAtIndexPath:(NSIndexPath *)subIndexPath inMainTableIndexPath:(NSIndexPath *)mainIndexPath;

@end


@interface MTHomeDropdown : UIView

+ (instancetype)dropdown;

- (void)reloadTableData;

@property (nonatomic, weak) id<MTHomeDropdownDataSource> dataSource;
@property (nonatomic, weak) id<MTHomeDropdownDelegate> delegate;

@end
