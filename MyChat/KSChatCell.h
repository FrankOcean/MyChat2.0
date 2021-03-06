//
//  KSChatCell2.h
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString *SenderCell = @"SenderCell";
static NSString *ReceiverCell = @"ReceiverCell";

@interface KSChatCell : UITableViewCell

+(instancetype)chatCell:(UITableView *)tableView message:(EMMessage *)message;

@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

@property (strong, nonatomic) EMMessage *message;
//cell的高度
-(CGFloat)cellHeight;

@end
