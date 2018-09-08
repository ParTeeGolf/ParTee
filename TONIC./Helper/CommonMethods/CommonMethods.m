//
//  CommonMethods.m
//  ParTee
//
//  Created by Admin on 07/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "CommonMethods.h"

@implementation CommonMethods
#pragma mark- Calculate Height Dynamically
/**
 @Description
 * This Method used to get the height of any object like uilabel, uitextview etc.
 * @author Chetu India
 * @param text string that will display on object
 * @param font using for text on object
 * @param width of the object like textview or uilabel
 * @return CGFloat height of the object that needs to display text on object according to text string, font and also width of the object
 */

+(CGFloat)heightForText:(NSString*)text withFont:(UIFont *)font andWidth:(CGFloat)width
{
    CGSize constrainedSize = CGSizeMake(width, MAXFLOAT);
    NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text attributes:attributesDictionary];
    CGRect requiredHeight = [string boundingRectWithSize:constrainedSize options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (requiredHeight.size.width > width) {
        requiredHeight = CGRectMake(0,0,width, requiredHeight.size.height);
    }
    return requiredHeight.size.height;
}

/**
 @Description
 * This Method used to get the height of any object like uilabel, uitextview etc.
 * @author Chetu India
 * @param text string that will display on object
 * @param font using for text on object
 * @param width of the object like textview or uilabel
 * @return CGFloat height of the object that needs to display text on object according to text string, font and also width of the object
 */

+(NSString *)convertDateToAnotherFormat:(NSString *)dateStr originalFormat:(NSString *)originalFormat finalFormat:(NSString *)finalFormat
{
  //  2018-10-29T15:23:00Z
    
  //  First initialize the formatter with the appropriate format to parse the source string
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:originalFormat];
 //    Then use it to parse the date string:
    
    NSDate *date = [formatter dateFromString:dateStr];
//    Now you can create a new formatter to output in the new format, or just reuse the existing one:
    
    [formatter setDateFormat: finalFormat];
    NSString *convertFormatDateStr = [formatter stringFromDate:date];
    return convertFormatDateStr;
}
+ (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
