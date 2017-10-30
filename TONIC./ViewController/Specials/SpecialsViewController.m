//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "SpecialsViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "cell_ViewSpecials.h"
#import "MapViewController.h"
#import "CoursePreferencesViewController.h"
#import "CoursePhotoViewController.h"
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
    
    segmentMode=0;
    
    self.navigationController.navigationBarHidden=YES;
    tblList.tableFooterView = [UIView new];
    [lblNotAvailable setHidden:YES];
    
    arrData = [[NSMutableArray alloc] init];
    arrCoursesData = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kcoursePreferencesData] mutableCopy];
    
    [dictcoursePreferencesData setObject:@"0" forKey:@"cf_courseOption"];
    
    [[NSUserDefaults standardUserDefaults] setObject:dictcoursePreferencesData forKey:kcoursePreferencesData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    tblList.separatorInset = UIEdgeInsetsZero;
    
    [tblList reloadData];
    
    btnSearchBig.layer.cornerRadius = btnSearchBig.bounds.size.width / 2;
    btnSearchBig.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
    lblScreenTitle.text = @"Courses";
    
}

-(void) viewWillAppear:(BOOL)animated {
    self.menuContainerViewController.panMode=YES;
    
    [[AppDelegate sharedinstance] showLoader];
    
    _currentPage=0;
    shouldLoadNext = YES;
    
    [AppDelegate sharedinstance].strIsChatConnected = @"0";
    
    QBUUser *currentUser = [QBSession currentSession].currentUser;
    currentUser.password = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];
    
    if([[[AppDelegate sharedinstance] sharedChatInstance] isConnected])
    {
        [btnSearchBig setHidden:NO];
        [self getData];
    }
    else
    {
        // connect to Chat
        [[AppDelegate sharedinstance].sharedChatInstance connectWithUser:currentUser completion:^(NSError * _Nullable error) {
            [AppDelegate sharedinstance].strIsChatConnected = @"1";
            
            [self getData];
        }];
    }
}

-(void) getData
{
    NSArray *searchSegments = [NSArray arrayWithObjects:[NSNumber numberWithInteger:0]
                               , [NSNumber numberWithInteger:2]
                               , nil];
    NSNumber *selectedSegment = [NSNumber numberWithInteger:[segmentSpecials selectedSegmentIndex]];
    [btnSearchBig setHidden:[searchSegments  containsObject: selectedSegment]];
    
    arrData = [[NSMutableArray alloc] init];
    
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
            [getRequest setObject: @"order" forKey:@"sort_asc"];
            [self getGolfCourses:getRequest];
            break;
        case 1:
            strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],160934.0f];
            [getRequest setObject:strFilterDistance forKey:@"coordinates[near]"];
            [self getGolfCourses:getRequest];
            break;
        case 2:
            [getRequest setObject: strCurrentUserID forKey:@"userFavID[in]"];
            [self getGolfCourses:getRequest];
            break;
        case 3:
            dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kcoursePreferencesData] mutableCopy];
            
            if(dictcoursePreferencesData)
            {
                NSArray *arrcf_amenities= [[dictcoursePreferencesData  objectForKey:@"cf_amenities"] componentsSeparatedByString:@","];
                
                [QBRequest objectsWithClassName:@"CourseAmenities" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
                 {
                     
                     NSString *strcf_name = [dictcoursePreferencesData  objectForKey:@"cf_name"];
                     NSString *strcf_state= [dictcoursePreferencesData  objectForKey:@"cf_state"];
                     NSString *strcf_city = [dictcoursePreferencesData  objectForKey:@"cf_city"];
                     NSString *strcf_zipcode = [dictcoursePreferencesData  objectForKey:@"cf_zipcode"];
                     NSString *strcf_type= [dictcoursePreferencesData  objectForKey:@"cf_type"];
                     NSString *strcf_isFav= [dictcoursePreferencesData  objectForKey:@"cf_isFav"];
                     
                     
                     if(![strcf_type isEqualToString:@"All"])
                     {
                         [getRequest setObject: strcf_type forKey:@"CourseType"];
                     }
                     
                     if(![strcf_name isEqualToString:@"All"])
                     {
                         [getRequest setObject: strcf_name forKey:@"Name[ctn]"];
                     }
                     
                     if(![strcf_state isEqualToString:@"All"]) {
                         [getRequest setObject: strcf_state forKey:@"State"];
                     }
                     
                     if(![strcf_city isEqualToString:@"All"]) {
                         [getRequest setObject: strcf_city forKey:@"City[in]"];
                     }
                     
                     if(![strcf_zipcode isEqualToString:@"All"]) {
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
                         
                         [getRequest setObject: courseIds forKey:@"_id"];
                     }
                     
                     
                     if([strcf_isFav isEqualToString:@"1"]) {
                         showOnyFav=YES;
                         [getRequest setObject: strCurrentUserID forKey:@"userFavID[in]"];
                     }
                     else {
                         showOnyFav=NO;
                     }
                     [self getGolfCourses:getRequest];
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
                [self getGolfCourses:getRequest];
            }
            break;
    }
    
}

-(void) getGolfCourses:(NSMutableDictionary *)getRequest
{
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        
        [[AppDelegate sharedinstance] hideLoader];
        
        [arrData addObjectsFromArray:[objects mutableCopy]];
        
        if([arrData count]==0) {
            [lblNotAvailable setHidden:NO];
            [tblList setHidden:YES];
        }
        else {
            [lblNotAvailable setHidden:YES];
            [tblList setHidden:NO];
            
        }
        
        shouldLoadNext=[objects count]>=[kLimit integerValue];
        [tblList reloadData];
        
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
    
    if([arrData count]==0) {
        
        [[AppDelegate sharedinstance] displayMessage:@"No courses available"];
        return;
    }
    
    MapViewController *obj = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    obj.arrCourseData = arrData;
    obj.strFromScreen = @"1";
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(IBAction)searchtapped:(id)sender {
    
    CoursePreferencesViewController *obj = [[CoursePreferencesViewController alloc] initWithNibName:@"CoursePreferencesViewController" bundle:nil];
    
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
    return 182;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_ViewSpecials *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewSpecials"];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewSpecials" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    
    // FROM ALL
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Name"]];
    [cell.lblName setText:[str1 uppercaseString]];
    
    //        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Points"]];
    //        [cell.lblPoints setText:str1];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Address"]];
    
    NSString *strCity= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"City"]];
    NSString *strState= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"State"]];
    NSString *strZipCode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ZipCode"]];
    
    str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
    [cell.lblAddress setText:str1];
    
    [cell.imageUrl setShowActivityIndicatorView:YES];
    [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
    
    
    NSArray *arrCoord = [obj.fields objectForKey:@"coordinates"];
    
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
    
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    //Set the lat and long.
    placeCoord.latitude=[strlat doubleValue];
    placeCoord.longitude=[strlong doubleValue];
    
    CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
    scrplaceCoord = myposition;
    
    CLLocation *loc2;
    CLLocation *loc1;
    loc1 = [[CLLocation alloc] initWithLatitude:scrplaceCoord.latitude longitude:scrplaceCoord.longitude];
    loc2 = [[CLLocation alloc] initWithLatitude:desplaceCoord.latitude longitude:desplaceCoord.longitude];
    
    CLLocationDistance distanceInMeters = [loc1 distanceFromLocation:loc2];
    
    double distanceinKm =(distanceInMeters/1000.f);
    distanceinKm = roundf(distanceinKm * 10.0f)/10.0f;
    NSString *strDistance = [NSString stringWithFormat:@"%.1f mi",distanceinKm * 0.621371];
    [cell.lblDistance setText:strDistance];
    [cell.lblDistance setHidden:NO];
    
    NSLog(@" distance in km %f",distanceinKm);
    
    [cell.viewAlpha setAlpha:0];
    
    NSString *str11= [[arrData objectAtIndex:indexPath.row] description];
    NSString *str22= [[arrData lastObject] description];
    
    BOOL lastItemReached;
    
    if([str11 isEqualToString:str22]) {
        lastItemReached=YES;
    }
    else {
        lastItemReached=NO;
        
    }
    
    if (lastItemReached && indexPath.row == [arrData count] - 1) {
        
        if(shouldLoadNext) {
            _currentPage++;
            
            [self getData];
        }
    }
    
    
    
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    // FROM ALL
    PurchaseSpecialsViewController *viewController;
    viewController    = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
    
    viewController.status=1;
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    viewController.courseObject=obj;
    [self.navigationController pushViewController:viewController animated:YES];
    
    
    
}

//-----------------------------------------------------------------------


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (void)showGrid {
    NSInteger numberOfOptions = 5;
    NSArray *items;
    
    NSString *favoriteTitle = isFavCourse==YES ? @"Mark Unfavorite" : @"Mark Favorite";
    
    
    items= @[
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"unfav"] title:favoriteTitle],
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
            [self actionFav];
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
    QBCOCustomObject *obj = [arrData objectAtIndex:selectedRow];
    
    
    
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
    QBCOCustomObject *obj = [arrData objectAtIndex:selectedRow];
    
    
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

@end
