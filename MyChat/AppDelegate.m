//
//  AppDelegate.m
//  MyChat
//
//  Created by Vincent_Guo on 15/8/24.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "AppDelegate.h"
#import "EaseMob.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    /*
     *registerSDKWithAppKey: 区别app的标识，开发者注册及管理后台
     apnsCertName: iOS中推送证书名称。制作与上传推送证书
     */
    //环信的初始化
    [[EaseMob sharedInstance] registerSDKWithAppKey:@"vgios#hxchat" apnsCertName:@""];
    [[EaseMob sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    return YES;
}

// App进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationDidEnterBackground:application];
}

// App将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillEnterForeground:application];
}

// 申请处理时间
- (void)applicationWillTerminate:(UIApplication *)application
{
    [[EaseMob sharedInstance] applicationWillTerminate:application];
}

@end
