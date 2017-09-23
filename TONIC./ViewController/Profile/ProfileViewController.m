//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#define kImageChosen 1
#define kImageDelete 2
#define kImageLoaded 3
#define kImageCancel 3

#define kImageBase 201
#define kImageL 202
#define kImageR 203

#import "ProfileViewController.h"
#import "HomeViewController.h"

@interface ProfileViewController ()

@end

@implementation ProfileViewController
@synthesize status;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(isiPhone4) {
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 1000)];
        
    }
    

    [self setLayout];
    
    self.navigationController.navigationBarHidden=YES;
    
    imgView1.layer.cornerRadius = imgView1.frame.size.width/2;
    [imgView1.layer setMasksToBounds:YES];
    [imgView1.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView2.layer.cornerRadius = imgView2.frame.size.width/2;
    [imgView2.layer setMasksToBounds:YES];
    [imgView2.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView3.layer.cornerRadius = imgView3.frame.size.width/2;
    [imgView3.layer setMasksToBounds:YES];
    [imgView3.layer setBorderColor:[UIColor clearColor].CGColor];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *dateComponent = [calendar components:(NSWeekOfYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
        
        NSString *str = [NSString stringWithFormat:@"%d",dateComponent.weekOfYear];
        NSString *strVal = [[AppDelegate sharedinstance] getStringObjfromKey:@"userCurrentWeekAt"];

        if([strVal length]==0) {
            
            [[AppDelegate sharedinstance] setStringObj:str forKey:@"userCurrentWeekAt"];
        }
        
        // checking user there in custom user table or not.
        [[AppDelegate sharedinstance] hideLoader];

        arrData = objects;
        
        if([arrData count]>0) {
            
            NSArray *fields = @[ txtDisplayName,txtCity,txtOccupation];
            
            [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
            [self.keyboardControls setDelegate:self];

            [txtBday setUserInteractionEnabled:NO];

            self.menuContainerViewController.panMode=YES;
            
            [AppDelegate sharedinstance].isUpdate=YES;
            
            // If user exists, get info from server
            object =  [arrData objectAtIndex:0];
            [AppDelegate sharedinstance].delegateShareObject = object;
            
            NSString *strID = [NSString stringWithFormat:@"%@",object.ID];
            [[AppDelegate sharedinstance] setStringObj:strID forKey:kuserInfoID];
            
            NSString *struserPurchasedConnects = [NSString stringWithFormat:@"%@",[object.fields objectForKey:@"userPurchasedConnects"]];
            NSString *userWeeklyConnects = [NSString stringWithFormat:@"%@",[object.fields objectForKey:@"userFreeConnects"]];

            [[AppDelegate sharedinstance] setStringObj:struserPurchasedConnects forKey:@"userPurchasedConnects"];
            
            [[AppDelegate sharedinstance] setStringObj:userWeeklyConnects forKey:@"userFreeConnects"];

            txtDisplayName.text = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userDisplayName"]];
            
            NSString *strGender = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userGender"]];
            
            NSString *Points= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPoints"]];
           
            if([Points length]==0) {
                Points = @"10";
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
            
            BOOL isFullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kIAPFULLVERSION];
            
            [lblPoints setText:Points];

            if([strGender isEqualToString:@"male"]) {
                [segmentGender setSelectedSegmentIndex:0];
            }
            else {
                [segmentGender setSelectedSegmentIndex:1];
            }
            
            [imgView1 setShowActivityIndicatorView:YES];
            [imgView1 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [imgView3 setShowActivityIndicatorView:YES];
            [imgView3 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [imgView2 setShowActivityIndicatorView:YES];
            [imgView2 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            NSString *imageUrl ;
            
            if([[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPicBase"]] length]>0) {
                imageUrl = [NSString stringWithFormat:@"%@", [object.fields objectForKey:@"userPicBase"]];
                [imgView2 sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
                strImgURLBase=imageUrl;
            }
            else {
                imgView2.image = [UIImage imageNamed:@"user"];
            }
            
            if([[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPicLeft"]] length]>0) {
                imageUrl = [NSString stringWithFormat:@"%@", [object.fields objectForKey:@"userPicLeft"]];
                [imgView1 sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
                strImgURLL=imageUrl;
            }
            else {
                imgView1.image = [UIImage imageNamed:@"missing-profile-photo.png"];
            }
            
            if([[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPicRight"]] length]>0) {
                imageUrl = [NSString stringWithFormat:@"%@", [object.fields objectForKey:@"userPicRight"]];

                [imgView3 sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
                strImgURLR=imageUrl;
            }
            else {
                imgView3.image = [UIImage imageNamed:@"missing-profile-photo.png"];
            }
            
            NSString *strBday = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userBday"]];
            
            txtBday.text = strBday;
            
            NSString *strCity = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userCity"]];
            txtCity.text = strCity;
            
            NSString *strOccupation = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userOccupation"]];
            txtOccupation.text = strOccupation;
            
            needToSave=NO;
        }
        else
        {
            
            NSArray *fields = @[ txtDisplayName,txtBday,txtCity,txtOccupation];
            
            [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
            [self.keyboardControls setDelegate:self];
            txtBday.inputView=datePicker;
            
            self.menuContainerViewController.panMode=NO;

            needToSave=YES;
            
            // If user not exists, take from local dic
            [AppDelegate sharedinstance].isUpdate=NO;

            dictUserData = [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];
            
            strFName = [[AppDelegate sharedinstance] nullcheck:[dictUserData objectForKey:@"first_name"]];
            strLName = [[AppDelegate sharedinstance] nullcheck:[dictUserData objectForKey:@"last_name"]];
            
            NSString *strName = [NSString stringWithFormat:@"%@ %@",[dictUserData objectForKey:@"first_name"],[dictUserData objectForKey:@"last_name"]];
            txtDisplayName.text = strName;
            
            NSString *strGender = [dictUserData objectForKey:@"gender"];
            
            if([strGender isEqualToString:@"male"]) {
                [segmentGender setSelectedSegmentIndex:0];
            }
            else {
                [segmentGender setSelectedSegmentIndex:1];
            }
            
            txtBday.text = @"";
            txtCity.text = @"";
            txtOccupation.text = @"";
            
           NSString *str = [[AppDelegate sharedinstance] getStringObjfromKey:@"birthday"];
            
            if([str length]>0) {
            
                txtBday.text = str;
                [txtBday setUserInteractionEnabled:NO];
            }
            else {
                txtBday.text = @"";
                [txtBday setUserInteractionEnabled:YES];

            }
            
            [imgView2 setShowActivityIndicatorView:YES];
            [imgView2 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            NSString *imageUrlBase = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=500&height=500", [dictUserData objectForKey:@"id"]];
            strImgURLBase=imageUrlBase;
            strImgURLL=@"";
            strImgURLR=@"";
            
            [imgView2 sd_setImageWithURL:[NSURL URLWithString:imageUrlBase] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
            imgView2.image = [UIImage imageNamed:@"missing-profile-photo"];

            imgView1.image = [UIImage imageNamed:@"missing-profile-photo"];
            imgView3.image = [UIImage imageNamed:@"missing-profile-photo"];
      
            [self getFBimages];

        }
        
        [self localSave];
        
        // Login succeded
        [[AppDelegate sharedinstance] hideLoader];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) viewWillAppear:(BOOL)animated {

    
 
}

-(void) getFBimages {
    [[AppDelegate sharedinstance] showLoader];
    
    NSString *strCurrFBID =[[AppDelegate sharedinstance] getStringObjfromKey:@"userFBID"] ;
    
    arrTemp = [[NSMutableArray alloc] init];
    
    strCurrFBID = [NSString stringWithFormat:@"/%@/photos?type=uploaded",strCurrFBID];
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:strCurrFBID
                                  parameters:@{@"fields": @"images"}
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        [[AppDelegate sharedinstance] hideLoader];
        
        NSDictionary *dict = (NSDictionary*)result;
        
        NSArray *arr = [dict objectForKey:@"data"];
        
        if([arr count]>0) {
            
            for(int i=0;i<[arr count];i++) {
                
                NSDictionary *dict = [arr objectAtIndex:i];
                
                NSArray *arrImages = [dict objectForKey:@"images"];
                
                if([arrImages count]>0) {
                    
                    [arrTemp addObject:[[arrImages objectAtIndex:0] objectForKey:@"source"]];
                    
                }
            }
        }
        
        if([arrTemp count]>0) {
            
            if([arrTemp count]==1) {
                imgView1.image = [UIImage imageNamed:@"missing-profile-photo.png"];
                imgView3.image = [UIImage imageNamed:@"missing-profile-photo.png"];
            }
            else if([arrTemp count]==2) {
                strImgURLL=[arrTemp objectAtIndex:1];
                strImgURLR=[arrTemp objectAtIndex:2];
                
                [imgView1 sd_setImageWithURL:[NSURL URLWithString:[arrTemp objectAtIndex:1]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
                [imgView3 sd_setImageWithURL:[NSURL URLWithString:[arrTemp objectAtIndex:2]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
            }
            else if([arrTemp count]>=3) {
                strImgURLL=[arrTemp objectAtIndex:1];
                strImgURLR=[arrTemp objectAtIndex:2];
                
                [imgView1 sd_setImageWithURL:[NSURL URLWithString:[arrTemp objectAtIndex:1]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
                [imgView3 sd_setImageWithURL:[NSURL URLWithString:[arrTemp objectAtIndex:2]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
            }
        }
        else {
            imgView1.image = [UIImage imageNamed:@"missing-profile-photo.png"];
            imgView3.image = [UIImage imageNamed:@"missing-profile-photo.png"];
        }
    }];
}

-(void) setLayout {
    txtDisplayName.text=@"";
    txtBday.text=@"";
    txtOccupation.text=@"";
    txtCity.text=@"";
    
    imgView1.image = [UIImage imageNamed:@"missing-profile-photo.png"];
    imgView2.image = [UIImage imageNamed:@"missing-profile-photo.png"];
    imgView3.image = [UIImage imageNamed:@"missing-profile-photo.png"];
    
    datePicker.maximumDate = [NSDate date];
    datePicker.backgroundColor = [UIColor whiteColor];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    formatter.dateFormat = @"mm/dd/yyyy";
    
    txtBday.text=@"";
    
    [txtDisplayName setTag:101];
    [txtBday setTag:102];
    [txtCity setTag:103];
    [txtOccupation setTag:104];

  }

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(IBAction)genderChanged:(id)sender {
    
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    if(needToSave)
    {
        [[AppDelegate sharedinstance] displayMessage:@"Please complete your profile"];
        
        return;
    }
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
        
    }];
    
}

- (IBAction) saveProfile :(id)sender {
        if(![self validateData]) {
            return;
        }
    
    [self localSave];
    
    [[AppDelegate sharedinstance] showLoader];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponent = [calendar components:(NSWeekOfYearCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:[NSDate date]];
    
    NSString *str = [NSString stringWithFormat:@"%d",dateComponent.weekOfYear];
    
    if([arrData count]==0) {
        // Insert object
        object = [QBCOCustomObject customObject];
        
        [object.fields setObject:@"0" forKey:@"userPurchasedConnects"];
        [object.fields setObject:@"4" forKey:@"userFreeConnects"];
        
        
        [[AppDelegate sharedinstance] setStringObj:@"0" forKey:@"userPurchasedConnects"];
        
        [[AppDelegate sharedinstance] setStringObj:@"4" forKey:@"userFreeConnects"];
        
        [[AppDelegate sharedinstance] setStringObj:str forKey:@"userCurrentWeekAt"];

        [object.fields setObject:[[AppDelegate sharedinstance] getStringObjfromKey:@"userFBID"] forKey:@"userFBID"];
        [object.fields setObject:@"10" forKey:@"userPoints"];
        [object.fields setObject:@"0" forKey:@"userFullMode"];
        [object.fields setObject:@"1" forKey:@"userDeviceType"];
        [object.fields setObject:str forKey:@"userCurrentWeekAt"];
        [object.fields setObject:@"1" forKey:@"userPush"];

    }
    else {
        // update object
    }
    
    object.className = @"UserInfo";
    
    if(segmentGender.selectedSegmentIndex==0)
    {
        [object.fields setObject:@"male" forKey:@"userGender"];
        
        // male
    }
    else {
        // female
        [object.fields setObject:@"female" forKey:@"userGender"];
    }
    

    [object.fields setObject:[[AppDelegate sharedinstance] getCurrentUserEmail]  forKey:@"userEmail"];

    [object.fields setObject:txtDisplayName.text forKey:@"userDisplayName"];
    
    [object.fields setObject:txtBday.text forKey:@"userBday"];
    [object.fields setObject:txtCity.text forKey:@"userCity"];
    [object.fields setObject:txtOccupation.text forKey:@"userOccupation"];
    [object.fields setObject:@"1" forKey:@"userDeviceType"];
    
    [object.fields setObject:strImgURLBase forKey:@"userPicBase"];
    [object.fields setObject:strImgURLL forKey:@"userPicLeft"];
    [object.fields setObject:strImgURLR forKey:@"userPicRight"];
    
    if([arrData count]==0) {
        // Insert object
        
        
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            needToSave=NO;
            
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];

            NSString *strID = [NSString stringWithFormat:@"%@",object.ID];
            [[AppDelegate sharedinstance] setStringObj:strID forKey:kuserInfoID];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];

            NSLog(@"Response error: %@", [response.error description]);
        }];

    }
    else {
        
        // update object
        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            // object updated
            [[AppDelegate sharedinstance] hideLoader];
            
            //[[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
            
            NSString *strID = [NSString stringWithFormat:@"%@",object.ID];
            [[AppDelegate sharedinstance] setStringObj:strID forKey:kuserInfoID];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];

            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
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
    
    [dictUserDetails setObject:txtDisplayName.text forKey:@"userDisplayName"];
    
    [dictUserDetails setObject:txtBday.text forKey:@"userBday"];
    [dictUserDetails setObject:txtCity.text forKey:@"userCity"];
    [dictUserDetails setObject:txtOccupation.text forKey:@"userOccupation"];
    
    [dictUserDetails setObject:strImgURLBase forKey:@"userPicBase"];
    
    strImgURLL = [[AppDelegate sharedinstance] nullcheck:strImgURLL];
    strImgURLR = [[AppDelegate sharedinstance] nullcheck:strImgURLR];

    [dictUserDetails setObject:strImgURLL forKey:@"userPicLeft"];
    [dictUserDetails setObject:strImgURLR forKey:@"userPicRight"];
    
    if([object.fields  objectForKey:@"userPoints"]) {
        [dictUserDetails setObject:[object.fields  objectForKey:@"userPoints"] forKey:@"userPoints"];
    }
    else {
        [dictUserDetails setObject:@"10" forKey:@"userPoints"];
    }
    
    if([arrData count]>0) {
        [dictUserDetails setObject:[object.fields  objectForKey:@"userFullMode"] forKey:@"userFullMode"];
    }
    else {
        [dictUserDetails setObject:@"0" forKey:@"userFullMode"];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:kuserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

}

-(IBAction)previewProfile:(id)sender {
    
    [self localSave];
    
    UIViewController *viewController;
    viewController    = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
    
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

-(IBAction) picLPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag=kImageL;
    currentImage=kImageL;
    [actionSheet showInView:self.view];
}

-(IBAction) picRPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag=kImageR;
    currentImage=kImageR;

    [actionSheet showInView:self.view];
}

-(IBAction) picBasePressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select image"
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"Camera", @"Select from Library", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag=kImageBase;
    currentImage=kImageBase;

    [actionSheet showInView:self.view];
}

-(IBAction)dateChanged:(id)sender{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setDateFormat:@"MM/dd/yyyy"];

    NSString *string = [formatter stringFromDate:datePicker.date];
    txtBday.text=string;
}

//-----------------------------------------------------------------------

-(BOOL) validateData {
    
    if([[[AppDelegate sharedinstance] nullcheck:txtDisplayName.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtBday.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtOccupation.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:txtCity.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    return YES;
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
          
                    [self presentViewController:self.imagePickerController animated:YES completion:nil];
                    
            }];
        }
        default:
            // Do Nothing.........
            break;
    }
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark Keyboard Controls Delegate

//-----------------------------------------------------------------------

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    view = field.superview.superview;
    
    if(direction == BSKeyboardControlsDirectionNext){
        if([field tag]>101) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, field.center.y-60)animated:NO];
            [UIView commitAnimations];
        }
    }
    else
    {
        if([field tag]>101) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, field.center.y-60)animated:NO];
            [UIView commitAnimations];
        }
        else{
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, 0) animated:NO];
            [UIView commitAnimations];
            
        }
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
    
    if(currentImage==kImageBase) {
        imgView2.image=image;
        
    }
    else if(currentImage==kImageL) {
        imgView1.image=image;

    }
    else if(currentImage==kImageR) {
        imgView3.image=image;

    }

    NSData *imageData = UIImageJPEGRepresentation(image, .7);
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest TUploadFile:imageData fileName:@"logo.jpg" contentType:@"image/jpg" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
        NSString *url = [blob publicUrl];
        
        if(currentImage==kImageBase) {
            strImgURLBase=url;
        }
        else if(currentImage==kImageL) {
           strImgURLL=url;
        }
        else if(currentImage==kImageR) {
            strImgURLR=url;
        }
        
        [[AppDelegate sharedinstance] hideLoader];

        [picker dismissViewControllerAnimated:YES completion:^{}];

    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        // handle progress

    } errorBlock:^(QBResponse *response) {
        
        NSLog(@"error: %@", response.error);
    }];

    
}

//-----------------------------------------------------------------------

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {

        [picker dismissViewControllerAnimated:YES completion:^{}];
}

//-----------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Methods

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, textField.center.y-60)animated:NO];
        [UIView commitAnimations];
        
    [self.keyboardControls setActiveField:textField];
    
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

#pragma mark - CHAT Methods

//-----------------------------------------------------------------------

- (IBAction) chatWithUser: (id)sender  {
    
        QBUUser *user = [QBUUser user];
    
        user.password = [QBSession currentSession].sessionDetails.token;  //[[FBSDKAccessToken currentAccessToken] tokenString];
        user.ID = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    
//        user.password = @"12345678";  //[[FBSDKAccessToken currentAccessToken] tokenString];
//        user.ID =16347628;  // [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    
        int nameForChatRoom = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
        nameForChatRoom = nameForChatRoom + 16766971;//17301512;// customShareObj.userID;

        // connect to Chat
        [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {

            QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
            
            NSMutableDictionary *filterRequest = [[NSMutableDictionary alloc] init];
            
            filterRequest[@"name"] = [NSString stringWithFormat:@"%d",nameForChatRoom];
            
            [QBRequest dialogsForPage:page extendedRequest:filterRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
                
                if([dialogObjects count]==0) {
                    
                                // Create room
                    
                                QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypeGroup];
                                chatDialog.name =  [NSString stringWithFormat:@"%d",nameForChatRoom];
                                chatDialog.occupantIDs = @[@(16884167), @(16766971)];
                    
                                [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                                    
                                    
                                } errorBlock:^(QBResponse *response) {
                                    
                                    
                                }];
                }
                else {
       
                        QBChatMessage *message = [QBChatMessage message];
                        [message setText:@"Hey there"];
                        //
                        NSMutableDictionary *params = [NSMutableDictionary dictionary];
                        params[@"save_to_history"] = @YES;
                        [message setCustomParameters:params];
                        
                        QBChatDialog *dialog = [dialogObjects objectAtIndex:0];
                        
                        [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
                            [dialog sendMessage:message completionBlock:^(NSError * _Nullable error) {
                                
                            }];
                        }];
                    
                }
            } errorBlock:^(QBResponse *response) {
                
            }];
        }];
}

@end
