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
#define adColor [UIColor colorWithRed:0.7020 green:0.9176 blue:0.7922 alpha:1.0]
#define infoPopupColor [UIColor colorWithRed:0.8392 green:0.8549 blue:0.8471 alpha:1.0]

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


// NSString *const kAppName = @"ParTee";
//NSString *const MySecondConstant = @"SecondConstant";

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
#define kEventPreferencesData @"eventPreferencesData"


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

/************* Event Screen constants *************/
static NSString *const kAdEventlblTxt           = @"Advertisment Event";
static NSString *const kEventCellName           = @"EventTableViewCell";
static NSString *const kEventTblName            = @"CourseEvents";
static NSString *const kAdEventTblName          = @"AdEvent";
static NSString *const kEventLimitParam         = @"limit";
static NSString *const kEventSkipParam          = @"skip";
static NSString *const kEventDateFormatOriginal = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
static NSString *const kEventDateFormatFinal    =  @"dd-MMM-yyyy";
static NSString *const kEventLimit              = @"25";
static NSString *const kAdEventLimit            = @"100";
static NSString *const kEventTrue               = @"true";
static NSString *const kEventFeatured           = @"featured";
static NSString *const kEventOrder              = @"order";
static NSString *const kEventSortAsc            = @"sort_asc";
static NSString *const kEventCordNear           = @"coordinates[near]";
static NSString *const kEventFavIn              = @"userFavID[in]";
static NSString *const kEventCount              = @"count";
static NSString *const kEventFavID              = @"userFavID";
static NSString *const kEventMarkUnFav          = @"Mark Unfavorite";
static NSString *const kEventMarkFav            = @"Mark Favorite";
static NSString *const kEventFavImg             = @"fav.png";
static NSString *const kEventUnFavImg           = @"unfav";
static NSString *const kEventFavTitle           = @"Your Favorite";
static NSString *const kEventInfoTitle          = @"Information";
static NSString *const kEventMapTitle           = @"On Map";
static NSString *const kEventDir                = @"Directions";
static NSString *const kEventCalendar           = @"Add to Calendar";
static NSString *const kEventInfoFilledImg      = @"info-filled";
static NSString *const kEventMapImg             = @"viewmap";
static NSString *const kEventDirImg             = @"direction";
static NSString *const kEventCalenderImg        = @"CalanderImg";
static NSString *const kEventCord               = @"coordinates";
static NSString *const kEventCourseId           = @"eventCourseID";
static NSString *const kEventIdIn               = @"ID[in]";
static NSString *const kEventID                 = @"ID";
static NSString *const kEventMapVc              = @"MapViewController";
static NSString *const kEventNoCourseAv         = @"No courses available";
static NSString *const kEventDescParam          = @"Description";
static NSString *const kEventTitleParam         = @"Title";
static NSString *const kEventStartDate          = @"StartDate";
static NSString *const kEventEndDateParam       = @"EndDate";
static NSString *const kEventNoInfoAvailTitle   = @"No information available";
static NSString *const kEventAd                 = @"AdEvent";
static NSString *const kEventPrefVc             = @"EventPreferncesViewController";
static NSString *const kEventContact            = @"ContactNumber";
static NSString *const kEventAddParam           = @"Address";
static NSString *const kEventAdvTitle           = @"AdTitle";
static NSString *const kEventAdDesc             = @"AdDesc";
static NSString *const kEventAdWebSite          = @"AdWebsite";
static NSString *const kEventWebsiteParam       = @"Website";
static NSString *const kEventCoordNear          = @"coordinates[near]";
static NSString *const kEventCourseIdIn         = @"eventCourseID[in]";
static NSString *const kEmptyStr                   = @"";
static NSString *const kEventOneStr                = @"1";
static NSString *const kEventGolfCourse            = @"GolfCourses";
static NSString *const kEventState                 = @"event_state";
static NSString *const kEventCity                  = @"event_City";
static NSString *const kEventAll                   = @"All";
static NSString *const kEventTitleName             = @"event_tiltleName";
static NSString *const kEventDistance              = @"event_Distance";
static NSString *const kEventFav                   = @"event_isFav";
static NSString *const kEventTitle                 = @"Title[ctn]";
static NSString *const kEventDateTblFormat         = @"yyyy-MM-dd'T'HH:mm:ssZ";
static NSString *const kEventIntervalFormat        = @"yyyy-MM-dd'T'HH:mm:ss";
static NSString *const kAdEventCellImgUrl          = @"AdImageUrl";
static NSString *const kEventCellDefaultImg        = @"imgplaceholder.jpg";
static NSString *const kEventCellImgUrl            = @"ImageUrl";
static NSString *const kFontNameEventHelveticaNeue      = @"Request Timed Out";
static NSString *const kEventFetchPreviousRecordBtnTitle = @"PREV";
static NSString *const kEventFetchNextRecordBtnTitle    = @"NEXT";
static NSString *const kEventFetchInitialRecordBtnTitle = @"  <<  ";
static NSString *const kEventMaxTenCitiesSelectAlertTitle = @"Maximum 10 Cities you can select.";
static NSString *const kEventStateTblName       = @"StateList";
static NSString *const kEventStateName          = @"StateName";
static NSString *const kCourseState             = @"State";
static NSString *const kCourseCity              = @"City";
static NSString *const kEventNo                 = @"NO";
static NSString *const kEventYes                = @"YES";
/************* Event Search Screen constants *************/

/************* Event Screen constants *************/
static NSString *const kEventPreFilledCircle       = @"filledcircle";
static NSString *const kEventPreRefreshContent     = @"refreshContent";
static NSString *const kEventPreState              = @"State";
static NSString *const kEventPreCity               = @"City";
static NSString *const kUserInfoTbl                = @"UserInfo";
static NSString *const kEventFavId                 = @"userFavID[in]";
static NSString *const kEventPreToggleOff          = @"toggleOff";
static NSString *const kEventPreToggleOn           = @"toggleOn";
static NSString *const kEventPreDesc               = @"description";
static NSString *const kEventPreCourseCell         = @"CourseCellTableViewCell";
static NSString *const kEventPreBlueChk            = @"blue_chk.png";
static NSString *const kEventPreUnchecked          = @"unchecked_circle.png";

static NSString *const kEventClearSearchAlertTitle = @"Clear Search Parameters?";
static NSString *const kEventBackBtnAlertTitle     = @"What would you like to do?";
static NSString *const kEventBackSaveSearchBtnAlertTitle = @"Save and Search";
static NSString *const kEventBackStartOverBtnAlertTitle = @"Start Over";
static NSString *const kEventAppName                    = @"ParTee";
static NSString *const kEventOkAlertBtnTitle                 = @"OK";
static NSString *const kEventYesAlertBtnTitle                = @"Yes";
static NSString *const kEventNoAlertBtnTitle                 = @"No";
static NSString *const kEventFeatureSoonAlertTitle = @"This Feature Coming Soon!";

/************* Event Search Screen constants *************/

/************ News feed Constants ************/
static NSString *const kArticleDetailVc         = @"ArticleDetailsVC";
static NSString *const knewsFeedCellName        = @"NewsFeedTblViewCell";
static NSString *const kNewsFeedUrl = @"https://www.partee.golf/feed.xml";
static NSString *const kInstaFeedUrl = @"https://web.stagram.com/rss/n/parteegolfers";
static NSString *const kCellIdentifier = @"cellIdentifier";
static NSString *const kParserItem = @"item";
static NSString *const kMediaThumbnail = @"media:thumbnail";
static NSString *const kInstaUrl = @"url";
static NSString *const kFeedTitleParam = @"title";
static NSString *const kFeedLinkParam = @"link";
static NSString *const kFeedGuidParam = @"guid";
static NSString *const kFeedDescParam = @"description";
static NSString *const kFeedDateParam = @"pubDate";
static NSString *const kFeedContentParam = @"content:encoded";
static NSString *const kFeedCreatorParam = @"dc:creator";
static NSString *const kFeedLangParam  = @"dc:language";
static NSString *const kInstaFeedTitle = @"instaTitle";
static NSString *const kInstaFeedLink = @"instaLink";
static NSString *const kInstaFeedDesc = @"instaDesc";
static NSString *const kInstaFeedPubDate = @"instaPubDate";
static NSString *const kInstaFeedCreator = @"instaCreator";
static NSString *const kInstaFeedThumbnail = @"instaThumbnail";
static NSString *const kAdNewsFeedTblName = @"AdNewsFeed";
static NSString *const kFeedMorningReadTitle = @"The Morning Read";
static NSString *const kFeedParteeLineTitle = @"The ParTee Line";
static NSString *const kUnSpecifiedPng = @"unspecified.png";
static NSString *const kInstaFeedContent = @"content";
static NSString *const kInstaFeedCreater = @"creator";


static NSString *const kformatOriginal = @"EEE, dd MMM yyyy HH:mm:ss Z";
static NSString *const kfinalFormat = @"MM-dd-yy";
static NSString *const kFormatOriginalCreatedDate = @"yyyy-MM-dd HH:mm:ss";
static NSString *const kAdLink    = @"adLink";
static NSString *const kAdTitle   = @"adTitle";
static NSString *const kAdCreater = @"adCreater";
static NSString *const kAdDesc    = @"adDesc";
static NSString *const kAdContent = @"AdContent";
static NSString *const kLargeTxtFeedImg = @"largeTxtFeed";
static NSString *const kSmallTxtImg     = @"smallTxtFeed";
static NSString *const kShareImg        = @"shareFeed";
static NSString *const kLargeTitle      = @"Large";
static NSString *const kSmallTitle      = @"Small";
static NSString *const kShareTitle      = @"Share";
static NSString *const kTextSmall       = @"document.getElementsByTagName('body')[0].style.webkitTextFillColor= 'white';document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='140%%';DOMReady();";

/************ News feed Constants ************/



/**************** Ubuntu Title VC ***********/
#define ubuntutuTitleFont  [UIFont fontWithName:@"Ubuntu-R" size:22]
/**************** Ubuntu Title VC ***********/
#endif /* LocalizedString_h */
