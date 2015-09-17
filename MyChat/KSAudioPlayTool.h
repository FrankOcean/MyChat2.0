//
//  KSAudioPlayTool.h
//  MyChat
//
//  Created by Vincent_Guo on 15/9/17.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSAudioPlayTool : NSObject

+(void)playWithMessage:(EMMessage *)message atLabel:(UILabel *)label receiver:(BOOL)receiver;
+(void)stop;

@end
