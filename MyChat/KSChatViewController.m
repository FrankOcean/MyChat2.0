//
//  KSChatViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/26.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController.h"

@interface KSChatViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputToolBarBottomConstraint;

@end

@implementation KSChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 1.监听键盘通知
    [self setupKeyboardNotification];
}

#pragma mark - 键盘
#pragma mark 添加键盘通知
-(void)setupKeyboardNotification{
    NSNotificationCenter * ntfcCenter = [NSNotificationCenter defaultCenter];
    [ntfcCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [ntfcCenter addObserver:self selector:@selector(keyboardHideShow) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark 键盘将显示
-(void)keyboardWillShow:(NSNotification *)noti{
    CGRect kbEndFrm = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.inputToolBarBottomConstraint.constant = kbEndFrm.size.height;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark 键盘将隐藏
-(void)keyboardHideShow{
    self.inputToolBarBottomConstraint.constant = 0;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark 移除通知
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
