//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "SpecialsViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "cell_ViewSpecials.h"
#import "cell_ViewEvents.h"
#import "MapViewController.h"
#import "CoursePreferencesViewController.h"
#import "CoursePhotoViewController.h"
#import "EditEventViewController.h"
#define kLimit @"100"

#define kIndexFav 0
#define kIndexInfo 1
#define kIndexMap 2
#define kIndexDirection 3
#define kIndexPhoto 4

#define kFeatured 0;
#define kNearMe 1;
#define kFavorite 2;

@interface SpecialsViewController ()

@end

@implementation SpecialsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    shouldLoadNext=YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    self.navigationController.navigationBarHidden=YES;
    tblList.tableFooterView = [UIView new];
    [lblNotAvailable setHidden:YES];
    
    tblList.separatorInset = UIEdgeInsetsZero;
    
    [tblList reloadData];
    
    btnSearchBig.layer.cornerRadius = btnSearchBig.bounds.size.width / 2;
    btnSearchBig.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    _roleId = [[AppDelegate sharedinstance] getCurrentRole];
    
    if([self roleId] == 2 || [self roleId] == 3)
    {
        [tblList setFrame:CGRectMake(tblList.frame.origin.x, 60, tblList.frame.size.width, tblList.frame.size.height
                                     + 29)];
    }
    
    
    [self setUpFavorites];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4.5, 0, 4.5);
}

-(void) viewWillAppear:(BOOL)animated {
    self.menuContainerViewController.panMode=YES;
    
    arrData = [[NSMutableArray alloc] init];
    arrCoursesData = [[NSMutableArray alloc] init];
    arrCourses = [[NSMutableArray alloc] init];
    arrEvents = [[NSMutableArray alloc] init];
    arrPhotos = [[NSMutableArray alloc] init];
    
    [[AppDelegate sharedinstance] showLoader];
    
    switch([self DataType])
    {
        case filterCourse:
            lblScreenTitle.text = @"Courses";
            [addButton setHidden:YES];
            [backButton setHidden:YES];
            break;
        case filterEvent:
            lblScreenTitle.text = @"Events";
            [menuButton setHidden:[self roleId] == 2];
            [addButton setHidden:[self roleId] != 2];
            [backButton setHidden:[self roleId] != 2];
            break;
    }
    
    _currentPage=0;
    shouldLoadNext = YES;
    
    [AppDelegate sharedinstance].strIsChatConnected = @"0";
    
    QBUUser *currentUser = [QBSession currentSession].currentUser;
    currentUser.password = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];
    [btnSearchBig setHidden:[self roleId] == 2 || [self roleId] == 3];
    [mapButton setHidden:[self roleId] == 2 || [self roleId] == 3];
    [segmentSpecials setHidden:[self roleId] == 2 || [self roleId] == 3];
    
   
    
    
    if([[[AppDelegate sharedinstance] sharedChatInstance] isConnected])
    {
        switch([self roleId])
        {
            case 2:
            case 3:
                [self getDataForEventsManager];
                break;
                default:
                [self getData];
                break;
        }
        
    }
    else
    {
        // connect to Chat
        [[AppDelegate sharedinstance].sharedChatInstance connectWithUser:currentUser completion:^(NSError * _Nullable error) {
            [AppDelegate sharedinstance].strIsChatConnected = @"1";
            
            switch([self roleId])
            {
                case 2:
                case 3:
                    [self getDataForEventsManager];
                    break;
                default:
                    [self getData];
                    break;
            }
        }];
    }
    
}

-(void) getDataForEventsManager
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];

    switch([self DataType])
    {
        case filterEvent:
             [getRequest setObject:[self courseIds] forKey:@"_parent_id[in]"];
            [self getCourseEvents:getRequest :true];
            break;
        case filterCourse:
             [getRequest setObject:[self courseIds] forKey:@"_id[in]"];
            [self getGolfCourses:getRequest :false];
            break;
    }   
}

-(void) setUpFavorites
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserGuid] forKey:@"_parent_id"];
    
    [QBRequest objectsWithClassName:@"UserFavorite" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
       
        arrFavorites = [objects mutableCopy];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) getData
{
    NSArray *searchSegments = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0]
                               , [NSNumber numberWithInteger:2]
                               , nil];
    NSNumber *selectedSegment = [NSNumber numberWithInteger:[segmentSpecials selectedSegmentIndex]];
    [btnSearchBig setHidden:[self roleId] == 2 || [searchSegments  containsObject: selectedSegment]];
    
    arrCourses = [[NSMutableArray alloc] init];
    arrEvents = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:kLimit forKey:@"limit"];
    
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * _currentPage];
    
    [getRequest setObject:strPage forKey:@"skip"];
    
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
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    switch([selectedSegment integerValue])
    {
        case 0:
            [getRequest setObject: @"true" forKey:@"featured"];
            switch([self DataType])
        {
            case filterCourse:
                [getRequest setObject: @"order" forKey:@"sort_asc"];
                [self getGolfCourses:getRequest:false];
                break;
            case filterEvent:
                [getRequest setObject: @"StartDate" forKey:@"sort_asc"];
                [self getCourseEvents:getRequest:true];
                break;
        }
            
            break;
        case 1:
            strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],160934.0f];
            [getRequest setObject:strFilterDistance forKey:@"coordinates[near]"];
            [self getGolfCourses:getRequest:[self DataType] == filterEvent];
            break;
        case 2:
            [self getFavorites];
            break;
        case 3:
            switch([self DataType])
        {
            case filterCourse:
                dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kSearchCourse] mutableCopy];
                
                if(dictcoursePreferencesData)
                {
                    NSArray *arrcf_amenities= [[dictcoursePreferencesData  objectForKey:@"Amenities"] componentsSeparatedByString:@","];
                    
                    [QBRequest objectsWithClassName:@"CourseAmenities" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
                     {
                         
                         NSString *strcf_name = [dictcoursePreferencesData  objectForKey:@"Name"];
                         NSString *strcf_state= [dictcoursePreferencesData  objectForKey:@"State"];
                         NSMutableArray *strcf_city = [dictcoursePreferencesData  objectForKey:@"City"];
                         NSString *strcf_zipcode = [dictcoursePreferencesData  objectForKey:@"Zipcode"];
                         NSString *strcf_type= [dictcoursePreferencesData  objectForKey:@"Type"];
                         NSString *strcf_isFav= [dictcoursePreferencesData  objectForKey:@"Favorite"];
                         
                         
                         if(![strcf_type isEqualToString:@"All"])
                         {
                             [getRequest setObject: strcf_type forKey:@"CourseType"];
                         }
                         
                         if(![strcf_name isEqualToString:@""])
                         {
                             [getRequest setObject: strcf_name forKey:@"Name[ctn]"];
                         }
                         
                         if(![strcf_state isEqualToString:@"All"]) {
                             [getRequest setObject: strcf_state forKey:@"State"];
                         }
                         
                         if(![strcf_city containsObject:@"All"]) {
                             [getRequest setObject: strcf_city forKey:@"City[in]"];
                         }
                         
                         if(![strcf_zipcode isEqualToString:@""]) {
                             [getRequest setObject: strcf_zipcode forKey:@"ZipCode"];
                         }
                         
                         if(![arrcf_amenities containsObject:@"Any"])
                         {
                             NSMutableArray *objAmenities = [objects mutableCopy];
                             
                             NSMutableArray *courseIds = [[NSMutableArray alloc] init];
                             
                             for(QBCOCustomObject *obj in objAmenities)
                             {
                                 if([arrcf_amenities containsObject:[[obj.fields objectForKey:@"Amenity"] lowercaseString]])
                                 {
                                     [courseIds addObject:obj.parentID];
                                 }
                             }
                             
                             [getRequest setObject: courseIds forKey:@"_id[in]"];
                         }
                         
                         
                         if([strcf_isFav isEqualToString:@"1"]) {
                             [getRequest setObject: strCurrentUserID forKey:@"userFavID[in]"];
                         }
                         
                         [self getGolfCourses:getRequest:false];
                     } errorBlock:^(QBResponse *response) {
                         // error handling
                         [[AppDelegate sharedinstance] hideLoader];
                         
                         NSLog(@"Response error: %@", [response.error description]);
                     }];
                    
                }
                else
                {
                    NSString *strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong1 floatValue],[strlat1 floatValue],9999999.f];
                    [getRequest setObject:strFilterDistance forKey:@"coordinates[near]"];
                    [self getGolfCourses:getRequest:false];
                }
                break;
            case filterEvent:
                dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kSearchEvent] mutableCopy];
                
                if(dictcoursePreferencesData)
                {
                    
                    
                    NSString *strcf_name = [dictcoursePreferencesData  objectForKey:@"Name"];
                    NSString *strcf_state= [dictcoursePreferencesData  objectForKey:@"State"];
                    NSMutableArray *strcf_city = [dictcoursePreferencesData  objectForKey:@"City"];
                    NSString *strcf_zipcode = [dictcoursePreferencesData  objectForKey:@"Zipcode"];
                    
                    if(![strcf_name isEqualToString:@""])
                    {
                        [getRequest setObject: strcf_name forKey:@"Name[ctn]"];
                    }
                    
                    if(![strcf_state isEqualToString:@"All"]) {
                        [getRequest setObject: strcf_state forKey:@"State"];
                    }
                    
                    if(![strcf_city containsObject:@"All"]) {
                        [getRequest setObject: strcf_city forKey:@"City[in]"];
                    }
                    
                    if(![strcf_zipcode isEqualToString:@""]) {
                        [getRequest setObject: strcf_zipcode forKey:@"ZipCode"];
                    }
                    
                    
                    [self getGolfCourses:getRequest:true];
                    
                    
                }
                else
                {
                    NSString *strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong1 floatValue],[strlat1 floatValue],9999999.f];
                    [getRequest setObject:strFilterDistance forKey:@"coordinates[near]"];
                    [self getGolfCourses:getRequest:false];
                }
                break;
                
        }
            
            break;
    }
    
}

-(void) getFavorites
{
    NSMutableArray *courseId;
    NSMutableDictionary *getRequest;
    NSMutableArray *eventId;
    
    switch([self DataType])
    {
        case filterCourse:
            courseId = [[NSMutableArray alloc] init];
            
            for(QBCOCustomObject *obj in arrFavorites)
            {
                if([obj.fields objectForKey:@"CourseId"] != nil)
                {
                    [courseId addObject:[obj.fields objectForKey:@"CourseId"]];
                }
                
            }
            
            getRequest = [NSMutableDictionary dictionary];
            
            [getRequest setObject:courseId forKey:@"_id[in]"];
            [self getGolfCourses:getRequest:false];
            break;
        case filterEvent:
            eventId = [[NSMutableArray alloc] init];
            
            for(QBCOCustomObject *obj in arrFavorites)
            {
                if([obj.fields objectForKey:@"EventId"] != nil)
                {
                    [eventId addObject:[obj.fields objectForKey:@"EventId"]];
                }
            }
            
            NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
            [getRequest setObject:eventId forKey:@"_id[in]"];
            
            [self getCourseEvents:getRequest:true];
            break;
    }
}

-(void) getGolfCourses:(NSMutableDictionary *)getRequest :(BOOL) getEvents
{
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        
        [[AppDelegate sharedinstance] hideLoader];
        
        [arrCourses addObjectsFromArray:[objects mutableCopy]];

        shouldLoadNext=[objects count]>=[kLimit integerValue];
        
        NSMutableArray *courseIds = [[NSMutableArray alloc] init];
        
        for(QBCOCustomObject *obj in arrCourses)
        {
            [courseIds addObject:obj.ID];
        }
        
        NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
        [getRequest setObject:courseIds forKey:@"_parent_id[in]"];
        [getRequest setObject:@"true" forKey:@"Primary"];
        
        [QBRequest objectsWithClassName:@"CoursePhoto" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            
            NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
            
            [[AppDelegate sharedinstance] hideLoader];
            
            [arrPhotos addObjectsFromArray:[objects mutableCopy]];
            
            shouldLoadNext=[objects count]>=[kLimit integerValue];
            
            if(getEvents)
            {
                NSMutableArray *courseIds = [[NSMutableArray alloc] init];
                
                for(QBCOCustomObject *obj in arrCourses)
                {
                    [courseIds addObject:obj.ID];
                }
                NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                [getRequest setObject: courseIds forKey:@"_parent_id[in]"];
                [self getCourseEvents:getRequest:false];
                
            }
            else
            {
                [lblNotAvailable setHidden:[arrCourses count]!=0];
                [tblList setHidden:[arrCourses count]==0];
                [tblList reloadData];
            }
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) getCourseEvents:(NSMutableDictionary *)getRequest :(BOOL) getCourses
{
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"CourseEvents" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        
        [[AppDelegate sharedinstance] hideLoader];
        
        [arrEvents addObjectsFromArray:[objects mutableCopy]];
        
        shouldLoadNext=[objects count]>=[kLimit integerValue];
        NSMutableArray *parentIds = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kSearchEvent] mutableCopy];
        
        NSString *startDate = [dictcoursePreferencesData  objectForKey:@"StartDate"];
        NSString *endDate = [dictcoursePreferencesData  objectForKey:@"EndDate"];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        
        NSDate *end = endDate.length > 0 ? [formatter dateFromString:endDate] : [NSDate date];
        NSDate *start = startDate.length > 0 ? [formatter dateFromString:startDate] : nil;
        
        
        
        for(QBCOCustomObject *obj in arrEvents)
        {
            NSString *dateString =  [obj.fields objectForKey:@"EndDate"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
            NSDate *date = [dateFormatter dateFromString:dateString];
            
            long days = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                         fromDate:end
                                                           toDate:date options:0]day];
            
            if(days >= 0 || _roleId == 2)
            {
                [parentIds addObject:obj.parentID];
            }
            else
            {
                [arrEvents removeObject:obj];
            }
            
            if(start != nil)
            {
                NSString *dateString =  [obj.fields objectForKey:@"StartDate"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                NSDate *date = [dateFormatter dateFromString:dateString];
                
                long days = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                             fromDate:start
                                                               toDate:date options:0]day];
                
                if(days >= 0)
                {
                    [parentIds addObject:obj.parentID];
                }
                else
                {
                    [arrEvents removeObject:obj];
                }
            }
            
        }
        
        [tblList setHidden:[arrEvents count]==0];
        [lblNotAvailable setHidden:[arrEvents count]!=0];
        
        if(getCourses)
        {
            
            [arrCourses removeAllObjects];
            
            NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
            [getRequest setObject: parentIds forKey:@"_id[in]"];
            
            [self getGolfCourses:getRequest :false];
        }
        else
        {
            [tblList reloadData];
        }

    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
    //
}

- (IBAction)segmentSwitch:(id)sender
{
    [self getData];
}

-(IBAction)mapviewtapped:(id)sender {
    
    if([arrCourses count]==0) {
        
        [[AppDelegate sharedinstance] displayMessage:@"No courses available"];
        return;
    }
    
    NSMutableArray *eventCourses = [[NSMutableArray alloc] init];
    
    MapViewController *obj = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    switch([self DataType])
    {
        case filterCourse:
            obj.arrCourseData = arrCourses;
            break;
        case filterEvent:
            for(QBCOCustomObject *event in arrEvents)
            {
                for(QBCOCustomObject *course in arrCourses)
                {
                    if([course.ID isEqualToString:event.parentID])
                    {
                        [eventCourses addObject:course];
                    }
                }
            }
            obj.arrCourseData = eventCourses;
            break;
    }
    
    obj.strFromScreen = @"1";
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(IBAction)searchtapped:(id)sender {
    
    CoursePreferencesViewController *obj = [[CoursePreferencesViewController alloc] initWithNibName:@"CoursePreferencesViewController" bundle:nil];
    obj.SearchType = [self DataType];
    
    [segmentSpecials setSelectedSegmentIndex:3];
    
    [self.navigationController pushViewController:obj animated:YES];
}

#pragma mark - Table view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 183;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self DataType] == filterCourse ? arrCourses.count : arrEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_ViewSpecials *cell;
    cell_ViewEvents *cellEvent;
    QBCOCustomObject *obj;
    BOOL lastItemReached;
    NSString *str11;
    NSString *str22;
    NSString *strDistance;
    NSString *strCity;
    NSString *strState;
    NSString *strZipCode;
    NSString *str1;
    
    switch([self DataType ])
    {
        case filterCourse:
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewSpecials"];
            cell = [[[NSBundle mainBundle] loadNibNamed:@"cell_ViewSpecials" owner:self options:nil] objectAtIndex:0];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor=[UIColor clearColor];
            cell.contentView.backgroundColor=[UIColor clearColor];
            
            // FROM ALL
            obj = [arrCourses objectAtIndex:indexPath.row];
            
            str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Address"]];
            strCity= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"City"]];
            strState= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"State"]];
            strZipCode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ZipCode"]];
            str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
            
            [cell.lblAddress setText:str1];
            [cell.lblName setText:[[[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Name"]] uppercaseString]];
            
            for(QBCOCustomObject *photo in arrPhotos)
            {
                if([photo.parentID isEqualToString:obj.ID])
                {
                    [cell.imageUrl setShowActivityIndicatorView:YES];
                    [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                    [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[photo.fields objectForKey:@"Image"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
                    break;
                }
            }
            
            
            
            strDistance = [NSString stringWithFormat:@"%.1f mi",[self calculateDistance:[obj.fields objectForKey:@"coordinates"]]];
            [cell.lblDistance setText:strDistance];
            [cell.lblDistance setHidden:_roleId == 2 || _roleId == 3];
            [cell.buttonOptions setHidden:_roleId == 2 || _roleId == 3];
        
            
            [cell.viewAlpha setAlpha:0];
            
            str11= [[arrCourses objectAtIndex:indexPath.row] description];
            str22= [[arrCourses lastObject] description];

            lastItemReached=[str11 isEqualToString:str22];

            if (lastItemReached && indexPath.row == [arrData count] - 1) {
                
                if(shouldLoadNext) {
                    _currentPage++;
                    
                    [self getData];
                }
            }

            return cell;
            break;
        case filterEvent:
            cellEvent = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewEvents"];
            cellEvent = [[[NSBundle mainBundle] loadNibNamed:@"cell_ViewEvents" owner:self options:nil] objectAtIndex:0];
            cellEvent.selectionStyle = UITableViewCellSelectionStyleNone;
            cellEvent.backgroundColor=[UIColor clearColor];
            cellEvent.contentView.backgroundColor=[UIColor clearColor];
            
            obj = [arrEvents objectAtIndex:indexPath.row];
            
            NSString *test = [obj.fields objectForKey:@"Title"];
            cellEvent.eventTitle.text = [obj.fields objectForKey:@"Title"];
            
            for(QBCOCustomObject *course in arrCourses)
            {
                if([obj.parentID isEqualToString:course.ID])
                {
                    cellEvent.courseName.text = [course.fields objectForKey:@"Name"];
                    strDistance = [NSString stringWithFormat:@"%.1f mi",[self calculateDistance:[course.fields objectForKey:@"coordinates"]]];
                    [cellEvent.lblDistance setText:strDistance];
                    [cellEvent.lblDistance setHidden:_roleId == 2];
                    break;
                }
                
            }
            NSString *eventType =  [obj.fields objectForKey:@"EventType"];
            if([eventType isEqualToString:@"One Time"])
            {
                NSDate *today = [NSDate date];
                
                NSString *dateString =  [obj.fields objectForKey:@"StartDate"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
                NSDate *date = [dateFormatter dateFromString:dateString];
                
                long days = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                             fromDate:today
                                                               toDate:date options:0]day];
                
                cellEvent.numberOfDays.text = [NSString stringWithFormat:@"In %ld days", days];
            }
            else if([eventType isEqualToString:@"Recurring"])
            {
                NSString *days = @"";
                NSMutableArray *week =  [obj.fields objectForKey:@"Week"];
                
                for(int i = 0; i < 7; ++i)
                {
                    bool selected = [[week objectAtIndex:i] boolValue];
                    if(selected)
                    {
                        switch(i)
                        {
                            case 0:
                                days = [NSString stringWithFormat:@"%@SUN,", days];
                                break;
                            case 1:
                                days = [NSString stringWithFormat:@"%@ MON,", days];
                                break;
                            case 2:
                                days = [NSString stringWithFormat:@"%@ TUES,", days];
                                break;
                            case 3:
                                days = [NSString stringWithFormat:@"%@ WED,", days];
                                break;
                            case 4:
                                days = [NSString stringWithFormat:@"%@ THURS,", days];
                                break;
                            case 5:
                                days = [NSString stringWithFormat:@"%@ FRI,", days];
                                break;
                            case 6:
                                days = [NSString stringWithFormat:@"%@ SAT,", days];
                                break;
                        }
                    }
                }
                days = [days stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
                cellEvent.numberOfDays.text = days;
            }
            
            
            [cellEvent.imageViewEvents setShowActivityIndicatorView:YES];
            [cellEvent.imageViewEvents setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [cellEvent.imageViewEvents sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];

            return cellEvent;
            break;
    }
    return nil;
}

-(double) calculateDistance:(NSArray *)arrCoord
{
    CLLocationCoordinate2D placeCoord;
    
    //Set the lat and long.
    placeCoord.latitude=[[[AppDelegate sharedinstance] nullcheck:[arrCoord objectAtIndex:1]] doubleValue];
    placeCoord.longitude=[[[AppDelegate sharedinstance] nullcheck:[arrCoord objectAtIndex:0]] doubleValue];
    desplaceCoord = placeCoord;
    
    //Set the lat and long.
    placeCoord.latitude=[[[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlat]] doubleValue];
    placeCoord.longitude=[[[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlong]] doubleValue];
    
    CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
    scrplaceCoord = myposition;
    
    CLLocation *loc1 = [[CLLocation alloc] initWithLatitude:scrplaceCoord.latitude longitude:scrplaceCoord.longitude];
    CLLocation *loc2 = [[CLLocation alloc] initWithLatitude:desplaceCoord.latitude longitude:desplaceCoord.longitude];
    
    CLLocationDistance distanceInMeters = [loc1 distanceFromLocation:loc2];
    
    double distanceinKm =(distanceInMeters/1000.f);
    distanceinKm = roundf(distanceinKm * 10.0f)/10.0f;
    
    
    return distanceinKm * 0.621371;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController;
    QBCOCustomObject *event;
    QBCOCustomObject *obj;
    
    int roleId = [[AppDelegate sharedinstance] getCurrentRole];
    
    
    switch ([self DataType])
    {
        case filterCourse:
            switch(roleId)
        {
            case 0:
            case 1:
            case 3:
                viewController = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
                ((PurchaseSpecialsViewController*)viewController).status=1;
                
                obj = [arrCourses objectAtIndex:indexPath.row];
                
                ((PurchaseSpecialsViewController*)viewController).courseObject=obj;
                [self.navigationController pushViewController:viewController animated:YES];
                break;
            case 2:
                viewController = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                
                NSMutableArray *course = [[NSMutableArray alloc] init];
                obj = arrCourses[indexPath.row];
                [course addObject:obj.ID];
                ((SpecialsViewController*)viewController).DataType = filterEvent;
                ((SpecialsViewController*)viewController).courseIds = course;
                [self.navigationController pushViewController:viewController animated:YES];
                break;
        }
            
            break;
        case filterEvent:
            [[AppDelegate sharedinstance] showLoader];
            event = [arrEvents objectAtIndex:indexPath.row];
            bool isFavorite = false;
            for(QBCOCustomObject *obj in arrFavorites)
            {
                if([[obj.fields objectForKey:@"EventId"] isEqualToString:event.ID])
                {
                    isFavorite = true;
                    break;
                }
            }
            
            NSString *parentId = event.parentID;
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Event Description"
                                         message:[event.fields objectForKey:@"Description"]
                                         preferredStyle:UIAlertControllerStyleActionSheet];
            
            UIAlertAction* favoriteButton;
            if(!isFavorite)
            {
                favoriteButton = [UIAlertAction
                                  actionWithTitle:@"Add to Favorites"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self addToEventFavorites:event.ID];
                                  }];
            }
            
            else
            {
                favoriteButton = [UIAlertAction
                                  actionWithTitle:@"Remove from Favorites"
                                  style:UIAlertActionStyleDefault
                                  handler:^(UIAlertAction * action) {
                                      [self removeFromEventFavorites:event.ID:event.parentID];
                                      [tblList reloadData];
                                  }];
            }
            
            
            UIAlertAction* courseButton = [UIAlertAction
                                           actionWithTitle:@"Go to Course"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                               PurchaseSpecialsViewController *viewController = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
                                               
                                               viewController.status=1;
                                               
                                               for(QBCOCustomObject *course in arrCourses)
                                               {
                                                   if([parentId isEqualToString:course.ID] )
                                                   {
                                                       viewController.courseObject=course;
                                                       [self.navigationController pushViewController:viewController animated:YES];
                                                       break;
                                                   }
                                               }
                                               
                                           }];
            
            UIAlertAction* closeButton = [UIAlertAction
                                          actionWithTitle:@"Close"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              
                                          }];
            
            UIAlertAction* editButton = [UIAlertAction
                                          actionWithTitle:@"Edit Event"
                                          style:UIAlertActionStyleDefault
                                          handler:^(UIAlertAction * action) {
                                              [self editEvent:event];
                                          }];
            
            UIAlertAction* deleteButton = [UIAlertAction
                                           actionWithTitle:@"Delete Event"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [self deleteEvent:event.ID];
                                         }];
            
            switch([[AppDelegate sharedinstance] getCurrentRole])
        {
            case 2:
                [alert addAction:editButton];
                [alert addAction:deleteButton];
                break;
            default:
                [alert addAction:favoriteButton];
                [alert addAction:courseButton];
                
                break;
                
        }
           [alert addAction:closeButton];
            
            alert.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath];
            [self presentViewController:alert animated:YES completion:nil];
            [[AppDelegate sharedinstance] hideLoader];
            break;
    }
}

-(void) addToEventFavorites: (NSString *) eventId
{
    QBCOCustomObject *obj = [[QBCOCustomObject alloc] init];
     
    obj.className = @"UserFavorite";
    
    [obj.fields setObject:eventId forKey:@"EventId"];
    
    obj.parentID = [[AppDelegate sharedinstance] getCurrentUserGuid];
    
    [QBRequest createObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *obj)
     {
         [self setUpFavorites];
     }
                 errorBlock:^(QBResponse *response) {
                     // error handling
                     [[AppDelegate sharedinstance] hideLoader];
                     
                     NSLog(@"Response error: %@", [response.error description]);
                 }];
}

-(void) editEvent:(QBCOCustomObject *) object
{
    EditEventViewController *viewController = [[EditEventViewController alloc] initWithNibName:@"EditEventViewController" bundle:nil];
    viewController.object = object;
    viewController.IsEdit = YES;
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    
}

-(IBAction) addEvent
{
    EditEventViewController *viewController = [[EditEventViewController alloc] initWithNibName:@"EditEventViewController" bundle:nil];
    viewController.courseId = [[self courseIds] objectAtIndex:0];
    viewController.IsEdit = NO;
    
    [self.navigationController pushViewController:viewController animated:YES];
    
    
}

-(void) deleteEvent:(NSString *) id
{
    [QBRequest deleteObjectWithID:id className:@"CourseEvents" successBlock:^(QBResponse * _Nonnull response) {
        [arrEvents removeAllObjects];
        [self getDataForEventsManager];
    } errorBlock:^(QBResponse * _Nonnull response) {

     }
     ];
}

-(void) removeFromEventFavorites: (NSString *) eventId : (NSString *) parentId
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:eventId forKey:@"EventId"];
    [getRequest setObject:parentId forKey:@"_parent_id"];
    
    [QBRequest objectsWithClassName:@"UserFavorite" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         QBCOCustomObject *obj = objects[0];
         
         [QBRequest deleteObjectWithID:obj.ID className:@"UserFavorite" successBlock:^(QBResponse * _Nonnull response) {
             [self setUpFavorites];
             
         } errorBlock:^(QBResponse * _Nonnull response) {
             // error handling
             [[AppDelegate sharedinstance] hideLoader];
             
             
             NSLog(@"Response error: %@", [response.error description]);
         }];
     }errorBlock:^(QBResponse * _Nonnull response) {
         // error handling
         [[AppDelegate sharedinstance] hideLoader];
         
         NSLog(@"Response error: %@", [response.error description]);
     }];
}

-(void) addToCourseFavorites: (NSString *) eventId
{
    QBCOCustomObject *obj = [[QBCOCustomObject alloc] init];
    
    obj.className = @"UserFavorite";
    
    [obj.fields setObject:eventId forKey:@"CourseId"];
    
    obj.parentID = [[AppDelegate sharedinstance] getCurrentUserGuid];
    
    [QBRequest createObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *obj)
     {
         [self setUpFavorites];
     }
                 errorBlock:^(QBResponse *response) {
                     // error handling
                     [[AppDelegate sharedinstance] hideLoader];
                     
                     NSLog(@"Response error: %@", [response.error description]);
                 }];
}

-(void) removeFromCourseFavorites: (NSString *) eventId : (NSString *) parentId
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:eventId forKey:@"CourseId"];
    [getRequest setObject:parentId forKey:@"_parent_id"];
    
    [QBRequest objectsWithClassName:@"UserFavorite" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         QBCOCustomObject *obj = objects[0];
         
         [QBRequest deleteObjectWithID:obj.ID className:@"UserFavorite" successBlock:^(QBResponse * _Nonnull response) {
             [self setUpFavorites];
             
         } errorBlock:^(QBResponse * _Nonnull response) {
             // error handling
             [[AppDelegate sharedinstance] hideLoader];
             
             NSLog(@"Response error: %@", [response.error description]);
         }];
     }errorBlock:^(QBResponse * _Nonnull response) {
         // error handling
         [[AppDelegate sharedinstance] hideLoader];
         
         NSLog(@"Response error: %@", [response.error description]);
     }];
}

//-----------------------------------------------------------------------


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(IBAction)favTapped:(UIButton*)sender  {
    
    CGPoint center=sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    selectedRow = indexPath.row;
    
    sharedobj = [arrCourses objectAtIndex:selectedRow] ;
    
    isFavCourse=NO;
    for(QBCOCustomObject *favorite in arrFavorites)
    {
        if([[favorite.fields objectForKey:@"CourseId"] isEqualToString:sharedobj.ID])
        {
            isFavCourse=YES;
        }
    }
    
    [self showGrid];
    
}


- (void)showGrid {
    NSInteger numberOfOptions = 5;
    NSArray *items;
    
    NSString *favoriteTitle = isFavCourse ? @"Mark Unfavorite" : @"Mark Favorite";
    NSString *favoriteImage = isFavCourse ? @"unfav" : @"fav";
    
    
    items= @[
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:favoriteImage] title:favoriteTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"info-filled"] title:@"Information"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"viewmap"] title:@"On Map"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"direction"] title:@"Directions"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"image-placeholder"] title:@"Photos"],
             ];
    
    
    
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
            if(!isFavCourse)
            {
                [self addToCourseFavorites:sharedobj.ID];
            }
            else
            {
                [self removeFromCourseFavorites:sharedobj.ID:[[AppDelegate sharedinstance] getCurrentUserGuid]];
            }
 
            break;
        case kIndexInfo:
            [self actionInfo];
            break;
        case kIndexMap:
            [self actionMap];
            break;
        case kIndexDirection:
            [self actionDirection];
            break;
        case kIndexPhoto:
            [self actionPhoto];
            break;
    }
}

-(void) actionPhoto {
    
    CoursePhotoViewController *obj = [[CoursePhotoViewController alloc] initWithNibName:@"CoursePhotoViewController" bundle:nil];
    obj.courseID =sharedobj.ID;
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(void) actionMap {
    
    MapViewController *obj = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    obj.dictCourseMapData =sharedobj;
    obj.strFromScreen = @"2";
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(void ) actionDirection {
    NSArray *arrCoord = [sharedobj.fields objectForKey:@"coordinates"];
    
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

-(void) actionInfo {
    // All courses
    QBCOCustomObject *obj = [arrCourses objectAtIndex:selectedRow];

    NSString *strInfo = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"description"]];
    
    if([strInfo length]>0) {
        
        
        NSString* messageString = strInfo;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Information"
                                                                                 message:messageString
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        alertController.view.frame = [[UIScreen mainScreen] bounds];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                          }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [[AppDelegate sharedinstance] displayMessage:@"No information available"];
    }
    
}

-(void) actionFav {
    
    // All courses
    QBCOCustomObject *obj = [arrCourses objectAtIndex:selectedRow];
    
    
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
    
 
    [obj.fields setObject:arr forKey:@"userFavID"];

    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        [arrData replaceObjectAtIndex:selectedRow withObject:obj];
        
        
        if(showOnyFav) {
            
            [self getData];
        }
        else {
            [[AppDelegate sharedinstance] hideLoader];
            [tblList reloadData];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
    
}

- (IBAction)backPresses:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
