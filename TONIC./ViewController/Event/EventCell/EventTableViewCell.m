    //
//  EventTableViewCell.m
//  ParTee
//
//  Created by Admin on 03/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setDataFromQbObj:(QBCOCustomObject *)obj {
  
    [self.imgEvent setShowActivityIndicatorView:YES];
    [self.imgEvent setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.imgEvent sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:kEventCellImgUrl]] placeholderImage:[UIImage imageNamed:kEventCellDefaultImg]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
