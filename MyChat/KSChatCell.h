//
//  KSChatCell.h
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMMessage.h"

@interface KSChatCell : UITableViewCell

@property(nonatomic,strong)EMMessage *message;

@end