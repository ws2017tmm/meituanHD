//
//  MTDealAnnotation.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/12/5.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTDealAnnotation.h"

@implementation MTDealAnnotation

- (BOOL)isEqual:(MTDealAnnotation *)other
{
    return [self.title isEqual:other.title];
}

@end
