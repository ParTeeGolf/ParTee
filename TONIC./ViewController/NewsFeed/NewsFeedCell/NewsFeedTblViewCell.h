//
//  NewsFeedTblViewCell.h
//  ParTee
//
//  Created by Admin on 10/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedTblViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *articleImgView;
@property (strong, nonatomic) IBOutlet UITextView *headingTxtView;
@property (strong, nonatomic) IBOutlet UILabel *adminNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *dateLbl;
-(void)setFeedDataFromDict:(NSDictionary *)dict;
-(void)setAdFeedDataFromQbObj:(QBCOCustomObject *)obj;
@end
