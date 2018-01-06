//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "CoursePreferencesViewController.h"

#import "CourseCellTableViewCell.h"

#define kButtonCity 1
#define kButtonzipcode 2
#define kButtonType 3
#define kButtonState 4
#define kButtonname 5
#define kButtonamenities 6
#define kButtonCourse 7

#define kPickerState 1
#define kPickerType 2
#define kPickerAge 6
#define kPickerHandicap 7
#define kPickerCourse 8


#define kScreenViewUsers @"1"
#define kScreenMenu @"2"

@interface CoursePreferencesViewController ()

@end

@implementation CoursePreferencesViewController
@synthesize cameFromScreen;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    [pickerView setHidden:YES];
    [datePicker setHidden:YES];
    [handicapView setHidden:[self SearchType] == filterPro];
    
    [tblMembers setSeparatorColor:[UIColor clearColor]];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    [datePicker setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBarHidden=YES;
    
    arrTypeList = [[NSMutableArray alloc] init];
    arrCityList = [[NSMutableArray alloc] init];
    arrCityStateList = [[NSMutableArray alloc] init];
    arrStateList = [[NSMutableArray alloc] init];
    arrHomeCourseList = [[NSMutableArray alloc] init];
    arramenitiesList = [[NSMutableArray alloc] init];
    
    [self setUpAmenitiesList];
    
    arrAgeList=[[NSMutableArray alloc] init];
    
    for(int i = 18; i <= 100; ++i)
    {
        [arrAgeList addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    arrHandicapList=[[NSMutableArray alloc] init];
    
    for(int i = -40; i <= 5; ++i)
    {
        [arrHandicapList addObject:[NSString stringWithFormat:@"%d",i]];
    }
    
    tempArraySelcted=[[NSMutableArray alloc]init];
    
    
    
    if(isiPhone4) {
        // [courseView setContentSize:CGSizeMake(320, 650)];
        // [eventView setContentSize:CGSizeMake(320, 650)];
        // [golferView setContentSize:CGSizeMake(320, 650)];
    }
    
    [tblMembers reloadData];
    
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    self.menuContainerViewController.panMode = NO;
    
    switch([self SearchType])
    {
        case filterEvent:
            searchTitle.text = @"Search Events";
            break;
        case filterCourse:
            searchTitle.text = @"Search Courses";
            break;
        case filterGolfer:
            searchTitle.text = @"Search Golfers";
            break;
        case filterPro:
            searchTitle.text = @"Search Pros";
            break;
    }
    
    [golferView setHidden:[self SearchType] != filterGolfer && [self SearchType] != filterPro];
    [courseView setHidden:[self SearchType] != filterCourse];
    [eventView setHidden:[self SearchType] != filterEvent];
    
    [self bindData];
    
}

-(void) getLocationDataFromServer
{
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(QBCOCustomObject *obj in objects) {
            NSString *strState = [obj.fields objectForKey:@"userState"];
            NSString *strCity = [obj.fields objectForKey:@"userCity"];
            
            NSArray *cityState = @[strCity, strState];
            
            if(![arrStateList containsObject:strState])
            {
                [arrStateList addObject:strState];
            }
            
            if(![arrCityStateList containsObject:cityState])
            {
                [arrCityStateList addObject:cityState];
            }
        }
        
        [arrStateList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        
        [arrStateList insertObject:@"All" atIndex:0];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) bindSearchData:(QBCOCustomObject *) userObject searchType:(NSString*) searchType
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject: userObject.ID forKey:@"_parent_id"];
    [getRequest setObject: searchType forKey:@"SearchType"];
    
    [QBRequest objectsWithClassName:@"UserSearch" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         if([objects count] == 0)
         {
             NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
             [getRequest setObject: @"Default" forKey:@"SearchType"];
             
             [QBRequest objectsWithClassName:@"UserSearch" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
              {
                  QBCOCustomObject *defaultObject = objects[0];
                  defaultObject.parentID = userObject.ID;
                  [defaultObject.fields setObject:searchType forKey:@"SearchType"];
                  
                  [QBRequest createObject:defaultObject successBlock:^(QBResponse *response, QBCOCustomObject *newObject)
                   {
                       [self bindSearchData:userObject searchType:searchType];
                   }
                               errorBlock:^(QBResponse *response) {
                                   // error handling
                                   [[AppDelegate sharedinstance] hideLoader];
                                   
                                   NSLog(@"Response error: %@", [response.error description]);
                               }];
              }
                                  errorBlock:^(QBResponse *response) {
                                      // error handling
                                      [[AppDelegate sharedinstance] hideLoader];
                                      
                                      NSLog(@"Response error: %@", [response.error description]);
                                  }];
             return;
             
         }
         
         object = objects[0];
         
         switch([self SearchType])
         {
             case filterGolfer:
             case filterPro:
                 [self bindGolfer];
                 break;
             case filterCourse:
                 [self bindCourse];
                 break;
             case filterEvent:
                 [self bindEvent];
                 break;
         }
     }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}

-(void)bindGolfer
{
    [self getLocationDataFromServer];
    [self populateCourses];
    
    NSMutableDictionary *proTypes = [[AppDelegate sharedinstance] getAllProIcons];
    for(NSString *str in [[proTypes allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)])
    {
        [arrTypeList addObject:[[str stringByReplacingOccurrencesOfString:@"lpga" withString:@"LPGA"] stringByReplacingOccurrencesOfString:@"pga" withString:@"PGA"]];
    }
    
    Gender = [[[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Gender"]] componentsSeparatedByString:@","] mutableCopy];
    
    [Gender removeObject:@""];
    
    NSString *maleImage, *femaleImage;
    
    if([Gender count] == 0 || [Gender containsObject:@"All"])
    {
        [Gender addObject:@"male"];
        [Gender addObject:@"female"];
    }
    
    maleImage = [Gender containsObject:@"male"] ? @"guestmalefilled" : @"guestmale";
    
    femaleImage = [Gender containsObject:@"female"] ? @"guestfemalefilled" : @"guestfemale";
    
    [btnMale setImage:[UIImage imageNamed:maleImage] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:femaleImage] forState:UIControlStateNormal];
    
    
    NSArray *arrCity = [object.fields objectForKey:@"City"];
    NSString *strCity = [arrCity componentsJoinedByString:@","];
    NSString *strState = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"State"]];
    NSString *strhome_course= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Course"]];
    NSString *strName= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Name"]];
    
    NSString *strAge = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Age"]];
    NSString *strType = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Type"]];
    NSString *strHandicap = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Handicap"]];
    
    
    if([strCity length]==0) {
        [txtCityGolfer setText:@"All"];
        
    }
    else {
        [txtCityGolfer setText:strCity];
    }
    
    if([strState length]==0) {
        [txtStateGolfer setText:@"All"];
    }
    else {
        [txtStateGolfer setText:strState];
    }
    
    if([strhome_course length]==0) {
        [txtCourseGolfer setText:@"All"];
    }
    else {
        [txtCourseGolfer setText:strhome_course];
    }
    
    if([strAge length] == 0){
        strAge = @"18-100";
    }
    
    [txtAge setText:strAge];
    
    if([strType length] == 0) {
        strType = @"All";
    }
    
    [txtType setText:strType];
    
    txtName.text = strName;
    
    if([strHandicap length]==0)
    {
        strHandicap = @"-40 - 5";
        [handicapSwitch setOn:YES];
    }
    else
    {
        [handicapSwitch setOn:![strHandicap isEqualToString:@"All"]];
    }
    
    [txtHandicap setText:strHandicap];
    handicapButton.enabled = ![strHandicap isEqualToString:@"All"];
}

- (void) populateCourses
{
    NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
    [getRequest setValue:@"Name" forKey:@"sort_asc"];
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest: getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(QBCOCustomObject *obj in arrData)
        {
            [arrHomeCourseList addObject:[obj.fields objectForKey:@"Name"]];
        }
        
        [arrHomeCourseList insertObject:@"" atIndex:0];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) bindCourse
{
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest: nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(QBCOCustomObject *obj in arrData) {
            NSString *strType = [obj.fields objectForKey:@"CourseType"];
            NSString *strState = [obj.fields objectForKey:@"State"];
            NSString *strCity = [obj.fields objectForKey:@"City"];
            
            NSArray *cityState = @[strCity, strState];
            
            if(![arrTypeList containsObject:strType])
            {
                [arrTypeList addObject:strType];
            }
            
            if(![arrStateList containsObject:strState])
            {
                [arrStateList addObject:strState];
            }
            
            if(![arrCityStateList containsObject:cityState])
            {
                [arrCityStateList addObject:cityState];
            }
            
            [arrHomeCourseList addObject:[obj.fields objectForKey:@"Name"]];
        }
        
        [arrStateList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arrTypeList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [arrStateList insertObject:@"All" atIndex:0];
        [arrTypeList insertObject:@"All" atIndex:0];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
    //strPush = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Favorite"]];
    
    [favoriteSwitch setOn:[[object.fields objectForKey:@"Favorite"] boolValue]];
    
    NSString *strState = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"State"]];
    NSString *str_cf_city= [[object.fields objectForKey:@"City"] componentsJoinedByString:@","];
    
    NSString *strcf_name = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Name"]];
    NSString *strcf_zipcode= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Zipcode"]];
    
    if([strcf_zipcode length]==0 || [strcf_zipcode isEqualToString:@"All"] ) {
        [txtCourseZipcode setText:@""];
        
    }
    else {
        [txtCourseZipcode setText:strcf_zipcode];
    }
    
    
    if([str_cf_city length]==0) {
        [txtCity setText:@"All"];
        
    }
    else {
        [txtCity setText:str_cf_city];
    }
    
    if([strState length]==0) {
        [txtState setText:@"All"];
    }
    else {
        [txtState setText:strState];
    }
    
    if([strcf_name length]==0 || [strcf_name isEqualToString:@"All"]) {
        [txtCourseName setText:@""];
    }
    else {
        [txtCourseName setText:strcf_name];
    }
    
    NSString *strType = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Type"]];
    
    if([strType length] == 0)
    {
        strType = @"All";
    }
    
    [txtType setText:strType];
    
    NSString *strcf_amenities = [[object.fields objectForKey:@"Amenities"] componentsJoinedByString:@","];
    
    if([strcf_amenities length]==0) {
        
        [txtAmenities setText:@"Any"];
    }
    else {
        [txtAmenities setText:strcf_amenities];
        
    }
    
}

-(void) bindEvent
{
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            NSString *strType = [obj.fields objectForKey:@"CourseType"];
            NSString *strState = [obj.fields objectForKey:@"State"];
            NSString *strCity = [obj.fields objectForKey:@"City"];
            
            NSArray *cityState = @[strCity, strState];
            
            if(![arrTypeList containsObject:strType])
            {
                [arrTypeList addObject:strType];
            }
            
            if(![arrStateList containsObject:strState])
            {
                [arrStateList addObject:strState];
            }
            
            if(![arrCityStateList containsObject:cityState])
            {
                [arrCityStateList addObject:cityState];
            }
        }
        
        [arrStateList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arrTypeList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [arrStateList insertObject:@"All" atIndex:0];
        [arrTypeList insertObject:@"All" atIndex:0];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
    NSString *strState = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"State"]];
    NSString *str_cf_city= [[object.fields objectForKey:@"City"] componentsJoinedByString:@","];
    
    NSString *strcf_name = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Name"]];
    NSString *strcf_zipcode= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Zipcode"]];
    
    if([strcf_zipcode length]==0 || [strcf_zipcode isEqualToString:@"All"] ) {
        [txtCourseZipcode setText:@""];
        
    }
    else {
        [txtCourseZipcode setText:strcf_zipcode];
    }
    
    
    if([str_cf_city length]==0) {
        [txtCityEvent setText:@"All"];
        
    }
    else {
        [txtCityEvent setText:str_cf_city];
    }
    
    if([strState length]==0) {
        [txtStateEvent setText:@"All"];
    }
    else {
        [txtStateEvent setText:strState];
    }
    
    if([strcf_name length]==0 || [strcf_name isEqualToString:@"All"]) {
        [txtCourseNameEvent setText:@""];
    }
    else {
        [txtCourseNameEvent setText:strcf_name];
    }
    
    NSString *startDate = [object.fields objectForKey:@"StartDate"];
    NSString *endDate = [object.fields objectForKey:@"EndDate"];
    
    txtStartDate.text = [startDate substringToIndex:10];
    txtEndDate.text = [endDate substringToIndex:10];
    
    
}

-(IBAction)maleTapped:(id)sender
{
    if([Gender containsObject:@"male"])
    {
        [Gender removeObject:@"male"];
    }
    else
    {
        [Gender addObject:@"male"];
    }
    
    NSString *icon = [Gender containsObject:@"male"] ? @"guestmalefilled" : @"guestmale";
    
    [btnMale setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btnMale setImage:[UIImage imageNamed:icon] forState:UIControlStateSelected];
    [btnMale setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
}

-(IBAction)femaleTapped:(id)sender
{
    if([Gender containsObject:@"female"])
    {
        [Gender removeObject:@"female"];
    }
    else
    {
        [Gender addObject:@"female"];
    }
    
    NSString *icon = [Gender containsObject:@"female"] ? @"guestfemalefilled" : @"guestfemale";
    
    [btnFemale setImage:[UIImage imageNamed:icon] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:icon] forState:UIControlStateSelected];
    [btnFemale setImage:[UIImage imageNamed:icon] forState:UIControlStateHighlighted];
}

-(IBAction) ageTapped:(id)sender {
    [viewToolbar setHidden:NO];
    [viewTable setHidden:YES];
    [pickerView setHidden:NO];
    //[minMaxView setHidden:NO];
    //[minMax setHidden:NO];
    
    NSArray* splitAge = [txtAge.text componentsSeparatedByString: @"-"];
    int first = [[splitAge objectAtIndex: 0] intValue];
    int second = [[splitAge objectAtIndex: 1] intValue];
    
    pickerOption = kPickerAge;
    
    [pickerView reloadAllComponents];
    
    [pickerView selectRow:first - 18 inComponent:0 animated:YES];
    [pickerView reloadComponent:0];
    [pickerView selectRow:second - 18 inComponent:1 animated:YES];
    [pickerView reloadComponent:1];
    
}

-(IBAction) handicapTapped:(id)sender {
    [viewToolbar setHidden:NO];
    [viewTable setHidden:YES];
    [pickerView setHidden:NO];
    //[minMaxView setHidden:NO];
    //[minMax setHidden:NO];
    
    NSArray* splitAge = [txtHandicap.text componentsSeparatedByString: @" - "];
    int first = [[splitAge objectAtIndex: 1] intValue];
    int second = [[splitAge objectAtIndex: 0] intValue];
    
    pickerOption = kPickerHandicap;
    
    [pickerView reloadAllComponents];
    
    [pickerView selectRow:first + 40 inComponent:1 animated:YES];
    [pickerView reloadComponent:1];
    [pickerView selectRow:second + 40 inComponent:0 animated:YES];
    [pickerView reloadComponent:0];
    
}


-(void) bindData
{
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        arrData=objects;
        
        [[AppDelegate sharedinstance] hideLoader];
        
        if([objects count]>0) {
            
            object = arrData[0];
            
            switch([self SearchType])
            {
                case filterGolfer:
                    [self bindSearchData:object searchType:@"User"];
                    break;
                case filterPro:
                    [self bindSearchData:object searchType:@"Pros"];
                    break;
                case filterCourse:
                    [self bindSearchData:object searchType:@"Courses"];
                    break;
                case filterEvent:
                    [self bindSearchData:object searchType:@"Events"];
                    break;
            }
        }
    }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}


- (IBAction) saveTapped:(id)sender {
    
    [self savesettings];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:@"Do you want to save preferences?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Yes"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    [self savesettings];
                                }];
    
    UIAlertAction* noButton = [UIAlertAction
                               actionWithTitle:@"No"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   [self.navigationController popViewControllerAnimated:YES];
                               }];
    
    [alert addAction:yesButton];
    [alert addAction:noButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    
}

//-----------------------------------------------------------------------

- (IBAction)action_gotoMyMatches:(id)sender {
    UIViewController *viewController;
    viewController    = [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
}

//-----------------------------------------------------------------------

-(IBAction) nameTapped:(id)sender {
    
}

//-----------------------------------------------------------------------

-(IBAction) cityTapped:(id)sender {
    
    buttonTapped = kButtonCity;
    
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) stateTapped:(id)sender {
    buttonTapped = kButtonState;
    pickerOption = kPickerState;
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) zipcodeTapped:(id)sender {
    
    
    buttonTapped = kButtonzipcode;
    
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) amenitiesTapped:(id)sender {
    buttonTapped = kButtonamenities;
    [self changeData];
    
}

//-----------------------------------------------------------------------

-(IBAction) typeTapped:(id)sender {
    
    buttonTapped = kButtonType;
    pickerOption = kPickerType;
    [self changeData];
    
}

-(IBAction) courseTapped:(id)sender {
    
    buttonTapped = kButtonCourse;
    pickerOption = kPickerCourse;
    [self changeData];
    
}

//-----------------------------------------------------------------------

-(IBAction) selectiondoneTapped:(id)sender {
    
    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    [pickerView setHidden:YES];
    [datePicker setHidden:YES];
    
    UITextField *textFieldCity;

    if(buttonTapped == kButtonCity)
    {
        switch([self SearchType])
        {
            case filterGolfer:
                case filterPro:
               textFieldCity = txtCityGolfer;
                break;
            case filterCourse:
                textFieldCity = txtCity;
                break;
            case filterEvent:
                textFieldCity = txtCityEvent;
                break;
                
        }
        
        if([tempArraySelcted count]>0)
        {
            if([tempArraySelcted containsObject:@"All"] && [tempArraySelcted count]>1)
            {
                textFieldCity.text = @"All";
            }
            else
            {
                textFieldCity.text =  [[tempArraySelcted valueForKey:@"description"] componentsJoinedByString:@","];
            }
        }
    }
    else if(buttonTapped == kButtonamenities)  {
        
        if([tempArraySelcted count]>0)
        {
            if([tempArraySelcted containsObject:@"Any"] )
            {
                txtAmenities.text = @"Any";
            }
            else
            {
                txtAmenities.text =  [[tempArraySelcted valueForKey:@"description"] componentsJoinedByString:@","];
            }
        }
        
        
    }
    
}

//-----------------------------------------------------------------------

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) savesettings
{
    NSArray* splitAge;
    switch([self SearchType])
    {
        case filterGolfer:
        case filterPro:
            splitAge = [txtAge.text componentsSeparatedByString: @"-"];
            int first = [[splitAge objectAtIndex: 0] intValue];
            int second = [[splitAge objectAtIndex: 1] intValue];
            
            if(second < first)
            {
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:kAppName
                                             message:@"Invalid Age Range"
                                             preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction* okButton = [UIAlertAction
                                           actionWithTitle:@"OK"
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction * action) {
                                           }];
                
                
                [alert addAction:okButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
                return;
            }

            if(![handicapView isHidden] && ![txtHandicap.text isEqualToString:@"All"])
            {
                NSArray* splitHandicap = [txtHandicap.text componentsSeparatedByString: @" - "];
                first = [[splitHandicap objectAtIndex: 0] intValue];
                second = [[splitHandicap objectAtIndex: 1] intValue];
                
                if(second > first)
                {
                    
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:kAppName
                                                 message:@"Invalid Handicap Range"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction* okButton = [UIAlertAction
                                               actionWithTitle:@"OK"
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                               }];
                    
                    
                    [alert addAction:okButton];
                    
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    return;
                }
            }
            
            [object.fields setObject:[Gender componentsJoinedByString:@","]  forKey:@"Gender"];
            [object.fields setObject:txtStateGolfer.text forKey:@"State"];
            [object.fields setObject:txtCourseGolfer.text forKey:@"Course"];
            [object.fields setObject:txtName.text forKey:@"Name"];
            [object.fields setObject:txtAge.text  forKey:@"Age"];
            [object.fields setObject:txtTypeGolfer.text  forKey:@"Type"];
            [object.fields setObject:txtHandicap.text forKey:@"Handicap"];
            [object.fields setObject:[txtCityGolfer.text componentsSeparatedByString: @","] forKey:@"City"];
            break;
        case filterCourse:
            [object.fields setObject:[txtCity.text componentsSeparatedByString: @","] forKey:@"City"];
            [object.fields setObject:txtState.text forKey:@"State"];
            [object.fields setObject:txtCourseName.text forKey:@"Name"];
            [object.fields setObject:txtCourseZipcode.text forKey:@"Zipcode"];
            [object.fields setObject:txtAmenities.text forKey:@"Amenities"];
            [object.fields setObject:[favoriteSwitch isOn] ? @"1" : @"0"  forKey:@"Favorite"];
            [object.fields setObject:txtType.text forKey:@"Type"];
            break;
        case filterEvent:
            [object.fields setObject:[txtCityEvent.text componentsSeparatedByString: @","] forKey:@"City"];
            [object.fields setObject:txtState.text forKey:@"State"];
            [object.fields setObject:txtCourseName.text forKey:@"Name"];
            [object.fields setObject:txtCourseZipcode.text forKey:@"Zipcode"];
            [object.fields setObject:txtStartDate.text forKey:@"StartDate"];
            [object.fields setObject:txtEndDate.text forKey:@"EndDate"];
            break;
            
    }

    
    
    // convert miles to metres
    
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
        
        NSString *searchData;
        
        switch([self SearchType])
        {
            case filterGolfer:
                searchData = kSearchUser;
                break;
            case filterPro:
                searchData = kSearchPro;
                break;
            case filterCourse:
                searchData = kSearchCourse;
                break;
            case filterEvent:
                searchData = kSearchEvent;
                break;
        }
        
        NSMutableDictionary *dictSearchData = [[[NSUserDefaults standardUserDefaults] objectForKey:searchData] mutableCopy];
        
        if(!dictSearchData) {
            dictSearchData =[[NSMutableDictionary alloc] init];
        }
        
        switch([self SearchType])
        {
            case filterGolfer:
            case filterPro:
                [dictSearchData setObject:[Gender componentsJoinedByString:@","]  forKey:@"Gender"];
                [dictSearchData setObject:txtStateGolfer.text forKey:@"State"];
                [dictSearchData setObject:txtCourseGolfer.text forKey:@"Course"];
                [dictSearchData setObject:txtName.text forKey:@"Name"];
                [dictSearchData setObject:txtAge.text  forKey:@"Age"];
                [dictSearchData setObject:txtTypeGolfer.text  forKey:@"Type"];
                [dictSearchData setObject:txtHandicap.text forKey:@"Handicap"];
                [dictSearchData setObject:[txtCityGolfer.text componentsSeparatedByString: @","] forKey:@"City"];
                break;
            case filterCourse:
                [dictSearchData setObject:[txtCity.text componentsSeparatedByString: @","] forKey:@"City"];
                [dictSearchData setObject:txtState.text forKey:@"State"];
                [dictSearchData setObject:txtCourseName.text forKey:@"Name"];
                [dictSearchData setObject:txtCourseZipcode.text forKey:@"Zipcode"];
                [dictSearchData setObject:txtAmenities.text forKey:@"Amenities"];
                [dictSearchData setObject:[favoriteSwitch isOn] ? @"1" : @"0" forKey:@"Favorite"];
                [dictSearchData setObject:txtType.text forKey:@"Type"];
                break;
            case filterEvent:
                [dictSearchData setObject:[txtCityEvent.text componentsSeparatedByString: @","] forKey:@"City"];
                [dictSearchData setObject:txtState.text forKey:@"State"];
                [dictSearchData setObject:txtCourseName.text forKey:@"Name"];
                [dictSearchData setObject:txtCourseZipcode.text forKey:@"Zipcode"];
                [dictSearchData setObject:txtStartDate.text forKey:@"StartDate"];
                [dictSearchData setObject:txtEndDate.text forKey:@"EndDate"];
                break;
        }
        
        
        [[NSUserDefaults standardUserDefaults] setObject:dictSearchData forKey:searchData];
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        [self.navigationController popViewControllerAnimated:YES];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) changeData {
    [tempArraySelcted removeAllObjects];
    
    NSString *strStateSelected;
    
    [txtCourseName resignFirstResponder];
    [txtCourseZipcode resignFirstResponder];
    
    [viewTable setHidden:YES];
    [pickerView setHidden:YES];
    [viewToolbar setHidden:NO];
    [datePicker setHidden:YES];
    
    switch(buttonTapped)
    {
        case kButtonCity:
            switch([self SearchType])
        {
            case filterGolfer:
            case filterPro:
                strStateSelected = txtStateGolfer.text;
                break;
            case filterCourse:
                strStateSelected = txtState.text;
                break;
            case filterEvent:
                strStateSelected = txtStateEvent.text;
                break;
                
        }
            
            if([arrCityList count]>0)
                [arrCityList removeAllObjects];
            
            for(NSArray *obj in arrCityStateList)
            {
                
                NSString *strName = obj[1];
                
                if([strName isEqualToString:strStateSelected])
                {
                    if(![arrCityList containsObject:obj[0]])
                    {
                        [arrCityList addObject: obj[0]];
                    }
                }
            }
            
            [arrCityList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            [arrCityList insertObject:@"All" atIndex:0];
            
            tblMembers.allowsMultipleSelection = YES;
            [viewTable setHidden:NO];
            break;
        case kButtonState:
            [pickerView setHidden:NO];
            break;
        case kButtonamenities:
            [self setUpAmenitiesList];
            
            tblMembers.allowsMultipleSelection = YES;
            [viewTable setHidden:NO];
            break;
        case kButtonType:
            [pickerView setHidden:NO];
            break;
        case kButtonCourse:
            [pickerView setHidden:NO];
            break;
    
    }
    
    [pickerView reloadAllComponents];
    [tblMembers reloadData];
    
}

//-----------------------------------------------------------------------

-(IBAction)resetFilters:(id)sender {
    
    [txtType setText:@"All"];
    [txtCourseName setText:@"All"];
    [txtCity setText:@"All"];
    [txtState setText:@"All"];
    [txtCourseZipcode setText:@"All"];
    [txtAmenities setText:@"Any"];

    [favoriteSwitch setOn:NO];
    
    [Gender removeAllObjects];
    [Gender addObject:@"male"];
    [Gender addObject:@"female"];
    [btnMale setImage:[UIImage imageNamed:@"guestmalefilled"] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:@"guestfemalefilled"] forState:UIControlStateNormal];
    
    [txtTypeGolfer setText:@"All"];
    [txtAge setText:@"18-100"];
    [txtCityGolfer setText:@"All"];
    [txtStateGolfer setText:@"All"];
    [txtCourseName setText:@"All"];
    [txtName setText:@""];
    
    [txtHandicap setText:@"5 - -40"];
    [handicapButton setEnabled:YES];
    [handicapSwitch setOn:YES];
    
    [txtCityEvent setText:@"All"];
    [txtStateEvent setText:@"All"];
    [txtCourseNameEvent setText:@"All"];
    [txtCourseZipcodeEvent setText:@""];
    [txtStartDate setText:@""];
    [txtEndDate setText:@""];
}




//-----------------------------------------------------------------------

#pragma mark -
#pragma mark - Tableview

//-----------------------------------------------------------------------

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(buttonTapped == kButtonCity) {
        
        return [arrCityList count];
        
    }
    else if(buttonTapped == kButtonType) {
        
        return [arrTypeList count];
        
    }
    
    else if(buttonTapped == kButtonState) {
        
        return [arrStateList count];
        
    }
    else if(buttonTapped == kButtonamenities) {
        
        return [arramenitiesList count];
        
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CourseCellTableViewCell";
    CourseCellTableViewCell *SendMessageCell =(CourseCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SendMessageCell.backgroundView=nil;
    SendMessageCell.backgroundColor=[UIColor clearColor];
    
    [SendMessageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    if (SendMessageCell == nil) {
        NSArray *cell = [[NSBundle mainBundle]loadNibNamed:@"CourseCellTableViewCell" owner:self options:nil];
        SendMessageCell = [cell objectAtIndex:0];
    }
    
    NSString *str;
    
    if(buttonTapped == kButtonCity) {
        str = [arrCityList objectAtIndex:indexPath.row];
        
    }
    else if(buttonTapped == kButtonType) {
        str = [arrTypeList objectAtIndex:indexPath.row];
    }
    else if(buttonTapped == kButtonState) {
        str = [arrStateList objectAtIndex:indexPath.row];
    }
    else if(buttonTapped == kButtonamenities) {
        str = [arramenitiesList objectAtIndex:indexPath.row];
    }
    
    if([tempArraySelcted containsObject:str])    {
        [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
        [SendMessageCell.selectbtnimg setHidden:NO];
    }
    else
    {
        [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
        [SendMessageCell.selectbtnimg setHidden:YES];
    }
    
    //        [SendMessageCell setBackgroundColor:[UIColor colorWithRed:0/255 green:0/255 blue:0/55 alpha:0.5]];
    
    [SendMessageCell.selectbtnimg setTag:indexPath.row];
    
    //    [SendMessageCell.selectbtnimg addTarget:self
    //                                     action:@selector(checkBtnClicked:)
    //                           forControlEvents:UIControlEventTouchUpInside];
    
    // SendMessageCell.lblName.textColor=PlaceholderRGB;
    
    SendMessageCell.lblName.text = str;//[[arrMembers objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    return SendMessageCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CourseCellTableViewCell *ObjCirCell =(CourseCellTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    [ObjCirCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *str;
    
    if(buttonTapped == kButtonCity) {
        str = [arrCityList objectAtIndex:indexPath.row];
        
        if([str isEqualToString:@"All"])
        {
            [tempArraySelcted removeAllObjects];
        }
        else
        {
            [tempArraySelcted removeObject:@"All"];
        }
        
        if ([tempArraySelcted containsObject:str]) {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted removeObject:str];
        }
        else {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted addObject:str];
        }
    }
    
    else  if(buttonTapped == kButtonamenities){
        
        str = [arramenitiesList objectAtIndex:indexPath.row];
        
        if([str isEqualToString:@"Any"])
        {
            [tempArraySelcted removeAllObjects];
        }
        else
        {
            [tempArraySelcted removeObject:@"Any"];
        }
        
        if ([tempArraySelcted containsObject:str]) {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted removeObject:str];
        }
        else {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted addObject:str];
        }
        
    }
    else  if(buttonTapped == kButtonType){
        [tempArraySelcted removeAllObjects];
        
        str = [arrTypeList objectAtIndex:indexPath.row];
        if (![tempArraySelcted containsObject:str]) {
            
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted addObject:str];
        }
    }
    
    
    [tblMembers reloadData];
}


-(void) viewWillDisappear:(BOOL)animated {
    self.menuContainerViewController.panMode = YES;
}

-(void) setUpAmenitiesList
{
    [arramenitiesList removeAllObjects];
    NSMutableDictionary *amenities = [[AppDelegate sharedinstance] getAllAmenitiesIcons];
    
    for(NSString *amenity in amenities.allKeys)
    {
        [arramenitiesList addObject:amenity];
    }
    
    [arramenitiesList insertObject:@"Any" atIndex:0];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

//-----------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource

//-----------------------------------------------------------------------


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch(pickerOption)
    {
        case kPickerType:
        case kPickerState:
        case kPickerCourse:
            return 1;
            break;
            
    }
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch(pickerOption)
    {
        case kPickerAge:
            return arrAgeList.count;
            break;
        case kPickerHandicap:
            return arrHandicapList.count;
            break;
        case kPickerState:
            return arrStateList.count;
            break;
        case kPickerType:
            return arrTypeList.count;
            break;
        case kPickerCourse:
            return arrHomeCourseList.count;
            break;
    }
    
    return 10;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(pickerOption)
    {
        case kPickerAge:
            return arrAgeList[row];
            break;
        case kPickerHandicap:
            return arrHandicapList[row];
            break;
        case kPickerState:
            return arrStateList[row];
            break;
        case kPickerType:
            return arrTypeList[row];
            break;
        case kPickerCourse:
            return arrHomeCourseList[row];
            break;
    }
    
    return @"";
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", (long)row);
    NSArray* splitAge;
    NSArray* splitHandicap;
    NSString* first;
    NSString* second;
    
    switch (pickerOption)
    {
        case kPickerAge:
            splitAge = [txtAge.text componentsSeparatedByString: @"-"];
            first = [splitAge objectAtIndex: 0];
            second = [splitAge objectAtIndex: 1];
            switch(component)
        {
            case 0:
                txtAge.text = [NSString stringWithFormat:@"%@-%@",[arrAgeList objectAtIndex:row], second];
                break;
            case 1:
                txtAge.text = [NSString stringWithFormat:@"%@-%@",first, [arrAgeList objectAtIndex:row]];
                break;
        }
            break;
            
        case kPickerHandicap:
            splitHandicap = [txtHandicap.text componentsSeparatedByString: @" - "];
            first = [splitHandicap objectAtIndex: 0];
            second = [splitHandicap objectAtIndex: 1];
            switch(component)
        {
            case 0:
                txtHandicap.text = [NSString stringWithFormat:@"%@ - %@",[arrHandicapList objectAtIndex:row], second];
                break;
            case 1:
                txtHandicap.text = [NSString stringWithFormat:@"%@ - %@",first, [arrHandicapList objectAtIndex:row]];
                break;
        }
            break;
        case kPickerState:
            switch([self SearchType])
        {
            case filterGolfer:
            case filterPro:
                txtStateGolfer.text = [arrStateList objectAtIndex:row];
                txtCityGolfer.text = @"All";
                break;
            case filterCourse:
                txtState.text = [arrStateList objectAtIndex:row];
                txtCity.text = @"All";
                break;
            case filterEvent:
                txtStateEvent.text = [arrStateList objectAtIndex:row];
                txtCityEvent.text = @"All";
                break;
        }
            
            break;
            
        case kPickerType:
            switch([self SearchType])
        {
            case filterGolfer:
            case filterPro:
                txtTypeGolfer.text = [arrTypeList objectAtIndex:row];
                break;
            case filterCourse:
                txtType.text = [arrTypeList objectAtIndex:row];
                break;
        }
            break;
        case kPickerCourse:
            txtCourseGolfer.text = [arrHomeCourseList objectAtIndex:row];
            break;
    }
    
}

-(IBAction)StartDateTapped:(id)sender
{
    [self SetUpDatePicker:txtStartDate.text];
    dateOption = 0;
}

-(IBAction)EndDateTapped:(id)sender
{
    [self SetUpDatePicker:txtEndDate.text];
    dateOption = 1;
}

-(void) SetUpDatePicker: (NSString *) date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    datePicker.date = date.length > 0  ? [formatter dateFromString:date] : [NSDate date];
    [datePicker setHidden:NO];
    [viewToolbar setHidden:NO];
}

-(IBAction) DateChanged
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    switch(dateOption)
    {
        case 0:
            txtStartDate.text = [formatter stringFromDate:[datePicker date]];
            break;
        case 1:
            txtEndDate.text = [formatter stringFromDate:[datePicker date]];
            break;
    }
}

-(IBAction) HandicapSwitched
{
    [handicapButton setEnabled:[handicapSwitch isOn]];
    txtHandicap.text = [handicapSwitch isOn] ? @"5 - -40" : @"All";
}

@end
