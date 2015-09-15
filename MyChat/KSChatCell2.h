//
//  KSChatCell2.h
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KSChatCell2 : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

//cell的高度
-(CGFloat)cellHeight;

@end
