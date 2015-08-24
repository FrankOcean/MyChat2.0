//
//  ViewController.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/24.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSLoginViewController.h"
#import "EaseMob.h"
#import "MBProgressHUD+Add.h"

@interface KSLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@end

@implementation KSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)loginAction{

    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:@"vgios1" password:@"123456" completion:^(NSDictionary *loginInfo, EMError *error) {
        NSLog(@"%@",[NSThread currentThread]);
                NSLog(@"%@",loginInfo);
        if (error) {
            NSLog(@"登录失败%@",error);
        }
        
    } onQueue:nil];

}

- (IBAction)registerAction{
    
    [MBProgressHUD showSuccess:@"注册中..." toView:nil];
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_usernameField.text password:_passwordField.text withCompletion:^(NSString *username, NSString *password, EMError *error) {
        
        [MBProgressHUD hideHUDForView:nil animated:YES];
        
        if (error) {
            [MBProgressHUD showError:error.description toView:nil];
        }else{
            [MBProgressHUD showSuccess:@"注册成功，请登录" toView:nil];
        }
        NSLog(@"error:%@ username:%@ pwd:%@",error,username,password);
    } onQueue:nil];
}

@end
