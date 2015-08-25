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

    [MBProgressHUD showMessag:@"登录中" toView:nil];
    
    [[EaseMob sharedInstance].chatManager asyncLoginWithUsername:_usernameField.text password:_passwordField.text completion:^(NSDictionary *loginInfo, EMError *error) {
        [MBProgressHUD hideHUDForView:nil animated:NO];
        
        NSLog(@"-------%@",[NSThread currentThread]);
                NSLog(@"%@",loginInfo);
        if (error) {
            [MBProgressHUD showMessag:error.description toView:nil];
            NSLog(@"登录失败%@",error);
          
        }else{
        
            // 进度主界面
            self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
           
            // 调自动登录
            [[EaseMob sharedInstance].chatManager setIsAutoLoginEnabled:YES];
        }
        
    } onQueue:nil];

}

- (IBAction)registerAction{
    
    [MBProgressHUD showSuccess:@"注册中..." toView:nil];
    [[EaseMob sharedInstance].chatManager asyncRegisterNewAccount:_usernameField.text password:_passwordField.text withCompletion:^(NSString *username, NSString *password, EMError *error) {
        
        [MBProgressHUD hideHUDForView:nil animated:NO];
        
        if (error) {
            [MBProgressHUD showError:error.description toView:nil];
        }else{
            [MBProgressHUD showSuccess:@"注册成功，请登录" toView:nil];
        }
        NSLog(@"error:%@ username:%@ pwd:%@",error,username,password);
    } onQueue:nil];
}

@end
