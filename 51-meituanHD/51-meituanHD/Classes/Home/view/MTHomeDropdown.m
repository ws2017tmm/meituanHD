//
//  MTHomeDropdown.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/8.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTHomeDropdown.h"
#import "MTCategory.h"
#import "MTHomeDropdownMainCell.h"
#import "MTHomeDropdownSubCell.h"

@interface MTHomeDropdown ()<UITableViewDataSource, UITableViewDelegate>

//主表
@property (weak, nonatomic) IBOutlet UITableView *mainTableView;
@property (weak, nonatomic) IBOutlet UITableView *subTableView;

//被选中的类别
@property (strong, nonatomic) MTCategory *selectedCategory;

/** 左边主表选中的行号 */
@property (strong, nonatomic) NSIndexPath *selectedMainTableIndex;

@end

@implementation MTHomeDropdown

+ (instancetype)dropdown {
    return [[[NSBundle mainBundle] loadNibNamed:@"MTHomeDropdown" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    self.autoresizingMask = UIViewAutoresizingNone;
}

- (void)reloadTableData {
    [self.mainTableView reloadData];
    [self.subTableView reloadData];
}

#pragma mark - UITableView数据源方法

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.mainTableView) {
        //主表多少行
        NSInteger mainTableRows = [self.dataSource numberOfRowsInMainTableOfHomeDropdown:self];
        return mainTableRows;
    } else {
        //主表某一cell对应的子表有多少行
        NSArray *subTableData = [self.dataSource homeDropdown:self subTableDataOfMainTableIndexPath:self.selectedMainTableIndex];
        return subTableData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MTHomeDropdownMainCell *cell = nil;
    if (tableView == self.mainTableView) { //主表
        //初始化cell
        cell = [MTHomeDropdownMainCell cellWithTableView:tableView];
        
        //为每个主表cell赋值数据
        cell = [self.dataSource homeDropdown:self originalCell:cell proposedCellForRowAtMainTableIndexPath:indexPath];
        
        //主表某一cell对应的子表的数据
        NSArray *subTableData = [self.dataSource homeDropdown:self subTableDataOfMainTableIndexPath:indexPath];
        if (subTableData.count) { //如果字表有数据,显示指示器(>)
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        
    } else { //从表
        cell = [MTHomeDropdownMainCell cellWithTableView:tableView];
        
        NSArray *subTableData = [self.dataSource homeDropdown:self subTableDataOfMainTableIndexPath:self.selectedMainTableIndex];
        
        cell.textLabel.text = subTableData[indexPath.row];
    }
    return cell;
}

#pragma mark - UITableView的代理方法

//点击每个cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.mainTableView) { //点击的是主表
        self.selectedMainTableIndex = indexPath;
        [self.subTableView reloadData];
        
        //通知代理
        if ([self.delegate respondsToSelector:@selector(homeDropdown:didSelectRowInMainTableAtIndexPath:)]) {
            [self.delegate homeDropdown:self didSelectRowInMainTableAtIndexPath:indexPath];
        }
    } else { //点击的是子表
        //通知代理
        if ([self.delegate respondsToSelector:@selector(homeDropdown:didSelectRowInSubTableAtIndexPath:inMainTableIndexPath:)]) {
            [self.delegate homeDropdown:self didSelectRowInSubTableAtIndexPath:indexPath inMainTableIndexPath:self.selectedMainTableIndex];
        }
    }
    
}

@end
