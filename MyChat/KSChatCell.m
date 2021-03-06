//
//  KSChatCell2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatCell.h"
#import "KSAudioPlayTool.h"



@implementation KSChatCell

+(instancetype)chatCell:(UITableView *)tableView message:(EMMessage *)message{
    // 1.当前登录用户名
    NSString *loginUsername = [[EaseMob sharedInstance].chatManager loginInfo][@"username"];
    KSChatCell *cell = nil;
    // 2.发送方(自己-右边)
    if ([message.from isEqualToString:loginUsername]) {
        cell = [tableView dequeueReusableCellWithIdentifier:SenderCell];
    // 3.接收方(好友-左边)
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:ReceiverCell];
    }
    
    // 4.设置消息模型，内部set方法，实现数据显示
    cell.message = message;
    
    return cell;
}

- (void)awakeFromNib {
    // Initialization code
    [self.contentView bringSubviewToFront:self.msgLabel];
    
    //1.添加点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.bgImageView addGestureRecognizer:tap];
    self.bgImageView.userInteractionEnabled = YES;
    
    //2.设置背景和选中背景为透明
    self.backgroundColor = [UIColor clearColor];
    self.selectedBackgroundView = [[UIView alloc] init];
}

- (void)tap:(UITapGestureRecognizer *)tap{
    BOOL isReceiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
    id body = self.message.messageBodies[0];
    if ([body isKindOfClass:[EMVoiceMessageBody class]]) {
        // 播放语音(自己写的工具类)
        [KSAudioPlayTool playWithMessage:self.message atLabel:self.msgLabel receiver:isReceiver];
    }
}

-(CGFloat)cellHeight{
    //重新布局子控件
    [self layoutIfNeeded];
    return 15 + self.msgLabel.bounds.size.height + 10 + 10;
#warning 不用下面的方法
//    [self sizeToFit];
//    return self.bounds.size.height + 10;
}

-(void)setMessage:(EMMessage *)message{
    _message = message;
    // 1.获取消息体
    id body = message.messageBodies[0];
    
    // 2.文本消息
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        self.msgLabel.text = [textBody text];
    // 3.语音消息
    }else if([body isKindOfClass:[EMVoiceMessageBody class]]){
        self.msgLabel.attributedText = [self getVoiceAttText];
    }else{
    // 4.未知消息
        self.msgLabel.text = @"未知消息类型";
    }
}

/**
 * 获取声音的富文本
 */
-(NSAttributedString *)getVoiceAttText{
    // 1.获取消息体
    EMVoiceMessageBody *body = self.message.messageBodies[0];
    
    // 2.获取音频的时间
    double duration = body.duration;
    
    // 3.接收方(好友)
    BOOL isReceiver = [self.reuseIdentifier isEqualToString:ReceiverCell];
    
    // 4.富文本
    /** 接收方 ＝ 图片 + 时长
     *  发送方 ＝ 时长 + 图片
     */
    NSMutableAttributedString *attStrM = [[NSMutableAttributedString alloc] init];
    if (isReceiver) {
        // 拼接图片
        [attStrM appendAttributedString:[self audioAtt:@"chat_receiver_audio_playing_full"]];
        // 拼接时长
        [attStrM appendAttributedString:[self timeAtt:duration]];
        
    }else{
        // 拼接时长
        [attStrM appendAttributedString:[self timeAtt:duration]];
        
        // 拼接图片
        [attStrM appendAttributedString:[self audioAtt:@"chat_sender_audio_playing_full"]];
        
    }
    return [attStrM copy];
}


-(NSAttributedString *)timeAtt:(double)duration{
    NSString *timeStr = [NSString stringWithFormat:@"%.0lf '",duration];
    return [[NSAttributedString alloc] initWithString:timeStr];
}

/** 音频图片*/
-(NSAttributedString *)audioAtt:(NSString *)imgName{
    NSTextAttachment *imgAttach = [[NSTextAttachment alloc] init];
    imgAttach.image = [UIImage imageNamed:imgName];
    NSAttributedString *audioAtt = [NSAttributedString attributedStringWithAttachment:imgAttach];
    imgAttach.bounds = CGRectMake(0, -7, 25, 25);
    return audioAtt;
}


@end
