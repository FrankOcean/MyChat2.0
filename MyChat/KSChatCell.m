//
//  KSChatCell.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatCell.h"
#import "EMCDDeviceManager.h"
#import "KSVoiceAnimationTool.h"

@interface KSChatCell()
/** 头像*/
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

/** 聊天内容文字*/
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;
@end

@implementation KSChatCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
          [self setupCellStype];
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupCellStype];
    }
    
    return self;
}

// 设置cell的样式
-(void)setupCellStype{
    self.backgroundColor = [UIColor clearColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

-(void)awakeFromNib{
    self.chatTextLabel.backgroundColor = [UIColor clearColor];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
//    NSLog(@"%@ %@ %@",touch.view,NSStringFromCGRect(self.chatTextLabel.frame),NSStringFromCGPoint(point));
    if (CGRectContainsPoint(self.chatTextLabel.frame, point)) {
        NSLog(@"点击label");
        [self labelClick];
    }
}

-(void)labelClick{
    if (self.message.messageBodies.count > 0) {
        // 判断消息体的类型
        id body = self.message.messageBodies[0];
        if ([body isKindOfClass:[EMVoiceMessageBody class]]) {//播放语音
            EMVoiceMessageBody *voiceBody = body;
            // 本地存在语音文件，就播放本地的，不存在，就播放网络
            NSFileManager *fileMng = [NSFileManager defaultManager];
            NSString *filePath = nil;
            if([fileMng fileExistsAtPath:voiceBody.localPath]){
                KSLog(@"%@ 存在",voiceBody.localPath);
                filePath = voiceBody.localPath;
            }else{
                KSLog(@"%@ 不存在",voiceBody.localPath);
                filePath = voiceBody.remotePath;
            }
            [KSVoiceAnimationTool startAnimationWithLabel:self.chatTextLabel receiver:[self.reuseIdentifier isEqualToString:receiverCellID]];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:filePath completion:^(NSError *error) {
                [KSVoiceAnimationTool endAnimation];
                NSLog(@"播放完成%@",error);
            }];
        }
    }
}

-(void)setMessage:(EMMessage *)message{
    _message = message;
    
    // 显示内容
    if(message.messageBodies.count > 0){
        // 获取消息体
        id body = message.messageBodies[0];
        
        if ([body isKindOfClass:[EMTextMessageBody class]]) {//普通文本
            EMTextMessageBody *textBody = body;
            // 显示文字
            self.chatTextLabel.text = textBody.text;
        }else if([body isKindOfClass:[EMVoiceMessageBody class]]){//语音
            // 5.显示语音图片和时间
            self.chatTextLabel.attributedText = [self voiceAttStr:body];
        }else{
            self.chatTextLabel.text = @"图片/或者视频";
        }
        
        [self.contentView bringSubviewToFront:self.chatTextLabel];
        
    }
    
}

/**
 * 返回语音的富文本
 */
-(NSAttributedString *)voiceAttStr:(EMVoiceMessageBody *)voiceBody{
    
    UIImage *voiceImg = nil;
    BOOL isReceiver = [self.reuseIdentifier isEqualToString:receiverCellID];
    if (isReceiver) {
        voiceImg = [UIImage imageNamed:@"chat_receiver_audio_playing_full"];
    }else{
        voiceImg = [UIImage imageNamed:@"chat_sender_audio_playing_full"];
    }

    
    // 1.图片附件
    NSTextAttachment *imgAttach = [[NSTextAttachment alloc] init];
    imgAttach.image = voiceImg;
    imgAttach.bounds = (CGRect){0, -10, 30,30};
    // 2.图片富文本
    NSAttributedString *imgStr = [NSAttributedString attributedStringWithAttachment:imgAttach];
    
    // 3.可变富文本
    NSMutableAttributedString *attStrM = [[NSMutableAttributedString alloc] init];
    
    // 时间
    NSString *timeStr = nil;
    if (isReceiver) {
        timeStr = [NSString stringWithFormat:@"  %zd'",[voiceBody duration]];
    }else{
        timeStr = [NSString stringWithFormat:@"%zd'  ",[voiceBody duration]];
    }
    
    NSAttributedString *timeAttStr = [[NSAttributedString alloc] initWithString:timeStr];
    
    // 4.拼接图片
    if (isReceiver) {
        [attStrM appendAttributedString:imgStr];
        [attStrM appendAttributedString:timeAttStr];
    }else{
        [attStrM appendAttributedString:timeAttStr];
        [attStrM appendAttributedString:imgStr];
    }
    
    // 设置字体大小
    [attStrM addAttribute:NSFontAttributeName value:self.chatTextLabel.font range:NSMakeRange(0, attStrM.length)];
    
    return [attStrM copy];
    
}

-(CGFloat)cellHeight{
    // 重新布局子控件
    [self layoutIfNeeded];
//    KSLog(@"%@",NSStringFromCGRect(self.chatTextLabel.bounds));
    
    CGFloat label = self.chatTextLabel.bounds.size.height;
    CGFloat cellHeight = 15 + label + 10 + 10;
    return cellHeight;
}

@end
