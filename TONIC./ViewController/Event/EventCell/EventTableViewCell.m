//
//  EventTableViewCell.m
//  ParTee
//
//  Created by Admin on 03/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell
#pragma mark- awakeFromNib
/**
 @Description
 * Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
- (void)awakeFromNib {
    [super awakeFromNib];
  
}

/**
 @Description
 * This Method set the data from QBCOCustomObject in cell.
 * @author Chetu India
 * @param obj is type of QBCOCustomObject that contain all the details about a event to be showed in event screen. These objects we are getting from Event table on quickblox.
 * @return void nothing will return by this method.
 */
#pragma mark- setDataFromEventObject
-(void)setEventDataFromQbObj:(QBCOCustomObject *)obj {
  
    [self.imgEvent setShowActivityIndicatorView:YES];
    [self.imgEvent setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.imgEvent sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:kEventCellImgUrl]] placeholderImage:[UIImage imageNamed:kEventCellDefaultImg]];
}

/**
 @Description
 * This Method set the data from QBCOCustomObject in cell.
 * @author Chetu India
 * @param obj is type of QBCOCustomObject that contain all the details about a AdEvent to be showed in event screen. These objects we are getting from AdEvent table on quickblox.
 * @return void nothing will return by this method.
 */
#pragma mark- setDataFromEventObject
-(void)setAdEventDataFromQbObj:(QBCOCustomObject *)obj {
    
    [self.imgEvent setShowActivityIndicatorView:YES];
    [self.imgEvent setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.imgEvent sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:kAdEventCellImgUrl]] placeholderImage:[UIImage imageNamed:kEventCellDefaultImg]];
}
/**
 @Description
 * Sets the selected state of the cell, optionally animating the transition between states.
 * @author Chetu India
 * @param selected YES to set the cell as selected, NO to set it as unselected. The default is NO.
 * @param animated YES to animate the transition between selected states, NO to make the transition immediate.
 * @return void nothing will return by this method.
 */
#pragma mark- Set Selected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
