//
//  KSChatInputView.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/27.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatInputToolBar.h"

@interface KSChatInputToolBar()
/**录音按钮*/
@property(nonatomic,weak)IBOutlet UIButton *recordBtn;
//chatBar_textBg
@property(nonatomic,weak)IBOutlet UITextView *textView;
@end

@implementation KSChatInputToolBar

-(void)awakeFromNib{
//    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"messageToolbarBg"]];
}


-(IBAction)voiceAction:(UIButton *)voiceBtn{
    [self endEditing:YES];
    self.recordBtn.hidden = !self.recordBtn.hidden;
    NSString *normalImg = @"chatBar_record";
    if (!self.recordBtn.hidden) {
     normalImg = @"chatBar_keyboard";
    }
    
    [voiceBtn setImage:[UIImage imageNamed:normalImg] forState:UIControlStateNormal];
}
@end
