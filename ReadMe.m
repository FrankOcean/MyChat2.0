//
//  ReadMe.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/23.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import <Foundation/Foundation.h>

》好友
•添加好友
1.发送好友请求
2.监听好友请求回执(同意、拒绝)

•显示好友列表
1.buddyList要自动登录完成后才有值
  >可在监听自动登录完成再赋值【didAutoLoginWithInfo】
  >或者监听 didUpdateBuddyList方法再赋值
2.用户删除软件第一次登录，buddyList没有值，要设置一个"自动获取好友列表"属性
  [[EaseMob sharedInstance].chatManager setIsAutoFetchBuddyList:YES];
  //原理，添加好友操作，会在数据库里添加一条记录,所在buddyList有值
  //登录后，数据库没有好友记录，需要从服务器获取

•监听到好友同意，刷新表格
1>"如果 didUpdateBuddyList方法不会被调用可以从服务器获取最新的好友数据"

•同意好友请求

•删除好友

•被好友删除


