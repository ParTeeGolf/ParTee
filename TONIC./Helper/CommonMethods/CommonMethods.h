//
//  CommonMethods.h
//  ParTee
//
//  Created by Admin on 07/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject
+(CGFloat)heightForText:(NSString*)text withFont:(UIFont *)font andWidth:(CGFloat)width;
+(NSString *)convertDateToAnotherFormat:(NSString *)dateStr originalFormat:(NSString *)originalFormat finalFormat:(NSString *)finalFormat;
+ (BOOL)validateEmailWithString:(NSString*)email;
@end
