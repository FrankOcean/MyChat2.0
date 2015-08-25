//
//  KSAddFriendOrGroupViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/25.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSAddFriendOrGroupViewController.h"

@interface KSAddFriendOrGroupViewController ()

@property (weak, nonatomic) IBOutlet UITextField *friendName;

@end

@implementation KSAddFriendOrGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)AddAction:(id)sender {
    
    if (!self.friendName.text.length) {
        
        KSLog(@"请输入好友帐号");
        [EMAlertView showAlertWithTitle:@"提示" message:self.friendName.placeholder completionBlock:nil cancelButtonTitle:@"好的" otherButtonTitles:nil];
        return;
        
    }
    id<IChatManager> cm = [EaseMob sharedInstance].chatManager;

    NSString *msg = [NSString stringWithFormat:@"我是%@",[cm loginInfo][@"username"]];
    if([cm addBuddy:self.friendName.text message:msg error:nil]){
        
        [EMAlertView showAlertWithTitle:@"提示" message:@"好友添加申请已经发送" completionBlock:^(NSUInteger buttonIndex, EMAlertView *alertView) {
            
        } cancelButtonTitle:@"好的" otherButtonTitles:nil];
    }
}



@end
