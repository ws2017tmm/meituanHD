//
//  MTMapViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/30.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTMapViewController.h"
#import "UIBarButtonItem+Extension.h"
#import "MTHomeTopItem.h"
#import "MTCategoryViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DPAPI.h"
#import "MJExtension.h"
#import "MTDeal.h"
#import "MTBusiness.h"
#import "MTCategory.h"
#import "MTModelDataTool.h"
#import "MTDealAnnotation.h"
#import "MTHttpTool.h"
#import "MBProgressHUD+MJ.h"


@interface MTMapViewController ()<MKMapViewDelegate,CLLocationManagerDelegate,DPRequestDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)backToMyPosition;

@property (weak, nonatomic) UIBarButtonItem *categoryItem;

@property (nonatomic, strong) CLGeocoder *coder;

@property (nonatomic, copy) NSString *city;

@property (strong, nonatomic) CLLocationManager *mgr;

@property (nonatomic, strong) DPRequest *lastRequest;

@property (nonatomic, copy) NSString *selectedCategoryName;

@property (strong, nonatomic) CLLocation *currentLocation;


@end

@implementation MTMapViewController

- (CLGeocoder *)coder
{
    if (!_coder) {
        self.coder = [[CLGeocoder alloc] init];
    }
    return _coder;
}

- (CLLocationManager *)mgr {
    if (!_mgr) {
        _mgr = [[CLLocationManager alloc] init];
        //两百米发一次请求
//        _mgr.distanceFilter = 200;
        _mgr.delegate = self;
    }
    return _mgr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNav];
    
    //切换分类通知
    [MTNotificationCenter addObserver:self selector:@selector(categoryDidChanged:) name:MTCategoryDidChangedNotification object:nil];
}

- (void)dealloc
{
    [MTNotificationCenter removeObserver:self];
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
    
    // 3.删除之前的所有大头针
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    // 4.重新发送请求给服务器
    [self mapView:self.mapView regionDidChangeAnimated:YES];
    
    
}


- (void)setupNav {
    // 标题
    self.title = @"地图";
    
    //返回
    UIBarButtonItem *backItem = [UIBarButtonItem itemWithTarget:self action:@selector(back) image:@"icon_back" highlightedImage:@"icon_back_highlighted"];
    
    //2.类别
    MTHomeTopItem *categoryTopItem = [MTHomeTopItem item];
    [categoryTopItem addTarget:self action:@selector(categoryClick)];
    UIBarButtonItem *categoryItem = [[UIBarButtonItem alloc] initWithCustomView:categoryTopItem];
    [categoryTopItem setMainTitle:@"全部分类"];
    [categoryTopItem setSubTitle:@"全部"];
    [categoryTopItem setIcon:@"icon_category_-1" highIcon:@"icon_category_highlighted_-1"];
    self.categoryItem = categoryItem;
    
    self.navigationItem.leftBarButtonItems = @[backItem,categoryItem];
    
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

- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backToMyPosition {
    // 让地图显示到用户所在的位置
    MKCoordinateRegion region = MKCoordinateRegionMake(self.currentLocation.coordinate, MKCoordinateSpanMake(0.15, 0.15));
    [self.mapView setRegion:region animated:YES];
}

#pragma mark - MKMapViewDelegate

/**
 *  地图即将加载的时候
 */
- (void)mapViewWillStartLoadingMap:(MKMapView *)mapView {
    // 设置地图跟踪用户的位置
    mapView.userTrackingMode = MKUserTrackingModeFollow;
    mapView.showsUserLocation = YES;
    [self.mgr requestAlwaysAuthorization];
}

/**
 *  地图加载完毕的时候
 */
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    
}

/**
 * 当用户的位置更新了就会调用一次
 */
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    // 经纬度 --> 城市名 : 反地理编码
    // 城市名 --> 经纬度 : 地理编码
    [self.coder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error || placemarks.count == 0) return;
        
        CLPlacemark *pm = [placemarks firstObject];
        NSString *city = pm.locality ? pm.locality : pm.addressDictionary[@"State"];
        self.city = [city substringToIndex:city.length - 1];
        
        // 第一次发送请求给服务器
        [self mapView:self.mapView regionDidChangeAnimated:YES];
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (self.city == nil) return;
    // 发送请求给服务器
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 城市
    params[@"city"] = self.city;
    // 搜索条数
    params[@"limit"] = @40;
    
    // 类别
    if (self.selectedCategoryName) {
        params[@"category"] = self.selectedCategoryName;
    }
    // 经纬度
    params[@"latitude"] = @(mapView.region.center.latitude);
    params[@"longitude"] = @(mapView.region.center.longitude);
    params[@"radius"] = @(1000);
    
//    MTHttpTool *tool = [[MTHttpTool alloc] init];
//    [tool requestWithUrl:@"v1/deal/find_deals" params:params success: ^(id josn) {
//        
//        NSArray *deals = [MTDeal objectArrayWithKeyValuesArray:josn[@"deals"]];
//        for (MTDeal *deal in deals) {
//            
//            // 获得团购所属的类型
//            MTCategory *category = [MTModelDataTool categoryWithDeal:deal];
//            
//            for (MTBusiness *business in deal.businesses) {
//                MTDealAnnotation *anno = [[MTDealAnnotation alloc] init];
//                anno.coordinate = CLLocationCoordinate2DMake(business.latitude, business.longitude);
//                anno.title = business.name;
//                anno.subtitle = deal.title;
//                anno.icon = category.map_icon;
//                
//                if ([self.mapView.annotations containsObject:anno]) break;
//                
//                [self.mapView addAnnotation:anno];
//            }
//        }
//    } fail:^(NSError *error) {
//        [MBProgressHUD showError:@"请求失败，稍后再试"];
//    }];
    
    self.lastRequest = [api requestWithURL:@"v1/deal/find_deals" params:params delegate:self];
}

#pragma mark - 请求代理
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error
{
    if (request != self.lastRequest) return;
    
    NSLog(@"请求失败 - %@", error);
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result
{
    if (request != self.lastRequest) return;
    NSArray *deals = [MTDeal objectArrayWithKeyValuesArray:result[@"deals"]];
    for (MTDeal *deal in deals) {
        
        // 获得团购所属的类型
        MTCategory *category = [MTModelDataTool categoryWithDeal:deal];
        
        for (MTBusiness *business in deal.businesses) {
            MTDealAnnotation *anno = [[MTDealAnnotation alloc] init];
            anno.coordinate = CLLocationCoordinate2DMake(business.latitude, business.longitude);
            anno.title = business.name;
            anno.subtitle = deal.title;
            anno.icon = category.map_icon;
            
            if ([self.mapView.annotations containsObject:anno]) break;
            
            [self.mapView addAnnotation:anno];
        }
    }
}

/**
 *  自定义大头针
 */
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(MTDealAnnotation *)annotation {
    // 返回nil,意味着交给系统处理
    if (![annotation isKindOfClass:[MTDealAnnotation class]]) return nil;
    
    // 创建大头针控件
    static NSString *ID = @"deal";
    MKAnnotationView *annoView = [mapView dequeueReusableAnnotationViewWithIdentifier:ID];
    if (annoView == nil) {
        annoView = [[MKAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:ID];
        annoView.canShowCallout = YES;
    }
    
    // 设置模型(位置\标题\子标题)
    annoView.annotation = annotation;
    
    // 设置图片
    annoView.image = [UIImage imageNamed:annotation.icon];
    
    return annoView;
}

#pragma mark - CLLocationManagerDelegate
/**
 *  授权状态发生改变时调用
 *
 *  @param manager 触发事件的对象
 *  @param status  当前授权的状态
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"等待用户授权");
    }else if (status == kCLAuthorizationStatusAuthorizedAlways ||
              status == kCLAuthorizationStatusAuthorizedWhenInUse)
        
    {
        NSLog(@"授权成功");
        // 开始定位
        [self.mgr startUpdatingLocation];
        
    }else
    {
        NSLog(@"授权失败");
    }
}

/**
 *  获取到位置信息之后就会调用(调用频率非常高)
 *
 *  @param manager   触发事件的对象
 *  @param locations 获取到的位置
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations {
    
    CLLocation *userLocation = [locations firstObject];
    //记录当前用户的位置
    self.currentLocation = userLocation;
    // 让地图显示到用户所在的位置
    MKCoordinateRegion region = MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.15, 0.15));
    [self.mapView setRegion:region animated:YES];
    
}


@end
