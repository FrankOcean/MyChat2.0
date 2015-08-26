//
//  KSContactsViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSContactsViewController.h"
#import "KSChatViewController.h"

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
    if (self.friendsList.count == 0) {
        [self getFriendsListFromServer];
    }
    
 
}



-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMBuddy *buddy = self.friendsList[indexPath.row];
        [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:nil];
    }
}

-(void)didRemovedByBuddy:(NSString *)username{
    
}


-(void)getFriendsListFromServer{
    __weak typeof(self) weakSelf = self;
    
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
        
        [weakSelf.refreshControl endRefreshing];
    } onQueue:nil];

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

- (IBAction)beginRefreshAction:(UIRefreshControl *)rc {
    //[self getFriendsListFromServer];
    // 重新赋值数据源
    self.friendsList = [[EaseMob sharedInstance].chatManager buddyList];
    // 刷新
    [self.tableView reloadData];
    
    // 结束刷新
    [self.refreshControl endRefreshing];
    
}


- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd{
    // 重新赋值数据源
    self.friendsList = buddyList;
    // 刷新
    [self.tableView reloadData];
    
}


#pragma mark  - 表格代理
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // 1.目标控制器
    id desVc = segue.destinationViewController;
    if ([desVc isKindOfClass:[KSChatViewController class]]) {
        NSInteger row = [self.tableView indexPathForSelectedRow].row;
        KSChatViewController *chatVc = desVc;
        chatVc.buddy = self.friendsList[row];
        chatVc.isGroup = NO;
    }
}

@end
