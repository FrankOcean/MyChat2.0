//
//  KSChatManagerTool.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatManagerTool.h"


static KSChatManagerTool *instance;


@interface KSChatManagerTool()<EMChatManagerDelegate>
/**代理数组*/
@property(nonatomic,strong)NSMutableArray *delegates;

@end

@implementation KSChatManagerTool


-(NSMutableArray *)delegates{
    if (!_delegates) {
        _delegates = [NSMutableArray array];
    }
    
    return _delegates;
}

+(instancetype)sharedTool{
    if (!instance) {
        instance = [[self alloc] init];
    }
    
    return instance;
}



+(instancetype)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
        // 设置环信的 “聊天管理器代理”
        [[EaseMob sharedInstance].chatManager addDelegate:instance delegateQueue:dispatch_get_main_queue()];
    });
    
    return instance;
}


#pragma mark 添加代理
-(void)addDelegate:(id<EMChatManagerDelegate>)delegate{
    // 代理数组中，不存在当前的代理对象，才添加到数组中
    if (![self.delegates containsObject:delegate]) {
        [self.delegates addObject:delegate];
    }
}

#pragma mark 移除代理
-(void)removeDelegate:(id<EMChatManagerDelegate>)delegate{
    [self.delegates removeObject:delegate];
}

#pragma mark - Buddy Delegate
#pragma mark 发出的好友请求被用户username接受了
- (void)didAcceptedByBuddy:(NSString *)username{
    // 调用多态代理
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didAcceptedByBuddy:)]) {
            [delegate didAcceptedByBuddy:username];
        }
    }
}

#pragma mark 发出的好友请求被用户username拒绝了
-(void)didRejectedByBuddy:(NSString *)username{
    // 调用多态代理
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didRejectedByBuddy:)]) {
            [delegate didRejectedByBuddy:username];
        }
    }
}

#pragma mark 接收到好友请求
-(void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message{
    
    NSString *msg = [NSString stringWithFormat:@"%@ 请求加为好友\n附加信息:%@",username,message];
    [EMAlertView showAlertWithTitle:@"好友请求" message:msg completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
        if (buttonIndex == 0) {
            [[EaseMob sharedInstance].chatManager rejectBuddyRequest:username reason:@"你是谁" error:nil];
        }else{
            [[EaseMob sharedInstance].chatManager acceptBuddyRequest:username error:nil];
        }
        
    } cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意"];
    
}

#pragma mark 被移除
- (void)didRemovedByBuddy:(NSString *)username{

    NSString *msg = [NSString stringWithFormat:@"你已经被%@ 移除好友列表",username];
    [EMAlertView showAlertWithTitle:@"提示" message:msg];
}

#pragma mark 通讯录改变
- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didUpdateBuddyList:changedBuddies:isAdd:)]) {
            [delegate didUpdateBuddyList:buddyList changedBuddies:changedBuddies isAdd:isAdd];
        }
    }
}

#pragma mark - Login Delegate
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(willAutoLoginWithInfo:error:)]) {
            [delegate willAutoLoginWithInfo:loginInfo error:error];
        }
    }}

-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didAutoLoginWithInfo:error:)]) {
            [delegate didAutoLoginWithInfo:loginInfo error:error];
        }
    }
}

-(void)willAutoReconnect{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(willAutoReconnect)]) {
            [delegate willAutoReconnect];
        }
    }
}

-(void)didAutoReconnectFinishedWithError:(NSError *)error{
    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didAutoReconnectFinishedWithError:)]) {
            [delegate didAutoReconnectFinishedWithError:error];
        }
    }
}


#pragma mark - Util Delegate
-(void)didConnectionStateChanged:(EMConnectionState)connectionState{

    for (id delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(didConnectionStateChanged:)]) {
            [delegate didConnectionStateChanged:connectionState];
        }
    }
}



@end
