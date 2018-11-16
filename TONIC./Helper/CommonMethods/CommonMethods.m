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
#pragma mark- interval Bw Dates In Sec
/**
 @Description
 * This Method used to find the interval between event date and current date in seconds.
 * @author Chetu India
 * @param eventDate is the date in string format on which event is to be organized.
 * @param (BOOL) return true if string provided is a valid email string while it will return false if it is not valid string provided.
 * @return return nsdate on which notification to be trigered.
 */

+(NSDate *)intervalBwDatesInSec:(NSString *)eventDate
{

     // convert event time in format to find interval bw current date and event date.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:kEventDateTblFormat];
    NSDate *eventDateTime = [dateFormatter dateFromString:eventDate];
    
    // find current date and time.
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:kEventIntervalFormat];
    NSString *currentDateString = [dateFormat stringFromDate:currentDate];
    // convert current date and time in format to find interval bw current date and event date.
    NSDate *currentDateTime = [dateFormat dateFromString:currentDateString];
    
    // A NSTimeInterval value is always specified in seconds.
    NSTimeInterval distanceBetweenDates = [eventDateTime timeIntervalSinceDate:currentDateTime];
  //  distanceBetweenDates = 106;
    NSDate *dateToSend = [NSDate dateWithTimeIntervalSinceNow:distanceBetweenDates];
    NSTimeInterval timeSince1970 = [dateToSend timeIntervalSince1970];
    timeSince1970 -= fmod(timeSince1970, 60); // subtract away any extra seconds
    // find time on which notofcation need to be sent in format supported by quickblox.
    NSDate *nowMinus = [NSDate dateWithTimeIntervalSince1970:timeSince1970];
    
    return nowMinus;
   
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
 * This Method used to fetch notificationId from combined str that have stored in table.
 * @author Chetu India
 * @param EventNotificationID is the id of notification event created on push notification table.
 * @param eventIdStr is the Id of Event that user made the favourite now.
 * @return (NSString) return string combined first 8 digits from eventId and push notification event id so that we able to store in quickblox table because in array not able to store the complete string.
 */

+(NSString *)FetchNotifIdFromCombinedStr:(NSString*)combinedStr EventId:(NSString *)eventIdStr
{

    NSString *digitsFromEventId = [[eventIdStr componentsSeparatedByCharactersInSet:
                                    [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]
                                   componentsJoinedByString:@""];

    NSUInteger eventIdStrLength = digitsFromEventId.length;
    NSString *firstEightDigitsFromEventId;

    if (eventIdStrLength == 8) {
        firstEightDigitsFromEventId  = [digitsFromEventId substringToIndex:8];
    }else if (eventIdStrLength > 8) {
        firstEightDigitsFromEventId  = [digitsFromEventId substringToIndex:8];
    }else if (eventIdStrLength < 8){
        firstEightDigitsFromEventId  = digitsFromEventId;
        NSUInteger length = firstEightDigitsFromEventId.length;
        int remainingChToAdd = (int) (8 - length);
        for (int i = 0; i < remainingChToAdd; i++) {
            [firstEightDigitsFromEventId stringByAppendingString:@"0"];
        }
    }

   NSString *eventId = [combinedStr substringFromIndex: [combinedStr length] - 8];
    
    if ([eventId isEqualToString:firstEightDigitsFromEventId]) {
       
    }
    
    return combinedStr;
}
//
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


// #pragma mark- Create Noti Action
// /*
// @Description
// * This Method will create the local notification on device so that user able to recieve
// * @author Chetu India
// * @return IBAction nothing will return by this method.
// */
//-(void)createLocalNotifEvent:(int)selectedEventIndex
//{
//    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
//    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
//
//    // Request using shared Notification Center
//    [center requestAuthorizationWithOptions:options
//                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
//                              if (granted) {
//                                  NSLog(@"Notification Granted");
//                              }
//                          }];
//
//    // Notification authorization settings
//    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
//        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
//            NSLog(@"Notification allowed");
//        }
//    }];
//
//
//    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
//    content.title = @"Event Notification";
//    content.body = @"Event Local Recieved";
//    content.sound = [UNNotificationSound defaultSound];
//
//
//    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedEventIndex];
//    NSString *eventStartDate = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventStartDate]];
//    NSDate *notificationEventDate = [CommonMethods intervalBwDatesInSec:eventStartDate];
//    NSString *eventIdStr = [NSString stringWithFormat:@"%@", obj.ID];
//    // Trigger with date
//    NSDateComponents *triggerDate = [[NSCalendar currentCalendar]
//                                     components:NSCalendarUnitYear +
//                                     NSCalendarUnitMonth + NSCalendarUnitDay +
//                                     NSCalendarUnitHour + NSCalendarUnitMinute +
//                                     NSCalendarUnitSecond fromDate:notificationEventDate];
//    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerDate repeats:NO];
//
//
//    // Scheduling the notification
//    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventIdStr content:content trigger:trigger];
//
//    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//        if (error != nil) {
//            NSLog(@"Something went wrong: %@",error);
//        }
//    }];
//
//}
//#pragma mark- Delete Noti Action
///**
// @Description
// * This Method will delete the local notification on device based on identifier.
// * @author Chetu India
// * @return IBAction nothing will return by this method.
// */
//-(void)deleteLocalNotification:(int)selectedEventIndex
//{
//
//    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedEventIndex];
//    NSString *eventIdStr = [NSString stringWithFormat:@"%@", obj.ID];
//    [[UNUserNotificationCenter currentNotificationCenter]getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
//        if (requests.count>0) {
//
//
//            for (UNNotificationRequest *pendingRequest  in requests) {
//                if ([pendingRequest.identifier isEqualToString:eventIdStr]) {
//                    [[UNUserNotificationCenter currentNotificationCenter]removePendingNotificationRequestsWithIdentifiers:@[pendingRequest.identifier]];
//
//                }
//            }
//
//        }
//
//    }];
//
//    if (eventOption == 2) {
//        [self getEventRecordsCount];
//    }else {
//        [[AppDelegate sharedinstance] hideLoader];
//
//    }
//}
// */
@end
