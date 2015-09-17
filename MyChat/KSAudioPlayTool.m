//
//  KSAudioPlayTool.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/17.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSAudioPlayTool.h"
#import "EMCDDeviceManager.h"

static UIImageView *animationingImgView;

@implementation KSAudioPlayTool


+(void)playWithMessage:(EMMessage *)message atLabel:(UILabel *)label receiver:(BOOL)receiver{
    
    // 移除以前的动画
    [animationingImgView removeFromSuperview];
    
    NSLog(@"播放音频....");
    EMVoiceMessageBody *body = message.messageBodies[0];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *filePath = body.localPath;
    // 本地音频文件不存在，使用远程服务的文件路径
    if(![fileManager fileExistsAtPath:body.localPath]){
        filePath = body.remotePath;
    }

    //1.播放音频
    [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:filePath completion:^(NSError *error) {
        [animationingImgView removeFromSuperview];
        if (!error) {
            NSLog(@"播放完成");
        }else{
            NSLog(@"播放失败 %@",error);
        }
    }];
    
    //2.添加播放动画
    UIImageView *animationImgView = [[UIImageView alloc] init];
//    animationImgView.backgroundColor = [UIColor yellowColor];
    if (receiver) {
        animationImgView.frame = CGRectMake(0, 0, 25, 25);
    }else{
        animationImgView.frame = CGRectMake(label.bounds.size.width - 25, 0, 25, 25);
    }

    NSMutableArray *images = [NSMutableArray array];
    if (receiver) {
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing000"]];
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing001"]];
       
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing002"]];
       
        [images addObject:[UIImage imageNamed:@"chat_receiver_audio_playing003"]];

    }else{
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_000"]];
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_001"]];
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_002"]];
        [images addObject:[UIImage imageNamed:@"chat_sender_audio_playing_003"]];
    }
    animationImgView.animationImages = images;
    animationImgView.animationDuration = 1;
    [label addSubview:animationImgView];
    [animationImgView startAnimating];
    
    animationingImgView = animationImgView;
}

+(void)stop{
    if ([EMCDDeviceManager sharedInstance].isPlaying) {
        [[EMCDDeviceManager sharedInstance] stopPlaying];
        [animationingImgView removeFromSuperview];
    }
    
}
@end
