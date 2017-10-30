//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "SettingsViewController.h"
#import "SendMessageCellTableViewCell.h"


#define kButtonCity 1
#define kButtonAge 2
#define kButtonType 3
#define kButtonState 4
#define kButtonHomeCourse 5

#define kPickerAge 6
#define kPickerHandicap 7
#define kPickerState 8


#define kScreenViewUsers @"1"
#define kScreenMenu @"2"

@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize cameFromScreen;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *thumb = [UIImage imageNamed:@"filledcircle"];
    btnNA.layer.cornerRadius = 10;
    
    arrTypeList = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    
    [tblMembers setSeparatorColor:[UIColor clearColor]];

    self.navigationController.navigationBarHidden=YES;

    arrCityList = [[NSMutableArray alloc] init];
    
    arrStateList = [[NSMutableArray alloc] init];
    arrHomeCourseList = [[NSMutableArray alloc] init];

    
    arrCityStateList=[[NSMutableArray alloc] init];
    
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
   
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    
    [minMaxView setHidden:YES];
    [minMax setHidden:YES];

    [btnMale setImage:[UIImage imageNamed:@"guestmalefilled"] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:@"guestfemalefilled"] forState:UIControlStateNormal];

       tempArraySelcted=[[NSMutableArray alloc]init];

    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 650)];
    }
    
    [tblMembers reloadData];
    
   [self bindData];
}

-(void) viewWillAppear:(BOOL)animated {
    self.menuContainerViewController.panMode = NO;

    if([cameFromScreen isEqualToString:kScreenViewUsers]) {
        [btnBack setBackgroundImage:[UIImage imageNamed:@"ico-back"] forState:UIControlStateNormal];
        [btnBack setFrame:CGRectMake(15, 30, 11, 20)];

    }
    else {
        [btnBack setBackgroundImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
        [btnBack setFrame:CGRectMake(15, 34, 20, 16)];

    }
}

-(void) bindData {
    
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        arrData=objects;
        
        [[AppDelegate sharedinstance] hideLoader];
        
        if([objects count]>0) {
            
            [AppDelegate sharedinstance].isUpdate=YES;
            
            // If user exists, get info from server
            object =  [arrData objectAtIndex:0];
            
            lblTitle.text = ![self IsPro] ? @"Search Golfers" : @"Search Pros";
            
            [HandicapView setHidden:[self IsPro]];
            [TypeView setHidden:![self IsPro]];
            
            
            if ([self IsPro])
            {
                [self bindSearchData:object searchType:@"Pro"];
            }
            else
            {
                [self bindSearchData:object searchType:@"User"];
            }
            

            
        }
        else {
            [btnMale setImage:[UIImage imageNamed:@"guestmalefilled"] forState:UIControlStateNormal];
            [btnFemale setImage:[UIImage imageNamed:@"guestfemalefilled"] forState:UIControlStateNormal];
            
            strPush=@"1";

        }
        

        
        
    }
    errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
    [self getLocationDataFromServer];
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
         NSString *strLocation = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Location"]];
         

         
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
             [txtCity setText:@"All"];
             
         }
         else {
             [txtCity setText:strCity];
         }
         
         if([strState length]==0) {
             [txtState setText:@"All"];
         }
         else {
             [txtState setText:strState];
         }
         
         if([strhome_course length]==0) {
             [txtCourse setText:@"All"];
         }
         else {
             [txtCourse setText:strhome_course];
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
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}

-(void) getLocationDataFromServer
{
    NSString *role = [self IsPro] ? @"1" : @"0";
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:role forKey:@"UserRole"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
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

- (IBAction) pushTapped:(id)sender {
    
    if([strPush isEqualToString:@"1"]) {
        strPush=@"0";
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        
    }
    else {
        strPush=@"1";
        [[AppDelegate sharedinstance] registerForNotifications];
    }
}

- (IBAction) saveTapped:(id)sender
{
    NSArray* splitAge = [txtAge.text componentsSeparatedByString: @"-"];
    int first = [[splitAge objectAtIndex: 0] intValue];
    int second = [[splitAge objectAtIndex: 1] intValue];
    
    if(second < first)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Invalid Age Range" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        alert.tag=121;
        [alert show];
        return;
    }
    
    if(![txtHandicap.text isEqualToString:@"All"])
    {
        NSArray* splitHandicap = [txtHandicap.text componentsSeparatedByString: @" - "];
        first = [[splitHandicap objectAtIndex: 0] intValue];
        second = [[splitHandicap objectAtIndex: 1] intValue];
        
        if(second > first)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Invalid Handicap Range" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            alert.tag=121;
            [alert show];
            return;
        }
    }

    [self savesettings];
}



//-----------------------------------------------------------------------

-(IBAction) restorePurchases :(id)sender {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
        
    if([cameFromScreen isEqualToString:kScreenViewUsers]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Do you want to save preferences?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag=121;
        [alert show];
        
        
    }
    else {
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            
        }];
        
    }

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

-(IBAction) cityTapped:(id)sender {
    
    [viewTable setHidden:NO];
    [viewToolbar setHidden:NO];
    buttonTapped = kButtonCity;
    
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) stateTapped:(id)sender {
    
    [viewToolbar setHidden:NO];
    [viewTable setHidden:YES];
    [minMaxView setHidden:NO];
    [minMax setHidden:YES];
    
    pickerOption = kPickerState;
    
    NSInteger selectedRow = [arrStateList indexOfObject:txtState.text];
    
    [pickerView reloadAllComponents];
    
    [pickerView selectRow:selectedRow inComponent:0 animated:YES];
    [pickerView reloadComponent:0];
}

//-----------------------------------------------------------------------

-(IBAction) homeCourseTapped:(id)sender {
    
    [viewTable setHidden:NO];
    [viewToolbar setHidden:NO];
    buttonTapped = kButtonHomeCourse;
    
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) ageTapped:(id)sender {
    [viewToolbar setHidden:NO];
    [viewTable setHidden:YES];
    [minMaxView setHidden:NO];
    [minMax setHidden:NO];
    
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
    [minMaxView setHidden:NO];
    [minMax setHidden:NO];
    
    NSArray* splitAge = [txtHandicap.text componentsSeparatedByString: @" - "];
    int first = [[splitAge objectAtIndex: 1] intValue];
    int second = [[splitAge objectAtIndex: 0] intValue];
    
    pickerOption = kPickerHandicap;
    
    [pickerView reloadAllComponents];
    
    [pickerView selectRow:first + 40 inComponent:0 animated:YES];
    [pickerView reloadComponent:0];
    [pickerView selectRow:second + 40 inComponent:1 animated:YES];
    [pickerView reloadComponent:1];
    
}

//-----------------------------------------------------------------------

-(IBAction) typeTapped:(id)sender {
    
    [viewTable setHidden:NO];
    [viewToolbar setHidden:NO];
    buttonTapped = kButtonType;
    [self changeData];

}

-(IBAction) changePwdTapped:(id)sender {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    UIAlertView *forgotpasswordAlert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Enter your new password"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    forgotpasswordAlert.tag=300;
    forgotpasswordAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textField = [forgotpasswordAlert textFieldAtIndex:0];
    textField.secureTextEntry=YES;
    textField.placeholder=@"Enter password here";
    [forgotpasswordAlert show];
    
}

-(void) changePwd {
    QBUUser *user = [QBUUser user];
    user.ID = [[[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID] integerValue];
    user.oldPassword = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];
    
    user.password = @"newpassword";

}

//-----------------------------------------------------------------------

-(IBAction) selectiondoneTapped:(id)sender {
    
    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    [minMaxView setHidden:YES];
    [minMax setHidden:YES];
    
    if(buttonTapped == kButtonCity) {
        if([tempArraySelcted count]>0)
        {
            if([tempArraySelcted containsObject:@"All"] && [tempArraySelcted count]>1)
            {
                txtCity.text = @"All";
            }
            else
            {
                txtCity.text =  [[tempArraySelcted valueForKey:@"description"] componentsJoinedByString:@","];
            }
        }
        
        txtCourse.text = @"All";

    }
    else if(buttonTapped == kButtonHomeCourse) {
        if([tempArraySelcted count]>0)
        {
            if([tempArraySelcted containsObject:@"All"] && [tempArraySelcted count]>1)
            {
                txtCourse.text = @"All";
            }
            else
            {
                txtCourse.text =  [[tempArraySelcted valueForKey:@"description"] componentsJoinedByString:@","];
            }
        }
    }
    else if(buttonTapped == kButtonType) {
        
        if([tempArraySelcted count]>0)
            txtType.text =  [[tempArraySelcted valueForKey:@"description"] componentsJoinedByString:@","];

    }
}

//-----------------------------------------------------------------------

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) savesettings
{
    [object.fields setObject:[Gender componentsJoinedByString:@","]  forKey:@"Gender"];
    [object.fields setObject:txtState.text forKey:@"State"];
    [object.fields setObject:txtCourse.text forKey:@"Course"];
    [object.fields setObject:txtName.text forKey:@"Name"];
    [object.fields setObject:txtAge.text  forKey:@"Age"];
    [object.fields setObject:txtType.text  forKey:@"Type"];
    
    [object.fields setObject:txtHandicap.text forKey:@"Handicap"];
    [object.fields setObject:[txtCity.text componentsSeparatedByString: @","] forKey:@"City"];

    [object.fields setObject:@"Course" forKey:@"Location"];
    
    object.className = @"UserSearch";
    
    [[AppDelegate sharedinstance] showLoader];
    
    NSString *searchType = ![self IsPro] ? kuserSearchUser : kuserSearchPro;
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        // object updated
        
        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:searchType ] mutableCopy];
        [dictUserData setObject:[Gender componentsJoinedByString:@","] forKey:@"Gender"];
        
        [dictUserData setObject:[txtCity.text componentsSeparatedByString: @","] forKey:@"City"];
        [dictUserData setObject:txtState.text forKey:@"State"];
        [dictUserData setObject:txtName.text forKey:@"Name"];
        [dictUserData setObject:txtCourse.text forKey:@"Course"];

        [dictUserData setObject:txtAge.text forKey:@"Age"];
        [dictUserData setObject:txtType.text forKey:@"Type"];
        [dictUserData setObject: txtHandicap.text forKey:@"Handicap"];

        [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:searchType];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
        
        if([cameFromScreen isEqualToString:kScreenViewUsers]) {

            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) changeData {
    [tempArraySelcted removeAllObjects];
    [minMaxView setHidden:YES];
    
    
    if(buttonTapped == kButtonCity) {
        NSString *strStateSelected = txtState.text;
        
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
        
        NSArray *citiesSelected = [txtCity.text componentsSeparatedByString: @","];
        
        for(NSString *str in citiesSelected)
        {
            [tempArraySelcted addObject:str];
        }
       
    }
    else if(buttonTapped == kButtonState) {

        tblMembers.allowsMultipleSelection = NO;
    }
    else if(buttonTapped == kButtonHomeCourse) {
        arrHomeCourseList = [[NSMutableArray alloc] init];
        arrHomeCoursesObjects = [[NSMutableArray alloc] init];

        NSString *strCity = txtCity.text;
        [[AppDelegate sharedinstance] showLoader];
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:strCity forKey:@"City[in]"];
        
        [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            [[AppDelegate sharedinstance] hideLoader];
            
            // checking user there in custom user table or not.
            
            if([objects count]>0) {
                
                for(QBCOCustomObject *obj in objects) {
                    
                    NSString *strname = [obj.fields objectForKey:@"Name"];
                    
                    //arrHomeCourses
                    [arrHomeCourseList addObject:strname];
                }
                
            }
            
            [arrHomeCourseList addObject:@"All"];

            tblMembers.allowsMultipleSelection = NO;
            [tblMembers reloadData];

        }
                             errorBlock:^(QBResponse *response) {
                                 // error handling
                                 [[AppDelegate sharedinstance] hideLoader];
                                 
                                 NSLog(@"Response error: %@", [response.error description]);
                             }];
        
    }
    else if(buttonTapped == kButtonType)
    {
        [arrTypeList removeAllObjects];
        NSMutableDictionary *proType = [[AppDelegate sharedinstance] getAllProIcons];
        
        for(NSString *type in proType.allKeys)
        {
            [arrTypeList addObject:[[type capitalizedString] stringByReplacingOccurrencesOfString:@"Pga" withString:@"PGA"]];
        }
        
        [arrTypeList insertObject:@"All" atIndex:0];
        tblMembers.allowsMultipleSelection = YES;

    }
    
    [tblMembers reloadData];
    
}

//-----------------------------------------------------------------------

-(IBAction)resetFilters:(id)sender
{
    [Gender removeAllObjects];
    [Gender addObject:@"male"];
    [Gender addObject:@"female"];
    [btnMale setImage:[UIImage imageNamed:@"guestmalefilled"] forState:UIControlStateNormal];
    [btnFemale setImage:[UIImage imageNamed:@"guestfemalefilled"] forState:UIControlStateNormal];
    
    [txtType setText:@"All"];
    [txtAge setText:@"18-100"];
    [txtCity setText:@"All"];
    [txtState setText:@"All"];
    [txtCourse setText:@"All"];
    [txtName setText:@""];
    
    [txtHandicap setText:@"5 - -40"];
    [handicapButton setEnabled:YES];
    
    [btnNA setTitle:@"NA: YES" forState:UIControlStateNormal];
    
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
    else if(buttonTapped == kButtonAge) {
        
        return [arrAgeList count];

    }
    else if(buttonTapped == kButtonState) {
        
        return [arrStateList count];
        
    }
    else if(buttonTapped == kButtonHomeCourse) {
        
        return [arrHomeCourseList count];
        
    }
    return 0;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifier = @"SendMessageCellTableViewCell";
    SendMessageCellTableViewCell *SendMessageCell =(SendMessageCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SendMessageCell.backgroundView=nil;
    SendMessageCell.backgroundColor=[UIColor clearColor];
    
    [SendMessageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    if (SendMessageCell == nil) {
        NSArray *cell = [[NSBundle mainBundle]loadNibNamed:@"SendMessageCellTableViewCell" owner:self options:nil];
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
    else if(buttonTapped == kButtonHomeCourse) {
        str = [arrHomeCourseList objectAtIndex:indexPath.row];
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
    
    SendMessageCellTableViewCell *ObjCirCell =(SendMessageCellTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    
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
    
       else  if(buttonTapped == kButtonType){
        [tempArraySelcted removeAllObjects];

        str = [arrTypeList objectAtIndex:indexPath.row];
        if (![tempArraySelcted containsObject:str]) {
            
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted addObject:str];
        }
    }
   
    else  if(buttonTapped == kButtonHomeCourse) {
        str = [arrHomeCourseList objectAtIndex:indexPath.row];
        
        if ([tempArraySelcted containsObject:str]) {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted removeObject:str];
        }
        else {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted addObject:str];
        }
    }

    
    
   [tblMembers reloadData];
}

//-----------------------------------------------------------------------

#pragma mark - Alert View Methods

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView tag]==300) {
        
        NSString *newpassword = [alertView textFieldAtIndex:0].text;
        
        if (buttonIndex == 0) {
            
        } else {
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [newpassword stringByTrimmingCharactersInSet:whitespace];
            
            if([trimmed length]<8 ) {
                [[AppDelegate sharedinstance] displayMessage:@"Password should be of atleast eight characters"];
                return;
            } else {
 
              [[AppDelegate sharedinstance] showLoader];
                
                QBUUser *user = [QBUUser user];
                user.ID = [[[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID] integerValue];
                
                QBUpdateUserParameters *updateParameters = [QBUpdateUserParameters new];
                updateParameters.password = newpassword;
                updateParameters.oldPassword = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];
                [QBRequest updateCurrentUser:updateParameters successBlock:^(QBResponse *response, QBUUser *user) {
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Password successfully changed."];
                    
             } errorBlock:^(QBResponse *response) {
                    // Handle error
                 [[AppDelegate sharedinstance] hideLoader];
                 [[AppDelegate sharedinstance] displayMessage:@"Some error occured"];
                }];
              }
        }
    }
    else if(alertView.tag==121) {
        if (buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];

        }
        else if (buttonIndex == 1)
        {
            [self savesettings];
        }
    }
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark - IAP

//-----------------------------------------------------------------------

-(void) purchaseCall {
    
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:@"com.product.fullversion"]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
        
    }
}

//-----------------------------------------------------------------------

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchaseCall];
        
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (IBAction)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) restore{
   }

- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %i", queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIAPFULLVERSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self doRemoveAds];
            
            
            break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

//-----------------------------------------------------------------------

- (void)doRemoveAds {
    
    // Change isDownloaded to 1 for langid and lesson id
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIAPFULLVERSION];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //    int currentPurchasedConnects = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userPurchasedConnects"] integerValue];
    //    currentPurchasedConnects = currentPurchasedConnects + 4;
    //
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"UserInfo";
    object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
    
    [object.fields setObject:[NSString stringWithFormat:@"%d",1]  forKey:@"userFullMode"];
    
    //    [object.fields setObject:[NSString stringWithFormat:@"%d",currentPurchasedConnects]  forKey:@"userPurchasedConnects"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        
        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
        [dictUserData setObject:[NSString stringWithFormat:@"%d",1] forKey:@"userFullMode"];
        [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[AppDelegate sharedinstance] displayMessage:@"Purchases restored successfully.\nSuccessfully upgraded to full version"];
        [[AppDelegate sharedinstance] hideLoader];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    } errorBlock:^(QBResponse *response) {
        
        [[AppDelegate sharedinstance] hideLoader];
        NSLog(@"Response error: %@", [response.error description]);
    }];

}

-(void) viewWillDisappear:(BOOL)animated {
    self.menuContainerViewController.panMode = YES;

}

//-----------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource

//-----------------------------------------------------------------------


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    switch(pickerOption)
    {
        case kPickerState:
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
            txtState.text = [arrStateList objectAtIndex:row];
            txtCity.text = @"All";
            [tempArraySelcted removeAllObjects];
            break;
    }
    
}

-(IBAction)HandicapTapped:(id)sender
{
    txtHandicap.text = [handicapSwitch isOn] ? @"5 - -40" : @"All";
    handicapButton.enabled = [handicapSwitch isOn];
    
    [viewToolbar setHidden:YES];
    [minMaxView setHidden:YES];
    [minMax setHidden:YES];
    
}

-(BOOL) prefersStatusBarHidden {
    return NO;
}

@end
