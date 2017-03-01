//
//  MTBusiness.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/12/2.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTBusiness : NSObject

/** 店名 */
@property (copy, nonatomic) NSString *name;

/** 纬度 */
@property (assign, nonatomic) float latitude;

/** 经度 */
@property (assign, nonatomic) float longitude;

@end
