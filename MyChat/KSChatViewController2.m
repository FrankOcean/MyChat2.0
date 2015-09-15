//
//  KSChatViewController2.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/15.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSChatViewController2.h"
#import "KSChatCell2.h"

@interface KSChatViewController2 ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (strong, nonatomic) NSMutableArray *records;//聊天记录
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic)  KSChatCell2 *chatCell2Tool;
@end

@implementation KSChatViewController2

- (void)viewDidLoad {
    [super viewDidLoad];

    self.records = [NSMutableArray array];
    for (int i = 0 ; i < 20;i++) {
        [self.records addObject:@"NSMutableArray 是一个可变数组，不可以使用copy策略，成为一个不可变的数组NSMutableArray 是一个可变数组，不可以使用copy策略，成为一个不可变的数组NSMutableArray 是一个可变数组，不可以使用copy策略，成为一个不可变的数组NSMutableArray 是一个可变数组，不可以使用copy策略，成为一个不可变的数组"];
    }
    self.chatCell2Tool = [self.tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];

    // 预估99高度
    // 计算高度的工具对象
    self.tableView.estimatedRowHeight = 99;
//    self.tableView.rowHeight = 120;

    //1.添加键盘显示与隐藏监听
    [self setupKeyboardObserver];
}

- (void)setupKeyboardObserver {
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)kbWillShow:(NSNotification *)notification{
    CGFloat kbHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    self.bottomConstraint.constant = kbHeight;
    [UIView animateWithDuration:0.25 animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(void)kbWillHide:(NSNotification *)notification{
    self.bottomConstraint.constant = 0;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


#pragma mark -数据源方法

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.records.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KSChatCell2 *cell = nil;
    if (indexPath.row % 2 == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SenderCell"];
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"ReceiverCell"];
    }

    
    cell.msgLabel.text = self.records[indexPath.row];
    
//    [tableView updateConstraints];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.chatCell2Tool.msgLabel.text = self.records[indexPath.row];
    return [self.chatCell2Tool cellHeight];
}

@end
