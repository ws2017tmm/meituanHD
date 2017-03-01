//
//  MTCollectViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/18.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTCollectViewController.h"
#import "MJRefresh.h"
#import "UIView+Extension.h"
#import "MTDatabaseTool.h"
#import "Masonry.h"
#import "MTDealCell.h"
#import "MTDetailViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MTDeal.h"



@interface MTCollectViewController ()<MTDealCellDelegate>

@property (assign, nonatomic) int currentPage;

@property (strong, nonatomic) NSMutableArray *deals;

/** 没有数据的View */
@property (nonatomic, weak) UIImageView *noDataView;

@property (nonatomic, strong) UIBarButtonItem *backItem;
@property (nonatomic, strong) UIBarButtonItem *selectAllItem;
@property (nonatomic, strong) UIBarButtonItem *unselectAllItem;
@property (nonatomic, strong) UIBarButtonItem *removeItem;

@end

@implementation MTCollectViewController

- (NSMutableArray *)deals {
    if (!_deals) {
        _deals = [[NSMutableArray alloc] init];
    }
    return _deals;
}


- (UIImageView *)noDataView {
    if (!_noDataView) {
        // 添加一个"没有数据"的提醒
        UIImageView *noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_collects_empty"]];
        [self.view addSubview:noDataView];
        [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.centerX);
            make.centerY.equalTo(self.view.centerY);
        }];
        self.noDataView = noDataView;
    }
    return _noDataView;
}

- (UIBarButtonItem *)backItem
{
    if (!_backItem) {
        
        self.backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highlightedImage:@"icon_back_highlighted"];
    }
    return _backItem;
}

- (UIBarButtonItem *)selectAllItem {
    if (!_selectAllItem) {
        self.selectAllItem = [[UIBarButtonItem alloc] initWithTitle:MTString(@"全选") style:UIBarButtonItemStyleDone target:self action:@selector(selectAll)];
    }
    return _selectAllItem;
}

- (UIBarButtonItem *)unselectAllItem {
    if (!_unselectAllItem) {
        self.unselectAllItem = [[UIBarButtonItem alloc] initWithTitle:MTString(@"全不选") style:UIBarButtonItemStyleDone target:self action:@selector(unselectAll)];
    }
    return _unselectAllItem;
}

- (UIBarButtonItem *)removeItem {
    if (!_removeItem) {
        self.removeItem = [[UIBarButtonItem alloc] initWithTitle:MTString(@"删除") style:UIBarButtonItemStyleDone target:self action:@selector(remove)];
        self.removeItem.enabled = NO;
    }
    return _removeItem;
}


static NSString * const reuseIdentifier = @"deals";

#pragma mark - System Method

- (instancetype)init {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    // cell的大小
    flowLayout.itemSize = CGSizeMake(305, 305);
    return [self initWithCollectionViewLayout:flowLayout];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = MTGlobalBg;
    self.navigationItem.title = @"收藏的团购";
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MTDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.alwaysBounceVertical = YES;
    
    // 加载第一页的收藏数据
    [self loadMoreDeals];
    
    [self addFooter];
    // 左边的返回
    self.navigationItem.leftBarButtonItems = @[self.backItem];
    
    // 设置导航栏内容
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:MTEdit style:UIBarButtonItemStyleDone target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem.enabled = self.deals.count;
    
    // 监听收藏状态改变的通知
    [MTNotificationCenter addObserver:self selector:@selector(collectStateChange:) name:MTCollectStateDidChangeNotification object:nil];
}

- (void)edit:(UIBarButtonItem *)item
{
    if ([item.title isEqualToString:MTEdit]) {
        item.title = MTDone;
        self.navigationItem.leftBarButtonItems = @[self.backItem, self.selectAllItem, self.unselectAllItem, self.removeItem];
        
        // 进入编辑状态
        for (MTDeal *deal in self.deals) {
            deal.editing = YES;
        }
    } else {
        item.title = MTEdit;
        self.navigationItem.leftBarButtonItems = @[self.backItem];
        
        // 结束编辑状态
        for (MTDeal *deal in self.deals) {
            deal.editing = NO;
        }
    }
    // 刷新表格
    [self.collectionView reloadData];
}

#pragma mark - 屏幕旋转

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    
    int col;
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsPortrait(orientation)) { //竖屏
        col = 2;
    } else if (UIDeviceOrientationIsLandscape(orientation)) { //横屏
        col = 3;
    }
    [self setItemMarginWithSize:size column:col];
}

//改变每个Item之间的间距
- (void)setItemMarginWithSize:(CGSize)size column:(int)column {
    // 根据列数计算内边距
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionViewLayout;
    CGFloat margin = (size.width - layout.itemSize.width * column) / (column + 1);
    
    //每个item之间的间距
    layout.sectionInset = UIEdgeInsetsMake(margin, margin, margin, margin);
    
    // 设置每一行之间的间距
    layout.minimumLineSpacing = margin;
}

#pragma mark - cell的代理
- (void)dealCellCheckingStateDidChanged:(MTDealCell *)cell
{
    BOOL hasChecking = NO;
    for (MTDeal *deal in self.deals) {
        if (deal.isChecking) {
            hasChecking = YES;
            break;
        }
    }
    // 根据有没有打钩的情况,决定删除按钮是否可用
    self.removeItem.enabled = hasChecking;
}

#pragma mark - item的点击方法
//返回
- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  全选
 */
- (void)selectAll {
    for (MTDeal *deal in self.deals) {
        deal.checking = YES;
    }
    [self.collectionView reloadData];
    self.removeItem.enabled = YES;
}

/**
 *  全不选
 */
- (void)unselectAll {
    for (MTDeal *deal in self.deals) {
        deal.checking = NO;
    }
    [self.collectionView reloadData];
    self.removeItem.enabled = NO;
}

/**
 *  删除
 */
- (void)remove {
    NSMutableArray *tempArray = [NSMutableArray array];
    for (MTDeal *deal in self.deals) {
        if (deal.isChecking) {
            [MTDatabaseTool cancelCollectDeal:deal];
            
            [tempArray addObject:deal];
        }
    }
    
    // 删除所有打钩的模型
    [self.deals removeObjectsInArray:tempArray];
    [self.collectionView reloadData];
    //设置item是否可点
    self.removeItem.enabled = NO;
    if (!self.deals.count) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.rightBarButtonItem.title = MTEdit;
        self.navigationItem.leftBarButtonItems = @[self.backItem];
    }
    
}

#pragma mark - 监听通知方法
- (void)collectStateChange:(NSNotification *)notification
{
    //    if ([notification.userInfo[MTIsCollectKey] boolValue]) {
    //        // 收藏成功
    //        [self.deals insertObject:notification.userInfo[MTCollectDealKey] atIndex:0];
    //    } else {
    //        // 取消收藏成功
    //        [self.deals removeObject:notification.userInfo[MTCollectDealKey]];
    //    }
    //
    //    [self.collectionView reloadData];
    [self.deals removeAllObjects];
    
    self.currentPage = 0;
    [self loadMoreDeals];
}

#pragma mark - 上下拉控件

- (void)addFooter {
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDeals)];
}

//上拉加载
- (void)loadMoreDeals {
    // 页码加1
    self.currentPage++;
    
    //加载数据
    [self.deals addObjectsFromArray:[MTDatabaseTool collectDeals:self.currentPage]];
    
    //刷新表格
    [self.collectionView reloadData];
    
    //结束刷新
    [self.collectionView.mj_footer endRefreshing];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    int col;
    if (Portrait()) { // 竖屏
        col = 2;
    } else if (Lanscape()){ //横屏
        col = 3;
    }
    [self setItemMarginWithSize:self.collectionView.size column:col];
    
    // 控制"没有数据"的提醒
    self.noDataView.hidden = (self.deals.count != 0);
    
    //是否隐藏上拉加载控件
    int collectCount = [MTDatabaseTool collectDealsCount];
    self.collectionView.mj_footer.hidden = (self.deals.count == collectCount);
    
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.delegate = self;
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MTDeal *deal = self.deals[indexPath.item];
    
    MTDetailViewController *detailVC = [[MTDetailViewController alloc] init];
    detailVC.deal = deal;
    
    [self presentViewController:detailVC animated:YES completion:^{
        //数据库调换顺序
        [MTDatabaseTool beginFirstDeal:deal];
    }];
    
}

@end
