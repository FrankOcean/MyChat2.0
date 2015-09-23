//
//  KSChatViewController2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController.h"
#import "KSChatCell.h"
#import "KSTimeCell.h"
#import "EMCDDeviceManager.h"
#import "KSAudioPlayTool.h"
#import "KSTimeTool.h"

@interface KSChatViewController ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,UITextViewDelegate>
#pragma mark 控件与约束
/**聊天表格*/
@property (weak, nonatomic) IBOutlet UITableView *tableView;
/**计算cell高度的对象*/
@property (strong, nonatomic)KSChatCell *chatCellTool;
/**"输入控件"高度约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeihgt;
/**"输入控件"底部约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
/**录音按钮*/
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
/**聊天文本输入框*/
@property (weak, nonatomic) IBOutlet UITextView *textView;
/**背景*/
@property (weak, nonatomic) IBOutlet UIImageView *textBg;
/** 最后一条的时间*/
@property (copy, nonatomic) NSString  *lastTime;
/**聊天记录-数据源*/
@property (strong, nonatomic) NSMutableArray *records;
/**当前会话*/
@property (strong, nonatomic)EMConversation *conversation;
@end

@implementation KSChatViewController

#pragma mark -懒加载
-(NSMutableArray *)records{
    if (!_records) {
        _records = [NSMutableArray array];
    }
    return _records;
}

-(KSChatCell *)chatCellTool{
    if (!_chatCellTool) {
        _chatCellTool = [self.tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];
    }
    return _chatCellTool;
}

#pragma mark -控制器生命周期
- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.添加代理
    [[EaseMob sharedInstance].chatManager addDelegate:self delegateQueue:nil];
    // 2.设置标题
    self.title = self.buddy.username;

    // 3.添加键盘显示与隐藏监听
    [self setupKeyboardObserver];
    
    // 4.加载聊天数据
    [self loadChatData];
    
    // 5.隐藏录音按钮
    self.recordBtn.hidden = YES;
    
    // 6.去除分隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 7.设置背景
    self.tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
}

-(void)viewDidAppear:(BOOL)animated{
    [self scrollToBottom];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

#pragma mark -私有方法
- (void)setupKeyboardObserver {
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
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

-(void)loadChatData{
    // 1.获取当前会话对象
    self.conversation = [[EaseMob sharedInstance].chatManager conversationForChatter:self.buddy.username conversationType:eConversationTypeChat];
    if (self.conversation) {//载20条
        // 当前时间
        long long timestamp = [[NSDate date] timeIntervalSince1970] * 1000;
        
        NSArray *records = [self.conversation loadNumbersOfMessages:100 before:timestamp];
        
        // 遍历信息为已读
        [records enumerateObjectsUsingBlock:^(EMMessage *msg, NSUInteger idx, BOOL *stop) {
            [self addDataSourceWithMessage:msg];
        }];
    }
}

#pragma mark 发送文字
-(void)sendWithText:(NSString *)text{
    // 1.生成消息体
    EMChatText *txtChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *txtBody = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    
    // 2.发送消息
    [self sendMessageWithBody:txtBody];
}

-(void)sendWithRecordFile:(NSString *)filePath duration:(NSInteger)duration{
    EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:filePath displayName:@"[主意]"];
    EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
    voiceBody.duration = duration;
    [self sendMessageWithBody:voiceBody];
}


#pragma mark 向服务器发送聊天消息
-(void)sendMessageWithBody:(id<IEMMessageBody>)body{
    if (!body) return;
    // 1.构造消息对象
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    
    // 2.添加到数据源
    [self addDataSourceWithMessage:message];
    
    // 3.刷新并滚动表格
    [self refreshDataAndScroll];
    
    // 4.发送网络请求
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        KSLog(@"准备发送聊天消息 %@",error);
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        KSLog(@"聊天消息发送完成 %@",error);
    } onQueue:nil];
    
}

#pragma mark 添加消息模型到数据源
-(void)addDataSourceWithMessage:(EMMessage *)msg{
    NSString *timeStr = [KSTimeTool timeStr:msg.timestamp];
    
    // 1.添加 “时间字符串” 到数据源
    if (![self.lastTime isEqualToString:timeStr]) {
        [self.records addObject:timeStr];
        self.lastTime = timeStr;
    }
    
    // 2.添加 "消息模型"
    [self.records addObject:msg];
    
    // 3.设置消息为"已读"
    if (!msg.isRead && [msg.from isEqualToString:self.buddy.username]) {
        [self.conversation markMessageWithId:msg.messageId asRead:YES];
    }
    
}



-(void)refreshDataAndScroll{
    [self.tableView reloadData];
    
    [self scrollToBottom];
}

-(void)scrollToBottom{
    if (self.records.count == 0) {
        return;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.records.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark -数据源方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.records.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1.获取记录
    id record = self.records[indexPath.row];
    // 2.时间类型的Cell
    if ([record isKindOfClass:[NSString class]]) {
       return [KSTimeCell timeCell:tableView time:record];
    }
    // 3.聊天类型的cell
    return [KSChatCell chatCell:tableView message:record];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    // 1.时间返回20的固定高度
    if ([self.records[indexPath.row] isKindOfClass:[NSString class]]) {
        return 20;
    }
    
    // 2.聊天cell返回计算后的高度
    self.chatCellTool.message = self.records[indexPath.row];
    return [self.chatCellTool cellHeight];
}

#pragma mark -UITextView代理方法
#pragma mark 文字内容改变
-(void)textViewDidChange:(UITextView *)textView{
#warning 1.复位光标
    [textView setContentOffset:CGPointZero animated:YES];
//   [textView scrollRangeToVisible:textView.selectedRange];
    
#warning 2.计算 “输入工具条” 高度
    CGFloat minHeight = 33;
    CGFloat maxHeight = 68;
    CGFloat toHeight = 0;
    if(textView.contentSize.height < minHeight){
        toHeight = minHeight;
    }else if (textView.contentSize.height > 68){
        toHeight = maxHeight;
    }else{
        toHeight = textView.contentSize.height;
    }
   
#warning 3.发消息
    if ([textView.text hasSuffix:@"\n"]) {
        // 把尾部的换行符去除
        NSString *text = textView.text;
        text = [text substringToIndex:text.length - 1];
        
        // 发送文本
        [self sendWithText:text];
        
        // 清空文本
        textView.text = nil;
        
        toHeight = minHeight;
      }
    
#warning 4.更改高度
    self.inputViewHeihgt.constant = toHeight + 8 + 5;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
#warning 5.动画结束后，再滚动到可见区域
        [textView scrollRangeToVisible:textView.selectedRange];
    }];
}

#pragma mark scrollView将开始拖动
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //准备滑动表格时，要停止播放语音
    [KSAudioPlayTool stop];
}


#pragma mark -EMChatMamager代理
#pragma mark 接收到好友发的消息
-(void)didReceiveMessage:(EMMessage *)message{
    if ([message.from isEqualToString:self.buddy.username]) {
        //1.添加消息到数据源
        [self addDataSourceWithMessage:message];
        
        //2.刷新表格并滚动到底部
        [self refreshDataAndScroll];
    }
}

#pragma mark -Action
#pragma mark 显示录音按钮
- (IBAction)voiceAction:(UIButton *)btn {
    [self.view endEditing:YES];
    self.recordBtn.hidden =  !self.recordBtn.hidden;
    self.textView.hidden = !self.textView.hidden;
    self.textBg.hidden = !self.textBg.hidden;
    if (self.textView.hidden == YES) {
        [btn setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateNormal];
        self.inputViewHeihgt.constant = 46;
    }else{
        [btn setImage:[UIImage imageNamed:@"chatBar_record"] forState:UIControlStateNormal];
        [self textViewDidChange:self.textView];
        [self.textView becomeFirstResponder];
       
    }
}

#pragma mark 开始录音
- (IBAction)beginRecordAction:(id)sender {
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        KSLog(@"开始录音 %@",error);
    }];
}

#pragma mark 结束录音
- (IBAction)endRecordAction:(id)sender {
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
        if (!error) {
            KSLog(@"结束录音 本地路径 %@",recordPath);
            [self sendWithRecordFile:recordPath duration:aDuration];
        }else{
            KSLog(@"%@",error);
        }
    }];
}

#pragma mark 取消录音
- (IBAction)cancelRecordAction:(id)sender {
    KSLog(@"取消录音");
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}
@end
