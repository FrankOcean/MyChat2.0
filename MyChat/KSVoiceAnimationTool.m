//
//  KSVoiceAnimationTool.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/3.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSVoiceAnimationTool.h"

static UIImageView *animationView;

@implementation KSVoiceAnimationTool


+(void)startAnimationWithLabel:(UILabel *)label receiver:(BOOL)receiver{
    // 移除以前的
    [animationView removeFromSuperview];
    
    // 重新创建
    animationView = [[UIImageView alloc] init];

    if (receiver) {
        animationView.frame = CGRectMake(0, 0, 30, 30);
    }else{
        animationView.frame = CGRectMake(label.bounds.size.width - 30, 0, 30, 30);
    }
    
    [label addSubview:animationView];
    
    if (receiver) {
        animationView.animationImages = @[[UIImage imageNamed:@"chat_receiver_audio_playing000"],[UIImage imageNamed:@"chat_receiver_audio_playing001"],[UIImage imageNamed:@"chat_receiver_audio_playing002"],[UIImage imageNamed:@"chat_receiver_audio_playing003"]];
    }else{
        animationView.animationImages = @[[UIImage imageNamed:@"chat_sender_audio_playing_000"],[UIImage imageNamed:@"chat_sender_audio_playing_001"],[UIImage imageNamed:@"chat_sender_audio_playing_002"],[UIImage imageNamed:@"chat_sender_audio_playing_003"]];
    }
    
    animationView.animationDuration = 1;
    animationView.animationRepeatCount = MAXFLOAT;
    
    [animationView startAnimating];
    
}

+(void)endAnimation{

    [animationView stopAnimating];
    [animationView removeFromSuperview];
}
@end
