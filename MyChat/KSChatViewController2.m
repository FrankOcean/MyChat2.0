//
//  KSChatViewController2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController2.h"
#import "KSChatCell2.h"

@interface KSChatViewController2 ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) NSMutableArray *records;//聊天记录
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)KSChatCell2 *chatCell2Tool;
@property (strong, nonatomic)EMConversation *conversation;//当前会话
@end

@implementation KSChatViewController2


-(NSMutableArray *)records{
    if (!_records) {
        _records = [NSMutableArray array];
    }
    
    return _records;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 添加代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];

    // 1.设置标题
    self.title = self.buddy.username;
    
    self.chatCell2Tool = [self.tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];

    // 预估99高度
    // 计算高度的工具对象
//    self.tableView.estimatedRowHeight = 99;

    //2.添加键盘显示与隐藏监听
    [self setupKeyboardObserver];
    
    //3.加载聊天数据
    [self loadChatData];
}

#pragma mark -私有方法
- (void)setupKeyboardObserver {
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)kbWillShow:(NSNotification *)notification{
    CGFloat kbHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.bottomConstraint.constant = kbHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)kbWillHide:(NSNotification *)notification{
    self.bottomConstraint.constant = 0;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

-(void)loadChatData{
    // 1.获取当前会话对象
    EMConversation *conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    if (conversation) {//载20条
        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
        NSArray *records = [conversation loadNumbersOfMessages:20 before:timestamp];
//        NSLog(@"%@",[records[0] class]);
        [self.records addObjectsFromArray:records];
    }
}
#pragma mark -数据源方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.records.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KSChatCell2 *cell = nil;
    EMMessage *msg = self.records[indexPath.row];
    if ([msg.to isEqualToString:self.buddy.username]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SenderCell"];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];
    }

    
    cell.message = self.records[indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.chatCell2Tool.message = self.records[indexPath.row];
    return [self.chatCell2Tool cellHeight];
}


-(void)textViewDidChange:(UITextView *)textView{
    if ([textView.text hasSuffix:@"\n"]) {
     
        NSLog(@"%@",textView.text);
        [self sendWithText:textView.text];
        textView.text = nil;
    }
}



#pragma mark 发送文字
-(void)sendWithText:(NSString *)text{

    EMChatText *txtChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    [self.records addObject:message];

    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备 %@",error);
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"完成 %@",error);
    } onQueue:nil];
    
    [self refreshDataAndScroll];
}



-(void)didReceiveMessage:(EMMessage *)message{
    NSLog(@"%@",[NSThread currentThread]);
        [self.records addObject:message];
    
    [self refreshDataAndScroll];
}

-(void)refreshDataAndScroll{
    [self.tableView reloadData];
    
//    CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height);
//    [self.tableView setContentOffset:offset animated:YES];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.records.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}
@end
