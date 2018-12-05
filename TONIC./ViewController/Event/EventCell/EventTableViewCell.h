//
//  EventTableViewCell.h
//  ParTee
//
//  Created by Chetu India on 03/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell
// Outlet for Three dot favourite button
@property (nonatomic, strong) IBOutlet UIButton *BtnFav;
// Outlet for Date label that we need to show on cell with start and end date of event.
@property (nonatomic, strong) IBOutlet UILabel *lblDate;
//This Method set Event the data from QBCOCustomObject in cell.
-(void)setEventDataFromQbObj:(QBCOCustomObject *)obj;
//This Method set the AdEvent data from QBCOCustomObject in cell.
-(void)setAdEventDataFromQbObj:(QBCOCustomObject *)obj;
@end
