//
//  MTSearchViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/18.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTSearchViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MTSearchView.h"
#import "MJRefresh.h"

@interface MTSearchViewController ()

@property (copy, nonatomic) NSString *searchBarText;

@end

@implementation MTSearchViewController

- (void)dealloc {
    [MTNotificationCenter removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置导航栏
    [self setupNav];
    
    //通知
    [MTNotificationCenter addObserver:self selector:@selector(searchButtonDidClick:) name:MTSearchButtonDidClickNotification object:nil];
}

- (void)setupNav {
    // 左边的返回
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highlightedImage:@"icon_back_highlighted"];
    
    //中间的搜索
    self.navigationItem.titleView = [MTSearchView searchBar];
    
}

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 通知
- (void)searchButtonDidClick:(NSNotification *)notification {
    self.searchBarText = notification.userInfo[MTSearchText];
    
    //刷新表格数据
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - 实现父类提供的方法
- (void)setParams:(NSMutableDictionary *)params
{
    params[@"city"] = self.cityName;
    params[@"keyword"] = self.searchBarText;
}

@end
