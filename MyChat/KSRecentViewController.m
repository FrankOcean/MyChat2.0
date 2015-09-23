//
//  KSRecentViewController2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/16.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSRecentViewController.h"
#import "KSChatViewController.h"


@interface KSRecentViewController ()<EMChatManagerDelegate>
@property(nonatomic,strong)NSArray *conversations;
@end

@implementation KSRecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.获取历史会话记录
    [self loadConversations];
    
    // 2.添加代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
}

- (void)loadConversations {
    NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    

    if (conversations.count == 0) {
        conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    
    NSLog(@"loadConversations %@",conversations);
    self.conversations = conversations;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.conversations.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ConversationCell"];
    
    EMConversation *converstaion = self.conversations[indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@ 未读取消息数%zd",converstaion.chatter,converstaion.unreadMessagesCount];
    

    // 最后一条信息
    EMMessage *lastMsg = [converstaion latestMessage];
    
    id body = lastMsg.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {//文本消息
        EMTextMessageBody *textBody = body;
        cell.detailTextLabel.text = textBody.text;
    }else if([body isKindOfClass:[EMVoiceMessageBody class]]){//音频
        EMVoiceMessageBody *voiceBody = body;
        cell.detailTextLabel.text = voiceBody.displayName;
    }else{
        cell.detailTextLabel.text = @"未处理的消息类型";
    }
    
    return cell;
}

-(void)viewDidAppear:(BOOL)animated{
    [self refreshUI];
}

#pragma mark 有新的会话列表
- (void)didUpdateConversationList:(NSArray *)conversationList{
    self.conversations = conversationList;
    
    [self refreshUI];
}

#pragma mark 未读消息数改变
-(void)didUnreadMessagesCountChanged{
    [self refreshUI];
}

-(void)refreshUI{
   [self.tableView reloadData];
    
    // 1.设置tabbarButton的总未读数
    NSInteger totalCount = 0;
    for (EMConversation *conversation in self.conversations) {
        totalCount += [conversation unreadMessagesCount];
    }
    
    if (totalCount > 0) {
        self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd",totalCount];
    }else{
        self.navigationController.tabBarItem.badgeValue = nil;
    }
    
    //AppIcon的badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = totalCount;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    KSChatViewController *chatVc = [sb instantiateViewControllerWithIdentifier:@"KSChatViewController2"];
    EMConversation *conversation = self.conversations[indexPath.row];
    chatVc.buddy = [EMBuddy buddyWithUsername:conversation.chatter];
    [self.navigationController pushViewController:chatVc animated:YES];
}

@end
