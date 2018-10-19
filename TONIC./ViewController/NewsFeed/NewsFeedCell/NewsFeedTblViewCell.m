//
//  NewsFeedTblViewCell.m
//  ParTee
//
//  Created by Admin on 10/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "NewsFeedTblViewCell.h"

@implementation NewsFeedTblViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 @Description
 * This Method set the data from Dictioanry of item avaialble on rss feed in cell.
 * @author Chetu India
 * @param dict is type of NSDictionary that contain all the details about a feed to be showed in news feed screen. These objects we are getting from blog.
 * @return void nothing will return by this method.
 */
#pragma mark- setDataFromEventObject
-(void)setFeedDataFromDict:(NSDictionary *)dict {
    
    
    
    [self.articleImgView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:kFeedDescParam]] placeholderImage:[UIImage imageNamed:kUnSpecifiedPng]];
    NSString *pubDate = [dict objectForKey:kFeedDateParam];
    NSString *titleStr = [dict objectForKey:kFeedTitleParam];
    self.headingTxtView.text = titleStr;
    self.adminNameLbl.text = [dict objectForKey:kInstaFeedCreater];
    NSString *strDate = [CommonMethods convertDateToAnotherFormat:pubDate originalFormat:kformatOriginal finalFormat:kfinalFormat];
    self.dateLbl.text = strDate;
    
}
/**
 @Description
 * This Method set the data from QBCOCustomObject in item avaialble on rss feed in cell.
 * @author Chetu India
 * @param obj is type of QBCOCustomObject that contain all the details about a AdEvent to be showed in event screen. These objects we are getting from AdEvent table on quickblox.
 * @return void nothing will return by this method.
 */
#pragma mark- setDataFromEventObject
-(void)setAdFeedDataFromQbObj:(QBCOCustomObject *)obj {
    
    [self.articleImgView sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:kAdLink]] placeholderImage:[UIImage imageNamed:kUnSpecifiedPng]];
    self.headingTxtView.text = [obj.fields objectForKey:kAdTitle];
    self.adminNameLbl.text = [obj.fields objectForKey:kAdCreater];
  
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // set the date format related to what the string already you have

    [dateFormat setDateFormat:kFormatOriginalCreatedDate];
    NSString *finalDate = [dateFormat stringFromDate:obj.createdAt];
 NSString *dateStr = [CommonMethods convertDateToAnotherFormat:finalDate originalFormat:kFormatOriginalCreatedDate finalFormat:kfinalFormat];
    
    self.dateLbl.text = dateStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
