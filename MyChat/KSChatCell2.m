//
//  KSChatCell2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatCell2.h"

@implementation KSChatCell2

- (void)awakeFromNib {
    // Initialization code
    [self.contentView bringSubviewToFront:self.msgLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
    
    // 消息体
    id body = message.messageBodies[0];
    if ([body isKindOfClass:[EMTextMessageBody class]]) {
        EMTextMessageBody *textBody = body;
        self.msgLabel.text = [textBody text];
    }else{
        self.msgLabel.text = @"未知消息类型";
    }
}

@end
