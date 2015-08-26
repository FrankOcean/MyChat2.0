//
//  KSChatViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController.h"

@interface KSChatViewController ()<UITextViewDelegate,IEMChatProgressDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarBottomConstraint;

@end

@implementation KSChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.监听键盘通知
    [self setupKeyboardNotification];
    
    // 2.显示聊天标题
    self.title = self.buddy.username;
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
-(void)textViewDidEndEditing:(UITextView *)textView{
    KSLog(@"xx");
}

-(void)textViewDidChange:(UITextView *)textView{
    if ([textView.text hasSuffix:@"\n"]) {//发送
        [self sendMessage:textView];
    }
}

-(void)sendMessage:(UITextView *)textView{
    // 1.消息文本
    EMChatText *text = [[EMChatText alloc] initWithText:textView.text];
    
    // 2.消息体
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithChatObject:text];
    
    // 3.发送的消息对象
    EMMessage *message = [[EMMessage alloc] initWithReceiver:self.buddy.username
                                                        bodies:@[body]];
    // 不加密
    message.requireEncryption = NO;
    // 消息类型 《私聊》
    message.messageType = eMessageTypeChat;
    
    [[EaseMob sharedInstance].chatManager asyncSendMessage:message progress:self prepare:^(EMMessage *message, EMError *error) {
        KSLog(@"prepare %@",message.messageBodies);
    } onQueue:nil completion:^(EMMessage *message, EMError *error) {
        KSLog(@"完成 %@",message.messageBodies);
    } onQueue:nil];
    textView.text = nil;
}

- (void)setProgress:(float)progress
         forMessage:(EMMessage *)message
     forMessageBody:(id<IEMMessageBody>)messageBody{
    KSLog(@"%lf",progress);
}
@end
