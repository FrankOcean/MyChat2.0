//
//  KSChatViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController.h"
#import "KSChatCell.h"

#define KSCountPerLoad 20 //每次从数据库加载聊天记录数

static NSString *receiverCellID = @"ReceiverCell";
static NSString *senderCellID = @"SenderCell";

@interface KSChatViewController ()<UITextViewDelegate,IEMChatProgressDelegate,UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarBottomConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** cell的工具，用于计算cell的调度*/
@property(nonatomic,strong)KSChatCell *chatCellTool;
/** 聊天数据源*/
@property(nonatomic,strong)NSMutableArray *messages;
/** 当前会话管理者*/
@property(nonatomic,strong)EMConversation *conversation;
@end

@implementation KSChatViewController

-(NSMutableArray *)messages{
    if (!_messages) {
        _messages = [NSMutableArray array];
    }
    
    return _messages;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.监听键盘通知
    [self setupKeyboardNotification];
    
    // 2.显示聊天标题
    self.title = self.buddy.username;
    
    // 初始化cell的工具类
    self.chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:receiverCellID];
    self.tableView.estimatedRowHeight = 90;
    // 3.加载聊天消息
    [self loadChatMessages];
}

-(void)loadChatMessages{
    if (!self.isGroup) {//私聊
        // 1.获取会管理者对象
        self.conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    }
    
    // 2.获取在数据库的最新 20 条数据
    if (self.conversation) {
        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000 + 1;
        
        NSArray *msgFromDB = [self.conversation loadNumbersOfMessages:KSCountPerLoad before:timestamp];
        KSLog(@"%@",[msgFromDB[0] class]);
        // 3.添加到数据源中
        [self.messages addObjectsFromArray:msgFromDB];
    }else{
        KSLog(@"获取会话管理者对象失败");
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // 表格滑动到最底部
    [self scrollToBottom];

}

-(void)scrollToBottom{
    if (self.messages.count > 0) {
        NSIndexPath *bottomIndex = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:bottomIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
   
}

#pragma mark - 键盘
#pragma mark 添加键盘通知
-(void)setupKeyboardNotification{
    NSNotificationCenter * ntfcCenter = [NSNotificationCenter defaultCenter];
    [ntfcCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [ntfcCenter addObserver:self selector:@selector(keyboardHideShow) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 键盘将显示
-(void)keyboardWillShow:(NSNotification *)noti{
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.inputToolBarBottomConstraint.constant = kbEndFrm.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark 键盘将隐藏
-(void)keyboardHideShow{
    self.inputToolBarBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark 移除通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITextView代理
-(void)textViewDidChange:(UITextView *)textView{
    if ([textView.text hasSuffix:@"\n"]) {//发送
        [self sendMessage:textView];
    }
}

#pragma mark - 发聊天消息
#pragma mark 发纯文本
-(void)sendMessage:(UITextView *)textView{
    // 1.消息文本
    EMChatText *text = [[EMChatText alloc] initWithText:[textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    
    // 2.消息体
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    
    // 3.发送的消息对象
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username
                                                        bodies:@[body]];
    // 不加密
    message.requireEncryption = NO;
    // 消息类型 《私聊》
    message.messageType = eMessageTypeChat;
    
    
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:self];
    
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:self prepare:^(EMMessage *message, EMError *error) {
        KSLog(@"prepare %@",message.messageBodies);
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        KSLog(@"完成 %@",message.messageBodies);
    } onQueue:nil];
    textView.text = nil;
}


#pragma mark - 表格数据源
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.messages.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    EMMessage *message = self.messages[indexPath.row];
    KSChatCell *cell = nil;
    //接收方
    if([message.from isEqualToString:self.buddy.username]){
        cell = [tableView dequeueReusableCellWithIdentifier:receiverCellID];
    }else{//发送方(也就是自己)
        cell = [tableView dequeueReusableCellWithIdentifier:senderCellID];
    }
    
    
    // 显示内容
    cell.message = message;
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.chatCellTool.message = self.messages[indexPath.row];
    
    return [self.chatCellTool cellHeight];
}


@end
