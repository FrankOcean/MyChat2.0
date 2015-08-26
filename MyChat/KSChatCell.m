//
//  KSChatCell.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatCell.h"

@interface KSChatCell()
/** 头像*/
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

/** 聊天内容文字*/
@property (weak, nonatomic) IBOutlet UILabel *chatTextLabel;
@end

@implementation KSChatCell

-(void)setMessage:(EMMessage *)message{
    _message = message;
    
    // 显示内容
    if(message.messageBodies.count > 0){
        
        EMTextMessageBody *body = message.messageBodies[0];
        
        if ([body isKindOfClass:[EMTextMessageBody class]]) {//普通文本
            self.chatTextLabel.text = body.text;
        }else{
            self.chatTextLabel.text = @"语音或者图片";
        }
        
        [self.contentView bringSubviewToFront:self.chatTextLabel];
        
    }
    
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
