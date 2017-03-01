//
//  MTHttpTool.h
//  51-meituanHD
//
//  Created by XSUNT45 on 16/12/6.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTHttpTool : NSObject

- (void)requestWithUrl:(NSString *)urlString params:(NSMutableDictionary *)params success:(void (^)(id josn))sucess fail:(void (^)(NSError *error))fail;

@end
