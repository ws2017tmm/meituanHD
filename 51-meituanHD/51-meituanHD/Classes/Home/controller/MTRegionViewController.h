//
//  MTRegionViewController.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/11.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTRegionViewController : UIViewController

@property (nonatomic, strong) NSArray *regions;

/**
 *  刷新表格数据
 */
- (void)reloadDataWithCity:(NSString *)cityName;

@end
