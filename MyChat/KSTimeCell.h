//
//  KSTimeCell.h
//  MyChat
//
//  Created by Vincent_Guo on 15/9/18.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSTimeCell : UITableViewCell

+(instancetype)timeCell:(UITableView *)tableView time:(NSString *)time;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end
