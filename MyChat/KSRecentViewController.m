//
//  KSRecentViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSRecentViewController.h"
#import "EaseMob.h"
#import "KSChatViewController.h"
#import "KSChatViewController2.h"

@interface KSRecentViewController ()<EMChatManagerDelegate>

/**数据源*/
@property(nonatomic,strong)NSMutableArray *dataSources;
@end

@implementation KSRecentViewController

-(NSMutableArray *)dataSources{
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    
    return _dataSources;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"xxx";
    //1.设置 "聊天管理器" 代理
    [[KSChatManagerTool sharedTool] addDelegate:self];
    
    
    if(![[EaseMob sharedInstance].chatManager isLoggedIn]){
        self.title = @"②登录中...";
    }else{
    
    }
    
   
   //2.设置未读取消息数
    [self setupUnreadCount];
    
    
}

-(void)setupUnreadCount{
    [self.dataSources removeAllObjects];
    
   // 1.获取所有历史会话
   NSArray *conversations = [[EaseMob sharedInstance].chatManager conversations];
    
    // 2.如果内存中，没有会话，从数据库中加载
    if (conversations.count == 0) {
        conversations = [[EaseMob sharedInstance].chatManager loadAllConversationsFromDatabaseWithAppend2Chat:YES];
    }
    KSLog(@"%@",conversations);
    // 3.计算总未读取消息数
    NSUInteger totalUnreadCount = 0;
    for (EMConversation *cvst in conversations) {
        NSUInteger unreadCount = [cvst unreadMessagesCount];
        totalUnreadCount += unreadCount;
        KSLog(@"%@ %zd",cvst.chatter,unreadCount);
        [self.dataSources addObject:cvst];
    }
    
    // 4.刷新表格
    [self.tableView reloadData];
    
    // 5.设置badge
    NSString *badge = nil;
    if (totalUnreadCount > 0) {
        badge = [NSString stringWithFormat:@"%zd",totalUnreadCount];
    }
    self.navigationController.tabBarItem.badgeValue = badge;
    
}
-(void)dealloc{
    [[KSChatManagerTool sharedTool] removeDelegate:self];
}
#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMConversation *cvst = self.dataSources[indexPath.row];
    
    static NSString *ID = @"ConversationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    // 1.显示历史会话用户名称
    cell.textLabel.text = [NSString stringWithFormat:@"%@: %zd",cvst.chatter,cvst.unreadMessagesCount];
    
    // 2.最后一条消息
    NSArray *msgBodies = cvst.latestMessage.messageBodies;
    if (msgBodies.count > 0) {
        id<IEMMessageBody> msgBody = msgBodies[0];
        if ([msgBody isKindOfClass:[EMTextMessageBody class]]) {
            EMTextMessageBody *textMsgBody = msgBody;
            cell.detailTextLabel.text = textMsgBody.text;
        }else{
            cell.detailTextLabel.text = @"语音或者图片";
        }
    }
    
    
    
    
    return cell;
    
}
#pragma mark - 自动登录代理
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
//    [self setupUnreadCount];
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

-(void)didUnreadMessagesCountChanged{
    [self setupUnreadCount];
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    // 目标控制器
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[KSChatViewController class]]) {
        NSUInteger row = [self.tableView indexPathForSelectedRow].row;
        // 1.获取对应的会话管理者
        EMConversation *cvst = self.dataSources[row];
        
        // 2.获取聊天控制器
        KSChatViewController *chatVc = segue.destinationViewController;
        
        // 封装好友对象
        EMBuddy *buddy = [EMBuddy buddyWithUsername:cvst.chatter];
        
        // 4.设置参数
        chatVc.buddy = buddy;
        chatVc.isGroup = NO;//私聊，不是群聊

    }else if([destVc isKindOfClass:[KSChatViewController2 class]]){
        KSChatViewController2 *chat2Vc = destVc;
        
        // 获取一个好友模型，传递到下一个控制器
        if (self.dataSources.count > 0) {
            // 会话
            EMConversation *cvst = [self.dataSources lastObject];
            EMBuddy *buddy = [EMBuddy buddyWithUsername:cvst.chatter];
            chat2Vc.buddy = buddy;
        }
    }
    
}
- (IBAction)testChat2Action:(id)sender {
    
//    [self performSegueWithIdentifier:@"toChat2Page" sender:nil];
}

@end
