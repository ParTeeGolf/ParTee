//
//  NewsFeedTblViewCell.h
//  ParTee
//
//  Created by Chetu India on 10/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsFeedTblViewCell : UITableViewCell
// This Method set the data from Dictioanry of item avaialble on rss feed in cell.
-(void)setFeedDataFromDict:(NSDictionary *)dict;
// This Method set the data from QBCOCustomObject in item avaialble on rss feed in cell.
-(void)setAdFeedDataFromQbObj:(QBCOCustomObject *)obj;
@end
