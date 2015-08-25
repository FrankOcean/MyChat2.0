//
//  KSContactsViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSContactsViewController.h"

@interface KSContactsViewController ()<EMChatManagerDelegate>
/**
 * 好友数组
 */
@property(nonatomic,strong)NSArray *friendsList;
@end

@implementation KSContactsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.设置ChatManager代理
    [[KSChatManagerTool sharedTool] addDelegate:self];
    
    // 2.获取好友
    self.friendsList = [[EaseMob sharedInstance].chatManager buddyList];
    KSLog(@"%@",self.friendsList);
    
    // 3.如获本地数据库没联系人，从服务器获取
    __weak typeof(self) weakSelf = self;
    if (self.friendsList.count == 0) {
        [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
            if (error) {
                KSLog(@"%@",error);
                [EMAlertView showAlertWithTitle:@"xx" message:error.description];
            }else{
                KSLog(@"%@",buddyList);
                weakSelf.friendsList = buddyList;
                // 刷新表格
                [weakSelf.tableView reloadData];
            }
            
        } onQueue:nil];
    }
    
}


#pragma mark - 表格数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMBuddy *friend = self.friendsList[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    
    cell.textLabel.text = friend.username;
    
    return cell;
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
