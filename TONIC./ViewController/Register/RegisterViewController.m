//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "RegisterViewController.h"
#import "Shared.h"

#define kPickerBday 1
#define kPickerCity 2
#define kPickerState 3
#define kPickerHandicap 4
#define kPickerCourses 5

@interface RegisterViewController ()

@end

@implementation RegisterViewController
@synthesize HUD;

-(void) viewWillAppear:(BOOL)animated {
    [AppDelegate sharedinstance].currentScreen = kScreenRegister;
    
    doneButton.layer.cornerRadius = 20; // this value vary as per your desire
    doneButton.clipsToBounds = YES;
    
    if(autocompletePlaceStatus == -1) {

        strlat = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlat]];
        strlong = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlong]];
        
        if([strlat length]==0)
        {
            [self LocationMessage];
        }
    }
    else if(autocompletePlaceStatus==2)  {
        [self signUpUser];
    }
    
}

-(void) LocationMessage
{
    // Show 2 options to get location
    UIAlertController * ac = [UIAlertController
                              alertControllerWithTitle:@"Location will only be used when app is opened"
                              message:@"ParTee needs location access to show near by courses and golfers"
                              preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* automaticButton = [UIAlertAction
                                      actionWithTitle:@"Detect automatically"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [[AppDelegate sharedinstance] locationInit];
                                      }];
    UIAlertAction* manualButton = [UIAlertAction
                                   actionWithTitle:@"Add manually"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self manualAdd];
                                   }];
    [ac addAction:automaticButton];
    [ac addAction:manualButton];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[self sampleFillUser];
    [btnCheckmark setTag:200];
    
    strImgURLBase=@"";
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [[AppDelegate sharedinstance] hideLoader];
    
    [scrollViewContainer setContentSize:CGSizeMake(320, 1300)];
    
    [txtName setTag:101];
    [txtEmail setTag:102];
    [txtPwd setTag:103];
    [txtBday setTag:104];
    [txtState setTag:105];
    [txtCity setTag:106];
    [txtHomeCourse setTag:107];
    [txtHandicap setTag:109];
    [tvInfo setTag:110];
    
    datePicker.maximumDate=[NSDate date];
    datePicker.backgroundColor=[UIColor whiteColor];
    
    txtBday.inputView=datePicker;
    txtCity.inputView=pickerView;
    txtState.inputView=pickerView;
    txtHandicap.inputView = pickerView;
    txtHomeCourse.inputView = pickerView;
    
    txtHandicap.text = @"N/A";
    txtHomeCourse.text = @"N/A";
    
    arrStateList = [[NSMutableArray alloc] init];
    arrCityList = [[NSMutableArray alloc] init];
    arrHomeCourses= [[NSMutableArray alloc] init];
    arrHandicapList= [[NSMutableArray alloc] init];
    
    for(int i = -40; i <= 5; ++i)
    {
        [arrHandicapList addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    [arrHandicapList insertObject:@"N/A" atIndex:0];
    
    tvInfo.placeholder = @"Enter something about you";
    
    tvInfo.placeholderTextColor = [UIColor colorWithRed:0.780 green:0.780 blue:0.804 alpha:1.00];
    //tvInfo.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    
    NSArray *fields = @[ txtName,txtEmail,txtPwd,txtBday,txtState,txtCity,txtHomeCourse,txtHandicap,tvInfo];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    imgViewProfilePic.layer.cornerRadius = imgViewProfilePic.frame.size.width/2;
    [imgViewProfilePic.layer setMasksToBounds:YES];
    [imgViewProfilePic.layer setBorderColor:[UIColor clearColor].CGColor];
    
    self.navigationController.navigationBarHidden=YES;
    
    self.menuContainerViewController.panMode = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLocation) name:@"gotLocation" object:nil];
    
    [self getLocationDataFromServer];
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
    
    arrHomeCourses = [[NSMutableArray alloc] init];
    arrHomeCoursesObjects = [[NSMutableArray alloc] init];
    
    NSString *strCity = txtCity.text;
    
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:strCity forKey:@"City"];
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        [[AppDelegate sharedinstance] hideLoader];
        
        // checking user there in custom user table or not.
        
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
        
        [pickerView reloadAllComponents];
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
    
    if([[[AppDelegate sharedinstance] nullcheck:txtHandicap.text] length]==0) {
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

//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//---------------------------------------------------------------------

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
        
        strlat = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlat]];
        strlong = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlong]];

        [strlat length]==0 ? [self LocationMessage] : [self signUpUser];
        
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

-(IBAction)cameraPressed:(id)sender
{
    [self.view endEditing:YES];
    Shared *camera = [[Shared alloc] init];
    [camera cameraPressed:self];
}


//-----------------------------------------------------------------------



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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL] options:@{} completionHandler:nil];
    }
}




-(IBAction)Privacytapped:(id)sender {
    NSString *strWebsite = @"https://www.partee.golf/privacy";
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL] options:@{} completionHandler:nil];
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

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(pickerOption)
    {
        case kPickerState:
            return [arrStateList objectAtIndex:row];
            break;
        case kPickerCity:
            return [arrCityList objectAtIndex:row];
            break;
        case kPickerHandicap:
            return [arrHandicapList objectAtIndex:row];
            break;
        case kPickerCourses:
            return [arrHomeCourses objectAtIndex:row];
            break;
    }
    
    return nil;
}

//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", row);
    
    switch(pickerOption)
    {
        case kPickerState:
            txtState.text = [arrStateList objectAtIndex:row];
            break;
        case kPickerCity:
            txtCity.text = [arrCityList objectAtIndex:row];
            break;
        case kPickerHandicap:
            txtHandicap.text = [arrHandicapList objectAtIndex:row];
            break;
        case kPickerCourses:
            txtHomeCourse.text = [arrHomeCourses objectAtIndex:row];
            break;
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
        pickerOption=kPickerState;
        
        if([txtState.text length]==0)
            txtState.text = [arrStateList objectAtIndex:0];
    }
    else if(textField==txtCity) {
        pickerOption=kPickerCity;
        
        [self resetCityList:arrData :txtState.text];
        
        [pickerView reloadAllComponents];
        
    }
    else if(textField==txtHomeCourse) {
        pickerOption=kPickerCourses;
        
        if([txtHomeCourse.text length]==0)
            txtHomeCourse.text = @"N/A";
        
        [self getCoursesForSelection];
        
    }
    else {
        pickerOption=6;
    }
    
    [pickerView reloadAllComponents];
    
    return YES;
}

-(void) resetCityList:(NSArray *) data :(NSString *) strStateSelected
{
    if([arrCityList count]>0)
        [arrCityList removeAllObjects];
    
    for(QBCOCustomObject *obj in data) {
        
        NSString *strName = [obj.fields objectForKey:@"stateName"];
        
        if([strName isEqualToString:strStateSelected]) {
            
            [arrCityList addObject:[obj.fields objectForKey:@"cityName"]];
        }
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(textField ==txtState)
    {
        [self resetCityList:arrData :txtState.text];
        [pickerView reloadAllComponents];
    }
    
    
    return YES;
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

-(void)  localSave {
    NSMutableDictionary *dictUserDetails = [[NSMutableDictionary alloc] init];
    
    [dictUserDetails setObject:segmentGender.selectedSegmentIndex==0 ? @"male" : @"female" forKey:@"userGender"];
    [dictUserDetails setObject:txtName.text forKey:@"userDisplayName"];
    [dictUserDetails setObject:txtCity.text forKey:@"userCity"];
    [dictUserDetails setObject:txtState.text forKey:@"userState"];
    [dictUserDetails setObject:txtHandicap.text forKey:@"userHandicap"];
    [dictUserDetails setObject:tvInfo.text forKey:@"userInfo"];
    [dictUserDetails setObject:strImgURLBase forKey:@"userPicBase"];
    [dictUserDetails setObject:@"0" forKey:@"userFullMode"];
    [dictUserDetails setObject:txtEmail.text forKey:@"userEmail"];
    [dictUserDetails setObject:strCurrentUserId forKey:@"userInfoId"];
    [dictUserDetails setObject:[NSString stringWithFormat:@"%ld",[[AppDelegate sharedinstance] getAge:txtBday.text]] forKey:@"userAge"];
    
    [dictUserDetails setObject:txtHomeCourse.text forKey:@"home_coursename"];
    [dictUserDetails setObject:strHomeCourseID forKey:@"home_course_id"];
    [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:kuserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    
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
                
                [localObject.fields setObject:segmentGender.selectedSegmentIndex==0 ? @"male" :@"female"   forKey:@"userGender"];
                [localObject.fields setObject:txtEmail.text forKey:@"userEmail"];
                [localObject.fields setObject:txtName.text forKey:@"userDisplayName"];
                [localObject.fields setObject:txtBday.text forKey:@"userBday"];
                [localObject.fields setObject:txtCity.text forKey:@"userCity"];
                [localObject.fields setObject:txtState.text forKey:@"userState"];
                [localObject.fields setObject:[NSNumber numberWithInteger:[[AppDelegate sharedinstance] getAge:txtBday.text ]] forKey:@"userAge"];
                [localObject.fields setObject:txtHandicap.text forKey:@"userHandicap"];
                [localObject.fields setObject:tvInfo.text forKey:@"userInfo"];
                [[AppDelegate sharedinstance] setStringObj:@"0" forKey:@"userPurchasedConnects"];
                [[AppDelegate sharedinstance] setStringObj:@"10" forKey:@"userFreeConnects"];
                [localObject.fields setObject:@"0" forKey:@"userFullMode"];
                [localObject.fields setObject:@"0" forKey:@"userNumberOfBlocks"];
                [localObject.fields setObject:strImgURLBase forKey:@"userPicBase"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"advertisingBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"spamBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"contentBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"stolenBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"abusiveBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:0] forKey:@"otherBlockCount"];
                [localObject.fields setObject:[NSNumber numberWithInteger:1] forKey:@"user_type"];
                [localObject.fields setObject:txtHomeCourse.text forKey:@"home_coursename"];
                [localObject.fields setObject:[self getHomeCourseIdFromName:txtHomeCourse.text] forKey:@"home_course_id"];
                strlat = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlat]];
                strlong = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlong]];
                [localObject.fields setObject:[NSString stringWithFormat:@"%f,%f",[strlong floatValue],[strlat floatValue]] forKey:@"current_location"];
                [QBRequest createObject:localObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            
                    [[AppDelegate sharedinstance] setStringObj:object.ID forKey:kuserInfoID];
                    
                    // do something when object is successfully created on a server
                    strCurrentUserId= [NSString stringWithFormat:@"%lu",(unsigned long)user.ID];
                    
                    [[AppDelegate sharedinstance] setStringObj:strCurrentUserId forKey:kuserDBID];
                    [[AppDelegate sharedinstance] setStringObj:strCurrentUserId forKey:@"userQuickbloxID"];
                    
                    [self localSave];
                    [self registerForNotifications];
                    
                    [QBRequest createObject:localObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        QBCOCustomObject *localObject = [QBCOCustomObject customObject];
                        localObject.className = @"UserRoles"; // your Class name
                        
                        [localObject.fields setObject:object.ID forKey:@"_parent_id"];
                        [localObject.fields setObject:@"0" forKey:@"RoleId"];
                        [localObject.fields setObject:@"Golfer" forKey:@"Name"];
                        [localObject.fields setObject:@"Approved" forKey:@"Status"];
                        [localObject.fields setObject:[NSDate date] forKey:@"DateAsRole"];
                        
                        [[AppDelegate sharedinstance] setCurrentRole:0];
                        
                        [QBRequest createObject:localObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            [[AppDelegate sharedinstance] hideLoader];
                            
                            SpecialsViewController *vc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                            
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
                        [[AppDelegate sharedinstance] hideLoader];
                    } errorBlock:^(QBResponse *response) {
                        // error handling
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayServerErrorMessage];
                        
                        NSLog(@"Response error: %@", [response.error description]);
                    }];
                    
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
    strlat = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlat]];
    strlong = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlong]];
    
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
    
    NSString *strLat = [NSString stringWithFormat:@"%f", place.coordinate.latitude];
    NSString *strLong = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    [[AppDelegate sharedinstance] setStringObj:strLat forKey:klocationlat];
    [[AppDelegate sharedinstance] setStringObj:strLong forKey:klocationlong];
    
    NSLog(@"Place attributions %@", place.attributions.string);
    [self signUpUser];
    
}

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    autocompletePlaceStatus = 3;
    // TODO: handle the error.
    NSLog(@"error: %ld", (long)[error code]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    autocompletePlaceStatus = -1;
    NSLog(@"Autocomplete was cancelled.");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}


@end


