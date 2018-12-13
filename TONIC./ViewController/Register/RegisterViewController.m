//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "RegisterViewController.h"
#import "HomeViewController.h"
#import "PDFViewController.h"

#define kPickerBday 1
#define kPickerCity 2
#define kPickerState 3
#define kPickerHandicap 4
#define kPickerCourses 5

NSString *const constPasswordLimit = @"Maximum 10 Characters allowed for password.";
NSString *const constEmailLimit = @"Maximum 50 Characters allowed for Email.";
NSString *const constNameLimit = @"Maximum 50 Characters allowed for Name.";
NSString *const constZipcodeLimit = @"Maximum 10 Characters allowed for Zipcode.";


@interface RegisterViewController ()
{
    int currentPageCity;
    NSString *selectedState;
    int manageEmptyCityAndCourseArr;
}
@end

@implementation RegisterViewController
@synthesize HUD;

-(void) viewWillAppear:(BOOL)animated {
    [AppDelegate sharedinstance].currentScreen = kScreenRegister;
    
    manageEmptyCityAndCourseArr = 0;
    
    if(autocompletePlaceStatus == -1) {
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        if([strlat length]==0)
        {
            // Show 2 options to get location
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location will only be used when app is opened"
                                                            message:@"ParTee needs location access to show near by courses and golfers" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Detect automatically",@"Add manually",nil];
            alert.tag=121;
            [alert show];
        }
    }
    else if(autocompletePlaceStatus==2)  {
        [self signUpUser];
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
     currentPageCity = 0;
    [self updateViewConstarints];

  //[self sampleFillUser];
    [btnCheckmark setTag:200];
    
    strImgURLBase=@"";
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [[AppDelegate sharedinstance] hideLoader];
    

    [txtName setTag:101];
    [txtEmail setTag:102];
    [txtPwd setTag:103];
    [txtBday setTag:104];
    [txtState setTag:105];
    [txtCity setTag:106];
    [txtHomeCourse setTag:107];
    [txtZipCode setTag:108];
    [txtHandicap setTag:109];
    [tvInfo setTag:110];
    txtZipCode.keyboardType = UIKeyboardTypeNumberPad;
    datePicker.maximumDate=[NSDate date];
    datePicker.backgroundColor=[UIColor whiteColor];
    
    txtBday.inputView=datePicker;
    txtCity.inputView=pickerView;
    txtState.inputView=pickerView;
    txtHandicap.inputView = pickerView;
    txtHomeCourse.inputView = pickerView;

    txtHandicap.text = @"N/A";
  // txtHomeCourse.text = @"N/A";
    txtHomeCourse.text = @"";

//    arrStateList = [NSArray arrayWithObjects:@"Montana",nil];
//    arrCityList = [NSArray arrayWithObjects:@"Bozeman",@"Billings",@"Butte",@"Big Sky",@"Kalispell",@"Livingston",@"All",nil];
    
    arrStateList = [[NSMutableArray alloc] init];
    arrCityList = [[NSMutableArray alloc] init];
    arrHomeCourses= [[NSMutableArray alloc] init];
    
    [self setupHandicapArray];
    
    tvInfo.placeholder = @"Enter something about you";
    
    tvInfo.placeholderTextColor = [UIColor colorWithRed:0.780 green:0.780 blue:0.804 alpha:1.00];
    //tvInfo.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    NSArray *fields = @[ txtName,txtEmail,txtPwd,txtBday,txtState,txtCity,txtHomeCourse,txtZipCode,txtHandicap,tvInfo];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

    imgViewProfilePic.layer.cornerRadius = imgViewProfilePic.frame.size.width/2;
    [imgViewProfilePic.layer setMasksToBounds:YES];
    [imgViewProfilePic.layer setBorderColor:[UIColor clearColor].CGColor];

    self.navigationController.navigationBarHidden=YES;
    
    self.menuContainerViewController.panMode = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLocation) name:@"gotLocation" object:nil];

    if(isiPhone4) {
        
     
    }
    
    //  [self getLocationDataFromServer];
    [self getStateList];
}
#pragma mark- Get State List
/**
 @Description
 * This method will fetch state list from quickblox table.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getStateList {
    
    [[AppDelegate sharedinstance] showLoader];
    
    
    [QBRequest objectsWithClassName:@"StateList" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            NSString *strState = [obj.fields objectForKey:@"StateName"];
            
            if(![arrStateList containsObject:strState])
            {
                [arrStateList addObject:strState];
            }
            
        }
        
    //    txtState.text = [arrStateList objectAtIndex:0];
   //     selectedState  = [arrStateList objectAtIndex:0];
        [arrStateList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arrStateList insertObject:@"Select State" atIndex:0];
  //   [self getcityList];
        [pickerView reloadAllComponents];
        [[AppDelegate sharedinstance] hideLoader];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark- Get City List
/**
 @Description
 * This method will fetch city list from GolfCourses table based on state selected.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getcityList
{
 //   [[AppDelegate sharedinstance] showLoader];
    
    NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
    [getRequestObjectCount setObject: selectedState forKey:@"State"];
    
    [getRequestObjectCount setObject:@"100" forKey:@"limit"];
    NSString *strPage = [NSString stringWithFormat:@"%d",[@"100" intValue] * currentPageCity];
    
    [getRequestObjectCount setObject:strPage forKey:@"skip"];
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequestObjectCount successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            NSString *strCity = [obj.fields objectForKey:@"City"];
            
            if(![arrCityList containsObject:strCity])
            {
                [arrCityList addObject:strCity];
            }
        }
        
        currentPageCity++;
        if (objects.count < 100) {
            
            [arrCityList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [arrCityList insertObject:@"Select City" atIndex:0];
            [pickerView reloadAllComponents];
            [[AppDelegate sharedinstance] hideLoader];
            
        }else {
            [self getcityList];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(void) getLocationDataFromServer {
    
    [[AppDelegate sharedinstance] showLoader];

    [QBRequest objectsWithClassName:@"Location" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        [[AppDelegate sharedinstance] hideLoader];
        arrData=objects;
        
        for(int i=0;i<[arrData count];i++) {
            
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            NSString *strName = [obj.fields objectForKey:@"stateName"];

            if(![arrStateList containsObject:strName]) {
                [arrStateList addObject:strName];
            }
            
            strName = [obj.fields objectForKey:@"cityName"];
            
            if(![arrCityList containsObject:strName]) {
                [arrCityList addObject:strName];
            }
        }
        
        txtState.text = [arrStateList objectAtIndex:0];
        txtCity.text = [arrCityList objectAtIndex:0];

    }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
    
}

-(void) getCoursesForSelection {
    
    
    NSString *strCity = txtCity.text;
    
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:strCity forKey:@"City"];
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
       
        
        // checking user there in custom user table or not.
        arrHomeCourses = [[NSMutableArray alloc] init];
        arrHomeCoursesObjects = [[NSMutableArray alloc] init];
        arrHomeCoursesObjects = [objects mutableCopy];
        
        if([objects count]>0) {
            
            for(QBCOCustomObject *obj in objects) {
                
                NSString *strname = [obj.fields objectForKey:@"Name"];
                
                //arrHomeCourses
                [arrHomeCourses addObject:strname];
            }
            
        }
        
        if([arrHomeCourses count]==0) {
            
            [arrHomeCourses addObject:@"N/A"];
        }
      
        [arrHomeCourses sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arrHomeCourses insertObject:@"Select Golf Course" atIndex:0];
        [pickerView reloadAllComponents];
        [pickerView selectRow:0 inComponent:0 animated:YES];
         [[AppDelegate sharedinstance] hideLoader];
    }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}

-(BOOL) validateData {

    
    if([[[AppDelegate sharedinstance] nullcheck:txtName.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtEmail.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    NSString *errorMessage;
    
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    if (![emailPredicate evaluateWithObject:txtEmail.text]){
        errorMessage = @"Please enter a valid email address";
        
        [[AppDelegate sharedinstance] displayMessage:errorMessage];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtPwd.text] length]<8) {
        [[AppDelegate sharedinstance] displayMessage:@"Password should be of atleast eight characters"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtBday.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }

    
    if([[[AppDelegate sharedinstance] nullcheck:txtState.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }

    
    if([[[AppDelegate sharedinstance] nullcheck:txtCity.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }

    
    if([[[AppDelegate sharedinstance] nullcheck:txtZipCode.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtHandicap.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtHomeCourse.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:tvInfo.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }

    if([btnCheckmark tag]==200) {
        [self.view makeToast:@"You need to agree to terms to proceed"
                    duration:2.0
                    position:CSToastPositionBottom];
        
        return NO;
    }
    
    return YES;
}

#pragma mark- updateViewConstarintd
// updateViewConstarintd according to device

-(void)updateViewConstarints {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    
    scrollViewContainer.frame = CGRectMake(scrollViewContainer.frame.origin.x, scrollViewContainer.frame.origin.y, screenWidth, screenHeight);
    
    imgViewProfilePic.frame =  CGRectMake((screenWidth - 95 )/2, 20, 95, 95);
    cameraBtn.frame = CGRectMake((screenWidth - 95 )/2, 20, 95, 95);
    segmentGender.frame = CGRectMake((screenWidth - 222)/2, imgViewProfilePic.frame.origin.y + imgViewProfilePic.frame.size.height + 18, 222, 28);
    nameBaseView.frame = CGRectMake((screenWidth - 286)/2, nameBaseView.frame.origin.y, 286, 43);
    mailBaseView.frame = CGRectMake((screenWidth - 286)/2, mailBaseView.frame.origin.y, 286, 43);
    pwdBaseView.frame = CGRectMake((screenWidth - 286)/2, pwdBaseView.frame.origin.y, 286, 60);
    dobBaseView.frame = CGRectMake((screenWidth - 286)/2, dobBaseView.frame.origin.y, 286, 60);
    stateBaseView.frame = CGRectMake((screenWidth - 286)/2, stateBaseView.frame.origin.y, 286, 60);
    cityBaseView.frame = CGRectMake((screenWidth - 286)/2, cityBaseView.frame.origin.y, 286, 60);
    homeCourseBaseView.frame = CGRectMake((screenWidth - 286)/2, homeCourseBaseView.frame.origin.y, 286, 60);
    zipCodeBaseView.frame = CGRectMake((screenWidth - 286)/2, zipCodeBaseView.frame.origin.y, 286, 60);
    handicapBaseView.frame = CGRectMake((screenWidth - 286)/2, handicapBaseView.frame.origin.y, 286, 60);
    aboutBaseView.frame = CGRectMake((screenWidth - 286)/2, aboutBaseView.frame.origin.y, 286, 60);
    saveBaseVieqw.frame = CGRectMake(0, saveBaseVieqw.frame.origin.y, screenWidth, 60);
    btnCheckmark.frame = CGRectMake(aboutBaseView.frame.origin.x + 19 , btnCheckmark.frame.origin.y, 20, 20);
    btnCheckBig.frame = CGRectMake(btnCheckmark.frame.origin.x - 11, btnCheckBig.frame.origin.y, 34, 35);
    agreeBtn.frame = CGRectMake(btnCheckBig.frame.origin.x + 34 + 5, agreeBtn.frame.origin.y, 239, 25);
    privacyBtn.frame = CGRectMake(btnCheckBig.frame.origin.x + 34 + 5,privacyBtn.frame.origin.y , 239, 20);
    
    scrollViewContainer.contentSize = CGSizeMake(screenWidth, saveBaseVieqw.frame.origin.y + saveBaseVieqw.frame.size.height + 200 );
    doneBtnImg.frame = CGRectMake((screenWidth - 273 )/2, doneBtnImg.frame.origin.y, 273, 46);
    DoneBtn.frame = CGRectMake((screenWidth - 273 )/2, DoneBtn.frame.origin.y, 273, 46);
    
    if (screenWidth == 375) {
        narrowLineView1.frame = CGRectMake(114 + 34 , narrowLineView1.frame.origin.y, 119, 1);
        narrowLineView2.frame = CGRectMake( 5 + btnCheckBig.frame.origin.x + btnCheckBig.frame.size.width , narrowLineView2.frame.origin.y, narrowLineView2.frame.size.width, 1);
    }else if (screenWidth == 414) {
        narrowLineView1.frame = CGRectMake(114 + 34 , narrowLineView1.frame.origin.y, 119, 1);
        narrowLineView2.frame = CGRectMake( 5 + btnCheckBig.frame.origin.x + btnCheckBig.frame.size.width , narrowLineView2.frame.origin.y, narrowLineView2.frame.size.width, 1);
    }else if (screenWidth == 320) {
        narrowLineView1.frame = CGRectMake(114 + 5 , narrowLineView1.frame.origin.y, 119, 1);
        narrowLineView2.frame = CGRectMake( 5 + btnCheckBig.frame.origin.x + btnCheckBig.frame.size.width , narrowLineView2.frame.origin.y, narrowLineView2.frame.size.width, 1);
    }
    
    
}
//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//-----------------------------------------------------------------------

-(void) sampleFillUser {
    
    [txtName setText:@"Diana Rissusa"];
    [txtEmail setText:@"diana@gmail.com"];
    [txtPwd setText:@"12345678"];
    [txtBday setText:@"10/10/1980"];
    [txtState setText:@"Montana"];
    [txtCity setText:@"Bozeman"];
    [txtZipCode setText:@"59718"];
    [txtHandicap setText:@"10"];
    [tvInfo setText:@"I'm a golfer"];
    
//    [txtName setText:@"Developer"];
//    [txtEmail setText:@"hoodacreations@gmail.com"];
//    [txtPwd setText:@"12345678"];
//    [txtBday setText:@"12/11/1980"];
//    [txtState setText:@"Montana"];
//    [txtCity setText:@"Kalispell"];
//    [txtZipCode setText:@"300010"];
//    [txtHandicap setText:@"10"];
//    [tvInfo setText:@"I'm a developer"];
//    
//    [txtName setText:@"Demo"];
//    [txtEmail setText:@"developer.roadies@gmail.com"];
//    [txtPwd setText:@"12345678"];
//    [txtBday setText:@"02/11/1980"];
//    [txtState setText:@"Montana"];
//    [txtCity setText:@"Kalispell"];
//    [txtZipCode setText:@"300010"];
//    [txtHandicap setText:@"11"];
//    [tvInfo setText:@"I'm a good guy"];
    
}

-(void) registerForNotifications {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}


- (IBAction)action_CreateAccount:(id)sender  {
    
    [self.view endEditing:YES];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
    [UIView commitAnimations];
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    if([self validateData]) {
        
        // take location here
        
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
            if([strlat length]==0)
        {
            // Show 2 options to get location
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location will only be used when app is opened"
                                                            message:@"ParTee needs location access to show near by courses and golfers" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Detect automatically",@"Add manually",nil];
            alert.tag=121;
            [alert show];
            
        }
        else {
            [self signUpUser];

        }

    }
}

//-----------------------------------------------------------------------

-(NSString *) getHomeCourseIdFromName : (NSString *) strName
{
    
    for(QBCOCustomObject *obj in arrHomeCoursesObjects) {
        
        NSString *strGolfName = [obj.fields objectForKey:@"Name"];
        NSString *strGolfId = obj.ID;

        if([strName isEqualToString:strGolfName]) {
            
            return strGolfId;
        }
    }
    
    return @"N/A";

}

//-----------------------------------------------------------------------

-(void) sendtagForAgerange {
    
//    Age-18-29  (agerange = 1)
//    Age-30-39  (agerange = 2)
//    Age-40-49 (agerange = 3)
//    Age-50-59 (agerange = 4)
//    Age-60+ (agerange = 5)
    
    NSString *stringAgeRange;
    
    if(age>17 && age<30) {
        stringAgeRange=@"1";
    }
    else if(age>29 && age<40) {
        stringAgeRange=@"2";
    }
    else if(age>39 && age<50) {
        stringAgeRange=@"3";
    }
    else if(age>49 && age<60) {
        stringAgeRange=@"4";
    }
    else if(age>59) {
        stringAgeRange=@"5";
    }else {
         stringAgeRange=@"0";
    }
    
    NSString *stringGender;
    
    if(segmentGender.selectedSegmentIndex==0)
    {
        // male
        stringGender=@"gender-male";
    }
    else {
        // female
        stringGender=@"gender-female";
    }

    int handicapval = [txtHandicap.text intValue];
    
//    handicap-greaterorequalto0
//    handicap-1to-8
//    handicap-9to-16
//    handicap-17to-24
//    handicap-25to-32
//    handicap-33to-40

    NSString *stringHandicap;
    
    if(handicapval>=0) {
        stringHandicap=@"1"; //All “+X” and “0” values
    }
    else if(handicapval>=-8 && handicapval<=-1) {
        stringHandicap=@"2"; //-1 through -8
    }
    else if(handicapval>=-16 && handicapval<=-9) {
        stringHandicap=@"3"; //-9 through -16
    }
    else if(handicapval>=-24 && handicapval<=-17) {
        stringHandicap=@"4"; //-17 through -24
    }
    else if(handicapval>=-32 && handicapval<=-25) {
        stringHandicap=@"5"; //-25 through -32
    }
    else if(handicapval>=-40 && handicapval<=33) {
        stringHandicap=@"6"; //-33 through -40
    }
    
    NSString *stringCity=txtCity.text;
    stringCity = [stringCity stringByReplacingOccurrencesOfString:@" " withString:@""];
    stringCity = [NSString stringWithFormat:@"City-%@",stringCity];
    
    [OneSignal sendTags:@{@"agerange" : stringAgeRange, @"gender" : stringGender, @"handicap" : stringHandicap, @"city" : stringCity}];
    
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    //
    //    }];
    //
}

//-----------------------------------------------------------------------

-(IBAction)cameraPressed:(id)sender {
    
    [self.view endEditing:YES];

    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    
}

-(IBAction)dateChanged:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    formatter.dateFormat = @"dd/MM/yyyy";
    NSString *string = [formatter stringFromDate:datePicker.date];
    txtBday.text=string;
}



-(IBAction)Termstapped:(id)sender {
    NSString *strWebsite = @"https://www.partee.golf/terms-and-conditions";
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }
}



    
-(IBAction)Privacytapped:(id)sender {
    NSString *strWebsite = @"https://www.partee.golf/privacy";
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }
}

-(IBAction)checkmarkPressed:(id)sender {
    
    
    if([btnCheckmark tag]==200) {
        // Activate it
        [btnCheckmark setBackgroundImage:[UIImage imageNamed:@"check-filled"] forState:UIControlStateNormal];
        
        [btnCheckmark setTag:201];
    }
    else {
        // Deactivate it
        
        [btnCheckmark setBackgroundImage:[UIImage imageNamed:@"check-unfilled"] forState:UIControlStateNormal];
        
        [btnCheckmark setTag:200];
    }

}

//-----------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource

//-----------------------------------------------------------------------


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    if(pickerOption==kPickerState) {
        return arrStateList.count;
    }
    else if(pickerOption==kPickerCity) {
        return arrCityList.count;
    }
    else if(pickerOption==kPickerHandicap) {
        return arrHandicapList.count;
    }
    else if(pickerOption==kPickerCourses) {
        return arrHomeCourses.count;
    }

    return 10;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
    if(pickerOption==kPickerState) {
        return [arrStateList objectAtIndex:row];

    }
    else if(pickerOption==kPickerCity) {
        return [arrCityList objectAtIndex:row];

    }
    else if(pickerOption==kPickerHandicap) {
        return [arrHandicapList objectAtIndex:row];
    }
    else if(pickerOption==kPickerCourses) {
        
        return [arrHomeCourses objectAtIndex:row];
    }

    return @"";
}

//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", (long)row);
    
    
    if(pickerOption==kPickerState) {
        
        if ([[arrStateList objectAtIndex:row] isEqualToString:@"Select State"]) {
             txtState.text = @"";
             txtCity.text = @"";
             txtHomeCourse.text  = @"";
            
        }else {
            txtState.text = [arrStateList objectAtIndex:row];
            selectedState = [arrStateList objectAtIndex:row];
            currentPageCity = 0;
            txtCity.text = @"";
            
            [[AppDelegate sharedinstance] showLoader];
            if([arrCityList count]>0)
                [arrCityList removeAllObjects];
            [self getcityList];
        }
    }
    else if(pickerOption==kPickerCity) {
        if ([[arrCityList objectAtIndex:row] isEqualToString:@"Select City"]) {
             txtCity.text = @"";
             txtHomeCourse.text  = @"";
            
        }else {
            
        txtCity.text = [arrCityList objectAtIndex:row];
        txtHomeCourse.text = @"";
        [self getCoursesForSelection];
       
        }
    }
    else if(pickerOption==kPickerHandicap) {
        txtHandicap.text = [arrHandicapList objectAtIndex:row];

    }
    else if(pickerOption==kPickerCourses) {
        
        
        if ([[arrHomeCourses objectAtIndex:row] isEqualToString:@"Select Golf Course"]) {
            txtHomeCourse.text  = @"";
        }else {
            if([arrHomeCourses count]>0) {
                txtHomeCourse.text = [arrHomeCourses objectAtIndex:row];
                
            }
        }
        
        
    }
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark Keyboard Controls Delegate

//-----------------------------------------------------------------------

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *textFieldview;
    
    textFieldview = field.superview.superview;
    
    if([textFieldview tag]==101) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
        [UIView commitAnimations];
        
    }
    else if (field==tvInfo) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, textFieldview.center.y+65)animated:NO];
        [UIView commitAnimations];
        
    }
    else if([textFieldview tag]>101) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        
        NSLog(@"%ld",(43*([textFieldview tag]%10)));
        
        [scrollViewContainer setContentOffset:CGPointMake(0, 80 + (43*(([textFieldview tag]-1)%10))) animated:NO];
        [UIView commitAnimations];
        
    }
    
}

//-----------------------------------------------------------------------

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollViewContainer setContentOffset:CGPointMake(0, 0) animated:NO];
    [UIView commitAnimations];
    [self.view endEditing:YES];
}

//-----------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Methods

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    if([textField tag]==101) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
        [UIView commitAnimations];
        
    }
    else if([textField tag]>101) {

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        
        NSLog(@"%ld",(43*([textField tag]%10)));
        
        [scrollViewContainer setContentOffset:CGPointMake(0, 80 + (43*(([textField tag]-1)%10))) animated:NO];
        [UIView commitAnimations];
        
    }
    
    [self.keyboardControls setActiveField:textField];

    if(textField==txtBday) {
        pickerOption=kPickerBday;
    }
    else if(textField==txtHandicap) {
        pickerOption=kPickerHandicap;
        
        if([txtHandicap.text length]==0)
            txtHandicap.text = @"N/A";
    }
    else if(textField==txtState) {
        [pickerView selectRow:0 inComponent:0 animated:YES];
        pickerOption=kPickerState;
        
    //    if([txtState.text length]==0)
      //      txtState.text = [arrStateList objectAtIndex:0];
    }
    else if(textField==txtCity) {
        
        [txtState resignFirstResponder];
        
        if ([txtState.text isEqualToString:@""]) {
          
            if (manageEmptyCityAndCourseArr == 0) {
                manageEmptyCityAndCourseArr = 1;
                [textField resignFirstResponder];
                [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                [[AppDelegate sharedinstance] displayMessage:@"Please Select State first."];
                
                return NO;
            }else{
                [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                manageEmptyCityAndCourseArr = 0;
                [textField resignFirstResponder];
                
                return NO;
            }
        }else{
            if([arrCityList count] == 0) {
                
                if (manageEmptyCityAndCourseArr == 0) {
                    manageEmptyCityAndCourseArr = 1;
                    [textField resignFirstResponder];
                    [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                    [[AppDelegate sharedinstance] displayMessage:@"Please Select State first."];
                    
                    return NO;
                }else{
                    [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                    manageEmptyCityAndCourseArr = 0;
                    [textField resignFirstResponder];
                    
                    return NO;
                }
                
            }
        }
       
        
        [pickerView selectRow:0 inComponent:0 animated:YES];
        pickerOption = kPickerCity;
        
  //      NSString *strStateSelected = txtState.text;
        
//            if([arrCityList count]>0)
//                [arrCityList removeAllObjects];
//
//            for(int i=0;i<[arrData count];i++) {
//                QBCOCustomObject *obj = [arrData objectAtIndex:i];
//
//                NSString *strName = [obj.fields objectForKey:@"stateName"];
//
//                if([strName isEqualToString:strStateSelected]) {
//
//                    [arrCityList addObject:[obj.fields objectForKey:@"cityName"]];
//                }
//            }
        
        

    }else if(textField==txtHomeCourse) {
        
        [txtState resignFirstResponder];
        [txtCity resignFirstResponder];
        if ([txtState.text isEqualToString:@""] || [txtCity.text isEqualToString:@""]) {
            
            if (manageEmptyCityAndCourseArr == 0) {
                manageEmptyCityAndCourseArr = 1;
                [textField resignFirstResponder];
                [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                [[AppDelegate sharedinstance] displayMessage:@"Please Select State and City first."];
                return NO;
                
            }else{
                [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                manageEmptyCityAndCourseArr = 0;
                [textField resignFirstResponder];
                return NO;
            }
            
        }else{
            if([arrHomeCourses count] == 0) {
                
                if (manageEmptyCityAndCourseArr == 0) {
                    manageEmptyCityAndCourseArr = 1;
                    [textField resignFirstResponder];
                    [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                    [[AppDelegate sharedinstance] displayMessage:@"Please Select State and City first."];
                    return NO;
                    
                }else{
                    [scrollViewContainer setContentOffset:CGPointZero animated:YES];
                    manageEmptyCityAndCourseArr = 0;
                    [textField resignFirstResponder];
                    return NO;
                }
                
            }
        }
        
       
        
        pickerOption=kPickerCourses;
        
        if([txtHomeCourse.text length]==0)
           // txtHomeCourse.text = @"N/A";
           txtHomeCourse.text = @"";
        
        
    
    }
    else {
        pickerOption=6;
    }

    [pickerView reloadAllComponents];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    NSString *strStateSelected = txtState.text;
    
    if(textField ==txtState) {
        
//        if([arrCityList count]>0)
//            [arrCityList removeAllObjects];

        for(int i=0;i<[arrData count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            NSString *strName = [obj.fields objectForKey:@"stateName"];

            if([strName isEqualToString:strStateSelected]) {
                
                [arrCityList addObject:[obj.fields objectForKey:@"cityName"]];
            }
        }
        
        [pickerView reloadAllComponents];
    }
 
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger newLength = [textField.text length] + [string length] - range.length;
    // password characters limit
      if([textField tag]==103) {
          
          if (newLength <= 10) {
              return YES;
          }else{
              
            [textField resignFirstResponder];
              [self showAlertWithTitle:constPasswordLimit];
          }
          
      }else if ([textField tag]==101) {
          // name characters limit
          if (newLength <= 50) {
              return YES;
          }else{
              
              [textField resignFirstResponder];
              [self showAlertWithTitle:constNameLimit];
          }
          
      }else if ([textField tag]==108){
          // zipcode characters limit
          if (newLength <= 10) {
              return YES;
          }else{
              
              [textField resignFirstResponder];
              [self showAlertWithTitle:constZipcodeLimit];
          }
          
      }else if ([textField tag]==102){
          // Email characters limit
          if (newLength <= 50) {
              return YES;
          }else{
              
              [textField resignFirstResponder];
              [self showAlertWithTitle:constEmailLimit];
          }
          
      }
    
    return YES;
}

-(void)showAlertWithTitle:(NSString *)titleStr

{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Information" message:titleStr preferredStyle:UIAlertControllerStyleAlert];
    
    alertController.view.frame = [[UIScreen mainScreen] bounds];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action){
                                                      }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
//-----------------------------------------------------------------------

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

//-----------------------------------------------------------------------

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    
    [scrollViewContainer setContentOffset:CGPointMake(0, textView.center.y+460)animated:NO];
    [UIView commitAnimations];
    
    [self.keyboardControls setActiveField:textView];
}


//-----------------------------------------------------------------------

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    int i = buttonIndex;
    switch(i)
    {
        case 0:
        {
            if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                picker.delegate = self;
                self.imagePickerController = picker;
                //                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                picker.allowsEditing = YES;
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [self presentViewController:self.imagePickerController animated:YES completion:nil];
                }];
                
            }
            else {
                [[[UIAlertView alloc] initWithTitle:kAppName message:@"Device does not supports camera" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                return;
            }
        }
            break;
        case 1:
        {
            UIImagePickerController * picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePickerController = picker;
            picker.allowsEditing = YES;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
              
                }
                else {
                    [self presentViewController:self.imagePickerController animated:YES completion:nil];
                    
                }
            }];
        }
        default:
            // Do Nothing.........
            break;
    }
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    // Picking Image from Camera/ Library
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (!image)
    {
        return;
    }
    
    // Adjusting Image Orientations
    
    imgViewProfilePic.image=image;

    [picker dismissViewControllerAnimated:YES completion:^{}];

}

//-----------------------------------------------------------------------

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [imgViewProfilePic setAccessibilityIdentifier:@"default"] ;
   
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

//-----------------------------------------------------------------------

-(void)  localSave {
    NSMutableDictionary *dictUserDetails = [[NSMutableDictionary alloc] init];
    
    if(segmentGender.selectedSegmentIndex==0)
    {
        // male
        [dictUserDetails setObject:@"male" forKey:@"userGender"];
    }
    else {
        // female
        [dictUserDetails setObject:@"female" forKey:@"userGender"];
    }
    
    [dictUserDetails setObject:txtName.text forKey:@"userDisplayName"];
    [dictUserDetails setObject:txtCity.text forKey:@"userCity"];
    [dictUserDetails setObject:txtState.text forKey:@"userState"];
    [dictUserDetails setObject:txtZipCode.text forKey:@"userZipcode"];
    [dictUserDetails setObject:txtHandicap.text forKey:@"userHandicap"];
    [dictUserDetails setObject:tvInfo.text forKey:@"userInfo"];
    [dictUserDetails setObject:strImgURLBase forKey:@"userPicBase"];
    [dictUserDetails setObject:@"0" forKey:@"userFullMode"];
    [dictUserDetails setObject:txtEmail.text forKey:@"userEmail"];

   
    [dictUserDetails setObject:@"1" forKey:@"userPush"];
    [dictUserDetails setObject:@"0" forKey:@"userFullMode"];
    [dictUserDetails setObject:strCurrentUserId forKey:@"userInfoId"];
    

    [dictUserDetails setObject:[NSString stringWithFormat:@"%ld",(long)age] forKey:@"userAge"];
    
//    [dictUserDetails setObject:@"" forKey:@"isDevelopment"];

//    if([[AppDelegate sharedinstance].strisDevelopment  isEqualToString:@"1"]) {
//        [dictUserDetails setObject:@"1" forKey:@"isDevelopment"];
//    }
//    else {
//        [dictUserDetails setObject:@"" forKey:@"isDevelopment"];
//    }
    
    [dictUserDetails setObject:@"" forKey:@"isDevelopment"];

    [dictUserDetails setObject:txtHomeCourse.text forKey:@"home_coursename"];
    [dictUserDetails setObject:strHomeCourseID forKey:@"home_course_id"];
    https://www.linkedin.com/in/hoodacreations/
    [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:kuserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    
}

-(void) setupHandicapArray {
    arrHandicapList = [[NSMutableArray alloc] init];
    
    [arrHandicapList addObject:@"N/A"];
    [arrHandicapList addObject:@"-40"];
    [arrHandicapList addObject:@"-39"];
    [arrHandicapList addObject:@"-38"];
    [arrHandicapList addObject:@"-37"];
    [arrHandicapList addObject:@"-36"];
    [arrHandicapList addObject:@"-35"];
    [arrHandicapList addObject:@"-34"];
    [arrHandicapList addObject:@"-33"];
    [arrHandicapList addObject:@"-32"];
    [arrHandicapList addObject:@"-31"];
    [arrHandicapList addObject:@"-30"];
    [arrHandicapList addObject:@"-29"];
    [arrHandicapList addObject:@"-28"];
    [arrHandicapList addObject:@"-27"];
    [arrHandicapList addObject:@"-26"];
    [arrHandicapList addObject:@"-25"];
    [arrHandicapList addObject:@"-24"];
    [arrHandicapList addObject:@"-23"];
    [arrHandicapList addObject:@"-22"];
    [arrHandicapList addObject:@"-21"];
    [arrHandicapList addObject:@"-20"];
    [arrHandicapList addObject:@"-19"];
    [arrHandicapList addObject:@"-18"];
    [arrHandicapList addObject:@"-17"];
    [arrHandicapList addObject:@"-16"];
    [arrHandicapList addObject:@"-15"];
    [arrHandicapList addObject:@"-14"];
    [arrHandicapList addObject:@"-13"];
    [arrHandicapList addObject:@"-12"];
    [arrHandicapList addObject:@"-11"];
    [arrHandicapList addObject:@"-10"];

    [arrHandicapList addObject:@"-9"];
    [arrHandicapList addObject:@"-8"];
    [arrHandicapList addObject:@"-7"];
    [arrHandicapList addObject:@"-6"];
    [arrHandicapList addObject:@"-5"];
    [arrHandicapList addObject:@"-4"];
    [arrHandicapList addObject:@"-3"];
    [arrHandicapList addObject:@"-2"];
    [arrHandicapList addObject:@"-1"];
    [arrHandicapList addObject:@"0"];

    [arrHandicapList addObject:@"1"];
    [arrHandicapList addObject:@"2"];
    [arrHandicapList addObject:@"3"];
    [arrHandicapList addObject:@"4"];
    [arrHandicapList addObject:@"5"];
    [arrHandicapList addObject:@"6"];
    [arrHandicapList addObject:@"7"];
    [arrHandicapList addObject:@"8"];
    [arrHandicapList addObject:@"9"];
    [arrHandicapList addObject:@"10"];

    
}

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == 121) {
        
        if (buttonIndex == 0) {
            
            // automatic
            
            [[AppDelegate sharedinstance] locationInit];
            
        }
        else {
            
            // manual
            [self manualAdd];

        }
    }
}

-(void) signUpUser {

    QBUUser *user = [QBUUser user];
    user.fullName = txtName.text;
    user.password = txtPwd.text;
    
    user.email = txtEmail.text;
    [[AppDelegate sharedinstance] showLoader];
    
    // Registration/sign up of User
    [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
        [[AppDelegate sharedinstance] setStringObj:txtPwd.text forKey:kuserPassword];
        
        [QBRequest logInWithUserEmail:txtEmail.text password:txtPwd.text successBlock:^(QBResponse *response, QBUUser *user) {
            
            NSData *imageData = UIImageJPEGRepresentation(imgViewProfilePic.image, .7);
            
            [QBRequest TUploadFile:imageData fileName:@"Profile.jpg" contentType:@"image/jpg" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
                NSString *url = [blob publicUrl];
                
                strImgURLBase=url;
                
                [[AppDelegate sharedinstance] setStringObj:txtEmail.text forKey:kuserEmail];
                
                QBCOCustomObject *localObject = [QBCOCustomObject customObject];
                localObject.className = @"UserInfo"; // your Class name
                
                if(segmentGender.selectedSegmentIndex==0)
                {
                    // male
                    [localObject.fields setObject:@"male" forKey:@"userGender"];
                }
                else {
                    // female
                    [localObject.fields setObject:@"female" forKey:@"userGender"];
                }
                
                
                [localObject.fields setObject:txtEmail.text forKey:@"userEmail"];
                
                [localObject.fields setObject:txtName.text forKey:@"userDisplayName"];
                [localObject.fields setObject:txtBday.text forKey:@"userBday"];
                [localObject.fields setObject:txtCity.text forKey:@"userCity"];
                [localObject.fields setObject:txtState.text forKey:@"userState"];
                
                age = [[AppDelegate sharedinstance] getAge:txtBday.text ] ;
                
                [localObject.fields setObject:[NSNumber numberWithInteger:age] forKey:@"userAge"];
                
                
                [localObject.fields setObject:@"1" forKey:@"userDeviceType"];
                
                [localObject.fields setObject:txtZipCode.text forKey:@"userZipcode"];
                [localObject.fields setObject:txtHandicap.text forKey:@"userHandicap"];
                [localObject.fields setObject:txtHandicap.text forKey:@"userHandicap"];
                [localObject.fields setObject:tvInfo.text forKey:@"userInfo"];
                
                
                [[AppDelegate sharedinstance] setStringObj:@"0" forKey:@"userPurchasedConnects"];
                [[AppDelegate sharedinstance] setStringObj:@"10" forKey:@"userFreeConnects"];
 /********** ChetuChange *************/
                [localObject.fields setObject:@"0" forKey:@"userPurchasedConnects"];
                [localObject.fields setObject:@"10" forKey:@"userFreeConnects"];
  /********** ChetuChange *************/
                [localObject.fields setObject:@"1" forKey:@"userPush"];
                [localObject.fields setObject:@"0" forKey:@"userFullMode"];
                [localObject.fields setObject:@"0" forKey:@"userNumberOfBlocks"];
                
                [localObject.fields setObject:strImgURLBase forKey:@"userPicBase"];
                [localObject.fields setObject:@"" forKey:@"isDevelopment"];
                
                
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"advertisingBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"spamBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"contentBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"stolenBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"abusiveBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"otherBlockCount"];
                
                [localObject.fields setObject:[NSNumber numberWithInteger:1] forKey:@"user_type"];
                
                [localObject.fields setObject:txtHomeCourse.text forKey:@"home_coursename"];
               
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"UserRole"];
                strHomeCourseID = [self getHomeCourseIdFromName:txtHomeCourse.text];
                [localObject.fields setObject:strHomeCourseID forKey:@"home_course_id"];
                
                
                strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
                strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
                
                strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
                strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
                
                NSString *strPoint = [NSString stringWithFormat:@"%f,%f",[strlong floatValue],[strlat floatValue]];
                [localObject.fields setObject:strPoint forKey:@"current_location"];
                
                
                //                    if([[AppDelegate sharedinstance].strisDevelopment isEqualToString:@"1"]) {
                //                        [object.fields setObject:@"1" forKey:@"isDevelopment"];
                //
                //                    }
                //                    else {
                //                        [object.fields setObject:@"" forKey:@"isDevelopment"];
                //                    }
                
                [QBRequest createObject:localObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                    [self sendtagForAgerange];
                    
                    [[AppDelegate sharedinstance] setStringObj:object.ID forKey:kuserInfoID];
                    
                    // do something when object is successfully created on a server
                    strCurrentUserId= [NSString stringWithFormat:@"%lu",(unsigned long)user.ID];
                    
                    [[AppDelegate sharedinstance] setStringObj:strCurrentUserId forKey:kuserDBID];
                    [[AppDelegate sharedinstance] setStringObj:strCurrentUserId forKey:@"userQuickbloxID"];
                    
                    
                    [self localSave];
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    //                        [[AppDelegate sharedinstance] displayMessage:@"Account successfully created"];
                    
                    [self registerForNotifications];
                    
                    //                        ViewUsersViewController *viewController=[[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                    //                        viewController.strIsMyMatches=@"1";
                    
                    SpecialsViewController *vc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                    ((SpecialsViewController*)vc).strIsMyCourses=@"0";
                    
                    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
                    SideMenuViewController *leftMenuViewController;
                    leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
                    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                                    containerWithCenterViewController:nav
                                                                    leftMenuViewController:leftMenuViewController
                                                                    rightMenuViewController:nil];
                    container.panMode=YES;
                    
                    [[AppDelegate sharedinstance].window setRootViewController:container];
                    
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayServerErrorMessage];
                    
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
                
            } errorBlock:^(QBResponse *response) {
                
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayServerErrorMessage];
                
                NSLog(@"error: %@", response.error);
            }];
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
            [[AppDelegate sharedinstance] hideLoader];
            
        }];
        
    } errorBlock:^(QBResponse *response) {
        // Handle error here
        [[AppDelegate sharedinstance] hideLoader];
        
        if(response.status==422) {
            [[AppDelegate sharedinstance] displayMessage:@"Email has already been taken"];
        }
        else {
            [[AppDelegate sharedinstance] displayServerErrorMessage];
            
        }
        
        autocompletePlaceStatus = 3;

       [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void) gotLocation {
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    [self signUpUser];
}

-(void) manualAdd {
    // manual
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    autocompletePlaceStatus=2;
    
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    
    // txtAddress.text = place.formattedAddress;
    NSString *strLat = [NSString stringWithFormat:@"%f", place.coordinate.latitude];
    NSString *strLong = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    [[AppDelegate sharedinstance] setStringObj:strLat forKey:klocationlat];
    [[AppDelegate sharedinstance] setStringObj:strLong forKey:klocationlong];
    
    NSLog(@"Place attributions %@", place.attributions.string);
   [self signUpUser];
    
  //[self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    autocompletePlaceStatus = 3;
    // TODO: handle the error.
    NSLog(@"error: %ld", [error code]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    autocompletePlaceStatus = -1;
    NSLog(@"Autocomplete was cancelled.");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


@end


