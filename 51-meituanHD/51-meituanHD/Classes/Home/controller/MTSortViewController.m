//
//  MTSortViewController.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/14.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTSortViewController.h"
#import "MTModelDataTool.h"
#import "MTSort.h"
#import "Masonry.h"

/**
 *  自定义button,仅供内部使用
 */
@interface MTSortButton : UIButton

@property (nonatomic, strong) MTSort *sort;

@end

@implementation MTSortButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_normal"] forState:UIControlStateNormal];
        [self setBackgroundImage:[UIImage imageNamed:@"btn_filter_selected"] forState:UIControlStateHighlighted];
    }
    return self;
}

- (void)setSort:(MTSort *)sort
{
    _sort = sort;
    
    [self setTitle:sort.label forState:UIControlStateNormal];
}
@end


@interface MTSortViewController ()


@end

@implementation MTSortViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *sort = [MTModelDataTool sorts];
    
    __block UIView *previous = nil;
    for (NSUInteger i = 0; i < sort.count; i++) {
        MTSortButton *button = [[MTSortButton alloc] init];
        button.sort = sort[i];
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        [self.view addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(10.0f);
            make.right.equalTo(self.view).offset(-10.0f);
            make.height.equalTo(30.0f);
            if(previous)
            {
                make.top.equalTo(previous.bottom).offset(10.0f);
            } else {
                make.top.equalTo(self.view).offset(10.0f);
            }
            previous = button;
        }];
    }
    // 设置控制器在popover中的尺寸
    CGFloat width = 120;
    CGFloat height = 290;
    self.preferredContentSize = CGSizeMake(width, height);
    
}


- (void)buttonClick:(MTSortButton *)button
{
    [MTNotificationCenter postNotificationName:MTSortDidChangedNotification object:nil userInfo:@{MTSelectSort : button.sort}];
}


@end
