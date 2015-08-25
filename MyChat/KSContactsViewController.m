//
//  KSContactsViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSContactsViewController.h"

@interface KSContactsViewController ()<EMChatManagerDelegate>

@end

@implementation KSContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[KSChatManagerTool sharedTool] addDelegate:self];
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
#pragma mark 发出的好友请求被用户username接受了
- (void)didAcceptedByBuddy:(NSString *)username{
    NSString *msg = [username stringByAppendingString:@" 用户同意添加你为好友"];
    [EMAlertView showAlertWithTitle:@"好友接收提醒" message:msg];
}

#pragma mark 发出的好友请求被用户username拒绝了
-(void)didRejectedByBuddy:(NSString *)username{
    NSString *msg = [username stringByAppendingString:@" 用户拒绝你的好友请求"];
    [EMAlertView showAlertWithTitle:@"好友接收提醒" message:msg];
}

@end
