//
//  KSVoiceAnimationTool.h
//  MyChat
//
//  Created by Vincent_Guo on 15/9/3.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KSVoiceAnimationTool : NSObject

+(void)startAnimationWithLabel:(UILabel *)label receiver:(BOOL)receiver;

+(void)endAnimation;

@end
