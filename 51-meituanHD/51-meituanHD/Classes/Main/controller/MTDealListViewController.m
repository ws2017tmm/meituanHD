//
//  MTDealListViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/18.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTDealListViewController.h"
#import "Masonry.h"
#import "DPAPI.h"
#import "MTDeal.h"
#import "MTDealCell.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"
#import "MJExtension.h"
#import "UIView+Extension.h"
#import "MTDetailViewController.h"
#import "MTDatabaseTool.h"

@interface MTDealListViewController () <DPRequestDelegate>

/** 所有的团购数据 */
@property (nonatomic, strong) NSMutableArray *deals;

/** 页码，如不传入默认为1，即第一页 */
@property (assign, nonatomic) int currentPage;

/** 最后一次的请求 */
@property (strong, nonatomic) DPRequest *lastRequest;

/** 每个条件下对应数据的总数 */
@property (assign, nonatomic) int totalCount;

/** 没有数据的View */
@property (nonatomic, weak) UIImageView *noDataView;

@end

@implementation MTDealListViewController


static NSString * const reuseIdentifier = @"deals";

- (NSMutableArray *)deals
{
    if (!_deals) {
        self.deals = [[NSMutableArray alloc] init];
    }
    return _deals;
}

- (UIImageView *)noDataView
{
    if (!_noDataView) {
        // 添加一个"没有数据"的提醒
        UIImageView *noDataView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_deals_empty"]];
        [self.view addSubview:noDataView];
        [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.view.centerX);
            make.centerY.equalTo(self.view.centerY);
        }];
        self.noDataView = noDataView;
    }
    return _noDataView;
}


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
    
    // Register cell classes
    [self.collectionView registerNib:[UINib nibWithNibName:@"MTDealCell" bundle:nil] forCellWithReuseIdentifier:reuseIdentifier];
    self.collectionView.alwaysBounceVertical = YES;
    
    //添加上拉加载更多
    [self addFooter];
    //添加下拉刷新最新
    [self addHeader];
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

#pragma mark - 上下拉控件 

- (void)addFooter {
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDeals)];
}

- (void)addHeader {
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewDeals)];
}

//上拉加载
- (void)loadMoreDeals {
    self.currentPage++;
    //加载团购数据
    [self loadDeals];
}


#pragma mark - 和服务器交互

//下拉加载
- (void)loadNewDeals {
    self.currentPage = 1;
    //加载团购数据
    [self loadDeals];
}

//加载团购数据
- (void)loadDeals {
    
    DPAPI *api = [[DPAPI alloc] init];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [self setParams:params];
    // 每页的条数
    params[@"limit"] = @18;
    //page
    params[@"page"] = @(self.currentPage);
    
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

#pragma mark - DPRequestDelegate
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    //两次请求不一样,直接返回
    if (request != self.lastRequest) return;
    
    self.totalCount = [result[@"total_count"] intValue];
    // 1.取出团购的字典数组
    NSArray *newDeals = [MTDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    if (self.currentPage == 1) { //清除之前的数据
        [self.deals removeAllObjects];
    }
    [self.deals addObjectsFromArray:newDeals];
    
    // 2.刷新表格
    [self.collectionView reloadData];
    
    [self.collectionView.mj_header endRefreshing];
    [self.collectionView.mj_footer endRefreshing];
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if (request != self.lastRequest) return;
    
    NSLog(@"error = %@",error);
    [MBProgressHUD showError:@"网络繁忙,请稍后再试" toView:self.view];
    
    [self.collectionView.mj_footer endRefreshing];
    [self.collectionView.mj_header endRefreshing];
    
    if (self.currentPage > 1) {
        self.currentPage--;
    }
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
    self.collectionView.mj_footer.hidden = (self.deals.count == self.totalCount);
    
    return self.deals.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTDealCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.deal = self.deals[indexPath.item];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MTDeal *deal = self.deals[indexPath.item];
    
    MTDetailViewController *detailVC = [[MTDetailViewController alloc] init];
    detailVC.deal = deal;
    
    [self presentViewController:detailVC animated:YES completion:^{
        if (![MTDatabaseTool recentDealsContainsdeal:deal]) {
            //将点击的团购存入浏览记录
            [MTDatabaseTool addRecentDeal:deal];
            
        }
    }];
    
}

@end
