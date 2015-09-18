//
//  KSTimeCell.m
//  MyChat
//
//  Created by Vincent_Guo on 15/9/18.
//  Copyright (c) 2015年 Kwok_Sir. All rights reserved.
//

#import "KSTimeCell.h"

@implementation KSTimeCell

- (void)awakeFromNib {
    // Initialization code
    self.selectedBackgroundView = [[UIView alloc] init];
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



@end
