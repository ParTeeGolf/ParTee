//
//  NewsFeedTblViewCell.m
//  ParTee
//
//  Created by Chetu India on 10/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "NewsFeedTblViewCell.h"

@implementation NewsFeedTblViewCell
{
    // imageView to hold the image of feed.
    IBOutlet UIImageView *articleImgView;
    // textview to hold heading of the feed.
    IBOutlet UITextView *headingTxtView;
    // label to hold the name of the publisher of th feed.
    IBOutlet UILabel *adminNameLbl;
    // label to hold the date of published feed.
    IBOutlet UILabel *dateLbl;
}

#pragma mark- awakeFromNib
/**
 @Description
 * Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
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
    
    [articleImgView sd_setImageWithURL:[NSURL URLWithString:[dict objectForKey:kFeedDescParam]] placeholderImage:[UIImage imageNamed:kUnSpecifiedPng]];
    NSString *pubDate = [dict objectForKey:kFeedDateParam];
    NSString *titleStr = [dict objectForKey:kFeedTitleParam];
    headingTxtView.text = titleStr;
    [headingTxtView scrollRangeToVisible:NSMakeRange(0, 1)];
    adminNameLbl.text = [dict objectForKey:kInstaFeedCreater];
    NSString *strDate = [CommonMethods convertDateToAnotherFormat:pubDate originalFormat:kformatOriginal finalFormat:kfinalFormat];
    dateLbl.text = strDate;
    
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
    
    [articleImgView sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:kAdLink]] placeholderImage:[UIImage imageNamed:kUnSpecifiedPng]];
    headingTxtView.text = [obj.fields objectForKey:kAdTitle];
    adminNameLbl.text = [obj.fields objectForKey:kAdCreater];
    [headingTxtView scrollRangeToVisible:NSMakeRange(0, 1)];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    // set the date format related to what the string already you have
    
    [dateFormat setDateFormat:kFormatOriginalCreatedDate];
    NSString *finalDate = [dateFormat stringFromDate:obj.createdAt];
    NSString *dateStr = [CommonMethods convertDateToAnotherFormat:finalDate originalFormat:kFormatOriginalCreatedDate finalFormat:kfinalFormat];
    
    dateLbl.text = dateStr;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
