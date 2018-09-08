//
//  EventTableViewCell.h
//  ParTee
//
//  Created by Admin on 03/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIButton *BtnFav;
@property (strong, nonatomic) IBOutlet UILabel *lblDate;
@property (strong, nonatomic) IBOutlet UIImageView *imgEvent;
-(void)setDataFromQbObj:(QBCOCustomObject *)obj;
@end
