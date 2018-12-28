//
//  CommonMethods.h
//  ParTee
//
//  Created by Admin on 07/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject
// This Method used to get the height of any object like uilabel, uitextview etc.
+(CGFloat)heightForText:(NSString*)text withFont:(UIFont *)font andWidth:(CGFloat)width;
//  This Method using to convert the date string from one format to another format.
+(NSString *)convertDateToAnotherFormat:(NSString *)dateStr originalFormat:(NSString *)originalFormat finalFormat:(NSString *)finalFormat;
// This Method used to validate the string provided is a valid email or not.
+ (BOOL)validateEmailWithString:(NSString*)email;
// This Method used to convert the nsdata into link that we are getting in feed details.
+ (NSString *)convertDataToLink:(NSData *)data;
@end
