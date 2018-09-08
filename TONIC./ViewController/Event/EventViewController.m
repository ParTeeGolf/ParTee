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
#define kLimit @"25"

@interface EventViewController ()<RNGridMenuDelegate, MFMailComposeViewControllerDelegate>
{
    int currentPage;
    NSInteger selectedRow;
    QBCOCustomObject *sharedobj;
    BOOL isFavCourse;
    int courseOption;
    QBCOCustomObject *objEventGolfCourse;
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    NSString *strlat;
    NSString *strlong;
    NSString *favInfoMapDirStr;
    BOOL shouldLoadNext;
    int eventCount;
    
}
// This array contain events details fetched from the quickblox table.
@property (nonatomic, strong) NSMutableArray *arrEventsData;
@property (strong, nonatomic) UIButton *fetchPrevRecordBtn;
@property (strong, nonatomic) UILabel  *recordLbl;
@property (strong, nonatomic) UIButton *fetchNextRecordBtn;
@property (strong, nonatomic) UIButton *fecthInitialRecordBtn;
@end

@implementation EventViewController
@synthesize arrEventsData;
@synthesize lblNothingFound;
@synthesize eventTblView;
@synthesize fetchPrevRecordBtn;
@synthesize recordLbl;
@synthesize fetchNextRecordBtn;
@synthesize fecthInitialRecordBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    favInfoMapDirStr = @"";
    // courseOption set selected segment to all events
    courseOption = 3;
    _segmentControl.selectedSegmentIndex = 3;
    
    // Initialize eventDetails Array
    arrEventsData = [[NSMutableArray alloc]init];
    
    // Set current page to 0 which will show inital klimit records from the event table
    currentPage = 0;
    
    //    self.eventTblView.hidden = true;
    self.lblNothingFound.hidden = true;
    
    // hide nextPrevBaseView
    viewNextPrevHeightConstraints.constant = 30;
    _nextPrevRecordBaseView.hidden = false;
    eventTblView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self createRecordBaseView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    
    // Call getEventDetails method to fetch event details
    viewBlurInfo.hidden = true;
    viewInfoBase.hidden = true;
    currentPage=0;
    courseOption = 3;
    _segmentControl.selectedSegmentIndex = courseOption;
    shouldLoadNext = YES;
    fetchPrevRecordBtn.hidden = true;
    fecthInitialRecordBtn.hidden = true;
    [self getEventRecordsCount];
}


#pragma mark - Create Record Base View
// Create Record baseView prograrmmatically
-(void)createRecordBaseView {
    
    // get device size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    
    // create baseview for previous, next and lable
    UIView *loadRecordBaseView = [[UIView alloc]initWithFrame:CGRectMake((screenWidth - 250 )/2, 0, 250, _nextPrevRecordBaseView.frame.size.height)];
    loadRecordBaseView.backgroundColor = [UIColor clearColor];
    [_nextPrevRecordBaseView addSubview:loadRecordBaseView];
    
    // create previous button
    fetchPrevRecordBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 50, loadRecordBaseView.frame.size.height)];
    [fetchPrevRecordBtn setTitle:kFetchPreviousRecordBtnTitle forState:UIControlStateNormal];
    fetchPrevRecordBtn.titleLabel.font = [UIFont fontWithName:kFontNameHelveticaNeue size:25];
    //   [fetchPrevRecordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    fetchPrevRecordBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fetchPrevRecordBtn addTarget:self action:@selector(fetchPrevRecordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [loadRecordBaseView addSubview:fetchPrevRecordBtn];
    
    // create record label
    recordLbl = [[UILabel alloc]initWithFrame:CGRectMake(fetchPrevRecordBtn.frame.size.width + fetchPrevRecordBtn.frame.origin.x, 0, 150,loadRecordBaseView.frame.size.height)];
    //    recordLbl.text = @"1 - 25";
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
    
    _nextPrevRecordBaseView.backgroundColor = [UIColor colorWithRed:0.000 green:0.655 blue:0.176 alpha:1.00];
    
    // create previous button
    fecthInitialRecordBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, loadRecordBaseView.frame.origin.x, loadRecordBaseView.frame.size.height)];
    [fecthInitialRecordBtn setTitle:kFetchInitialRecordBtnTitle forState:UIControlStateNormal];
    fecthInitialRecordBtn.titleLabel.font = [UIFont fontWithName:kFontNameHelveticaNeue size:25];
    //   [fecthInitialRecordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    fecthInitialRecordBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [fecthInitialRecordBtn addTarget:self action:@selector(fetchInitialRecordBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_nextPrevRecordBaseView addSubview:fecthInitialRecordBtn];
    
    fetchPrevRecordBtn.hidden = true;
    fecthInitialRecordBtn.hidden = true;
}
#pragma mark - load Initial 25 Records
// Load Initial 25 records

-(void)fetchInitialRecordBtnPressed:(id)sender
{
    // load Initial 25 records if current page is not 0
    
    if (currentPage == 0) {
        
    }else {
        //         [fetchPrevRecordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        //         [fecthInitialRecordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        fetchPrevRecordBtn.hidden = true;
        fecthInitialRecordBtn.hidden = true;
        currentPage=0;
        shouldLoadNext = YES;
        [self getEventRecordsCount];
    }
    
    
}

#pragma mark - load Prev 25 Records
// Load previous 25 records

-(void)fetchPrevRecordBtnPressed:(id)sender
{
    // load previous 25 records if current page is not 0
    if (currentPage > 0) {
        currentPage--;
        [self getEventRecordsCount];
        
        if (currentPage == 0) {
            //            [fetchPrevRecordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            //            [fecthInitialRecordBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            fetchPrevRecordBtn.hidden = true;
            fecthInitialRecordBtn.hidden = true;
        }
        
    }
}
#pragma mark - load Next 25 Records
// Load Next 25 records

-(void)fetchNextRecordBtnPressed:(id)sender
{
    // load next 25 records if current page is not 0
    if(shouldLoadNext) {
        currentPage++;
        
        [self getEventRecordsCount];
        
        if (currentPage != 0) {
            //            [fetchPrevRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            //            [fecthInitialRecordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            fetchPrevRecordBtn.hidden = false;
            fecthInitialRecordBtn.hidden = false;
        }
    }
}

-(void)getEventRecordsCount
{
    
     [[AppDelegate sharedinstance] showLoader];
    
    NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
    [getRequestObjectCount setObject:kLimit forKey:kEventLimitParam];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPage];
    
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
    
    NSString *strFilterDistance;
    
    switch(courseOption)
    {
        case 0:
            [getRequestObjectCount setObject: @"true" forKey:@"featured"];
            [getRequestObjectCount setObject: @"order" forKey:@"sort_asc"];
            break;
        case 1:
            strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],10.6f];
            [getRequestObjectCount setObject:strFilterDistance forKey:@"coordinates[near]"];
            break;
        case 2:
            [getRequestObjectCount setObject: strCurrentUserID forKey:@"userFavID[in]"];
            break;
        case 3:
            break;
            
    }
    
     [getRequestObjectCount setObject:@"1" forKey:@"count"];
    
[QBRequest countObjectsWithClassName:kEventTblName extendedRequest:getRequestObjectCount successBlock:^(QBResponse * _Nonnull response, NSUInteger count) {
    
    NSLog(@"%lu",(unsigned long)count);
    eventCount = (int)count;
    NSString *recordcountStr;
    
    if (shouldLoadNext) {
        
    }else {
        if (eventCount == 0) {
            recordcountStr = [NSString stringWithFormat:@"0 - 0 (%d)", eventCount];
        }else if (eventCount < 25) {
            recordcountStr = [NSString stringWithFormat:@"1 - %d (%d)", eventCount, eventCount];
        }else {
            recordcountStr = [NSString stringWithFormat:@"1 - %@ (%d)", kLimit, eventCount];
        }
        
        recordLbl.text = recordcountStr;
    }
        [self getEventDetails];
    
} errorBlock:^(QBResponse *response) {
    [[AppDelegate sharedinstance] hideLoader];
    
    NSLog(@"Response error: %@", [response.error description]);
}];

}
#pragma mark- Get Event Details
/*
 @Description:  It will fetch first klimit records from Event table and also add the details to eventTableArray
 */
-(void) getEventDetails
{
  //  [[AppDelegate sharedinstance] showLoader];
    
    // Create dictionary for parameters to filter out the records from Course Events table on quickblox
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:kLimit forKey:kEventLimitParam];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPage];
    
    [getRequest setObject:strPage forKey:kEventSkipParam];
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    NSString *strlat1 = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat1 = [[AppDelegate sharedinstance] nullcheck:strlat1];
    
    NSString *strlong1 = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong1 = [[AppDelegate sharedinstance] nullcheck:strlong1];
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    NSString *strFilterDistance;
    
    switch(courseOption)
    {
        case 0:
            [getRequest setObject: @"true" forKey:@"featured"];
            [getRequest setObject: @"order" forKey:@"sort_asc"];
            break;
        case 1:
            strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],10.6f];
            [getRequest setObject:strFilterDistance forKey:@"coordinates[near]"];
            break;
        case 2:
            [getRequest setObject: strCurrentUserID forKey:@"userFavID[in]"];
            break;
        case 3:
            break;
            
    }
    
    [QBRequest objectsWithClassName:kEventTblName extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        [[AppDelegate sharedinstance] hideLoader];
        arrEventsData = [[NSMutableArray alloc]init];
        
        [arrEventsData addObjectsFromArray:[objects mutableCopy]];
        
        if([arrEventsData count]==0) {
            [lblNothingFound setHidden:NO];
            [eventTblView setHidden:YES];
        }
        else {
            [lblNothingFound setHidden:YES];
            [eventTblView setHidden:NO];
            
        }
          NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPage];
        int totalFetchedEvents = [strPage intValue];
        totalFetchedEvents = totalFetchedEvents + (int)[objects count];
        
        if (totalFetchedEvents < eventCount) {
            shouldLoadNext = YES;
            fetchNextRecordBtn.hidden = false;
        }else{
            shouldLoadNext=NO;
            fetchNextRecordBtn.hidden = true;
        }
        
//        if([objects count]>=[kLimit integerValue]) {
//            shouldLoadNext = YES;
//            fetchNextRecordBtn.hidden = false;
//        }
//        else {
//            shouldLoadNext=NO;
//            fetchNextRecordBtn.hidden = true;
//        }
        
        
        if (shouldLoadNext) {
            
            NSString *recordcountStr;
            
            NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPage];
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
            NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPage];
            int skipRecords = [strPage intValue];
            int diffLastRecords = eventCount - skipRecords;
            if (diffLastRecords <= [kLimit intValue]) {
                NSString *recordcountStr;
                if (skipRecords == 0 && eventCount == 0) {
                }else {
                    skipRecords = skipRecords + 1;
                }
                
                recordcountStr = [NSString stringWithFormat:@"%d - %d (%d)",skipRecords, eventCount, eventCount];
                recordLbl.text = recordcountStr;
            }
        }
        [eventTblView setContentOffset:eventTblView.contentOffset animated:NO];
        
        // Reload table view after getting data from quickblox table
        [eventTblView reloadData];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark - SideMenuBtnAction
- (IBAction)sideMenuAction:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark - MapScreenSideMenuAction
- (IBAction)mapSideMenuAction:(id)sender {
    
    favInfoMapDirStr = @"MAPSIDE";
    [self getEventCourseDetails:@""];

}
#pragma mark - SegmentChangedAction

- (IBAction)segmentChangedAction:(id)sender {
    
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    /*********** ChetuChange **********/
    
    // remove elements from array when segment change. we meed to remove previous segment courses from array and load for new segment.
    [eventTblView setContentOffset:eventTblView.contentOffset animated:NO];
    [arrEventsData removeAllObjects];
    courseOption = (int)selectedSegment;
    shouldLoadNext = NO;
    currentPage = 0;
    fetchPrevRecordBtn.hidden = true;
    fecthInitialRecordBtn.hidden = true;
    viewInfoBase.hidden = true;
    viewBlurInfo.hidden = true;
    [self getEventRecordsCount];
}
#pragma mark - SearchEventAction
- (IBAction)searchBottomBtnAction:(id)sender {
   
    EventPreferncesViewController *obj = [[EventPreferncesViewController alloc] initWithNibName:@"EventPreferncesViewController" bundle:nil];
    
    [self.navigationController pushViewController:obj animated:YES];
}
#pragma mark- Favourite button tapped
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
       //   [self showGrid];
     }else {
         
         int totalAdvEventsCount = (int)selectedRow;
         totalAdvEventsCount = totalAdvEventsCount / kAdvertisementEventNo;
         int totalEventRecords = (int)indexPath.row - totalAdvEventsCount;
        
         
         QBCOCustomObject *obj  = [arrEventsData objectAtIndex:totalEventRecords];
         
         sharedobj = obj;
         
         NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
         
         if(!arr || arr.count==0)
             arr = [[NSMutableArray alloc] init];
         
         NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
         
         if([arr containsObject:strCurrentUserID]) {
             // it is fav
             isFavCourse=YES;
         }
         else {
             isFavCourse=NO;
         }
         
         [self showGrid];
     }
    
  
}

- (void)showGrid {
    NSInteger numberOfOptions = 4;
    NSArray *items;
    /*********** ChetuChange ******/
    
    //  Chnage the title of favorite button
    NSString *favoriteTitle = isFavCourse==YES ? @"Mark Unfavorite" : @"Mark Favorite";
    
    //  NSString *favoriteTitle = @"Your favorite";
    NSString *favImgStr = @"";
    if ([favoriteTitle isEqualToString: @"Mark Unfavorite"]) {
        favImgStr = @"fav.png";
    }else {
        favImgStr = @"unfav";
    }
    items= @[
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:favImgStr] title:@"Your Favorite"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"info-filled"] title:@"Information"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"viewmap"] title:@"On Map"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"direction"] title:@"Directions"]
             ];
    
    /*********** ChetuChange ******/
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.bounces = YES;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

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
-(void) actionMap {
    
    favInfoMapDirStr = @"MAP";
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedRow];
    NSString *eventCourseId = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"eventCourseID"]];
    [self getEventCourseDetails:eventCourseId];
    
}

-(void ) actionDirectionTapped {
    
    favInfoMapDirStr = @"DIR";
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedRow];
    NSString *eventCourseId = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"eventCourseID"]];
    [self getEventCourseDetails:eventCourseId];
    
}

-(void)directionAction
{
    NSArray *arrCoord = [objEventGolfCourse.fields objectForKey:@"coordinates"];
    
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
    
    //    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f", scrplaceCoord.latitude, scrplaceCoord.longitude, desplaceCoord.latitude, desplaceCoord.longitude];
    
    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", scrplaceCoord.latitude, scrplaceCoord.longitude, desplaceCoord.latitude, desplaceCoord.longitude];
    
    
    //     NSString *strPlaceName = @"Batumi+Botanical+Garden";
    //
    //    NSString *googleMapUrlString = [NSString stringWithFormat:@"https://www.google.com/maps/place/%@",strPlaceName];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString] options:[[NSDictionary alloc] init] completionHandler:nil];
}

-(void)getEventCourseDetails:(NSString *)eventCourseId {
    
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
  
   
    [getRequest setObject:@"0" forKey:@"skip"];
    if ([favInfoMapDirStr isEqualToString:@"MAPSIDE"]) {
    
        NSString *allEventsCourseId = @"";
        
        for (QBCOCustomObject *obj in arrEventsData) {
             NSString *strDesc = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"eventCourseID"]];
            if ([allEventsCourseId isEqualToString:@""]) {
                 allEventsCourseId = strDesc;
            }else {
               allEventsCourseId = [NSString stringWithFormat:@"%@,%@",strDesc,allEventsCourseId];
            }
           
        }
       int totalEvents = (int)[arrEventsData count];
        NSString *totalEventsCount = [NSString stringWithFormat:@"%d", totalEvents];
          [getRequest setObject:totalEventsCount forKey:@"limit"];
        [getRequest setObject:allEventsCourseId forKey:@"ID[in]"];
    }else {
       [getRequest setObject:@"1" forKey:@"limit"];
       [getRequest setObject:eventCourseId forKey:@"ID"];
    }
    
    [[AppDelegate sharedinstance] showLoader];
    
        [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            
            if ( [favInfoMapDirStr isEqualToString:@"INFO"]) {
                 objEventGolfCourse = [objects objectAtIndex:0];
                favInfoMapDirStr= @"";
                NSString *addStr = [[AppDelegate sharedinstance] nullcheck:[objEventGolfCourse.fields objectForKey:@"Address"]];
                lblAddressEventInfo.text = addStr;
            }else if ([favInfoMapDirStr isEqualToString:@"MAP"]) {
                 objEventGolfCourse = [objects objectAtIndex:0];
                 favInfoMapDirStr= @"";
                MapViewController *mapVC = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
                mapVC.dictCourseMapData = objEventGolfCourse;
                mapVC.strFromScreen = @"2";
                [self.navigationController pushViewController:mapVC animated:YES];
                
            }else if ([favInfoMapDirStr isEqualToString:@"DIR"]){
                 objEventGolfCourse = [objects objectAtIndex:0];
                 favInfoMapDirStr= @"";
                [self directionAction];
            }else if ([favInfoMapDirStr isEqualToString:@"MAPSIDE"]) {
                
                NSMutableArray *allEventCourseEvents = [[NSMutableArray alloc]init];
                [allEventCourseEvents addObjectsFromArray:[objects mutableCopy]];
                 if([allEventCourseEvents count]==0) {
                 
                 [[AppDelegate sharedinstance] displayMessage:@"No courses available"];
                 return;
                 }
                 
                 MapViewController *obj = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
                 obj.arrCourseData = allEventCourseEvents;
                 obj.strFromScreen = @"1";
                 [self.navigationController pushViewController:obj animated:YES];
                 
                
            }
           
            
            [[AppDelegate sharedinstance] hideLoader];
            
          
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
    }

-(void) actionInfo {
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:selectedRow];
 
    NSString *strDesc = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Description"]];
    NSString *strEventTitle = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Title"]];
     NSString *strStartDate = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"StartDate"]];
    NSString *eventCourseId = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"eventCourseID"]];
    
    NSString *strDate = [CommonMethods convertDateToAnotherFormat:strStartDate originalFormat:kEventDateFormatOriginal finalFormat:kEventDateFormatFinal];
    NSString *endDate = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"EndDate"]];
    NSString *strEndDate = [CommonMethods convertDateToAnotherFormat:endDate originalFormat:kEventDateFormatOriginal finalFormat:kEventDateFormatFinal];
    NSString *strDateEvent = [NSString stringWithFormat:@"%@ To %@",strDate,strEndDate];
    
    if([strDesc length]>0) {
       
        textViewEventDescInfo.text = strDesc;
        lblEventTitleInfo.text = strEventTitle;
        lblStartEndDateInfo.text = strDateEvent;
        viewBlurInfo.hidden = false;
        viewInfoBase.hidden = false;
        CGFloat heightDescTextview  =  [CommonMethods heightForText:strDesc withFont:[UIFont systemFontOfSize:16] andWidth:textViewEventDescInfo.frame.size.width];
        textViewEventDescInfo.scrollEnabled = true;
        textViewEventDescInfo.editable = false;
        if (heightDescTextview >= 300) {
             heightDescTextview = 300;
        }
        constraintsInfoBaseViewHeight.constant = heightDescTextview + 327;
    }
    else {
        [[AppDelegate sharedinstance] displayMessage:@"No information available"];
    }

    favInfoMapDirStr = @"INFO";
    [self getEventCourseDetails:eventCourseId];
    
}


-(void) actionFav {
    
    
    int totalAdvEventsCount = (int)selectedRow;
    totalAdvEventsCount = totalAdvEventsCount / kAdvertisementEventNo;
    int totalEventRecords = (int)selectedRow - totalAdvEventsCount;
    
    QBCOCustomObject *obj = [arrEventsData objectAtIndex:totalEventRecords];
    
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        // already fav, so unfav
        
        [arr removeObject:strCurrentUserID];
    }
    else {
        [arr addObject:strCurrentUserID];
        
    }
    
    if(!arr || arr.count==0) {
        [obj.fields setObject:arr forKey:@"userFavID"];
        
    }
    else {
        [obj.fields setObject:arr forKey:@"userFavID"];
        
    }
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
     
       [arrEventsData replaceObjectAtIndex:totalEventRecords withObject:obj];
       
        [[AppDelegate sharedinstance] hideLoader];
        [eventTblView setContentOffset:eventTblView.contentOffset animated:NO];
        [eventTblView reloadData];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
    
}

#pragma mark- Contact Info Action
- (IBAction)btnInfoContactAction:(id)sender {
    
     NSString *contactStr = [[AppDelegate sharedinstance] nullcheck:[objEventGolfCourse.fields objectForKey:@"ContactNumber"]];
    BOOL validateEmail = [CommonMethods validateEmailWithString:contactStr];
    if (validateEmail) {
        [self sendEmail:contactStr];
    }else{
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",contactStr]]];
    }
    
}
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

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    viewInfoBase.hidden = true;
    viewBlurInfo.hidden = true;
    [controller dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark- Website Info Action
- (IBAction)btnWebsiteInfoAction:(id)sender {
   
    NSString *websiteStr = [[AppDelegate sharedinstance] nullcheck:[objEventGolfCourse.fields objectForKey:@"Website"]];
    websiteStr = [NSString stringWithFormat:@"http://%@",websiteStr];
 
    if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:websiteStr]]) {
         [[UIApplication sharedApplication] openURL:[NSURL URLWithString:websiteStr]];
        viewBlurInfo.hidden = true;
        viewInfoBase.hidden = true;
    }else {
        NSLog(@"Error");
        viewInfoBase.hidden = true;
        viewBlurInfo.hidden = true;
    }
    
    
   
}
#pragma mark- Close Info Action
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
    
    int totalAdvEventsCount = (int)arrEventsData.count;
    totalAdvEventsCount = totalAdvEventsCount / kAdvertisementEventNo;
    int totalEventRecords = totalAdvEventsCount + (int)arrEventsData.count;
    NSInteger totalEventRecordsCount = (NSInteger) totalEventRecords;
    
    return totalEventRecordsCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    EventTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kEventCellName];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:kEventCellName owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
   
    // find the indexpath for advertisement event that shows in table
    int rowno = (int)indexPath.row;
    rowno = rowno + 1;
    int val = rowno  % kAdvertisementEventNo;
    
    // Condition for advertisement cell or event cell
    if (val == kRemainderValAdvEvent) {
        cell.lblDate.text = kAdEventlblTxt;
        cell.lblDate.hidden = false;
        cell.lblDate.textColor = [UIColor redColor];
        [cell.BtnFav addTarget:self action:@selector(btnFavTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.BtnFav.backgroundColor = [UIColor colorWithRed:0.000 green:0.655 blue:0.176 alpha:1.00];
        
    }else {
       
        int totalAdvEventsCount = (int)indexPath.row;
        totalAdvEventsCount = totalAdvEventsCount / kAdvertisementEventNo;
        int totalEventRecords = (int)indexPath.row - totalAdvEventsCount;
        QBCOCustomObject *obj = [arrEventsData objectAtIndex:totalEventRecords];
       // Set Data from obj in tableview cell
        [cell setDataFromQbObj:obj];
        [cell.BtnFav addTarget:self action:@selector(btnFavTapped:) forControlEvents:UIControlEventTouchUpInside];
        cell.BtnFav.backgroundColor = [UIColor colorWithRed:0.000 green:0.655 blue:0.176 alpha:1.00];
    }
    
    return cell;
   
}

#pragma mark - Table view Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

@end
