//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "EditProfileViewController.h"
#import "PreviewProfileViewController.h"
#import "ProRegisterViewController.h"

#define kPickerBday 1
#define kPickerCity 2
#define kPickerState 3
#define kPickerHandicap 4
#define kPickerCourses 5


#define kImageChosen 1
#define kImageDelete 2
#define kImageLoaded 3
#define kImageCancel 3

@interface EditProfileViewController ()

@end

@implementation EditProfileViewController
@synthesize HUD;



- (void)viewDidLoad {
    [super viewDidLoad];
    imageChosen=kImageCancel;
    
    viewSave.layer.cornerRadius = 20;
    proButton.layer.cornerRadius = 20;
    doneButton.layer.cornerRadius = 20;
    saveButton.layer.cornerRadius = 20;

    [viewSave.layer setMasksToBounds:YES];
    txtHandicap.inputView = pickerView;

    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [[AppDelegate sharedinstance] hideLoader];
    
    proButton.enabled = YES;

    [txtName setTag:101];
    [txtState setTag:102];
    [txtCity setTag:103];
    [txtHomeCourse setTag:104];
    [txtHandicap setTag:106];
    [tvInfo setTag:107];

    txtCity.inputView=pickerView;
    txtState.inputView=pickerView;
    txtHomeCourse.inputView=pickerView;
    txtHandicap.inputView = pickerView;
    
     dateFormat = [[NSDateFormatter alloc] init];
    datePicker.maximumDate=[NSDate date];
    datePicker.backgroundColor=[UIColor whiteColor];
    [datePicker addTarget:self action:@selector(dateOfBirthChanged:)
     forControlEvents:UIControlEventValueChanged];
    
    txtBday.inputView = datePicker;
    
    NSArray *fields = @[ txtName,txtState,txtCity,txtHomeCourse,txtHandicap,tvInfo, txtBday];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

    imgViewProfilePic.layer.cornerRadius = imgViewProfilePic.frame.size.width/2;
    [imgViewProfilePic.layer setMasksToBounds:YES];
    [imgViewProfilePic.layer setBorderColor:[UIColor clearColor].CGColor];
    
    tvInfo.placeholder = @"Enter something about you";
    tvInfo.placeholderTextColor = [UIColor colorWithRed:0.780 green:0.780 blue:0.804 alpha:1.00];
    
    self.navigationController.navigationBarHidden=YES;
    
    self.menuContainerViewController.panMode = YES;
    
    arrStateList = [[NSMutableArray alloc] init];
    arrCityList = [[NSMutableArray alloc] init];
    arrHomeCourses= [[NSMutableArray alloc] init];
    arrHandicapList= [[NSMutableArray alloc] init];
    
    for(int i = -40; i <= 5; ++i)
    {
        [arrHandicapList addObject:[NSString stringWithFormat:@"%d", i]];
    }
    
    [arrHandicapList insertObject:@"N/A" atIndex:0];
    
    
    if(isiPhone4) {
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 1000)];

    }
    else {
        [scrollViewContainer setContentSize:CGSizeMake(320, 1000)];

    }
    
    switch(autocompletePlaceStatus)
    {
        case -1:
            strlat = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlat]];
            strlong = [[AppDelegate sharedinstance] nullcheck:[[AppDelegate sharedinstance] getStringObjfromKey:klocationlong]];
            
            if([strlat length]==0)
            {
                [self LocationMessage:self];
            }
            break;
        case 2:
            [self signUpUser];
            break;
    }
    
    NSString *userEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    [btnCheckmark setTag:200];
    [self getLocationDataFromServer];
    
    if(userEmail.length > 0)
    {
        [editView setHidden:NO];
        [registerView setHidden:YES];
        [btnBack setHidden:YES];
        menu.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        preview.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [segmentGender setHidden:YES];
        
        [self bindData];
    }
    else
    {
        btnBack.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        [titleLabel setText:@"Sign Up"];
        [menu setHidden:YES];
        [preview setHidden:YES];
        [editView setHidden:YES];
        [registerView setHidden:NO];
        [cityView setHidden:YES];
        [homeCourseView setHidden:YES];
    }
    
    btnBack.imageEdgeInsets = UIEdgeInsetsMake(0, 4.5, 0, 4.5);
}

- (void) bindData {

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];

    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {

        // response processing
        object =  [objects objectAtIndex:0];

        NSString *strID = [NSString stringWithFormat:@"%@",object.ID];
        [[AppDelegate sharedinstance] setStringObj:strID forKey:kuserInfoID];
        
        NSString *gender = [object.fields objectForKey:@"userGender"];
        
        segmentGender.selectedSegmentIndex = [gender isEqualToString:@"male"] ? 0 : 1;
        
        txtName.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userDisplayName"]];
        txtState.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userState"]];
        txtCity.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userCity"]];
        txtBday.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userBday"]];
        txtHomeCourse.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"home_coursename"]];
        txtHandicap.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userHandicap"]];
        tvInfo.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userInfo"]];
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
        NSString *bDay = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userBday"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        datePicker.date = [dateFormatter dateFromString:bDay];

        if([txtHomeCourse.text length]==0) {
             txtHomeCourse.text = @"N/A";
        }
        
        [imgViewProfilePic setShowActivityIndicatorView:YES];
        [imgViewProfilePic setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        NSString *imageUrl ;
        
        if([[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPicBase"]] length]>0) {

            imageUrl = [NSString stringWithFormat:@"%@", [object.fields objectForKey:@"userPicBase"]];
            [imgViewProfilePic sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"user"]];
        }
        
        NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userFullMode"]];
            
        [[NSUserDefaults standardUserDefaults] setBool:[userFullMode isEqualToString:@"1"] forKey:kIAPFULLVERSION];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:object.ID forKey:@"_parent_id"];
        [getRequest setObject:@[@"Pending",@"Approve",@"Renew"] forKey:@"Status[in]"];
        [getRequest setObject:@"true" forKey:@"Active"];
        [getRequest setObject:@"1" forKey:@"RoleId"];
        
        [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
        {
            [self getLocationDataFromServer];
            if(objects.count == 0)
            {
                return;
            }
            QBCOCustomObject *obj = [objects objectAtIndex:0];
            NSString *status = [obj.fields objectForKey:@"Status"];
            [proButton setTitle:[status isEqualToString:@"Pending"] ? @"Pro Request Sent" : @"Pro Status Confirmed" forState:UIControlStateNormal];
            proButton.enabled = NO;
            
        }errorBlock:^(QBResponse *response) {
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
    
}

-(void) getLocationDataFromServer {
    
    [QBRequest objectsWithClassName:@"Location" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        [[AppDelegate sharedinstance] hideLoader];
        arrData=objects;
        
        for(QBCOCustomObject *obj in arrData) {
            NSString *strName = [obj.fields objectForKey:@"stateName"];
            
            if(![arrStateList containsObject:strName]) {
                [arrStateList addObject:strName];
            }
            
            strName = [obj.fields objectForKey:@"cityName"];
            
            if(![arrCityList containsObject:strName]) {
                [arrCityList addObject:strName];
            }
        }
        
        [arrStateList insertObject:@"N/A" atIndex:0];
        [arrStateList insertObject:@"" atIndex:0];
    }errorBlock:^(QBResponse *response) {
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
    
    
    if([[[AppDelegate sharedinstance] nullcheck:txtState.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }

    if(![txtState.text isEqualToString:@"N/A"])
    {
        if([[[AppDelegate sharedinstance] nullcheck:txtCity.text] length]==0) {
            [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
            return NO;
        }
    }
    
    
    if([[[AppDelegate sharedinstance] nullcheck:txtHandicap.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:tvInfo.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtEmail.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if(![registerView isHidden])
    {
        if([[[AppDelegate sharedinstance] nullcheck:txtPwd.text] length]==0) {
            [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
            return NO;
        }
        
        if([[[AppDelegate sharedinstance] nullcheck:txtRePwd.text] length]==0) {
            [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
            return NO;
        }
        
        if(![txtPwd.text isEqualToString:txtRePwd.text]) {
            [[AppDelegate sharedinstance] displayMessage:@"Passwords do not match"];
            return NO;
        }
        
        if([btnCheckmark tag]==200 ) {
            [[AppDelegate sharedinstance] displayMessage:@"You need to agree to terms to proceed"];
        
            return NO;
        }
    }

    return YES;
    
}

//-----------------------------------------------------------------------

#pragma mark - Custom Methods


- (IBAction)action_UpdateProfile:(id)sender  {
    
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
    
        [object.fields setObject:txtName.text forKey:@"userDisplayName"];
        [object.fields setObject:txtCity.text forKey:@"userCity"];
        [object.fields setObject:txtState.text forKey:@"userState"];
        [object.fields setObject:txtHandicap.text forKey:@"userHandicap"];
        [object.fields setObject:txtBday.text forKey:@"userBday"];
        NSString *age = [NSString stringWithFormat:@"%ld", [[AppDelegate sharedinstance] getAge:txtBday.text]];
        [object.fields setObject:age forKey:@"userAge"];
        
        [object.fields setObject:tvInfo.text forKey:@"userInfo"];
        
        [object.fields setObject:txtHomeCourse.text forKey:@"home_coursename"];
        
        strHomeCourseID = [self getHomeCourseIdFromName:txtHomeCourse.text];
        [object.fields setObject:strHomeCourseID forKey:@"home_course_id"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        if(imageChosen==kImageChosen) {
            
            NSData *imageData = UIImageJPEGRepresentation(imgViewProfilePic.image, .7);
            
            [QBRequest TUploadFile:imageData fileName:@"Profile.jpg" contentType:@"image/jpg" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
                // File uploaded, do something
                // if blob.isPublic == YES
                
                NSString *url = [blob publicUrl];
                
                [object.fields setObject:url forKey:@"userPicBase"];
                
                imageChosen=kImageCancel;
      
                    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object1) {
                        // object updated
                        
                        object=object1;
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Profile updated successfully."];
                        
                        [self localSave:object];
                        
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
        }
        else {
            // If image is not changed, no need to upload.

            imageChosen=kImageCancel;
            [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                // object updated
                [self localSave:object];

                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayServerErrorMessage];
                
                NSLog(@"Response error: %@", [response.error description]);
            }];
        }
    }
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    
        }];
    //
}

//-----------------------------------------------------------------------

- (IBAction)action_PreviewProfile:(id)sender{
    
    PreviewProfileViewController *obj = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    obj.strCameFrom=@"2";
    obj.strEmailOfUser = [[AppDelegate sharedinstance] getCurrentUserEmail];
    obj.userID = object.ID;

    [self.navigationController pushViewController:obj animated:YES];
 
}

//-----------------------------------------------------------------------

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
        
        if([arrHomeCourses count]>0)
            [arrHomeCourses removeAllObjects];
        
        if([objects count]>0) {
            
            for(QBCOCustomObject *obj in objects) {
                
                NSString *strname = [obj.fields objectForKey:@"Name"];
                
                //arrHomeCourses
                [arrHomeCourses addObject:strname];
            }
            
        }

        [arrHomeCourses insertObject:@"N/A" atIndex:0];
        [arrHomeCourses insertObject:@"" atIndex:0];
        
        [pickerView selectRow:[arrHomeCourses indexOfObject:txtHomeCourse.text] inComponent:0 animated:NO];
        [pickerView reloadAllComponents];
    }errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
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
    switch(pickerOption)
    {
        case kPickerState:
             return arrStateList.count;
            break;
        case kPickerCity:
             return arrCityList.count;
            break;
        case kPickerHandicap:
             return arrHandicapList.count;
            break;
        case kPickerCourses:
            return arrHomeCourses.count;
            break;
    }
    
    return 10;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
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

    return @"";
}

-(void)dateOfBirthChanged:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    formatter.dateFormat = @"dd/MM/yyyy";
    NSString *string = [formatter stringFromDate:datePicker.date];
    txtBday.text=string;
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", row);
    
    switch(pickerOption)
    {
        case kPickerState:
            txtState.text = [arrStateList objectAtIndex:row];
            [cityView setHidden:[txtState.text isEqualToString:@"N/A"] || [txtState.text isEqualToString:@""]];
            if([txtState.text isEqualToString:@"N/A"] || [txtState.text isEqualToString:@""])
            {
                [homeCourseView setHidden:YES];
            }
            txtCity.text = @"";
            txtHomeCourse.text = @"";
            
            break;
        case kPickerCity:
            txtCity.text = [arrCityList objectAtIndex:row];
            [homeCourseView setHidden:[txtCity.text isEqualToString:@"N/A"] || [txtCity.text isEqualToString:@""]];
            break;
        case kPickerHandicap:
            txtHandicap.text = [arrHandicapList objectAtIndex:row];
            break;
        case kPickerCourses:
            if([arrHomeCourses count]>0) {
                txtHomeCourse.text = [arrHomeCourses objectAtIndex:row];
                
            }
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
        [scrollViewContainer setContentOffset:CGPointMake(0, textFieldview.center.y+5)animated:NO];
        [UIView commitAnimations];
        

    }
    
    else if([textFieldview tag]>101) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        
        NSLog(@"%ld",(43*([textFieldview tag]%10)));
        
        [scrollViewContainer setContentOffset:CGPointMake(0, 60 + (43*(([textFieldview tag]-1)%10))) animated:NO];
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
    
    if(textField==txtState) {
        pickerOption=kPickerState;
        if([txtState.text length]==0)
            txtState.text = @"";
        [pickerView selectRow:[arrStateList indexOfObject:txtState.text] inComponent:0 animated:NO];
    }
    else if(textField==txtCity) {
        pickerOption=kPickerCity;
        
        NSString *strStateSelected = txtState.text;
        
        if([arrCityList count]>0)
            [arrCityList removeAllObjects];
        
        for( QBCOCustomObject *obj in arrData) {
            NSString *strName = [obj.fields objectForKey:@"stateName"];
            
            if([strName isEqualToString:strStateSelected]) {
                
                [arrCityList addObject:[obj.fields objectForKey:@"cityName"]];
            }
        }
        
        [arrCityList insertObject:@"N/A" atIndex:0];
        [arrCityList insertObject:@"" atIndex:0];
        
        if([txtCity.text length]==0)
            txtCity.text = @"";
        
        [pickerView selectRow:[arrCityList indexOfObject:txtCity.text] inComponent:0 animated:NO];
    }
    else if(textField==txtHomeCourse) {
        pickerOption=kPickerCourses;
        
        if([txtHomeCourse.text length]==0)
            txtHomeCourse.text = @"";
        
        [self getCoursesForSelection];
        
    }
    else if(textField==txtHandicap) {
        pickerOption=kPickerHandicap;
        
        if([txtHandicap.text length]==0)
            txtHandicap.text = [arrHandicapList objectAtIndex:0];
        
    }
    else {
        pickerOption=6;
    }
    
    if(textField!=txtHomeCourse)
    {
        [pickerView reloadAllComponents];
    }
    
    
    
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
        
        NSLog(@"%d",(int)(43*([textField tag]%10)));
        
        [scrollViewContainer setContentOffset:CGPointMake(0, 60 + (43*(([textField tag]-1)%10))) animated:NO];
        [UIView commitAnimations];
        
    }
    
    [self.keyboardControls setActiveField:textField];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
    if(textField == txtState) {
        
        txtCity.text =@"";
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
    [scrollViewContainer setContentOffset:CGPointMake(0, textView.center.y+250)animated:NO];
    [UIView commitAnimations];
    
    [self.keyboardControls setActiveField:textView];
}

-(IBAction)cameraPressed:(id)sender
{
    [self.view endEditing:YES];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Select image"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraButton = [UIAlertAction
                                   actionWithTitle:@"Camera"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
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
                                           UIAlertController * ac = [UIAlertController
                                                                     alertControllerWithTitle:kAppName
                                                                     message:@"Device does not supports camera"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                           UIAlertAction* okButton = [UIAlertAction
                                                                      actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          
                                                                      }];
                                           [ac addAction:okButton];
                                           [self presentViewController:ac animated:YES completion:nil];
                                           return;
                                       }
                                   }];
    
    UIAlertAction* libraryButton = [UIAlertAction
                                    actionWithTitle:@"Select from Library"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                        picker.delegate = self;
                                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        picker.allowsEditing = YES;
                                        
                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                            
                                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                                
                                            }
                                            else {
                                                [self presentViewController:picker animated:YES completion:nil];
                                                
                                            }
                                        }];
                                    }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
    
    [alert addAction:cameraButton];
    [alert addAction:libraryButton];
    [alert addAction:cancelButton];
    alert.popoverPresentationController.sourceView = sender;
    [self presentViewController:alert animated:YES completion:nil];
}

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

-(void)  localSave: (QBCOCustomObject*) localObject {
    [[NSUserDefaults standardUserDefaults] setObject:localObject.fields forKey:kuserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    
}

-(IBAction)ProRequestTapped:(id)sender
{
    ProRegisterViewController *viewController    = [[ProRegisterViewController alloc] initWithNibName:@"ProRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
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
        
        [strlat length]==0 ? [self LocationMessage:sender] : [self signUpUser];
        
    }
}

-(void) LocationMessage:(id)sender
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
    ac.popoverPresentationController.sourceView = sender;
    [self presentViewController:ac animated:YES completion:nil];
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
                    
                    [self localSave:localObject];
                    [self registerForNotifications];
                    
                    [QBRequest createObject:localObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        QBCOCustomObject *localObject = [QBCOCustomObject customObject];
                        localObject.className = @"UserRoles"; // your Class name
                        
                        [localObject.fields setObject:object.ID forKey:@"_parent_id"];
                        [localObject.fields setObject:@"0" forKey:@"RoleId"];
                        [localObject.fields setObject:@"Golfer" forKey:@"Name"];
                        [localObject.fields setObject:@"Approved" forKey:@"Status"];
                        [localObject.fields setObject:@"true" forKey:@"Active"];
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
                            
                            vc.DataType = filterCourse;
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
            [[AppDelegate sharedinstance] displayMessage:@"User name has already been taken"];
        }
        else {
            [[AppDelegate sharedinstance] displayServerErrorMessage];
            
        }
        
        autocompletePlaceStatus = 3;
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

-(void) manualAdd {
    // manual
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

-(void) registerForNotifications {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
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

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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


