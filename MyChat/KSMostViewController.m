//
//  KSMostViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/19.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSMostViewController.h"
#import "MBProgressHUD+Add.h"

@interface KSMostViewController()
@property (weak, nonatomic) IBOutlet UIButton *logoutBtn;
@end

@implementation KSMostViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    
    // 1.显示登录名
    id<IChatManager> chatManger = [EaseMob sharedInstance].chatManager;
    NSString *loginUsername = [chatManger loginInfo][@"username"];
    NSString *title = [NSString stringWithFormat:@"退出登录(%@)",loginUsername];
    [self.logoutBtn setTitle:title forState:UIControlStateNormal];
}

- (IBAction)logoutAction:(UIButton *)logoutBtn {
    // 退出后，不再接收远程推送离线消息
    UIView *rootView = self.view.window.rootViewController.view;
    
    [MBProgressHUD showMessag:@"正在退出中..." toView:rootView];
    [[EaseMob sharedInstance].chatManager asyncLogoffWithUnbindDeviceToken:YES completion:^(NSDictionary *info, EMError *error) {
        [MBProgressHUD hideHUDForView:rootView animated:YES];
        if (!error) {
            KSLog(@"退出成功 %@",info);
            [MBProgressHUD showSuccess:@"退出成功" toView:rootView];
            // 切换到登录控制器
            self.view.window.rootViewController = [UIStoryboard storyboardWithName:@"Login" bundle:nil].instantiateInitialViewController;
        }else{//退出失败
            [MBProgressHUD showError:error.description toView:nil];
        }
    } onQueue:nil];
    
}

@end
