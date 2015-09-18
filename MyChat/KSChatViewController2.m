//
//  KSChatViewController2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController2.h"
#import "KSChatCell2.h"
#import "KSTimeCell.h"
#import "EMCDDeviceManager.h"
#import "KSAudioPlayTool.h"
#import "XHMessageTextView.h"
#import "KSTimeTool.h"

@interface KSChatViewController2 ()<UITableViewDataSource,UITableViewDelegate,EMChatManagerDelegate,UITextViewDelegate>
#pragma mark 控件与约束
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)KSChatCell2 *chatCell2Tool;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputViewHeihgt;

/**底部约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (weak, nonatomic) IBOutlet UIButton *recordBtn;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIImageView *textBg;
@property (copy, nonatomic) NSString  *lastTime;/** 最后一条的时间*/

#pragma mark 数据源
@property (strong, nonatomic) NSMutableArray *records;//聊天记录

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
    
    //4.隐藏录音按钮
    self.recordBtn.hidden = YES;
    
    //5.去除分隔线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //6.设置背景
    self.tableView.backgroundColor = [UIColor colorWithRed:246/255.0 green:246/255.0 blue:246/255.0 alpha:1];
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

/**
 * 添加数据源
 */
-(void)addDataSourceWithMessage:(EMMessage *)msg{
    NSString *timeStr = [KSTimeTool timeStr:msg.timestamp];
    
    // 1.添加 “时间字符串” 到数据源
    if (![self.lastTime isEqualToString:timeStr] || self.lastTime == nil ) {
        [self.records addObject:timeStr];
        NSLog(@"timeStr... %@",timeStr);
        self.lastTime = timeStr;
    }
  
    
    // 2.添加消息模型
    [self.records addObject:msg];
    
    // 3.设置消息为已读
    if (!msg.isRead && [msg.from isEqualToString:self.buddy.username]) {
        [self.conversation markMessageWithId:msg.messageId asRead:YES];
    }
    
}
#pragma mark -数据源方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.records.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    // 时间
    if ([self.records[indexPath.row] isKindOfClass:[NSString class]]) {
        KSTimeCell *timeCell = [tableView dequeueReusableCellWithIdentifier:@"TimeCell"];
        timeCell.timeLabel.text = self.records[indexPath.row];
       return timeCell;
    }
    
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
    // 时间返回20的高度
    if ([self.records[indexPath.row] isKindOfClass:[NSString class]]) {
        return 20;
    }
    self.chatCell2Tool.message = self.records[indexPath.row];
    return [self.chatCell2Tool cellHeight];
}



#pragma mark - UITextView代理方法
-(void)textViewDidChange:(UITextView *)textView{
    
#pragma 复位光标
    [textView setContentOffset:CGPointZero animated:YES];
//   [textView scrollRangeToVisible:textView.selectedRange];
    
#pragma mark 计算高度
    CGFloat minHeight = 33;
    CGFloat maxHeight = 68;
    CGFloat toHeight = 0;
//    NSLog(@"111111---contentSize: %@",NSStringFromCGSize(textView.contentSize));
    if(textView.contentSize.height < minHeight){
        toHeight = minHeight;
    }else if (textView.contentSize.height > 68){
        toHeight = maxHeight;
    }else{
        toHeight = textView.contentSize.height;
    }
   
#pragma mark 发消息
    if ([textView.text hasSuffix:@"\n"]) {
        // 把尾部的换行符去除
        NSString *text = textView.text;
        text = [text substringToIndex:text.length - 1];
        [self sendWithText:text];
        textView.text = nil;
        
        toHeight = minHeight;
      }
    

    
#pragma mark 更改高度
//    return;
    self.inputViewHeihgt.constant = toHeight + 8 + 5;

    NSLog(@"2222----%f",self.inputViewHeihgt.constant);
        [textView scrollRangeToVisible:textView.selectedRange];
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
#warning 动画结束后，再滚动到可见区域
        [textView scrollRangeToVisible:textView.selectedRange];
    }];
}



#pragma mark 发送文字
-(void)sendWithText:(NSString *)text{

    EMChatText *txtChat = [[EMChatText alloc] initWithText:text];
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:txtChat];
    
    // 生成message
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[body]];
    message.messageType = eMessageTypeChat; // 设置为单聊消息
    [self addDataSourceWithMessage:message];

    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
        NSLog(@"准备 %@",error);
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        NSLog(@"完成 %@",error);
    } onQueue:nil];
    
    [self refreshDataAndScroll];
}


#pragma mark 接收到好友发的消息
-(void)didReceiveMessage:(EMMessage *)message{
    
//    [self.conversation markMessageWithId:message.messageId asRead:YES];
//    [self.records addObject:message];

    [self addDataSourceWithMessage:message];
    
    [self refreshDataAndScroll];
}



-(void)refreshDataAndScroll{
    [self.tableView reloadData];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.records.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)scrollToBottom{
    if (self.records.count == 0) {
        return;
    }
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.records.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (IBAction)voiceBtnClick:(UIButton *)btn {
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

#pragma mark -录音
- (IBAction)beginRecordAction:(id)sender {
    int x = arc4random() % 100000;
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
    
    [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error) {
        
    }];
}
- (IBAction)endRecordAction:(id)sender {
    
    [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {

        if (error) {
            NSLog(@"%@",error);
        }else{
        NSLog(@"录音的本地路径 %@",recordPath);
        }
        // 发送
        EMChatVoice *voice = [[EMChatVoice alloc] initWithFile:recordPath displayName:@"audio"];
        EMVoiceMessageBody *voiceBody = [[EMVoiceMessageBody alloc] initWithChatObject:voice];
        voiceBody.duration = aDuration;
        EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username bodies:@[voiceBody]];
        message.messageType = eMessageTypeChat;

        [self.records addObject:message];
        
        [self refreshDataAndScroll];
        
        [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:nil prepare:^(EMMessage *message, EMError *error) {
            
        } onQueue:nil completion:^(EMMessage *message, EMError *error) {
            
        } onQueue:nil];
        
    }];
}

- (IBAction)cancelRecordAction:(id)sender {
    [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //准备滑动表格时，要停止播放语音
    [KSAudioPlayTool stop];
}

#pragma mark -生命周期
-(void)viewDidAppear:(BOOL)animated{
    [self scrollToBottom];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[EaseMob sharedInstance].chatManager removeDelegate:self];
}

@end
