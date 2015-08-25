//
//  KSRecentViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSRecentViewController.h"
#import "EaseMob.h"

@interface KSRecentViewController ()<EMChatManagerDelegate>

@end

@implementation KSRecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"xxx";
    //1.设置 "聊天管理器" 代理
//    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [[KSChatManagerTool sharedTool] addDelegate:self];
    if ([[EaseMob sharedInstance].chatManager isAutoLoginEnabled]) {
        if([[EaseMob sharedInstance].chatManager isLoggedIn]){
        
        }
        self.title = @"②登录中...";
    }
}


-(void)dealloc{
    [[KSChatManagerTool sharedTool] removeDelegate:self];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark 自动登录代理
#pragma mark 将自动登录
-(void)willAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    self.title = @"②自动登录中....";
    KSLog(@"%@",self.title);
}

#pragma mark 完成自动登录
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    if (error) {

        self.title = [NSString stringWithFormat:@"③%@",error.description];
    }else{
        self.title = @"③登录成功....";
    }
    
    KSLog(@"%@",self.title);
}

-(void)willAutoReconnect{
   self.title = @"④开始自动连接...";
   KSLog(@"%@",self.title);
}

-(void)didAutoReconnectFinishedWithError:(NSError *)error{
    if (error) {
        self.title = @"④自动连接失败";
    }else{
        self.title = @"④自动连接成功";
    }
    KSLog(@"%@",self.title);
}


-(void)didConnectionStateChanged:(EMConnectionState)connectionState{
    
    if (connectionState == eEMConnectionConnected) {
        self.title = @"①连接恢复...";
        KSLog(@"①连接恢复...");
    }else{
        self.title = @"①断开连接...";
        KSLog(@"①断开连接...");
    }
}

@end
