//
//  KSTimeCell.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/18.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSTimeCell.h"

@implementation KSTimeCell

+(instancetype)timeCell:(UITableView *)tableView time:(NSString *)time{
    static NSString *ID = @"TimeCell";
    //1.创建cell
    KSTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:ID];
    //2.设置时间
    timeCell.timeLabel.text = time;
    
    return timeCell;
}

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] init];
    self.backgroundColor = [UIColor clearColor];
}



@end
