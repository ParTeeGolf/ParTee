//
//  LocalizedStr.h
//  ParTee
//
//  Created by Admin on 23/08/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#ifndef LocalizedString
#define LocalizedString

#define jsonDecoder  ([[JSONDecoder alloc]init])
#import "BSKeyboardControls.h"

#define knotificationlink @"notificationlink"

#define kPDFDir @"PDF"

#define RGBCOLOR(r, g, b) [UIColor colorWithRed:r/225.0f green:g/225.0f blue:b/225.0f alpha:1]

#define isiPhone4  ([[UIScreen mainScreen] bounds].size.height == 480)?TRUE:FALSE
#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define isiPhone6  ([[UIScreen mainScreen] bounds].size.height == 667)?TRUE:FALSE
#define isiPhone6Plus  ([[UIScreen mainScreen] bounds].size.height == 736)?TRUE:FALSE

#define IPAD     UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define  kAudioFileName @"1.1"

#define kAudioPlayedInfo @"AudioPlayedInfo "

#define appdelegate ((AppDelegate *)[[UIApplication sharedApplication] delegate]);
#define kUserId @"userId"

#define kIsFirstTime @"kIsFirstTime"

#define kIAPFULLVERSION @"kIAPFULLVERSION"

#define kUserData @"UserData"

#define DOLocalUserData @"LocalUserData"

#define DOstatus @"status"

#define DOSuccess @"1"
#define DOFailurePassword @"0"
#define DOFailureNotRegistered @"2"

#define DOMessage @"message"
#define kUsageCounter @"kUsageCounter"


#define kAppName @"ParTee"

#define klocationlong @"klocationlong"
#define klocationlat @"klocationlat"

// Messages
#define kLoginUserNotRegisteredMessage @"User is not registered"
#define kLoginUserPasswordWrongMessage @"Password is not correct"
#define kNoInternet @"Network not connected. Please check your network connection"
#define kServerError @"Some error occured"

#define kOk @"OK"

// Database constants

#define kname @"name"
#define kcompanyName @"companyName"
#define khouseNumber @"houseNumber"
#define kaddressLine1 @"addressLine1"
#define kaddressLine2 @"addressLine2"
#define kcity @"city"
#define kcounty @"county"
#define kpostCode @"postCode"

#define ktelephone @"telephone"
#define kmobile @"mobile"
#define kemail @"email"
#define kwebsite @"website"
#define kDeviceToken @"MyDeviceToken"

#define klogo @"logo"
#define kaccountType @"accountType"
#define kuserEmail @"userEmail"
#define kuserPassword @"userPassword"

#define kuserDBID @"kuserDBID"
#define kuserInfoID @"kuserInfoID"

#define kuserAccessToken @"userToken"
#define kuserData @"userData"
#define kuserSearchUser @"userSearchUser"
#define kuserSearchPro @"userSearchPro"

#define kcoursePreferencesData @"coursePreferencesData"
#define kCourseFilterData @"kCourseFilterData"


/************ Courses Screen **********/
#define kFontNameHelveticaNeue @"Request Timed Out"
#define kFetchPreviousRecordBtnTitle @"PREV"
#define kFetchNextRecordBtnTitle @"NEXT"
#define kFetchInitialRecordBtnTitle @"  <<  "
/************ Courses Screen **********/
 
/************ MapStirng *********/
#define kUserMapProfileBackgrooundIcon @"MapProfileIcon"
/************ MapStirng *********/

/************ Courses Search Screen *********/
#define kMaxTenAmentiesSelectAlertTitle @"Maximum 10 Amenties you can select."
#define kMaxTenCitiesSelectAlertTitle @"Maximum 10 Cities you can select."
#define kClearSearchAlertTitle @"Clear Search Parameters?"
#define kBackBtnAlertTitle @"What would you like to do?"
#define kBackSaveSearchBtnAlertTitle @"Save and Search"
#define kBackStartOverBtnAlertTitle @"Start Over"

/************ Courses Search Screen *********/

/******** Alert Titles *************/
#define kOkAlertBtnTitle @"OK"
#define kYesAlertBtnTitle @"Yes"
#define kNoAlertBtnTitle @"No"
/******** Alert Titles *************/

/*************** Golfers Search Screen *********/
#define kFeatureSoonAlertTitle @"This Feature Coming Soon!"
/*************** Golfers Search Screen *********/

/**************** Event Sccreen ***********/
#define kAdEventlblTxt @"Advertisment Event"
#define kEventCellName @"EventTableViewCell"
#define kEventTblName @"CourseEvents"
#define kEventLimitParam @"limit"
#define kEventSkipParam @"skip"
#define kEventCellImgUrl @"ImageUrl"
#define kEventCellDefaultImg @"imgplaceholder.jpg"
#define kEventDateFormatOriginal @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define kEventDateFormatFinal  @"dd-MMM-yyyy"

/**************** Event Sccreen ***********/

#endif /* LocalizedString_h */
