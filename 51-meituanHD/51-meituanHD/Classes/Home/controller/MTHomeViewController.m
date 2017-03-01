//
//  MTHomeViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/8.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTHomeViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "UIView+Extension.h"
#import "MTHomeTopItem.h"
#import "MTCategoryViewController.h"
#import "MTRegionViewController.h"
#import "MTSortViewController.h"
#import "MTModelDataTool.h"
#import "MTCategory.h"
#import "MTRegion.h"
#import "MTCity.h"
#import "MTSort.h"
#import "MJExtension.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "Masonry.h"
#import "MTSearchViewController.h"
#import "MTNavigationController.h"
#import "AwesomeMenu.h"
#import "MTRecentViewController.h"
#import "MTCollectViewController.h"
#import "MTMapViewController.h"

@interface MTHomeViewController () <AwesomeMenuDelegate>

@property (strong, nonatomic) MTCategoryViewController *categoryVC;
@property (strong, nonatomic) MTRegionViewController *regionVC;
@property (strong, nonatomic) MTSortViewController *sortVC;

/** 分类item */
@property (weak, nonatomic) UIBarButtonItem *categoryItem;

/** 地区item */
@property (weak, nonatomic) UIBarButtonItem *regionItem;

/** 排序item */
@property (weak, nonatomic) UIBarButtonItem *sortItem;

/*-------------------------------------------------------------*/

/** 当前选中的城市名字 */
@property (nonatomic, copy) NSString *selectedCityName;

/** 当前选中的分类名字 */
@property (nonatomic, copy) NSString *selectedCategoryName;

/** 当前选中的区域名字 */
@property (nonatomic, copy) NSString *selectedRegionName;

/** 当前选中的排序 */
@property (nonatomic, strong) MTSort *selectedSort;

/*-------------------------------------------------------------*/

/** 分类popover */
@property (nonatomic, strong) UIPopoverPresentationController *categoryPopover;

/** 区域popover */
@property (nonatomic, strong) UIPopoverPresentationController *regionPopover;

/** 排序popover */
@property (nonatomic, strong) UIPopoverPresentationController *sortPopover;

/** 所有的团购数据 */
@property (nonatomic, strong) NSMutableArray *deals;


@end

@implementation MTHomeViewController

static NSString * const reuseIdentifier = @"deals";

- (NSMutableArray *)deals
{
    if (!_deals) {
        self.deals = [[NSMutableArray alloc] init];
    }
    return _deals;
}


//- (MTCategoryViewController *)categoryVC {
//    if (!_categoryVC) {
//        _categoryVC = [[MTCategoryViewController alloc] init];
//    }
//    return _categoryVC;
//}

//- (MTRegionViewController *)regionVC {
//    if (!_regionVC) {
//        _regionVC = [[MTRegionViewController alloc] init];
//        
//        _regionVC.modalPresentationStyle = UIModalPresentationPopover;
//        UIPopoverPresentationController *pover = _regionVC.popoverPresentationController;
//        NSLog(@"pover = %p",pover);
//        //设置在哪个控制器里面弹出来
//        pover.sourceView = self.view;
//        //设置弹出视图的位置
//        pover.barButtonItem = self.regionItem;
//        //设置弹出指向类型为任意
//        pover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//        
//    }
//    return _regionVC;
//}

//- (MTSortViewController *)sortVC {
//    if (!_sortVC) {
//        _sortVC = [[MTSortViewController alloc] init];
//    }
//    return _sortVC;
//}

#pragma mark - System Method

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置左边的item
    [self setupLeftNav];
    
    //设置右边的item
    [self setupRightNav];
    
    // 创建awesomemenu
    [self setupAwesomeMenu];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //监听通知
    [self monitorNotification];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //销毁通知
    [MTNotificationCenter removeObserver:self];
}

#pragma mark - 初始化navItem
//左边
- (void)setupLeftNav {
    //1.logo
    UIBarButtonItem *logoItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_meituan_logo"] style:UIBarButtonItemStyleDone target:nil action:nil];
    logoItem.enabled = NO;
    
    //2.类别
    MTHomeTopItem *categoryTopItem = [MTHomeTopItem item];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    [categoryTopItem setMainTitle:@"全部分类"];
    [categoryTopItem setSubTitle:@"全部"];
    [categoryTopItem setIcon:@"icon_category_-1" highIcon:@"icon_category_highlighted_-1"];
    self.categoryItem = categoryItem;
    
    //3.地区
    MTHomeTopItem *regionTopItem = [MTHomeTopItem item];
    [regionTopItem addTarget:self action:@selector(regionClick)];
    UIBarButtonItem *regionItem = [[UIBarButtonItem alloc] initWithCustomView:regionTopItem];
    self.regionItem = regionItem;
    
    //4.排序
    MTHomeTopItem *sortTopItem = [MTHomeTopItem item];
    [sortTopItem addTarget:self action:@selector(sortClick)];
    UIBarButtonItem *sortItem = [[UIBarButtonItem alloc] initWithCustomView:sortTopItem];
    [sortTopItem setMainTitle:@"排序"];
    [sortTopItem setSubTitle:@"默认排序"];
    [sortTopItem setIcon:@"icon_sort" highIcon:@"icon_sort_highlighted"];
    self.sortItem = sortItem;
    
    self.navigationItem.leftBarButtonItems = @[logoItem,categoryItem,regionItem,sortItem];
}

//右边
- (void)setupRightNav {
    
    UIBarButtonItem *mapItem = [UIBarButtonItem itemWithTarget:self action:@selector(mapItemClick) image:@"icon_map" highlightedImage:@"icon_map_highlighted"];
    mapItem.customView.width = 60;
    
    UIBarButtonItem *searchItem = [UIBarButtonItem itemWithTarget:self action:@selector(searchItemClick) image:@"icon_search" highlightedImage:@"icon_search_highlighted"];
    searchItem.customView.width = 60;
    
    self.navigationItem.rightBarButtonItems = @[mapItem,searchItem];
}

#pragma mark - 设置AwesomeMenu
- (void)setupAwesomeMenu {
    // 1.中间的item
    AwesomeMenuItem *startItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"icon_pathMenu_background_highlighted"] highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mainMine_normal"] highlightedContentImage:nil];
    
    // 2.周边的item
    UIImage *bgImage = [UIImage imageNamed:@"bg_pathMenu_black_normal"];
    
    AwesomeMenuItem *item0 = [[AwesomeMenuItem alloc] initWithImage:bgImage highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_mine_highlighted"]];
    
    AwesomeMenuItem *item1 = [[AwesomeMenuItem alloc] initWithImage:bgImage highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_collect_highlighted"]];
    
    AwesomeMenuItem *item2 = [[AwesomeMenuItem alloc] initWithImage:bgImage highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_scan_highlighted"]];
    
    AwesomeMenuItem *item3 = [[AwesomeMenuItem alloc] initWithImage:bgImage highlightedImage:nil ContentImage:[UIImage imageNamed:@"icon_pathMenu_more_normal"] highlightedContentImage:[UIImage imageNamed:@"icon_pathMenu_more_highlighted"]];
    
    NSArray *items = @[item0, item1, item2, item3];
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:CGRectZero startItem:startItem menuItems:items];
    menu.alpha = 0.3;
    // 设置菜单的活动范围
    menu.menuWholeAngle = M_PI_2;
    // 设置开始按钮的位置
    menu.startPoint = CGPointMake(50, 150);
    // 设置代理
    menu.delegate = self;
    // 不要旋转中间按钮
    menu.rotateAddButton = NO;
    [self.view addSubview:menu];
    
    // 设置菜单永远在左下角
    [menu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(200);
        make.height.equalTo(200);
        make.left.equalTo(self.view.left);
        make.bottom.equalTo(self.view.bottom);
    }];
}

#pragma mark - AwesomeMenuDelegate
- (void)awesomeMenuWillAnimateOpen:(AwesomeMenu *)menu
{
    //替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_cross_normal"];
    
    //完全显示
    menu.alpha = 1.0;
}

- (void)awesomeMenuWillAnimateClose:(AwesomeMenu *)menu
{
    //替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    
    //半透明显示
    menu.alpha = 0.3;
}

- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    //替换菜单的图片
    menu.contentImage = [UIImage imageNamed:@"icon_pathMenu_mainMine_normal"];
    //半透明显示
    menu.alpha = 0.3;
    
    switch (idx) {
        case 1: { // 收藏
            MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:[[MTCollectViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
            
        case 2: { // 最近访问记录
            MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:[[MTRecentViewController alloc] init]];
            [self presentViewController:nav animated:YES completion:nil];
            break;
        } 
            
        default:
            break;
    }
}


#pragma mark - 监听通知
- (void)monitorNotification {
    //切换分类通知
    [MTNotificationCenter addObserver:self selector:@selector(categoryDidChanged:) name:MTCategoryDidChangedNotification object:nil];
    
    //切换城市通知
    [MTNotificationCenter addObserver:self selector:@selector(cityDidChanged:) name:MTCityDidChangedNotification object:nil];
    
    //切换区域通知
    [MTNotificationCenter addObserver:self selector:@selector(regionDidChanged:) name:MTRegionDidChangedNotification object:nil];
    
    //切换排序条件
    [MTNotificationCenter addObserver:self selector:@selector(sortDidChanged:) name:MTSortDidChangedNotification object:nil];
}


#pragma mark - 通知的方法
//切换分类
- (void)categoryDidChanged:(NSNotification *)notification {
    MTCategory *category = notification.userInfo[MTSelectCategory];
    NSString *subcategoryName = notification.userInfo[MTSelectSubCategoryName];
    
    if (subcategoryName == nil || [subcategoryName isEqualToString:@"全部"]) { // 点击的数据没有子分类
        self.selectedCategoryName = category.name;
    } else {
        self.selectedCategoryName = subcategoryName;
    }
    if ([self.selectedCategoryName isEqualToString:@"全部分类"]) {
        self.selectedCategoryName = nil;
    }
    
    // 1.更换顶部item的文字
    MTHomeTopItem *topItem = (MTHomeTopItem *)self.categoryItem.customView;
    [topItem setIcon:category.icon highIcon:category.highlighted_icon];
    [topItem setMainTitle:category.name];
    [topItem setSubTitle:subcategoryName];
    
    // 2.关闭popover
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //刷新表格数据
    [self.collectionView.mj_header beginRefreshing];
    
}

//切换城市
- (void)cityDidChanged:(NSNotification *)notification {
    self.selectedCityName = notification.userInfo[MTSelectCityName];
    // 1.更换顶部区域item的文字
    MTHomeTopItem *topItem = (MTHomeTopItem *)self.regionItem.customView;
    [topItem setMainTitle:[NSString stringWithFormat:@"%@ - 全部", self.selectedCityName]];
//    [topItem setSubTitle:nil];
    
    // 获得当前选中城市
    MTCity *city = [[[MTModelDataTool cities] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.selectedCityName]] firstObject];
    self.regionVC.regions = city.regions;
    //刷新表格
    [self.regionVC reloadDataWithCity:self.selectedCityName];
}

//切换区域
- (void)regionDidChanged:(NSNotification *)notification {
    MTRegion *region = notification.userInfo[MTSelectRegion];
    NSString *subRegionName = notification.userInfo[MTSelectSubRegionName];
    
    if (subRegionName == nil || [subRegionName isEqualToString:@"全部"]) { // 点击的数据没有子分类
        self.selectedRegionName = region.name;
    } else {
        self.selectedRegionName = subRegionName;
    }
    if ([self.selectedRegionName isEqualToString:@"全部"]) {
        self.selectedRegionName = nil;
    }
    
    // 1.更换顶部item的文字
    MTHomeTopItem *topItem = (MTHomeTopItem *)self.regionItem.customView;
    [topItem setMainTitle:[NSString stringWithFormat:@"%@ - %@",region.name, self.selectedCityName]];
    [topItem setSubTitle:subRegionName?:@"全部"];
    
    // 2.关闭popover
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //刷新表格数据
    [self.collectionView.mj_header beginRefreshing];
}

//切换排序条件
- (void)sortDidChanged:(NSNotification *)notification {
    self.selectedSort = notification.userInfo[MTSelectSort];
    
    //更换顶部排序item的文字
    MTHomeTopItem *topItem = (MTHomeTopItem *)self.sortItem.customView;
    [topItem setSubTitle:self.selectedSort.label];
    
    //关闭popover
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //刷新表格数据
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - 父类
- (void)setParams:(NSMutableDictionary *)params {
    // 城市
    params[@"city"] = self.selectedCityName;
    
    // 分类(类别)
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    // 区域
    if (self.selectedRegionName) {
        params[@"region"] = self.selectedRegionName;
    }
    // 排序
    if (self.selectedSort) {
        params[@"sort"] = @(self.selectedSort.value);
    }
}

#pragma mark - 顶部item的点击事件
//分类的item点击事件
- (void)categoryClick {
    
    MTCategoryViewController *categoryVC = [[MTCategoryViewController alloc] init];
    categoryVC.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *pover = categoryVC.popoverPresentationController;
    
    //设置在哪个控制器里面弹出来
    pover.sourceView = self.view;
    //设置弹出视图的位置
    pover.barButtonItem = self.categoryItem;
    //设置弹出指向类型为任意
    pover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    //显示弹出控制器
    [self presentViewController:categoryVC animated:YES completion:nil];
    
}

//区域的item点击事件
- (void)regionClick {
    MTRegionViewController *regionVC = [[MTRegionViewController alloc] init];
    if (self.selectedCityName) {
        // 获得当前选中城市
        MTCity *city = [[[MTModelDataTool cities] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name = %@", self.selectedCityName]] firstObject];
        self.regionVC.regions = city.regions;
    } else {
        //定位
    }
    regionVC.modalPresentationStyle = UIModalPresentationPopover;
    self.regionVC = regionVC;
    
    UIPopoverPresentationController *pover = regionVC.popoverPresentationController;
    //设置在哪个控制器里面弹出来
    pover.sourceView = self.view;
    //设置弹出视图的位置
    pover.barButtonItem = self.regionItem;
    //设置弹出指向类型为任意
    pover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    
    //显示弹出控制器
    [self presentViewController:self.regionVC animated:YES completion:nil];
}

//排序的item点击事件
- (void)sortClick {
    MTSortViewController *sortVC = [[MTSortViewController alloc] init];
    sortVC.modalPresentationStyle = UIModalPresentationPopover;
    
    UIPopoverPresentationController *pover = sortVC.popoverPresentationController;
    
    //设置在哪个控制器里面弹出来
    pover.sourceView = self.view;
    //设置弹出视图的位置
    pover.barButtonItem = self.sortItem;
    //设置弹出指向类型为任意
    pover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    //显示弹出控制器
    [self presentViewController:sortVC animated:YES completion:nil];
}

//搜索item的点击事件
- (void)searchItemClick {
    if (self.selectedCityName) {
        MTSearchViewController *searchVc = [[MTSearchViewController alloc] init];
        searchVc.cityName = self.selectedCityName;
        MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:searchVc];
        [self presentViewController:nav animated:YES completion:nil];
    } else {
        [MBProgressHUD showError:@"请选择城市后再搜索" toView:self.view];
    }
}

//地图item的点击事件
- (void)mapItemClick {
    MTNavigationController *nav = [[MTNavigationController alloc] initWithRootViewController:[[MTMapViewController alloc] init]];
    
    [self presentViewController:nav animated:YES completion:nil];
}

@end
