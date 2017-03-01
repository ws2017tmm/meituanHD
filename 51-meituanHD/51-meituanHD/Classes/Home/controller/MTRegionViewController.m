//
//  MTRegionViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/11.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTRegionViewController.h"
#import "MTHomeDropdown.h"
#import "MTNavigationController.h"
#import "MTCityViewController.h"
#import "Masonry.h"
#import "MTRegion.h"


@interface MTRegionViewController ()<MTHomeDropdownDataSource,MTHomeDropdownDelegate>

@property (weak, nonatomic) IBOutlet UIView *headView;

@property (weak, nonatomic) IBOutlet UIButton *cityButton;

- (IBAction)changeCity;

@property (weak, nonatomic) MTHomeDropdown *dropdown;

@end

@implementation MTRegionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //创建dropdown
    MTHomeDropdown *dropdown = [MTHomeDropdown dropdown];
    dropdown.dataSource = self;
    dropdown.delegate = self;
    
    //    dropdown.y = self.headView.height;
    [self.view addSubview:dropdown];
    [dropdown mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headView.bottom);
        make.bottom.equalTo(self.view.bottom);
        make.left.equalTo(self.view.left);
        make.right.equalTo(self.view.right);
    }];
    
    self.dropdown = dropdown;
    
    // 设置控制器在popover中的尺寸
    self.preferredContentSize = dropdown.frame.size;
}


- (IBAction)changeCity {
    MTCityViewController *city = [[MTCityViewController alloc]  init];
    
    MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:city];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentViewController:nav animated:YES completion:nil];
    
}

//刷新表格数据
- (void)reloadDataWithCity:(NSString *)cityName {
    [self.dropdown reloadTableData];
    [self.cityButton setTitle:cityName forState:UIControlStateNormal];
}

#pragma mark - MTHomeDropdownDataSource

/**
 *  主表多少行
 */
- (NSInteger)numberOfRowsInMainTableOfHomeDropdown:(MTHomeDropdown *)dropdown {
    return self.regions.count;
}

/**
 *  主表每个cell显示什么
 */
- (MTHomeDropdownMainCell *)homeDropdown:(MTHomeDropdown *)dropdown originalCell:(MTHomeDropdownMainCell *)cell proposedCellForRowAtMainTableIndexPath:(NSIndexPath *)indexPath {
    
    MTRegion *region = self.regions[indexPath.row];
    cell.textLabel.text = region.name;
    
    return cell;
}

/**
 *  返回子表的数据
 */
- (NSArray *)homeDropdown:(MTHomeDropdown *)dropdown subTableDataOfMainTableIndexPath:(NSIndexPath *)indexPath {
    MTRegion *region = self.regions[indexPath.row];
    return region.subregions;
}

/**
 *  点击主表
 */
- (void)homeDropdown:(MTHomeDropdown *)dropdown didSelectRowInMainTableAtIndexPath:(NSIndexPath *)indexPath {
    MTRegion *region = self.regions[indexPath.row];
    if (region.subregions.count == 0) { //子表没有数据发出通知
        NSDictionary *dict = @{MTSelectRegion : region};
        [MTNotificationCenter postNotificationName:MTRegionDidChangedNotification object:nil userInfo:dict];
    }
}

/**
 *  点击子表
 */
- (void)homeDropdown:(MTHomeDropdown *)dropdown didSelectRowInSubTableAtIndexPath:(NSIndexPath *)subIndexPath inMainTableIndexPath:(NSIndexPath *)mainIndexPath {
    
    MTRegion *mainRegion = self.regions[mainIndexPath.row];
    MTRegion *subRegion = mainRegion.subregions[subIndexPath.row];
    
    NSDictionary *dict = @{MTSelectRegion : mainRegion, MTSelectSubRegionName : subRegion};
    [MTNotificationCenter postNotificationName:MTRegionDidChangedNotification object:nil userInfo:dict];
    
}


@end
