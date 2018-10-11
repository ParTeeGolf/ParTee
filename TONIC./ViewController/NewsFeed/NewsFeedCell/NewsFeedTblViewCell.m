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
 * This Method set the data from QBCOCustomObject in cell.
 * @author Chetu India
 * @param dict is type of NSDictionary that contain all the details about a feed to be showed in news feed screen. These objects we are getting from blog.
 * @return void nothing will return by this method.
 */
#pragma mark- setDataFromEventObject
-(void)setFeedDataFromDict:(NSDictionary *)dict {
    
    NSLog(@"%@", dict);
    NSString *myregex = @"<[^>]*>"; //regex to remove any html tag
    
    NSString *stringWithoutHTML = [dict objectForKey:@"content"];
    NSString *stringWithoutHTML1 = [dict objectForKey:@"description"];
    
     NSString *pubDate = [dict objectForKey:@"pubDate"];
     NSString *guidStr = [dict objectForKey:@"guid"];
     NSString *linkStr = [dict objectForKey:@"link"];
     NSString *titleStr = [dict objectForKey:@"title"];
    NSLog(@"%@%@%@%@%@%@%@", titleStr, pubDate, linkStr, titleStr, stringWithoutHTML, stringWithoutHTML1,guidStr);
    
    self.headingTxtView.text = titleStr;
    self.adminNameLbl.text = [dict objectForKey:@"creator"];
    
    NSString *formatOriginal = @"EEE, dd MMM yyyy HH:mm:ss Z";
    NSString *finalFormat = @"dd-mm-yy";
  //  NSString *strDate = [CommonMethods convertDateToAnotherFormat:pubDate originalFormat:formatOriginal finalFormat:finalFormat];
  //  NSLog(@"%@",strDate);
   // self.dateLbl.text = strDate;
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:formatOriginal];
    NSDate *dateFromString = [dateFormatter dateFromString:pubDate];
    
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter2 setDateFormat:finalFormat];
    NSString *newDateString = [dateFormatter2 stringFromDate:dateFromString];
    self.dateLbl.text = newDateString;
    NSLog(@"%@", newDateString);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
