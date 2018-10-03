//
//  EventViewController.m
//  ParTee
//
//  Created by Admin on 24/08/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "EventViewController.h"
#import "EventTableViewCell.h"
#import "MapViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "EventPreferncesViewController.h"


@interface EventViewController ()<RNGridMenuDelegate, MFMailComposeViewControllerDelegate, UNUserNotificationCenterDelegate>
{
    // constrrints used to hide nextPrevBaseView if it have value 0 then all the objects will adjust automatically by default its value is 30.
    IBOutlet NSLayoutConstraint *viewNextPrevHeightConstraints;
    /************ Information View Outlets ***********/
    IBOutlet UIView *viewBlurInfo;
    IBOutlet UIView *viewInfoBase;
    IBOutlet UILabel *lblEventTitleInfo;
    IBOutlet UILabel *lblStartEndDateInfo;
    IBOutlet UILabel *lblAddressEventInfo;
    IBOutlet UITextView *textViewEventDescInfo;
    IBOutlet UIButton *BtnContactInfo;
    IBOutlet UIButton *BtnWebsiteInfo;
    IBOutlet UIButton *btnCloseInfo;
    IBOutlet NSLayoutConstraint *constraintsInfoBaseViewHeight;
    /************ Information View Outlets ***********/
    
    /************ Advertiesment View Outlets ***********/
    IBOutlet UIView *viewAdvertiseInfoPopup;
    IBOutlet UILabel *lblAdvTitle;
    IBOutlet UITextView *txtViewAdvdesc;
    IBOutlet UIButton *btnWebsiteAdv;
    IBOutlet UIButton *btnCloseAdv;
    IBOutlet NSLayoutConstraint *constraintHeightTxtViewAdvDesc;
    IBOutlet NSLayoutConstraint *infoTitleLblHeightConstarints;
    IBOutlet NSLayoutConstraint *constraintWidthContactBtn;
    IBOutlet NSLayoutConstraint *constraintWidthWebsiteBtn;
    /************ Advertiesment View Outlets ***********/
    
    
    // Evnet table view that will show the list of events.
    IBOutlet UITableView *eventTblView;
    // This label will display nothing found if no one event exist for the prefernces.
    IBOutlet UILabel *lblNothingFound;
    // segment control used to filetr out the events from table based on favourite, featured , near me and all events.
    IBOutlet UISegmentedControl *segmentControl;
    // This is base view that contain next,prev and << button to fetch the require records
    IBOutlet UIView *nextPrevRecordBaseView;
    
    
    // Will contain value 0 or 1. 0 means city or state parameters available.
    int cityStateCourseFilter;
    // conatin current page number for records.
    int currentPage;
    // conatin current page number for advertisement events.
    int adCurrentPage;
    // contain selected segment control option value means which segment is selected for now by the user.
    int eventOption;
    // conatin all events count for prefernces selected by the user.
    int eventCount;
    // conatin all Adevents count.
    int totalAdvertEventCount;
    // having total number of advertisement events that was shown on previous page.
    int adEventUsedInPage;
    // number of users notifcation events fetched
    int notiEventUsersNumber;
    // conatin selected row value for which three dot popup to be shown.
    NSInteger selectedRow;
    // valirable used wheather particulr event is favourite for user or not.
    BOOL isFavEvent;
    // varibale that holds value wheather records left to be shown on next page.
    BOOL shouldLoadNext;
    // objects from course table on which particular event will happen for which event user want to get information like map, direction, information like adreess, website link, contact no to course.
    QBCOCustomObject *objEventGolfCourse;
    QBCOCustomObject *objAdvEvent;
    // Contain event object for which three dot pop up to be shown, and also having data about events.
    QBCOCustomObject *sharedobj;
    QBCOCustomObject *loginUserObject;
    /**************** Long latitude details of course to which user want get information about event  ************/
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    NSString *strlat;
    NSString *strlong;
    /**************** Long latitude details of course to which user want get information aboiut event  ************/
    // string used wheather user redirect to map screen through sidemenu or map option available on three dot popup.
    NSString *favInfoMapDirStr;
    
    // This array contain events details fetched from the quickblox table.
    NSMutableArray *arrEventsData;
    // This array contain AdEvents details fetched from the quickblox table.
    NSMutableArray *arrAdEventsDetails;
    // This array contain courses details fetched from the golfcourse table based on city or state preferred by the user to be logged in.
    NSMutableArray *courseDetailsStateCityArr;
    // This array contain AdEvents details fetched from the quickblox table.
    NSMutableArray *userEventNotificationArrList;
    // button that will load prev records from table and will show in table.
    UIButton *fetchPrevRecordBtn;
    // button that will load Next klimit records from table and will show in table.
    UIButton *fetchNextRecordBtn;
    // button that will load first klimit records from table and will show in table.
    UIButton *fecthInitialRecordBtn;
    // this will show the total number of records and current records showing in screen.
    UILabel  *recordLbl;
  
}

@end

@implementation EventViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeDataForScreen];
    [self createRecordBaseView];
}

-(void)viewWillAppear:(BOOL)animated {
    
    // hide info popup
    viewBlurInfo.hidden = true;
    viewInfoBase.hidden = true;
    // courseOption set selected segment to all events
    currentPage = kZeroValue;
    adCurrentPage = kZeroValue;
    eventOption = kThreeSegmentOptionValue;
    segmentControl.selectedSegmentIndex = eventOption;
    shouldLoadNext = NO;
    fetchPrevRecordBtn.hidden = true;
    fecthInitialRecordBtn.hidden = true;
    
    constraintWidthContactBtn.constant = (self.view.frame.size.width - 40) /2;
    constraintWidthWebsiteBtn.constant = (viewAdvertiseInfoPopup.frame.size.width - 40) /2;
    // Call getAdEventRecordsCount method to fetch Advertisment event details
    [self getAdEventRecordsCount];
}
#pragma mark- initialize Data
/**
 @Description
 * This method initialize all the set the initial required values used in this controller.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)initializeDataForScreen
{
    /******** set Initial values ********/
    cityStateCourseFilter = kZeroValue;
    adEventUsedInPage = kZeroValue;
    favInfoMapDirStr = kEmptyStr;
    currentPage = kZeroValue;
    adCurrentPage = kZeroValue;
    notiEventUsersNumber = kZeroValue;
    /******** set Initial values ********/
    eventOption = kThreeSegmentOptionValue;
    segmentControl.selectedSegmentIndex = eventOption;
    lblNothingFound.hidden = true;
    viewNextPrevHeightConstraints.constant = 30;
    nextPrevRecordBaseView.hidden = false;
    viewInfoBase.layer.borderWidth = 3.0;
    viewInfoBase.layer.borderColor = [UIColor blackColor].CGColor;
    eventTblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    viewAdvertiseInfoPopup.opaque = true;
    viewAdvertiseInfoPopup.layer.cornerRadius = 5.0;
    viewBlurInfo.alpha = 0.95;
    viewBlurInfo.backgroundColor = [UIColor blackColor];
    /************** Initialize array to hold events details for the screen **********/
    arrAdEventsDetails = [[NSMutableArray alloc]init];
    arrEventsData = [[NSMutableArray alloc]init];
    arrAdEventsDetails = [[NSMutableArray alloc]init];
    courseDetailsStateCityArr = [[NSMutableArray alloc]init];
    userEventNotificationArrList = [[NSMutableArray alloc]init];
    /************** Initialize array to hold events details for the screen **********/
    
    
}
#pragma mark- Get AdEvent Count
/**
 @Description
 * This method will count the advertisement events available in AdEvent table on quickblox based on parameters such as featured events, favourite, all, near me events.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getAdEventRecordsCount
{
    // show loader
    [[AppDelegate sharedinstance] showLoader];
    
    // Create Dictionary for parameters used to fetch Advertisement records available in the adEvents table on quickblox.
    NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
    [getRequestObjectCount setObject:kAdEventLimit forKey:kEventLimitParam];
    // find out the records thats need to skip based on current page
    NSString *strPage = [NSString stringWithFormat:@"%d",[kAdEventLimit intValue] * currentPage];
    [getRequestObjectCount setObject:strPage forKey:kEventSkipParam];
    // Add parameters for count the records available in the  table.
    [getRequestObjectCount setObject:kEventOneStr forKey:kEventCount];
    
    [QBRequest countObjectsWithClassName:kAdEventTblName extendedRequest:getRequestObjectCount successBlock:^(QBResponse * _Nonnull response, NSUInteger count) {
        
        NSLog(@"%lu",(unsigned long)count);
        
        // Total number of advertisment events available in AdEvent table on Quickblox
        totalAdvertEventCount = (int)count;
        [self getAdEventDetails];
        
    } errorBlock:^(QBResponse *response) {
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}
#pragma mark- Get Event Details
/**
 @Description
 * This will fetch the AdEvent details based on parameters provided by the user.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void) getAdEventDetails
{
    
    // Create dictionary for parameters to filter out the records from AdEvents table on quickblox
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    
    [getRequest setObject:kAdEventLimit forKey:kEventLimitParam];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kAdEventLimit intValue] * adCurrentPage];
    [getRequest setObject:strPage forKey:kEventSkipParam];
    
    
    [QBRequest objectsWithClassName:kAdEventTblName extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"%lu",(unsigned long)objects.count);
        // Add the Ad Event record details in array.
        [arrAdEventsDetails addObjectsFromArray:[objects mutableCopy]];
        
        // Arrange events randomly in array so that we able to show the advertisement events randomly on screen.
        for (int x = kZeroValue; x < [arrAdEventsDetails count]; x++) {
            int randInt = (arc4random() % ([arrAdEventsDetails count] - x)) + x;
            [arrAdEventsDetails exchangeObjectAtIndex:x withObjectAtIndex:randInt];
        }
        
        [self getEventRecordsCount];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark- Get Event Count
/**
 @Description
 * This method will count the events available in event table on quickblox based on parameters such as featured events, favourite, all, near me events.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getEventRecordsCount
{
 // Create dictionalry for parameters to filter out the events.
    NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
    
    [getRequestObjectCount setObject:kEventLimit forKey:kEventLimitParam];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kEventLimit intValue] * currentPage];
    
    [getRequestObjectCount setObject:strPage forKey:kEventSkipParam];
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    NSString *strlat1 = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat1 = [[AppDelegate sharedinstance] nullcheck:strlat1];
    
    NSString *strlong1 = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong1 = [[AppDelegate sharedinstance] nullcheck:strlong1];
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    NSMutableDictionary *dictcoursePreferencesData;
    NSString *strFilterDistance;
    
    // Select parameters based on option selected by the user for segment control
    switch(eventOption)
    {
        case 0:
            [getRequestObjectCount setObject: kEventTrue forKey:kEventFeatured];
            [getRequestObjectCount setObject: kEventOrder forKey:kEventSortAsc];
            break;
        case 1:
            strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],10.6f];
            [getRequestObjectCount setObject:strFilterDistance forKey:kEventCordNear];
            break;
        case 2:
            [getRequestObjectCount setObject: strCurrentUserID forKey:kEventFavIn];
            break;
        case 3:
            // Get dictionary of event preferences selected by the user from nsusredefault
            dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kEventPreferencesData] mutableCopy];
            if(dictcoursePreferencesData) {
                // get details from the dictionary
                NSString *strcf_name = [dictcoursePreferencesData  objectForKey:kEventTitleName];
                NSString *strcf_distance= [dictcoursePreferencesData  objectForKey:kEventDistance];
                NSString *strcf_isFav= [dictcoursePreferencesData  objectForKey:kEventFav];
                
                if(![strcf_name isEqualToString:kEventAll])
                {
                    
                    [getRequestObjectCount setObject: strcf_name forKey:kEventTitle];
                }
                // Convert distance in km into meters.
                if(![strcf_distance isEqualToString:@"500"]) {
                    
                    float val = [strcf_distance floatValue];
                    float metres = val* 1609.34f;
                    
                    NSString *strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],metres];
                    
                    
                    [getRequestObjectCount setObject:strFilterDistance forKey:kEventCoordNear];
                    
                }
                else {
                    NSString *strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong1 floatValue],[strlat1 floatValue],9999999.f];
                    
                    [getRequestObjectCount setObject:strFilterDistance forKey:kEventCoordNear];
                }
                
                if([strcf_isFav isEqualToString:kEventOneStr]) {
                    //   showOnyFav=YES;
                    [getRequestObjectCount setObject: strCurrentUserID forKey:kEventFavId];
                }
                else {
                    //   showOnyFav=NO;
                }
            }
            break;
    }
    
    [getRequestObjectCount setObject:kEventOneStr forKey:kEventCount];
    // If user provide details for city or state then first get the details of course from golf course table and after that get the details of events from event table.
    if (eventOption == kThreeSegmentOptionValue  &&  dictcoursePreferencesData) {
        NSString *strcf_state= [dictcoursePreferencesData  objectForKey:kEventState];
        NSString *strcf_city = [dictcoursePreferencesData  objectForKey:kEventCity];
        
        
        if(![strcf_state isEqualToString:kEventAll]  || ![strcf_city isEqualToString:kEventAll] ) {
            
            if (cityStateCourseFilter == kZeroValue) {
                [self getEventCourseIdBasedOnStateAndCity:strcf_state City:strcf_city];
            }else if(cityStateCourseFilter == 1) {
                
                // get the Courses ID from golf course available filtered based on city and state parameters.
                NSString *eventIds = @"";
                for ( QBCOCustomObject *obj in courseDetailsStateCityArr ) {
                    
                    NSString *courseId =   (NSString *)obj.ID;
                    eventIds = [NSString stringWithFormat:@"%@,%@",eventIds, courseId];
                }
                [getRequestObjectCount setObject: eventIds forKey:kEventCourseIdIn];
                cityStateCourseFilter = kZeroValue;
                [self getEventRecordsCount:getRequestObjectCount];
                
            }
            
        }else {
            
            [self getEventRecordsCount:getRequestObjectCount];
            
        }
    }else {
        [self getEventRecordsCount:getRequestObjectCount];
    }
    
    
}
#pragma mark- Get Event Count
/**
 @Description
 * This method will count the events available in event table on quickblox based on parameters such as featured events, favourite, all, near me events.
 * @author Chetu India
 * @return void nothing will return by this method.
 */

-(void)getEventRecordsCount:(NSMutableDictionary *)getRequestObjectCount {
    
    [QBRequest countObjectsWithClassName:kEventTblName extendedRequest:getRequestObjectCount successBlock:^(QBResponse * _Nonnull response, NSUInteger count) {
        
        NSLog(@"%lu",(unsigned long)count);
        eventCount = (int)count;
        
       // get the total number of needed advertisment events so that every 5th events will show as advertisment events on screen.
        int needAdvEventsCount = eventCount;
        needAdvEventsCount = needAdvEventsCount / (kAdvertisementEventNo -1);
        // Compare need Ad Events with available ad events that have been fetched from quickblox. If needed events are more and there are still available records in the table then fetch rest of advertisement events again.
        if (needAdvEventsCount > (int)[arrAdEventsDetails count] ) {
            
            if (totalAdvertEventCount > (int)[arrAdEventsDetails count] ) {
                adCurrentPage++;
                [self getAdEventDetails];
            }
            
            
        }
        // set the total number available events in label.
        NSString *recordcountStr;
        if (shouldLoadNext) {
            
        }else {
            if (eventCount == 0) {
                recordcountStr = [NSString stringWithFormat:@"0 - 0 (%d)", eventCount];
            }else if (eventCount < 25) {
                recordcountStr = [NSString stringWithFormat:@"1 - %d (%d)", eventCount, eventCount];
            }else {
                recordcountStr = [NSString stringWithFormat:@"1 - %@ (%d)", kEventLimit, eventCount];
            }
            
            recordLbl.text = recordcountStr;
        }
        [self getEventDetails:getRequestObjectCount];
        
    } errorBlock:^(QBResponse *response) {
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}
#pragma mark- Get Event Details
/**
 @Description
 * This will fetch the event details based on parameters provided by the user and also show these events on screen.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void) getEventDetails:(NSMutableDictionary *)getRequest
{
    
    [QBRequest objectsWithClassName:kEventTblName extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        [[AppDelegate sharedinstance] hideLoader];
        arrEventsData = [[NSMutableArray alloc]init];
        
        [arrEventsData addObjectsFromArray:[objects mutableCopy]];
        // show lbl nothing found if evnets table does not have any events.
        if([arrEventsData count]==0) {
            [lblNothingFound setHidden:NO];
            [eventTblView setHidden:YES];
        }
        else {
            [lblNothingFound setHidden:YES];
            [eventTblView setHidden:NO];
            
        }
        
        // show the events number for current pege;.
        NSString *strPage = [NSString stringWithFormat:@"%d",[kEventLimit intValue] * currentPage];
        int totalFetchedEvents = [strPage intValue];
        totalFetchedEvents = totalFetchedEvents + (int)[objects count];
        
        if (totalFetchedEvents < eventCount) {
            shouldLoadNext = YES;
            fetchNextRecordBtn.hidden = false;
        }else{
            shouldLoadNext=NO;
            fetchNextRecordBtn.hidden = true;
        }
        
        if (shouldLoadNext) {
            
            NSString *recordcountStr;
            
            NSString *strPage = [NSString stringWithFormat:@"%d",[kEventLimit intValue] * currentPage];
            int noOfRecords = (int)objects.count;
            int skipRecords = [strPage intValue];
            if (skipRecords != 0) {
                int lastLimitRecords = skipRecords + noOfRecords;
                skipRecords = skipRecords + 1;
                recordcountStr = [NSString stringWithFormat:@"%d - %d (%d)",skipRecords, lastLimitRecords, eventCount];
                recordLbl.text = recordcountStr;
            }else {
                int lastLimitRecords = skipRecords + noOfRecords;
                skipRecords = skipRecords + 1;
                recordcountStr = [NSString stringWithFormat:@"%d - %d (%d)",skipRecords, lastLimitRecords, eventCount];
                recordLbl.text = recordcountStr;
            }
            
            
        }else {
            NSString *strPage = [NSString stringWithFormat:@"%d",[kEventLimit intValue] * currentPage];
            int skipRecords = [strPage intValue];
            int diffLastRecords = eventCount - skipRecords;
            if (diffLastRecords <= [kEventLimit intValue]) {
                NSString *recordcountStr;
                if (skipRecords == 0 && eventCount == 0) {
                }else {
                    skipRecords = skipRecords + 1;
                }
                
                recordcountStr = [NSString stringWithFormat:@"%d - %d (%d)",skipRecords, eventCount, eventCount];
                recordLbl.text = recordcountStr;
            }
        }
        
        // stop the scrolling of event table.
        [eventTblView setContentOffset:eventTblView.contentOffset animated:NO];
        
        // Reload table view after getting data from quickblox table
        [eventTblView reloadData];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark - Get Course Details City and state
/**
 @Description
 * This method will fetch the golf courses details for city and state.
 * @author Chetu India
 * @param sender << button
 * @return void nothing will return by this method.
 */

-(void)getEventCourseIdBasedOnStateAndCity:(NSString *)state City:(NSString *)city
{
   // create dictionary for golf courses details for city and state.
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject: state forKey:@"State"];
    [getRequest setObject: city forKey:@"City[in]"];
    
    [QBRequest objectsWithClassName:kEventGolfCourse extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        courseDetailsStateCityArr = [[NSMutableArray alloc]init];
        
        [courseDetailsStateCityArr addObjectsFromArray:[objects mutableCopy]];
        cityStateCourseFilter = 1;
        [self getEventRecordsCount];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark - load Initial 25 Records
/**
 @Description
 * This method will fetch first klimit event records from the event table on quickblox and show on event screen.
 * @author Chetu India
 * @param sender << button
 * @return void nothing will return by this method.
 */

-(void)fetchInitialRecordBtnPressed:(id)sender
{
    // load Initial 25 records if current page is not 0
    if (currentPage == kZeroValue) {
        
    }else {
        fetchPrevRecordBtn.hidden = true;
        fecthInitialRecordBtn.hidden = true;
        currentPage = kZeroValue;
        shouldLoadNext = YES;
        [[AppDelegate sharedinstance] showLoader];
        [self getEventRecordsCount];
    }
    
    
}

#pragma mark - load Prev 25 Records
/**
 @Description
 * This method will fetch previous klimit event records from the event table on quickblox and show on event screen.
 * @author Chetu India
 * @param sender PREV button
 * @return void nothing will return by this method.
 */
-(void)fetchPrevRecordBtnPressed:(id)sender
{
    // load previous 25 records if current page is not 0
    if (currentPage > kZeroValue) {
        currentPage--;
        [[AppDelegate sharedinstance] showLoader];
        [self getEventRecordsCount];
        
        if (currentPage == kZeroValue) {
            fetchPrevRecordBtn.hidden = true;
            fecthInitialRecordBtn.hidden = true;
        }
        
    }
}
#pragma mark - load Next 25 Records
/**
 @Description
 * This method will fetch Next klimit event records from the event table on quickblox and show on event screen.
 * @author Chetu India
 * @param sender NEXT button
 * @return void nothing will return by this method.
 */

-(void)fetchNextRecordBtnPressed:(id)sender
{
    // load next 25 records if current page is not 0
    if(shouldLoadNext) {
        currentPage++;
        [[AppDelegate sharedinstance] showLoader];
        [self getEventRecordsCount];
        if (currentPage != kZeroValue) {
            fetchPrevRecordBtn.hidden = false;
            fecthInitialRecordBtn.hidden = false;
        }
    }
}

#pragma mark - SideMenuBtnAction
/**
 @Description
 * This method will toggle left side menu to select other option from the side menu list.
 * @author Chetu India
 * @param sender sideMenu button avilable on navigation bar.
 * @return void nothing will return by this method.
 */
- (IBAction)sideMenuAction:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark - MapScreenSideMenuAction
/**
 @Description
 * This method will redirect the user to map screen that will show the users current loaction and path between users location and event location and also will show the users profle picture in partee icon.
 * @author Chetu India
 * @param sender is map side menu button available on top navigation bar.
 */
- (IBAction)mapSideMenuAction:(id)sender {
    
    // set favInfoMapDirStr to examine wheather user comes to map screen.
    favInfoMapDirStr = @"MAPSIDE";
    [self getEventCourseDetails:@""];
    
}
#pragma mark - SegmentChangedAction
/**
 @Description
 * This method called when user change the segmnent control option from favourite, all, nearme, featured events.
 * @author Chetu India
 * @param segment option available on segment control.
 */
- (IBAction)segmentChangedAction:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    // remove elements from array when segment change. we meed to remove previous segment courses from array and load for new segment.
    [eventTblView setContentOffset:eventTblView.contentOffset animated:NO];
    [arrEventsData removeAllObjects];
    eventOption = (int)selectedSegment;
    shouldLoadNext = NO;
    currentPage = 0;
    fetchPrevRecordBtn.hidden = true;
    fecthInitialRecordBtn.hidden = true;
    viewInfoBase.hidden = true;
    viewBlurInfo.hidden = true;
    [[AppDelegate sharedinstance] showLoader];
    [self getEventRecordsCount];
}
#pragma mark - SearchEventAction
/**
 @Description
 * This will redirect the users to event preferences screen from where user can set the parameters to filter out the events according to their need.
 * @author Chetu India
 * @param search button vailable on right bottom corner.
 * @return void nothing will return by this method.
 */
- (IBAction)searchBottomBtnAction:(id)sender {
    
    EventPreferncesViewController *obj = [[EventPreferncesViewController alloc] initWithNibName:kEventPrefVc bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark- Favourite button tapped
/**
 @Description
 * This method will show the grid menu popup having favourite, info, direction, map options.
 * @author Chetu India
 * @param btnFav this three dot button available on each events displaying on screen.
 * @return void nothing will return by this method.
 */
-(void)btnFavTapped:(UIButton *)sender
{
    CGPoint center= sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:eventTblView];
    NSIndexPath *indexPath = [eventTblView indexPathForRowAtPoint:rootViewPoint];
    selectedRow = indexPath.row;
    
    int rowno = (int)selectedRow;
    rowno = rowno + 1;
    int val = rowno  % kAdvertisementEventNo;
    if (val == kRemainderValAdvEvent) {
        [self showAdvertPopup];
    }else {
        
        int totalAdvEventsCount = (int)selectedRow;
        totalAdvEventsCount = totalAdvEventsCount / kAdvertisementEventNo;
        int totalEventRecords = (int)indexPath.row - totalAdvEventsCount;
        
        selectedRow = totalEventRecords;
        QBCOCustomObject *obj  = [arrEventsData objectAtIndex:totalEventRecords];
        
        sharedobj = obj;
        
        NSMutableArray *arr = [[obj.fields objectForKey:kEventFavID] mutableCopy];
        
        if(!arr || arr.count==0)
            arr = [[NSMutableArray alloc] init];
        
        NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
        
        if([arr containsObject:strCurrentUserID]) {
            // it is fav
            isFavEvent=YES;
        }
        else {
            isFavEvent=NO;
        }
        
        [self showGrid];
    }
    
    
}

#pragma mark- showAdvertPopup
/**
 @Description
 * This method will show advertisement popup having information about advertisement event.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
- (void)showAdvertPopup {
    
    int rowno = (int)selectedRow;
    rowno = rowno + 1;
    int selectedAdEventIndex = rowno  / kAdvertisementEventNo;
    selectedAdEventIndex = selectedAdEventIndex - 1;
    int maxAdEventPage = [kEventLimit intValue];
    maxAdEventPage  = maxAdEventPage / (kAdvertisementEventNo - 1);
    maxAdEventPage = currentPage * maxAdEventPage + selectedAdEventIndex;
    
    objAdvEvent = [arrAdEventsDetails objectAtIndex:maxAdEventPage];
    NSString *eventTitleStr = [[AppDelegate sharedinstance] nullcheck:[objAdvEvent.fields objectForKey:kEventAdvTitle]];
    lblAdvTitle.text = eventTitleStr;
    [lblAdvTitle setAdjustsFontSizeToFitWidth:YES];
    NSString *eventDescStr = [[AppDelegate sharedinstance] nullcheck:[objAdvEvent.fields objectForKey:kEventAdDesc]];
    txtViewAdvdesc.text = eventDescStr;
    CGFloat heightDescTextview  =  [CommonMethods heightForText:eventDescStr withFont:[UIFont systemFontOfSize:17] andWidth:txtViewAdvdesc.frame.size.width];
    viewBlurInfo.hidden = false;
    viewAdvertiseInfoPopup.hidden = false;
    viewInfoBase.hidden = true;
    txtViewAdvdesc.editable = false;
    if (heightDescTextview >= 300) {
        heightDescTextview = 300;
    }
    txtViewAdvdesc.scrollEnabled = true;
    
    CGFloat totalHeight = heightDescTextview + 210;
    if (totalHeight > self.view.frame.size.height - 130 - 20 - 20) {
        constraintHeightTxtViewAdvDesc.constant = self.view.frame.size.height - 130 - 20 - 20;
    }else {
       constraintHeightTxtViewAdvDesc.constant = heightDescTextview + 210;
    }
   
    
}
#pragma mark- showGrid
/**
 @Description
 * This method will show balck popup having faourite, direction, info, map option when user will tap on three dot popup.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
- (void)showGrid {
    NSInteger numberOfOptions = 4;
    NSArray *items;
    
    //  Chnage the title of favorite button
    NSString *favoriteTitle = isFavEvent==YES ? kEventMarkUnFav : kEventMarkFav;
    
    //  NSString *favoriteTitle = @"Your favorite";
    NSString *favImgStr = kEmptyStr;
    if ([favoriteTitle isEqualToString: kEventMarkUnFav]) {
        favImgStr = kEventFavImg;
    }else {
        favImgStr = kEventUnFavImg;
    }
    
    items= @[
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:favImgStr] title:kEventFavTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kEventInfoFilledImg] title:kEventInfoTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kEventMapImg] title:kEventMapTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kEventDirImg] title:kEventDir]
             ];
    
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.bounces = YES;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}
#pragma mark- Btn Adv Website Action
/**
 @Description
 * This method will redirect the user to website linked to str
 * @author Chetu India
 */
- (IBAction)btnWebsiteAdvAction:(id)sender {
    NSString *eventAdvWebsite = [[AppDelegate sharedinstance] nullcheck:[objAdvEvent.fields objectForKey:kEventAdWebSite]];
    [self redirectToWebSite:eventAdvWebsite];
}
#pragma mark- Open Website Url
/**
 @Description
 * This method will redirect the user to website linked to str
 * @param str url to be redirected
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)redirectToWebSite:(NSString *)str
{
    if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
        
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[NSURL URLWithString: str] options:@{} completionHandler:nil];
        viewBlurInfo.hidden = true;
        viewAdvertiseInfoPopup.hidden = true;
        viewInfoBase.hidden = true;
    }else {
        viewInfoBase.hidden = true;
        viewAdvertiseInfoPopup.hidden = true;
        viewBlurInfo.hidden = true;
    }
}

#pragma mark- Btn Close Adv Action

- (IBAction)btnCloseAdvAction:(id)sender {
    viewBlurInfo.hidden = true;
    viewAdvertiseInfoPopup.hidden = true;
    viewInfoBase.hidden = true;
}

#pragma mark- grid Delegate
/**
 @Description
 * This is the delagate method of grid menu it will called when user select any options from grid popup.
 * @author Chetu India
 * @param gridMenu
 * @param item option selected from the grid.
 * @param itemIndex is the number to identify which options user seelcted from the grid,
 * @return void nothing will return by this method.
 */
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSLog(@"Dismissed with item %ld: %@", (long)itemIndex, item.title);
    
    switch(itemIndex)
    {
        case kIndexFav:
            [self actionFav];
            break;
        case kIndexInfo:
            [self actionInfo];
            break;
        case kIndexMap:
            [self actionMap];
            break;
        case kIndexDirection:
            [self actionDirectionTapped];
            break;
        case kIndexPhoto:
            //    [self actionPhoto];
            break;
    }
}
#pragma mark- Map Btn Popup
/**
 @Description
 * This method will fetch event details for the event that was selected by the user from poopup and redirect the user to map screen.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void) actionMap {
    
    favInfoMapDirStr = @"MAP";
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedRow];
    NSString *eventCourseId = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventCourseId]];
    [self getEventCourseDetails:eventCourseId];
    
}
#pragma mark- Diretion Btn Popup
/**
 @Description
 * This method will fetch event details for the event that was selected by the user from poopup and redirect the user to map screen.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void ) actionDirectionTapped {
    
    favInfoMapDirStr = @"DIR";
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedRow];
    NSString *eventCourseId = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventCourseId]];
    [self getEventCourseDetails:eventCourseId];
    
}

/**
 @Description
 * This method will fetch event details for the event that was selected by the user from poopup and redirect the user to map screen.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)directionAction
{
    NSArray *arrCoord = [objEventGolfCourse.fields objectForKey:kEventCord];
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    CLLocationCoordinate2D placeCoord;
    //Set the lat and long.
    placeCoord.latitude=[strlat doubleValue];
    placeCoord.longitude=[strlong doubleValue];
    
    CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
    scrplaceCoord = myposition;
    
    if([arrCoord count]>0) {
        strlat = [arrCoord objectAtIndex:1];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [arrCoord objectAtIndex:0];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        desplaceCoord = placeCoord;
        
    }
    
    
    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", scrplaceCoord.latitude, scrplaceCoord.longitude, desplaceCoord.latitude, desplaceCoord.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString] options:[[NSDictionary alloc] init] completionHandler:nil];
}
#pragma mark- Get Event Details
/**
 @Description
 * This will fetch the details of event based on golf course ID.
 * @author Chetu India
 * @param eventCourseId is the course id of which details need to fetch from quickblox table.
 * @return void nothing will return by this method.
 */
-(void)getEventCourseDetails:(NSString *)eventCourseId {
    
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"0" forKey:kEventSkipParam];
    if ([favInfoMapDirStr isEqualToString:@"MAPSIDE"]) {
        
        NSString *allEventsCourseId = kEmptyStr;
        
        for (QBCOCustomObject *obj in arrEventsData) {
            NSString *strDesc = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventCourseId]];
            if ([allEventsCourseId isEqualToString:kEmptyStr]) {
                allEventsCourseId = strDesc;
            }else {
                allEventsCourseId = [NSString stringWithFormat:@"%@,%@",strDesc,allEventsCourseId];
            }
            
        }
        int totalEvents = (int)[arrEventsData count];
        NSString *totalEventsCount = [NSString stringWithFormat:@"%d", totalEvents];
        [getRequest setObject:totalEventsCount forKey:kEventLimitParam];
        [getRequest setObject:allEventsCourseId forKey:kEventIdIn];
    }else {
        
        [getRequest setObject:kEventOneStr forKey:kEventLimitParam];
        [getRequest setObject:eventCourseId forKey:kEventID];
    }
    
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:kEventGolfCourse extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        if ( [favInfoMapDirStr isEqualToString:@"INFO"]) {
            objEventGolfCourse = [objects objectAtIndex:0];
            favInfoMapDirStr= kEmptyStr;
            NSString *addStr = [[AppDelegate sharedinstance] nullcheck:[objEventGolfCourse.fields objectForKey:kEventAddParam]];
            lblAddressEventInfo.text = addStr;
        }else if ([favInfoMapDirStr isEqualToString:@"MAP"]) {
            objEventGolfCourse = [objects objectAtIndex:0];
            favInfoMapDirStr= kEmptyStr;
            MapViewController *mapVC = [[MapViewController alloc] initWithNibName:kEventMapVc bundle:nil];
            mapVC.dictCourseMapData = objEventGolfCourse;
            mapVC.strFromScreen = @"2";
            [self.navigationController pushViewController:mapVC animated:YES];
            
        }else if ([favInfoMapDirStr isEqualToString:@"DIR"]){
            objEventGolfCourse = [objects objectAtIndex:0];
            favInfoMapDirStr= kEmptyStr;
            [self directionAction];
        }else if ([favInfoMapDirStr isEqualToString:@"MAPSIDE"]) {
            
            NSMutableArray *allEventCourseEvents = [[NSMutableArray alloc]init];
            [allEventCourseEvents addObjectsFromArray:[objects mutableCopy]];
            if([allEventCourseEvents count]==0) {
                
                [[AppDelegate sharedinstance] displayMessage:kEventNoCourseAv];
                return;
            }
            
            MapViewController *obj = [[MapViewController alloc] initWithNibName:kEventMapVc bundle:nil];
            obj.arrCourseData = allEventCourseEvents;
            obj.strFromScreen = kEventOneStr;
            [self.navigationController pushViewController:obj animated:YES];
            
            
        }
        
        
        [[AppDelegate sharedinstance] hideLoader];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark- Info Btn Popup
/**
 @Description
 * This method set the data on information popup and also fetch details from golfCourses table based on course id which is using as refernce key for event table on quickblox.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void) actionInfo {
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedRow];
    
    
    NSString *strDesc = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventDescParam]];
    NSString *strEventTitle = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventTitleParam]];
    NSString *strStartDate = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventStartDate]];
    NSString *eventCourseId = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventCourseId]];
    NSString *strDate = [CommonMethods convertDateToAnotherFormat:strStartDate originalFormat:kEventDateFormatOriginal finalFormat:kEventDateFormatFinal];
    NSString *endDate = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventEndDateParam]];
    NSString *strEndDate = [CommonMethods convertDateToAnotherFormat:endDate originalFormat:kEventDateFormatOriginal finalFormat:kEventDateFormatFinal];
    NSString *strDateEvent = [NSString stringWithFormat:@"%@ To %@",strDate,strEndDate];
    
    if([strDesc length]>0) {
        
        [lblEventTitleInfo setAdjustsFontSizeToFitWidth:true];
        lblEventTitleInfo.text = strEventTitle;
        lblStartEndDateInfo.text = strDateEvent;
        viewBlurInfo.hidden = false;
        viewInfoBase.hidden = false;
        viewAdvertiseInfoPopup.hidden = true;
        textViewEventDescInfo.text = strDesc;
        CGFloat heightDescTextview  =  [CommonMethods heightForText:strDesc withFont:[UIFont systemFontOfSize:16] andWidth:textViewEventDescInfo.frame.size.width];
        textViewEventDescInfo.scrollEnabled = true;
        textViewEventDescInfo.editable = false;
        if (heightDescTextview >= 300) {
            heightDescTextview = 300;
        }
        CGFloat totalHeight = heightDescTextview + 327;
        if (totalHeight > self.view.frame.size.height - 130 - 20 - 20) {
            constraintsInfoBaseViewHeight.constant = self.view.frame.size.height - 130 - 20 - 20;
        }else {
            constraintsInfoBaseViewHeight.constant = heightDescTextview + 327;
        }
       
    }
    else {
        [[AppDelegate sharedinstance] displayMessage:kEventNoInfoAvailTitle];
    }
    
    favInfoMapDirStr = @"INFO";
    [self getEventCourseDetails:eventCourseId];
    
}
#pragma mark- Fav Btn Action
/**
 @Description
 * This method will make the event as users favourite and reload the tableview as well.
 * @author Chetu India
 * @return void nothing will return by this method.
 */

-(void) actionFav {
    
    
    int totalAdvEventsCount = (int)selectedRow;
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:totalAdvEventsCount];
    NSMutableArray *eventFavUsersArr = [[obj.fields objectForKey:kEventFavID] mutableCopy];
    
    if(!eventFavUsersArr || eventFavUsersArr.count==0)
        eventFavUsersArr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    NSString *createNotificationStr = @"";
    // It will find event to be favourite or unfavourite yes if user tries to make event as favourite and No if user wants to make it unfavourite.
    if([eventFavUsersArr containsObject:strCurrentUserID]) {
        // already fav, so unfav
        createNotificationStr = @"NO";
        [eventFavUsersArr removeObject:strCurrentUserID];
    }
    else {
          createNotificationStr = @"YES";
        [eventFavUsersArr addObject:strCurrentUserID];
        
    }
    
    if(!eventFavUsersArr || eventFavUsersArr.count==0) {
        [obj.fields setObject:eventFavUsersArr forKey:kEventFavID];
        
    }
    else {
        [obj.fields setObject:eventFavUsersArr forKey:kEventFavID];
        
    }
    
    [[AppDelegate sharedinstance] showLoader];


    [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        
        [arrEventsData replaceObjectAtIndex:totalAdvEventsCount withObject:obj];
        [eventTblView setContentOffset:eventTblView.contentOffset animated:NO];
        [eventTblView reloadData];
        [[AppDelegate sharedinstance] hideLoader];
        
        if ([createNotificationStr isEqualToString:@"YES"]) {
            [self createLocalNotifEvent:totalAdvEventsCount];
        }else if ([createNotificationStr isEqualToString:@"NO"]) {
      
            [self deleteLocalNotification:totalAdvEventsCount];
        }
        
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
    
    
}
#pragma mark- Contact Info Action
/**
 @Description
 * This Method will create the local notification on device so that user able to recieve
 * @author Chetu India
 * @return IBAction nothing will return by this method.
 */
-(void)createLocalNotifEvent:(int)selectedEventIndex
{
    [[UNUserNotificationCenter currentNotificationCenter] setDelegate:self];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    
    // Request using shared Notification Center
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (granted) {
                                  NSLog(@"Notification Granted");
                              }
                          }];
    
    // Notification authorization settings
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
        if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
            NSLog(@"Notification allowed");
        }
    }];

    
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    content.title = @"Event Notification";
    content.body = @"Event Local Recieved";
    content.sound = [UNNotificationSound defaultSound];
  
    
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedEventIndex];
        NSString *eventStartDate = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:kEventStartDate]];
        NSDate *notificationEventDate = [CommonMethods intervalBwDatesInSec:eventStartDate];
    NSString *eventIdStr = [NSString stringWithFormat:@"%@", obj.ID];
    // Trigger with date
    NSDateComponents *triggerDate = [[NSCalendar currentCalendar]
                                     components:NSCalendarUnitYear +
                                     NSCalendarUnitMonth + NSCalendarUnitDay +
                                     NSCalendarUnitHour + NSCalendarUnitMinute +
                                     NSCalendarUnitSecond fromDate:notificationEventDate];
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:triggerDate repeats:NO];
    
    
    // Scheduling the notification
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:eventIdStr content:content trigger:trigger];
    
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error != nil) {
            NSLog(@"Something went wrong: %@",error);
        }
    }];
    
}
#pragma mark- Contact Info Action
/**
 @Description
 * This Method will delete the local notification on device based on identifier.
 * @author Chetu India
 * @return IBAction nothing will return by this method.
 */
-(void)deleteLocalNotification:(int)selectedEventIndex
{
    
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedEventIndex];
    NSString *eventIdStr = [NSString stringWithFormat:@"%@", obj.ID];
    [[UNUserNotificationCenter currentNotificationCenter]getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
        if (requests.count>0) {

           
            for (UNNotificationRequest *pendingRequest  in requests) {
                if ([pendingRequest.identifier isEqualToString:eventIdStr]) {
                    [[UNUserNotificationCenter currentNotificationCenter]removePendingNotificationRequestsWithIdentifiers:@[pendingRequest.identifier]];
                }
            }
          
        }
        
    }];
}

#pragma mark- Contact Info Action
/**
 @Description
 * This Method will open the dialer if contact is number or if it is valid mail then it will open mailcomposer.
 * @author Chetu India
 * @return IBAction nothing will return by this method.
 */
- (IBAction)btnInfoContactAction:(id)sender {
    
    NSString *contactStr = [[AppDelegate sharedinstance] nullcheck:[objEventGolfCourse.fields objectForKey:kEventContact]];
    BOOL validateEmail = [CommonMethods validateEmailWithString:contactStr];
    if (validateEmail) {
        [self sendEmail:contactStr];
    }else{
        UIApplication *application = [UIApplication sharedApplication];
        [application openURL:[NSURL URLWithString: [NSString stringWithFormat:@"tel:%@",contactStr]] options:@{} completionHandler:nil];
    }
    
}

#pragma mark - Create Record Base View
/**
 @Description
 * Create next prev << baseView prograrmmatically
 * @author Chetu India
 * @return void nothing will return by this method.
 */

-(void)createRecordBaseView {

    // get device size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    // create baseview for previous, next and lable
    UIView *loadRecordBaseView = [[UIView alloc]initWithFrame:CGRectMake((screenWidth - 250 )/2, kZeroValue, 250, nextPrevRecordBaseView.frame.size.height)];
    loadRecordBaseView.backgroundColor = [UIColor clearColor];
    [nextPrevRecordBaseView addSubview:loadRecordBaseView];
    
    // create previous button
    fetchPrevRecordBtn = [[UIButton alloc]initWithFrame:CGRectMake(kZeroValue, kZeroValue, 50, loadRecordBaseView.frame.size.height)];
    [fetchPrevRecordBtn setTitle:kFetchPreviousRecordBtnTitle forState:UIControlStateNormal];
    fetchPrevRecordBtn.titleLabel.font = [UIFont fontWithName:kFontNameHelveticaNeue size:25];
    fetchPrevRecordBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fetchPrevRecordBtn addTarget:self action:@selector(fetchPrevRecordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [loadRecordBaseView addSubview:fetchPrevRecordBtn];
    
    // create record label
    recordLbl = [[UILabel alloc]initWithFrame:CGRectMake(fetchPrevRecordBtn.frame.size.width + fetchPrevRecordBtn.frame.origin.x, kZeroValue, 150,loadRecordBaseView.frame.size.height)];
    recordLbl.adjustsFontSizeToFitWidth = YES;
    recordLbl.textAlignment = NSTextAlignmentCenter;
    recordLbl.font = [UIFont fontWithName:kFontNameHelveticaNeue size:17];
    recordLbl.textColor = [UIColor whiteColor];
    [loadRecordBaseView addSubview:recordLbl];
    
    // create next button to fetch next 25 records of courses
    fetchNextRecordBtn = [[UIButton alloc]initWithFrame:CGRectMake(recordLbl.frame.size.width + recordLbl.frame.origin.x, 0, 50, loadRecordBaseView.frame.size.height)];
    [fetchNextRecordBtn setTitle:kFetchNextRecordBtnTitle forState:UIControlStateNormal];
    [fetchNextRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    fetchNextRecordBtn.titleLabel.font = [UIFont fontWithName:kFontNameHelveticaNeue size:25];
    fetchNextRecordBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [fetchNextRecordBtn addTarget:self action:@selector(fetchNextRecordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [loadRecordBaseView addSubview:fetchNextRecordBtn];
    
    nextPrevRecordBaseView.backgroundColor = [UIColor colorWithRed:0.000 green:0.655 blue:0.176 alpha:1.00];
    
    // create previous button
    fecthInitialRecordBtn = [[UIButton alloc]initWithFrame:CGRectMake(kZeroValue, kZeroValue, loadRecordBaseView.frame.origin.x, loadRecordBaseView.frame.size.height)];
    [fecthInitialRecordBtn setTitle:kFetchInitialRecordBtnTitle forState:UIControlStateNormal];
    fecthInitialRecordBtn.titleLabel.font = [UIFont fontWithName:kFontNameHelveticaNeue size:25];
    fecthInitialRecordBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fecthInitialRecordBtn addTarget:self action:@selector(fetchInitialRecordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [nextPrevRecordBaseView addSubview:fecthInitialRecordBtn];
    
    fetchPrevRecordBtn.hidden = true;
    fecthInitialRecordBtn.hidden = true;
}

/**
 @Description
 * This method open the mail composer if user devices is compatable for mail.
 * @author Chetu India
 * @param emailStr string to which mail will send from the user.
 * @return void nothing will return by this method.
 */
-(void)sendEmail:(NSString *)emailStr {
    // From within your active view controller
    if([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailCont = [[MFMailComposeViewController alloc] init];
        mailCont.mailComposeDelegate = self;        // Required to invoke mailComposeController when send
        
        [mailCont setSubject:@"Email subject"];
        [mailCont setToRecipients:[NSArray arrayWithObject:emailStr]];
        [mailCont setMessageBody:@"Email message" isHTML:NO];
        
        [self presentViewController:mailCont animated:YES completion:nil];
    }
}
/**
 @Description
 * Delegate method of mail composer. called while ser tap on cancel, send, dicard mail button.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    viewInfoBase.hidden = true;
    viewBlurInfo.hidden = true;
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark- Website Info Action
/**
 @Description
 * This will redirect the user to course website from where he can find the more details about course.
 * @return IBAction nothing will return by this method.
 */
- (IBAction)btnWebsiteInfoAction:(id)sender {
    
    NSString *websiteStr = [[AppDelegate sharedinstance] nullcheck:[objEventGolfCourse.fields objectForKey:kEventWebsiteParam]];
    websiteStr = [NSString stringWithFormat:@"http://%@",websiteStr];
    [self redirectToWebSite:websiteStr];
    
}
#pragma mark- Close Info Action
/**
 @Description
 * This will hide the information popup shown.
 * @author Chetu India
 * @return IBAction nothing will return by this method.
 */
- (IBAction)btnCloseInfoAction:(id)sender {
    
    viewBlurInfo.hidden = true;
    viewInfoBase.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Table view DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kEventNoSectionTbl;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kEventCellSize;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Getting total number of records to be shown in the event tableview after adding total events available in quickbloax table and number of advertisement event that will be every fith event
    
    NSInteger totalNoOfRows = kZeroValue;
    int requiredAdEvents = eventCount / (kAdvertisementEventNo - 1);
    if (totalAdvertEventCount >= requiredAdEvents) {
        int totalAdvEventsCount = (int)arrEventsData.count;
        totalAdvEventsCount = totalAdvEventsCount / (kAdvertisementEventNo - 1);
        int totalEventRecords = (int)totalAdvEventsCount + (int)arrEventsData.count;
        adEventUsedInPage = (int)totalAdvEventsCount;
        NSInteger totalEventRecordsCount = (NSInteger) totalEventRecords;
        
        totalNoOfRows =  totalEventRecordsCount;
    }else {
        
        int limitEvent = [kEventLimit intValue];
        int maxAdEventPerPage = limitEvent;
        maxAdEventPerPage  = maxAdEventPerPage / (kAdvertisementEventNo - 1);
        int usedAdEvent = maxAdEventPerPage * currentPage;
        
        int remaingAdEventToShow = totalAdvertEventCount - usedAdEvent;
        
        if (remaingAdEventToShow == kZeroValue) {
            totalNoOfRows = (int)arrEventsData.count;
            adEventUsedInPage = kZeroValue;
        }else if (remaingAdEventToShow < kZeroValue) {
            totalNoOfRows = (int)arrEventsData.count;
            adEventUsedInPage = kZeroValue;
        }else {
            
            if (maxAdEventPerPage <= remaingAdEventToShow ) {
                totalNoOfRows = (int)arrEventsData.count +  maxAdEventPerPage;
                adEventUsedInPage = maxAdEventPerPage;
            }else {
                totalNoOfRows = (int)arrEventsData.count +  remaingAdEventToShow;
                adEventUsedInPage = remaingAdEventToShow;
            }
        }
    }
    return totalNoOfRows;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventCellName];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kEventCellName owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:kZeroValue];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // find the indexpath for advertisement event that shows in table
    int rowno = (int)indexPath.row;
    rowno = rowno + 1;
    int remainder = rowno  % kAdvertisementEventNo;
    int requiredAdEvents = eventCount / (kAdvertisementEventNo - 1);
    if (totalAdvertEventCount >= requiredAdEvents) {
        
    }else {
        int totalAdvEventsCount = (int)indexPath.row;
        int limitEvent = [kEventLimit intValue];
        int maxAdEventPage = limitEvent;
        maxAdEventPage  = maxAdEventPage / (kAdvertisementEventNo - 1);
        totalAdvEventsCount = currentPage * (maxAdEventPage + limitEvent) + totalAdvEventsCount;
        int maxEvent = totalAdvertEventCount * (kAdvertisementEventNo - 1);
        maxEvent = maxEvent + (kAdvertisementEventNo - 2);
        int totalAdEventPlusMaxEvent = maxEvent + totalAdvertEventCount;
        if (totalAdvEventsCount > totalAdEventPlusMaxEvent) {
            remainder = 6;
        }
    }
    // Condition for advertisement cell
    if (remainder == kRemainderValAdvEvent) {

        // get the index of the advertisement events
        int totalAdvEventsCount = (int)indexPath.row;
        totalAdvEventsCount = totalAdvEventsCount + 1;
        totalAdvEventsCount = totalAdvEventsCount / kAdvertisementEventNo;
        totalAdvEventsCount = totalAdvEventsCount - 1;
        int maxAdEventPage = [kEventLimit intValue];
        maxAdEventPage  = maxAdEventPage / (kAdvertisementEventNo - 1);
        maxAdEventPage = currentPage * maxAdEventPage + totalAdvEventsCount;
        QBCOCustomObject *obj = [arrAdEventsDetails objectAtIndex:maxAdEventPage];
        // Set Data from obj in tableview cell
        [cell setAdEventDataFromQbObj:obj];
        [cell.BtnFav addTarget:self action:@selector(btnFavTapped:) forControlEvents:UIControlEventTouchUpInside];
    }else {
        
        if (remainder == 6) {
          int indexValue = (int)indexPath.row;
            indexValue = indexValue - adEventUsedInPage;
            QBCOCustomObject *obj = [arrEventsData objectAtIndex:indexValue];
            // Set Data from obj in tableview cell
            [cell setEventDataFromQbObj:obj];
            [cell.BtnFav addTarget:self action:@selector(btnFavTapped:) forControlEvents:UIControlEventTouchUpInside];
        }else {
            int totalAdvEventsCount = (int)indexPath.row;
            totalAdvEventsCount = totalAdvEventsCount / (kAdvertisementEventNo);
            int totalEventRecords = (int)indexPath.row - totalAdvEventsCount;
            QBCOCustomObject *obj = [arrEventsData objectAtIndex:totalEventRecords];
            // Set Data from obj in tableview cell
            [cell setEventDataFromQbObj:obj];
            [cell.BtnFav addTarget:self action:@selector(btnFavTapped:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    }
    
    return cell;
    
}

#pragma mark - Table view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
