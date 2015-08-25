//
//  KSChatManagerTool.h
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "EMChatManagerDelegate.h"

@interface KSChatManagerTool : NSObject

+(instancetype)sharedTool;

-(void)addDelegate:(id<EMChatManagerDelegate>)delegate;

-(void)removeDelegate:(id<EMChatManagerDelegate>)delegate;

@end
