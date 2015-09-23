//
//  KSContactsViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSContactsViewController.h"
#import "KSChatViewController.h"

@interface KSContactsViewController ()<EMChatManagerDelegate,UIAlertViewDelegate>
/**
 * 好友数组
 */
@property(nonatomic,strong)NSArray *buddyList;
@property(nonatomic,copy)NSString *username;//请求添加好友的用户名
@end

@implementation KSContactsViewController



#pragma mark - 生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.设置ChatManager代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    
    // 2.获取好友
    self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
    KSLog(@"%@",self.buddyList);
}

-(void)dealloc{
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}


#pragma mark - 私有方法
-(void)getFriendsListFromServer{
    __weak typeof(self) weakSelf = self;
    [[EaseMob sharedInstance].chatManager asyncFetchBuddyListWithCompletion:^(NSArray *buddyList, EMError *error) {
        if (!error) {
            KSLog(@"%@",buddyList);
            weakSelf.buddyList = buddyList;
            // 刷新表格
            [weakSelf.tableView reloadData];
        }else{
            KSLog(@"%@",error);
            [EMAlertView showAlertWithTitle:@"xx" message:error.description];
        }
        
        [weakSelf.refreshControl endRefreshing];
    } onQueue:nil];

}


- (IBAction)beginRefreshAction:(UIRefreshControl *)rc {
    // 刷新是批从服务器获取最新的联系人列表
    [self getFriendsListFromServer];
}



#pragma mark - 表格数据源方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.buddyList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMBuddy *friend = self.buddyList[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell"];
    cell.textLabel.text = friend.username;
    
    return cell;
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // 1.目标控制器
    id desVc = segue.destinationViewController;
    if ([desVc isKindOfClass:[KSChatViewController class]]) {
        NSInteger row = [self.tableView indexPathForSelectedRow].row;
        KSChatViewController *chatVc = desVc;
        chatVc.buddy = self.buddyList[row];
    }
}

#pragma mark  - 表格代理

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EMBuddy *buddy = self.buddyList[indexPath.row];
        [[EaseMob sharedInstance].chatManager removeBuddy:buddy.username removeFromRemote:YES error:nil];
    }
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KSChatViewController *chatVc = [sb instantiateViewControllerWithIdentifier:@"KSChatViewController"];
    chatVc.buddy = self.buddyList[indexPath.row];
    [self.navigationController pushViewController:chatVc animated:YES];
}

#pragma mark - ChatManager代理方法
#pragma mark 被好友移除
-(void)didRemovedByBuddy:(NSString *)username{
    NSLog(@"%@移除了你",username);
    [self getFriendsListFromServer];
}

#pragma mark 发出的好友请求被接受了
- (void)didAcceptedByBuddy:(NSString *)username{
    NSString *msg = [username stringByAppendingString:@" 用户同意添加你为好友"];
    [EMAlertView showAlertWithTitle:@"好友接收提醒" message:msg];
    
    // 刷新表格，显示新好友
    [self getFriendsListFromServer];
    
}

#pragma mark 发出的好友请求被拒绝了
-(void)didRejectedByBuddy:(NSString *)username{
    NSString *msg = [username stringByAppendingString:@" 用户拒绝你的好友请求"];
    [EMAlertView showAlertWithTitle:@"好友接收提醒" message:msg];
}

#pragma mark 好友列表更新
- (void)didUpdateBuddyList:(NSArray *)buddyList
            changedBuddies:(NSArray *)changedBuddies
                     isAdd:(BOOL)isAdd{
    //    return;
    // 重新赋值数据源
    self.buddyList = buddyList;
    // 刷新
    [self.tableView reloadData];
    
}

#pragma mark 自动登录完成
-(void)didAutoLoginWithInfo:(NSDictionary *)loginInfo error:(EMError *)error{
    //    return;
    if (!error) {
        self.buddyList = [[EaseMob sharedInstance].chatManager buddyList];
        KSLog(@"%@",self.buddyList);
        [self.tableView reloadData];
    }
}

#pragma mark 好友添加请求
-(void)didReceiveBuddyRequest:(NSString *)username message:(NSString *)message{
    self.username = username;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友添加请求" message:message delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同音", nil];
    [alert show];
}


#pragma mark - AlertView代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[EaseMob sharedInstance].chatManager acceptBuddyRequest:self.username error:nil];
    }else{
        [[EaseMob sharedInstance].chatManager rejectBuddyRequest:self.username reason:@"没有原因" error:nil];
    }
}

@end
