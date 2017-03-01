//
//  MTCityViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/9.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTCityViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MTCityGroup.h"
#import "MJExtension.h"
#import "Masonry.h"
#import "MTCitySearchResultViewController.h"

@interface MTCityViewController ()<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>

@property (strong, nonatomic) NSArray *cityGroups;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (weak, nonatomic) IBOutlet UIButton *coverBtn;

@property (weak, nonatomic) MTCitySearchResultViewController *citySearchResultVC;

- (IBAction)coverBtnClick;


@end

@implementation MTCityViewController

- (MTCitySearchResultViewController *)citySearchResultVC {
    if (!_citySearchResultVC) {
        MTCitySearchResultViewController *citySearchResultVC = [[MTCitySearchResultViewController alloc] init];
        [self addChildViewController:citySearchResultVC];
        self.citySearchResultVC = citySearchResultVC;
        
        [self.view addSubview:citySearchResultVC.view];
        //添加约束
        [citySearchResultVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.tableView.left);
            make.right.equalTo(self.tableView.right);
            make.top.equalTo(self.tableView.top);
            make.bottom.equalTo(self.tableView.bottom);
        }];
        
    }
    return _citySearchResultVC;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"切换城市";
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithTarget:self action:@selector(close) image:@"btn_navigation_close" highlightedImage:@"btn_navigation_close_hl"];
    
    //plist转模型
    self.cityGroups = [MTCityGroup objectArrayWithFilename:@"cityGroups.plist"];
    
    self.tableView.sectionIndexColor = [UIColor blackColor];
    self.searchBar.tintColor = MTColor(32, 191, 179);
    
}


- (void)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableView 数据源方法

//一共多少组
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.cityGroups.count;
}

//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MTCityGroup *cityGroup = self.cityGroups[section];
    return cityGroup.cities.count;
}

//每行显示什么
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"city";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    MTCityGroup *group = self.cityGroups[indexPath.section];
    cell.textLabel.text = group.cities[indexPath.row];
    
    return cell;
}

#pragma mark - UITableView 代理方法

//点击cell
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    MTCityGroup *cityGroup = self.cityGroups[indexPath.section];
    NSString *cityName = cityGroup.cities[indexPath.row];
    
    NSDictionary *userInfo = @{MTSelectCityName : cityName};
    [MTNotificationCenter postNotificationName:MTCityDidChangedNotification object:nil userInfo:userInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//section的头部标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    MTCityGroup *cityGroup = self.cityGroups[section];
    return cityGroup.title;
}

//tableView右边的索引
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return [self.cityGroups valueForKeyPath:@"title"];
}

#pragma mark - 搜索框的代理方法
//键盘弹出,开始编辑文字
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    //隐藏导航栏
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    //显示取消按钮
    [searchBar setShowsCancelButton:YES animated:YES];
    
    //显示遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.coverBtn.alpha = 0.5;
    }];
    
    //修改搜索框的背景图片
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield_hl"]];
    
}

//键盘退下,结束编辑文字
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    //显示导航栏
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    //隐藏取消按钮
    [searchBar setShowsCancelButton:NO animated:YES];
    
    //隐藏遮盖
    [UIView animateWithDuration:0.5 animations:^{
        self.coverBtn.alpha = 0.0;
    }];
    
    //修改搜索框的背景图片
    [searchBar setBackgroundImage:[UIImage imageNamed:@"bg_login_textfield"]];
    
    //清空文字,隐藏搜索结果View
    searchBar.text = nil;
    self.citySearchResultVC.view.hidden = YES;
    
}

//searchBar里的cancelButon点击
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

//searchBar里的text变化时调用
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //
    if (searchText.length) { //输入了文字
        self.citySearchResultVC.view.hidden = NO;
        self.citySearchResultVC.searchText = searchText;
    } else { //没有文字
        self.citySearchResultVC.view.hidden = YES;
    }
    
}

#pragma mark - 遮盖的点击事件
- (IBAction)coverBtnClick {
    [self.searchBar resignFirstResponder];
}
















@end
