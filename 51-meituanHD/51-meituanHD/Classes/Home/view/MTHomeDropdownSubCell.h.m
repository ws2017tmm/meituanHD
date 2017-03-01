//
//  MTHomeSubCell.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/9.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTHomeDropdownSubCell.h"

@implementation MTHomeDropdownSubCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    NSString *ID = @"main-id";
    MTHomeDropdownSubCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[MTHomeDropdownSubCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *bg = [[UIImageView alloc] init];
        bg.image = [UIImage imageNamed:@"bg_dropdown_rightpart"];
        self.backgroundView = bg;
        
        UIImageView *selectedBg = [[UIImageView alloc] init];
        selectedBg.image = [UIImage imageNamed:@"bg_dropdown_right_selected"];
        self.selectedBackgroundView = selectedBg;
    }
    return self;
}

@end
