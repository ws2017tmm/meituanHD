//
//  MTHomeMainCell.m
//  51-meituanHD
//
//  Created by XSUNT45 on 16/11/9.
//  Copyright © 2016年 XSUNT45. All rights reserved.
//

#import "MTHomeDropdownMainCell.h"

@implementation MTHomeDropdownMainCell

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    NSString *ID = @"main-id";
    MTHomeDropdownMainCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[MTHomeDropdownMainCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *bg = [[UIImageView alloc] init];
        bg.image = [UIImage imageNamed:@"bg_dropdown_leftpart"];
        self.backgroundView = bg;
        
        UIImageView *selectedBg = [[UIImageView alloc] init];
        selectedBg.image = [UIImage imageNamed:@"bg_dropdown_left_selected"];
        self.selectedBackgroundView = selectedBg;
    }
    return self;
}

@end
