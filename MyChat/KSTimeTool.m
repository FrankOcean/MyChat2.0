//
//  KSTimeTool.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/18.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSTimeTool.h"

@implementation KSTimeTool

+(NSString *)timeStr:(long long)timestamp{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 当前月的 "号数"
    NSDateComponents *compnents = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:[NSDate date]];
    NSInteger currentDay = compnents.day;
    NSInteger currentMoth = compnents.month;
    
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp/1000.0];
    // 发信息的时间 "号数"
    compnents =[calendar components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:date];
    NSInteger msgDay = compnents.day;
    NSInteger msgMoth = compnents.month;
    
    NSString *timeFormat = nil;
    if (msgDay == currentDay && msgMoth == currentMoth) {//今天
        timeFormat = @"HH:mm";
    }else if(msgMoth == currentMoth && (msgDay + 1) == currentDay){//昨天
        timeFormat = @"昨天 HH:mm";
    }else{//昨天以前
        timeFormat = @"yyyy-MM-dd HH:mm";
    }
    
//    NSLog(@"%@",date);
    // 今天 -- HH:mm:ss
    // 昨天 -- 昨天:HH:mm:ss
    // 昨天以前 -- yyyy-MM-dd HH:mm:ss
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = timeFormat;
    return [dateFormatter stringFromDate:date];
}
@end
