//
//  MTDetailViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/21.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTDetailViewController.h"
#import "MTDeal.h"
#import "MTCenterLineLabel.h"
#import "MJExtension.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+MJ.h"
#import "DPAPI.h"
#import "MTRestrictions.h"
#import "MBProgressHUD+MJ.h"
#import "FMDB.h"
#import "MTDatabaseTool.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"

@interface MTDetailViewController () <UIWebViewDelegate,DPRequestDelegate>

- (IBAction)back;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (weak, nonatomic) IBOutlet UILabel *currentPrice;

@property (weak, nonatomic) IBOutlet MTCenterLineLabel *originalPrice;

- (IBAction)buyNow;

- (IBAction)collect:(UIButton *)collectBtn;

@property (weak, nonatomic) IBOutlet UIButton *collcetButton;


- (IBAction)share;

@property (weak, nonatomic) IBOutlet UIButton *refundableAnyTimeButton;

@property (weak, nonatomic) IBOutlet UIButton *refundableExpireButton;

@property (weak, nonatomic) IBOutlet UIButton *expireTimeButton;

@property (weak, nonatomic) IBOutlet UIButton *soldCountButton;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation MTDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //背景色
    self.view.backgroundColor = MTGlobalBg;
    
    //左边团购基本信息
    [self setupLeftInfo];
    
    //右边显示详情
    [self setupRightInfo];
    
    //收藏按钮是否被选中
    self.collcetButton.selected = [MTDatabaseTool isCollected:self.deal];
    
}

#pragma mark - 支持横竖屏
//这个界面只支持横屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

#pragma mark - 左边界面的详情
- (void)setupLeftInfo {
    // 设置基本信息
    self.titleLabel.text = self.deal.title;
    self.descLabel.text = self.deal.desc;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.deal.image_url]];
    //现价
    self.currentPrice.text = [NSString stringWithFormat:@"￥%@",self.deal.current_price.stringValue];
    //原价
    self.originalPrice.text = self.deal.list_price.stringValue;
    
    //过期时间
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    NSDate *deadTime = [fmt dateFromString:self.deal.purchase_deadline];
    deadTime = [deadTime dateByAddingTimeInterval:24 * 60 * 60];
    //当前时间
    NSDate *currDate = [NSDate date];
    NSCalendarUnit unit = NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *cmps = [[NSCalendar currentCalendar] components:unit fromDate:currDate toDate:deadTime options:0];
    if (cmps.day > 365) {
        [self.expireTimeButton setTitle:@"一年内不过期" forState:UIControlStateNormal];
    } else {
        [self.expireTimeButton setTitle:[NSString stringWithFormat:@"%d天%d小时%d分钟", cmps.day, cmps.hour, cmps.minute] forState:UIControlStateNormal];
    }
    
    //已售出多少
    NSString *title = [NSString stringWithFormat:@"已售出%d",self.deal.purchase_count];
    [self.soldCountButton setTitle:title forState:UIControlStateNormal];
    
    
    // 发送请求获得更详细的团购数据
    DPAPI *api = [[DPAPI alloc] init];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    //每个团购的id
    params[@"deal_id"] = self.deal.deal_id;
    [api requestWithURL:@"v1/deal/get_single_deal" params:params delegate:self];
    
}

#pragma mark - DPRequestDelegate
- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result {
    self.deal = [MTDeal objectWithKeyValues:[result[@"deals"] firstObject]];
    // 设置退款信息
    self.refundableAnyTimeButton.selected = self.deal.restrictions.is_refundable;
    self.refundableExpireButton.selected = self.deal.restrictions.is_refundable;
    
}

- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
    [MBProgressHUD showError:@"网络繁忙,请稍后再试" toView:self.view];
}

#pragma mark - 右边界面的详情
- (void)setupRightInfo {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.deal.deal_h5_url]]];
}

#pragma mark - UIWebViewDelegate
//右边的界面
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    if ([webView.request.URL.absoluteString isEqualToString:self.deal.deal_h5_url]) {
        // 旧的HTML5页面加载完毕
        NSString *ID = [self.deal.deal_id substringFromIndex:[self.deal.deal_id rangeOfString:@"-"].location + 1];
        NSString *urlStr = [NSString stringWithFormat:@"http://m.dianping.com/tuan/deal/moreinfo/%@", ID];
        webView.hidden = YES;
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]]];
    } else { // 详情页面加载完毕
        // 用来拼接所有的JS
        NSMutableString *js = [NSMutableString string];
        // 删除header
        [js appendString:@"var header = document.getElementsByTagName('header')[0];"];
        [js appendString:@"header.parentNode.removeChild(header);"];
        // 删除顶部的购买
        [js appendString:@"var box = document.getElementsByClassName('cost-box')[0];"];
        [js appendString:@"box.parentNode.removeChild(box);"];
        // 删除底部的购买
        [js appendString:@"var buyNow = document.getElementsByClassName('buy-now')[0];"];
        [js appendString:@"buyNow.parentNode.removeChild(buyNow);"];
        
        // 利用webView执行JS
        [webView stringByEvaluatingJavaScriptFromString:js];
        
        // 获得页面
        webView.hidden = NO;
        // 隐藏正在加载
        [self.loadingView stopAnimating];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error = %@",error);
}

#pragma mark - 按钮的点击事件
/**
 *  返回按钮
 */
- (IBAction)back {
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/**
 *   立即抢购
 */
- (IBAction)buyNow {
    
//    NSString *appID = [[NSUserDefaults standardUserDefaults] objectForKey:@"appkey"];
    NSString *appID = @"975791789";
    NSString *privateKey = @"232sds2sd23dse2";//乱写的
    /*============================================================================*/
    /*============================================================================*/
    /*============================================================================*/
    
    //partner和seller获取失败,提示
    if ([appID length] == 0 ||
        [privateKey length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"  message:@"缺少appId或者私钥。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    Order* order = [[Order alloc] init];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type设置
    order.sign_type = @"RSA";
    
    // NOTE: 商品数据
    order.biz_content = [[BizContent alloc] init];
    order.biz_content.body = self.deal.desc;
    order.biz_content.subject = self.deal.title;
    order.biz_content.out_trade_no = [self generateTradeNO]; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = [NSString stringWithFormat:@"%.2f", [self.deal.current_price floatValue]]; //商品价格
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    NSLog(@"orderSpec = %@",orderInfo);
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderInfo];
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"alimeituan";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            NSLog(@"reslut = %@",resultDic);
        }];
    }
}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand((unsigned)time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

/**
 *  收藏按钮的点击事件
 */
- (IBAction)collect:(UIButton *)collectBtn {
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[MTCollectDealKey] = self.deal;
    if (collectBtn.isSelected) { //取消收藏
        [MTDatabaseTool cancelCollectDeal:self.deal];
        [MBProgressHUD showSuccess:@"取消收藏成功" toView:self.view];
        info[MTIsCollectKey] = @NO;
    } else { //收藏
        [MTDatabaseTool addCollectDeal:self.deal];
        [MBProgressHUD showSuccess:@"收藏成功" toView:self.view];
        info[MTIsCollectKey] = @YES;
    }
    collectBtn.selected = !collectBtn.isSelected;
    
    // 发出通知
    [MTNotificationCenter postNotificationName:MTCollectStateDidChangeNotification object:nil userInfo:info];
}


/**
 *  分享按钮的点击事件
 */
- (IBAction)share {
    
}

@end
