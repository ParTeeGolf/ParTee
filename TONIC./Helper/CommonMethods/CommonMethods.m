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
#pragma mark- convert Date To Another Format
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
#pragma mark- convert Date To Another Format
/**
 @Description
 * This Method used to validate the string provided is a valid email or not.
 * @author Chetu India
 * @param email string to be validate wheather it is valid email string or not.
 * @return (BOOL) return true if string provided is a valid email string while it will return false if it is not valid string provided.
 */

+ (BOOL)validateEmailWithString:(NSString*)email
{
    
    // Regular expression to verify that a string provided is a valid email or not.
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    // Predicates are logical conditions, which you can use to filter collections of objects.
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

#pragma mark- combine Notif Id And EventIdDigits
/**
 @Description
 * This Method used to combine notificationId and EventId Digits only so that we able to store this string on quickblox table.
 * @author Chetu India
 * @param EventNotificationID is the id of notification event created on push notification table.
 * @param eventIdStr is the Id of Event that user made the favourite now.
 * @return (NSString) return string combined first 8 digits from eventId and push notification event id so that we able to store in quickblox table because in array not able to store the complete string.
 */


+(NSString *)combineNotifIdAndEventIdDigits:(NSString*)eventNotificationID EventId:(NSString *)eventIdStr
{
    /****************** Logic to combine notification Id and Event Id to happen ************/
    
    // fetch first 8 digits from notication event id crated on table on which notifcation will go to the user that made event as favourite.
    NSUInteger notifiEventIdLength = eventNotificationID.length;
    NSMutableString *firstEightDigitsFromNotifiEventId;
    if (notifiEventIdLength == 8) {
        firstEightDigitsFromNotifiEventId  =  [NSMutableString stringWithString:[eventNotificationID substringToIndex:8]];
    }else if (notifiEventIdLength > 8) {
        firstEightDigitsFromNotifiEventId  = [NSMutableString stringWithString: [eventNotificationID substringToIndex:8]];
    }else if (notifiEventIdLength < 8){
        firstEightDigitsFromNotifiEventId  = [NSMutableString stringWithString: eventNotificationID];
        NSUInteger length = firstEightDigitsFromNotifiEventId.length;
        int remainingChToAdd = (int) (8 - length);
        for (int i = 0; i < remainingChToAdd; i++) {
        firstEightDigitsFromNotifiEventId = [NSMutableString stringWithString:   [firstEightDigitsFromNotifiEventId stringByAppendingString:@"9"]];
        }
    }
    
    // fetch first 8 digits from eventId of that made event as favourite.
    
    NSString *digitsFromEventId = [[eventIdStr componentsSeparatedByCharactersInSet:
                            [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                           componentsJoinedByString:@""];
    
    NSUInteger eventIdStrLength = digitsFromEventId.length;
    NSMutableString *firstEightDigitsFromEventId;
    
    if (eventIdStrLength == 8) {
        firstEightDigitsFromEventId  = [NSMutableString stringWithString: [digitsFromEventId substringToIndex:8]];
    }else if (eventIdStrLength > 8) {
        firstEightDigitsFromEventId  = [NSMutableString stringWithString: [digitsFromEventId substringToIndex:8]];
    }else if (eventIdStrLength < 8){
        firstEightDigitsFromEventId  = [NSMutableString stringWithString:digitsFromEventId];
        NSUInteger length = firstEightDigitsFromEventId.length;
        int remainingChToAdd = (int) (8 - length);
        for (int i = 0; i < remainingChToAdd; i++) {
         firstEightDigitsFromEventId =   [NSMutableString stringWithString:  [firstEightDigitsFromEventId stringByAppendingString:@"0"]];
        }
    }
    
    NSString *combinedStr = [NSString stringWithFormat:@"%@%@",firstEightDigitsFromNotifiEventId,firstEightDigitsFromEventId];
    
    return combinedStr;
}


#pragma mark- Fetch Notif Id From CombinedStr
/**
 @Description
 * This Method used to convert the nsdata into link that we are getting in feed details.
 * @author Chetu India
 * @return NsData contain data from feed.
 */

+ (NSString *)convertDataToLink:(NSData *)data
{
    NSString *cDataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDataDetector *detect = [[NSDataDetector alloc] initWithTypes:NSTextCheckingTypeLink error:nil];
    NSArray *matches = [detect matchesInString:cDataString options:0 range:NSMakeRange(0, [cDataString length])];
    for(int i=0; i<matches.count;i++){
        NSTextCheckingResult *result = [matches objectAtIndex:i];
        NSString *linkUrl = [result URL].absoluteString;
        
        if([[linkUrl pathExtension] isEqualToString:@"jpg"]){
           
            NSLog(@"image link:%@", linkUrl);
            return linkUrl;
        } else if([[linkUrl pathExtension] isEqualToString:@"png"])
        {
            
            NSLog(@"link:%@", linkUrl);
            return linkUrl;
        }
    }
    return @"";
    
}
#pragma mark- Reset user Defaults
/**
 @Description
 * This Method used to remove the user persistent data from nsuserdefault while user signout from  the application.
 * @author Chetu India
 */
+ (void)resetDefaults {
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
    
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
   
}


@end
