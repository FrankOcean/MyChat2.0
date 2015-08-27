//
//  KSChatInputView.h
//  MyChat
//
//  Created by Vincent_Guo on 15/8/27.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KSChatInputToolBarDelegate <NSObject>
/**
 * 开始录音
 */
-(void)beginRecord;

/**
 * 取消录音
 */
-(void)cancelRecord;

/**
 * 结束录音
 */
-(void)endRecord;

@end

@interface KSChatInputToolBar : UIView

@property(nonatomic,weak)IBOutlet id<KSChatInputToolBarDelegate> delegate;

@end
