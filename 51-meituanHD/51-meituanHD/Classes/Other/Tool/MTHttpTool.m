//
//  MTHttpTool.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/12/6.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTHttpTool.h"
#import "DPAPI.h"

@interface MTHttpTool () <DPRequestDelegate>
@property (strong, nonatomic) DPRequest *request;

@end

@implementation MTHttpTool

static DPAPI *_api;
+ (void)initialize
{
    _api = [[DPAPI alloc] init];
    
}

- (void)requestWithUrl:(NSString *)urlString params:(NSMutableDictionary *)params success:(void (^)(id josn))sucess fail:(void (^)(NSError *error))fail {
    
    DPRequest *request = [_api requestWithURL:urlString params:params delegate:self];
    request.success = sucess;
    request.fail = fail;
    self.request = request;
}

#pragma mark - DPRequestDelegate
- (void)request:(DPRequest *)request didFailWithError:(NSError *)error {
    if (request.fail) {
        request.fail(error);
    }
}

- (void)request:(DPRequest *)request didFinishLoadingWithResult:(id)result {
    if (request.success) {
        request.success(result);
    }
}

@end
