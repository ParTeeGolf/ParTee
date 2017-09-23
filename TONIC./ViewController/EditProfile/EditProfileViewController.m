//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "EditProfileViewController.h"
#import "HomeViewController.h"
#import "PDFViewController.h"
#import "PreviewProfileViewController.h"

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

NSDateFormatter *dateFormat;

- (void)viewDidLoad {
    [super viewDidLoad];
    imageChosen=kImageCancel;
    
    viewSave.layer.cornerRadius = 20;
  //  viewSave.layer.borderWidth=1.0f;
    [viewSave.layer setMasksToBounds:YES];
   // [viewSave.layer setBorderColor:[UIColor clearColor].CGColor];
    txtHandicap.inputView = pickerView;

    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [[AppDelegate sharedinstance] hideLoader];
    
    dateFormat = [[NSDateFormatter alloc] init];

    [txtName setTag:101];
    [txtState setTag:102];
    [txtCity setTag:103];
    [txtHomeCourse setTag:104];

    [txtZipCode setTag:105];
    [txtHandicap setTag:106];
    [tvInfo setTag:107];

    txtCity.inputView=pickerView;
    txtState.inputView=pickerView;
    txtHomeCourse.inputView=pickerView;
    
    datePicker.maximumDate=[NSDate date];
    datePicker.backgroundColor=[UIColor whiteColor];
    [datePicker addTarget:self action:@selector(dateOfBirthChanged:)
     forControlEvents:UIControlEventValueChanged];
    
    txtBday.inputView = datePicker;
    
    NSArray *fields = @[ txtName,txtState,txtCity,txtHomeCourse,txtZipCode,txtHandicap,tvInfo, txtBday];
    
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
    
//    arrStateList = [NSArray arrayWithObjects:@"Montana",nil];
//    arrCityList = [NSArray arrayWithObjects:@"Bozeman",@"Billings",@"Butte",@"Big Sky",@"Kalispell",@"Livingston",@"All",nil];
    
    if(isiPhone4) {
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 1000)];

    }
    else {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];

    }
    
    [self bindData];
    
   
    
    //[self loginSampleUser];
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
        
        txtName.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userDisplayName"]];
        txtState.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userState"]];
        txtCity.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userCity"]];
        txtBday.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userBday"]];
        
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc]init];
        NSString *bDay = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userBday"]];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
        datePicker.date = [dateFormatter dateFromString:bDay];
        
        txtHomeCourse.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"home_coursename"]];
        
        if([txtHomeCourse.text length]==0) {
             txtHomeCourse.text = @"N/A";
        }
        
        txtZipCode.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userZipcode"]];
        txtHandicap.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userHandicap"]];
        tvInfo.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userInfo"]];

        [imgViewProfilePic setShowActivityIndicatorView:YES];
        [imgViewProfilePic setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        NSString *imageUrl ;
        
        if([[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPicBase"]] length]>0) {

            imageUrl = [NSString stringWithFormat:@"%@", [object.fields objectForKey:@"userPicBase"]];
            [imgViewProfilePic sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"user"]];
        }
        
        NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userFullMode"]];
        
        if([userFullMode isEqualToString:@"1"]) {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIAPFULLVERSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIAPFULLVERSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

        [self localSave];
        [self getLocationDataFromServer];
        
        
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
    
    if([[[AppDelegate sharedinstance] nullcheck:tvInfo.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
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
        [object.fields setObject:txtZipCode.text forKey:@"userZipcode"];
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
                        
                        [self localSave];
                        [self sendtags];
                        
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
                [self localSave];
                [self sendtags];

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

-(void) sendtags {
    NSString *stringHandicap;
    
    int handicapval = [txtHandicap.text intValue];

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
    
//    [OneSignal sendTags:@{@"agerange" : @"1",@"handicap" : stringHandicap, @"city" : stringCity}];
     [OneSignal sendTags:@{ @"handicap" : stringHandicap, @"city" : stringCity}];

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

    [self.navigationController pushViewController:obj animated:YES];
 
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
    NSLog(@"Selected Row %d", row);
    
    if(pickerOption==kPickerState) {
        txtState.text = [arrStateList objectAtIndex:row];
    }
    else if(pickerOption==kPickerCity) {
        txtCity.text = [arrCityList objectAtIndex:row];
    }
    else if(pickerOption==kPickerHandicap) {
        txtHandicap.text = [arrHandicapList objectAtIndex:row];
        
    }
    else if(pickerOption==kPickerCourses) {
        
        if([arrHomeCourses count]>0) {
            txtHomeCourse.text = [arrHomeCourses objectAtIndex:row];
            
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
        
//        if([txtState.text length]==0)
//            txtState.text = [arrStateList objectAtIndex:0];
        
    }
    else if(textField==txtCity) {
        pickerOption=kPickerCity;
        
        NSString *strStateSelected = txtState.text;
        
        if([arrCityList count]>0)
            [arrCityList removeAllObjects];
        
        for(int i=0;i<[arrData count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            NSString *strName = [obj.fields objectForKey:@"stateName"];
            
            if([strName isEqualToString:strStateSelected]) {
                
                [arrCityList addObject:[obj.fields objectForKey:@"cityName"]];
            }
        }
        
        if([txtCity.text length]==0)
            txtCity.text = [arrCityList objectAtIndex:0];
    }
    else if(textField==txtHomeCourse) {
        pickerOption=kPickerCourses;
        
        if([txtHomeCourse.text length]==0)
            txtHomeCourse.text = @"N/A";
        
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
    
    [pickerView reloadAllComponents];
    
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
    imageChosen=kImageChosen;

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
    
    if(imageChosen!=kImageChosen) {
        imageChosen=kImageCancel;
    }
    
    [imgViewProfilePic setAccessibilityIdentifier:@"default"] ;
   
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

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
    
    NSString *age = [NSString stringWithFormat:@"%ld", [[AppDelegate sharedinstance] getAge:txtBday.text]];
    
    [dictUserDetails setObject:txtName.text forKey:@"userDisplayName"];
    [dictUserDetails setObject:txtCity.text forKey:@"userCity"];
    [dictUserDetails setObject:txtState.text forKey:@"userState"];
    [dictUserDetails setObject:txtZipCode.text forKey:@"userZipcode"];
    [dictUserDetails setObject:txtBday.text forKey:@"userBday"];
    [dictUserDetails setObject:age forKey:@"userAge"];
    [dictUserDetails setObject:txtHandicap.text forKey:@"userHandicap"];
    [dictUserDetails setObject:tvInfo.text forKey:@"userInfo"];
    [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields  objectForKey:@"userPicBase"]] forKey:@"userPicBase"];
    [dictUserDetails setObject:[object.fields  objectForKey:@"userFullMode"] forKey:@"userFullMode"];
    
    
    [dictUserDetails setObject:[object.fields objectForKey:@"userPurchasedConnects"]forKey:@"userPurchasedConnects"];
    [dictUserDetails setObject:[object.fields objectForKey:@"userFreeConnects"]forKey:@"userFreeConnects"];

    [dictUserDetails setObject:[object.fields objectForKey:@"userPush"] forKey:@"userPush"];
    [dictUserDetails setObject:[object.fields objectForKey:@"userFullMode"] forKey:@"userFullMode"];
    
    [dictUserDetails setObject:txtHomeCourse.text forKey:@"home_coursename"];
    strHomeCourseID = [self getHomeCourseIdFromName:txtHomeCourse.text];

    [dictUserDetails setObject:strHomeCourseID forKey:@"home_course_id"];
    
    [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:kuserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    
}


@end


