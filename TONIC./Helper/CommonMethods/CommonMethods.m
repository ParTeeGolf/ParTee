//
//  CommonMethods.m
//  ParTee
//
//  Created by Chetu India on 07/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
// This file conatin all the methods that we used in the code for common use.


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
 * This Method using to convert the date string from one format to another format.
 * @author Chetu India
 * @param dateStr is the date to be converted in string format.
 * @param originalFormat fromat of date in which it is converting from.
 * @param finalFormat fromat of date in which it is converted to.
 * @return NSString Date in string format after converted into the final format
 */

+(NSString *)convertDateToAnotherFormat:(NSString *)dateStr originalFormat:(NSString *)originalFormat finalFormat:(NSString *)finalFormat
{
    
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
/**
 @Description
 * This Method used to validate the string provided is a valid email or not.
 * @author Chetu India
 * @param email string to be validate wheather it is valid email string or not.
 * @param (BOOL) return true if string provided is a valid email string while it will return false if it is not valid string provided.
 */

+ (BOOL)validateEmailWithString:(NSString*)email
{
    
    // Regular expression to verify that a string provided is a valid email or not.
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    // Predicates are logical conditions, which you can use to filter collections of objects.
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

@end
