//
//  KSChatViewController.h
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EMBuddy.h"

@interface KSChatViewController : UIViewController


/*
 * 好友模型
 */
@property(nonatomic,strong)EMBuddy *buddy;

/*
 * 是群聊还是私聊
 */
@property(nonatomic,assign)BOOL isGroup;
@end
