//
//  MTSearchView.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/18.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTSearchView.h"

@interface MTSearchView () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (IBAction)searchBtnDidClick;

@end

@implementation MTSearchView

+ (instancetype)searchBar {
    return [[[NSBundle mainBundle] loadNibNamed:@"MTSearchView" owner:nil options:nil] firstObject];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchBar= searchBar;
    
    NSDictionary *dict = @{MTSearchText : searchBar.text};
    [MTNotificationCenter postNotificationName:MTSearchButtonDidClickNotification object:nil userInfo:dict];
    // 退出键盘
    [searchBar resignFirstResponder];
}

- (IBAction)searchBtnDidClick {
    
    [self searchBarSearchButtonClicked:self.searchBar];
    
}

@end
