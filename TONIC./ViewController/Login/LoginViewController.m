//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "LoginViewController.h"
#import "HomeViewController.h"
#import "PDFViewController.h"
#import "RegisterViewController.h"
#import "EditProfileViewController.h"

@interface LoginViewController ()

@end

@implementation LoginViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    txtEmail.text = @"testreal@demo.com";
//    txtPwd.text = @"12345678";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLocationLogin) name:@"gotLocationLogin" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manualAdd) name:@"manualAdd" object:nil];


    
    NSArray *fields = @[ txtEmail,txtPwd];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
     
    }
    
    BOOL isFirstTime = [[NSUserDefaults standardUserDefaults] boolForKey:kIsFirstTime];
    
    if(isFirstTime) {
        
        
    }
    else {
        
        // basic
        EAIntroPage *page1 = [EAIntroPage page];
        page1.title = @"";
        page1.desc = @"";
        
        // basic
        EAIntroPage *page2 = [EAIntroPage page];
        page2.title = @"";
        page2.desc = @"";
        
        EAIntroPage *page3 = [EAIntroPage page];
        page3.title = @"";
        page3.desc = @"";
        
        EAIntroPage *page4 = [EAIntroPage page];
        page4.title = @"";
        page4.desc = @"";
        
        EAIntroPage *page5 = [EAIntroPage page];
        
        if(isiPhone4) {
            page1.bgImage = [UIImage imageNamed:@"Slide 1_4s"];
            page2.bgImage = [UIImage imageNamed:@"Slide 2_4s"];
            page3.bgImage = [UIImage imageNamed:@"Slide 3_4s"];
            page4.bgImage = [UIImage imageNamed:@"Slide 4_4s"];
            page5.bgImage = [UIImage imageNamed:@"Silde 5_4s"];

        }
        else {
            page1.bgImage = [UIImage imageNamed:@"Slide 1"];
            page2.bgImage = [UIImage imageNamed:@"Slide 2"];
            page3.bgImage = [UIImage imageNamed:@"Slide 3"];
            page4.bgImage = [UIImage imageNamed:@"Slide 4"];
            page5.bgImage = [UIImage imageNamed:@"Silde 5"];

        }
        
        EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1,page2,page3,page4,page5]];
        UIFont *font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
        [intro.skipButton.titleLabel setFont:font];
        [intro.skipButton setTitle:@"SKIP" forState:UIControlStateNormal];
        [intro.skipButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [intro setDelegate:self];
        [intro showInView:self.view animateDuration:0.0];
        
        [[NSUserDefaults standardUserDefaults]  setBool:YES forKey:kIsFirstTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
}

-(void) viewWillAppear:(BOOL)animated {
    [AppDelegate sharedinstance].currentScreen = kScreenLogin;

    self.navigationController.navigationBarHidden=YES;

    self.menuContainerViewController.panMode = NO;
    
    if(autocompletePlaceStatus == -1) {
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
       if([strlat length]==0)
        {
            // Show 2 options to get location
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"Location will only be used when app is opened"
                                         message:@"ParTee needs location access to show near by courses and golfers"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            
            UIAlertAction* autoButton = [UIAlertAction
                                        actionWithTitle:@"Detect automatically"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            [[AppDelegate sharedinstance] locationInit];
                                        }];
            
            UIAlertAction* manuallyButton = [UIAlertAction
                                       actionWithTitle:@"Add manually"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self manualAdd];
                                       }];
            
            [alert addAction:autoButton];
            [alert addAction:manuallyButton];
            
            [self presentViewController:alert animated:YES completion:nil];
           
        }
    }
    else if(autocompletePlaceStatus==2)  {
        [self login];
    }
}

-(BOOL) validateData {
    
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
    
    if([[[AppDelegate sharedinstance] nullcheck:txtPwd.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    return YES;
    
}

//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//-----------------------------------------------------------------------

- (IBAction)action_Login:(id)sender {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    

    
        // Normal login
        
        bool readyToProceed = [self validateData];
        
        if(readyToProceed)
        {
            
            strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
            strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
            
            strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
            strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
            
            if([strlat length]==0)
            {
                // Show 2 options to get location
                
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"Location will only be used when app is opened"
                                             message:@"ParTee needs location access to show near by courses and golfers"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                
                
                UIAlertAction* autoButton = [UIAlertAction
                                             actionWithTitle:@"Detect automatically"
                                             style:UIAlertActionStyleDefault
                                             handler:^(UIAlertAction * action) {
                                                 [[AppDelegate sharedinstance] locationInit];
                                             }];
                
                UIAlertAction* manuallyButton = [UIAlertAction
                                                 actionWithTitle:@"Add manually"
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                     [self manualAdd];
                                                 }];
                
                [alert addAction:autoButton];
                [alert addAction:manuallyButton];
                
                [self presentViewController:alert animated:YES completion:nil];
                
            }
            else
            {
                [self login];
                
            }

        }
    
}

 -(void) login {
     
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest logInWithUserEmail:txtEmail.text password:txtPwd.text successBlock:^(QBResponse *response, QBUUser *user) {
            
            [[AppDelegate sharedinstance] setStringObj:txtEmail.text forKey:kuserEmail];
            [[AppDelegate sharedinstance] setStringObj:txtPwd.text forKey:kuserPassword];
            
            NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
            [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
            
            [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                
                // response processing
                object =  [objects objectAtIndex:0];
                
                // user ID
                NSString *strID = [NSString stringWithFormat:@"%lu",(unsigned long)user.ID];
                [[AppDelegate sharedinstance] setStringObj:strID forKey:kuserDBID];
                [[AppDelegate sharedinstance] setStringObj:strID forKey:@"userQuickbloxID"];
                
                // user info obj ID
                [[AppDelegate sharedinstance] setStringObj:object.ID forKey:kuserInfoID];
                
                NSString *strName= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userDisplayName"]];
                NSString *strState = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userState"]];
                NSString *strCity = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userCity"]];
                NSString *strZipCode = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userZipcode"]];
                NSString *strHandicap = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userHandicap"]];
                NSString *strInfo = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userInfo"]];
                
                NSString *strHomeCourseId = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"home_course_id"]];
                
                NSString *strHomeCourseName = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"home_coursename"]];
                
                NSString *imageUrl ;
                
                if([[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPicBase"]] length]>0) {
                    
                    imageUrl = [NSString stringWithFormat:@"%@", [object.fields objectForKey:@"userPicBase"]];
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
                
                NSMutableDictionary *dictUserDetails = [[NSMutableDictionary alloc] init];
                [dictUserDetails setObject:strName forKey:@"userDisplayName"];
                [dictUserDetails setObject:strCity forKey:@"userCity"];
                [dictUserDetails setObject:strState forKey:@"userState"];
                [dictUserDetails setObject:strZipCode forKey:@"userZipcode"];
                [dictUserDetails setObject:strHandicap forKey:@"userHandicap"];
                [dictUserDetails setObject:strInfo forKey:@"userInfo"];
                [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields  objectForKey:@"userPicBase"]] forKey:@"userPicBase"];

                [dictUserDetails setObject:userFullMode forKey:@"userFullMode"];
                
                
                [dictUserDetails setObject:[object.fields objectForKey:@"userPurchasedConnects"]forKey:@"userPurchasedConnects"];
                [dictUserDetails setObject:[object.fields objectForKey:@"userFreeConnects"]forKey:@"userFreeConnects"];
                
                [dictUserDetails setObject:strID forKey:@"userInfoId"];
                
                [dictUserDetails setObject:strHomeCourseName forKey:@"home_coursename"];
                [dictUserDetails setObject:strHomeCourseId forKey:@"home_course_id"];
                
                               [dictUserDetails setObject:[object.fields objectForKey:@"userPush"] forKey:@"userPush"];
                
                
                strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
                strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
                
                strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
                strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
                
                NSString *strPoint = [NSString stringWithFormat:@"%f,%f",[strlong floatValue],[strlat floatValue]];
                [object.fields setObject:strPoint forKey:@"current_location"];
                
                [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"isDevelopment"]] forKey:@"isDevelopment"];
                
                [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:kuserData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self bindSearchData:object searchType: @"User"];
                [self bindSearchData:object searchType: @"Pro"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
                
                [self  registerForNotifications];
                
                [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object1) {
                    // object updated
                    
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
                    
                    [[AppDelegate sharedinstance] hideLoader];
           
                    
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayServerErrorMessage];
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                //                    ViewUsersViewController *viewController=[[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                //                    viewController.strIsMyMatches=@"1";
                
                
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayServerErrorMessage];
                
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
            
        } errorBlock:^(QBResponse *response) {
            
            [[AppDelegate sharedinstance] hideLoader];
            
            [[AppDelegate sharedinstance] displayMessage:@"Email or password is not correct"];
            
            autocompletePlaceStatus=3;
            [self dismissViewControllerAnimated:YES completion:nil];
            
        }];
     
}

-(void) bindSearchData:(QBCOCustomObject *) userObject searchType:(NSString *) searchType
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
                       [self bindSearchData:userObject searchType: searchType];
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
         
         NSMutableDictionary *dictUserDetails = [[NSMutableDictionary alloc] init];
         [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Gender"]] forKey:@"Gender"];
         
         NSMutableArray *arrCity = [object.fields objectForKey:@"City"];
         if(arrCity == nil)
         {
             arrCity = [[NSMutableArray alloc] init];
         }
         
         [dictUserDetails setObject: arrCity forKey:@"City"];
         [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Age"] ]forKey:@"Age"];
         [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Type"]] forKey:@"Type"];
         [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"ZipCode"]] forKey:@"ZipCode"];
         [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"State"]] forKey:@"State"];
         
         NSString *strinterested_in_Handicap =[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Handicap"]];
         
         if([strinterested_in_Handicap length]>0) {
             [dictUserDetails setObject:[object.fields objectForKey:@"Handicap"] forKey:@"Handicap"];
         }
        // [dictUserDetails setObject:[object.fields objectForKey:@"userPush"] forKey:@"userPush"];
         
         NSString *strinterested_in_location =[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Location"]];
         
         if([strinterested_in_location length]>0) {
             [dictUserDetails setObject:[object.fields objectForKey:@"Location"] forKey:@"Location"];
         }
         
        /* NSString *strinterested_in_home_coursename =[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"interested_in_home_coursename"]];
         
         if([strinterested_in_home_coursename length]>0) {
             [dictUserDetails setObject:[object.fields objectForKey:@"interested_in_home_coursename"] forKey:@"interested_in_home_coursename"];
         }*/
         
         NSString *searchDataType = [searchType isEqualToString:@"User"] ? kuserSearchUser : kuserSearchPro;
         
         [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:searchDataType];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
         
         [self  registerForNotifications];
         
        
     }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}


//-----------------------------------------------------------------------

- (IBAction)action_CreateAccount:(id)sender  {
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    RegisterViewController *viewController =[[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
      [self.navigationController pushViewController:viewController animated:YES];
    
}

//-----------------------------------------------------------------------

- (IBAction)action_ForgotPassword:(id)sender {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:@"Forgot password?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"Enter Email Here";
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
    }];
    
    
    
    UIAlertAction* okButton = [UIAlertAction
                                 actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     NSString *email = [alert textFields][0].text;
                                     NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
                                     NSString *trimmed = [email stringByTrimmingCharactersInSet:whitespace];
                                     NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
                                     NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                                     
                                     
                                     if([trimmed length]==0 || ![emailPredicate evaluateWithObject:trimmed])
                                     {
                                         UIAlertController * alert = [UIAlertController
                                                                      alertControllerWithTitle:kAppName
                                                                      message:@"Please enter a valid email address"
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
                                     else
                                     {

                                             
                                             [[AppDelegate sharedinstance] showLoader];
                                             
                                             // Reset User's password with email
                                             [QBRequest resetUserPasswordWithEmail:trimmed successBlock:^(QBResponse *response) {
                                                 // Reset was successful
                                                 
                                                 [[AppDelegate sharedinstance] hideLoader];
                                                 
                                                 [[AppDelegate sharedinstance] displayMessage:@"Password reset instructions has been mailed."];
                                                 
                                             } errorBlock:^(QBResponse *response) {
                                                 // Error
                                                 [[AppDelegate sharedinstance] hideLoader];
                                                 
                                                 if([response status]==404) {
                                                     
                                                     [[AppDelegate sharedinstance] displayMessage:@"Email not registered"];
                                                 }
                                             }];
                                         
                                     }
                                 }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                       
                                     }];
    
    [alert addAction:okButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    //
    //    }];
    //
}

-(void) registerForNotifications {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

-(void) manualAdd {
    // manual
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    [self presentViewController:acController animated:YES completion:nil];
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark Keyboard Controls Delegate

//-----------------------------------------------------------------------

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *view;
    
    view = field.superview.superview;
    
    if(isiPhone4) {
        
        if([field tag]==101) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, field.center.y+60)animated:NO];
            [UIView commitAnimations];
            
        }
        else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, field.center.y+120)animated:NO];
            [UIView commitAnimations];
            
        }
        
    }
    else {
        if(direction == BSKeyboardControlsDirectionNext){
            if([field tag]>101) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationDuration:.5];
                [scrollViewContainer setContentOffset:CGPointMake(0, field.center.y+20)animated:NO];
                [UIView commitAnimations];
            }
        }
        else
        {
            if([field tag]>101) {
                [UIView beginAnimations:nil context:NULL];
                [UIView setAnimationBeginsFromCurrentState:YES];
                [UIView setAnimationDuration:.5];
                [scrollViewContainer setContentOffset:CGPointMake(0, field.center.y+20)animated:NO];
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
    
    if(isiPhone4) {
        
        if([textField tag]==101) {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, textField.center.y+60)animated:NO];
            [UIView commitAnimations];
            
            [self.keyboardControls setActiveField:textField];
        }
        else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, textField.center.y+120)animated:NO];
            [UIView commitAnimations];
            
            [self.keyboardControls setActiveField:textField];
        }
        
    }
    else {
        if([textField tag]==101) {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
            [UIView commitAnimations];
            
            [self.keyboardControls setActiveField:textField];
        }
        
        else {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDuration:.5];
            [scrollViewContainer setContentOffset:CGPointMake(0, textField.center.y+20)animated:NO];
            [UIView commitAnimations];
        
            [self.keyboardControls setActiveField:textField];
        
        }
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

-(void) gotLocationLogin {
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    [self login];
}

//-----------------------------------------------------------------------

// Handle the user's selection.
- (void)viewController:(GMSAutocompleteViewController *)viewController
didAutocompleteWithPlace:(GMSPlace *)place {
    autocompletePlaceStatus=2;

    NSString *strLat = [NSString stringWithFormat:@"%f", place.coordinate.latitude];
    NSString *strLong = [NSString stringWithFormat:@"%f",place.coordinate.longitude];
    
    [[AppDelegate sharedinstance] setStringObj:strLat forKey:klocationlat];
    [[AppDelegate sharedinstance] setStringObj:strLong forKey:klocationlong];
    
    // Do something with the selected place.
    NSLog(@"Place name %@", place.name);
    NSLog(@"Place address %@", place.formattedAddress);
    
   // txtAddress.text = place.formattedAddress;
    
    NSLog(@"Place attributions %@", place.attributions.string);
    

    
    [self login];

   // [self dismissViewControllerAnimated:YES completion:nil];
    
}

//-----------------------------------------------------------------------

- (void)viewController:(GMSAutocompleteViewController *)viewController
didFailAutocompleteWithError:(NSError *)error {
    autocompletePlaceStatus =3;
    // TODO: handle the error.
    NSLog(@"error: %ld", [error code]);
    [self dismissViewControllerAnimated:YES completion:nil];
}

//-----------------------------------------------------------------------

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    autocompletePlaceStatus = -1;
    NSLog(@"Autocomplete was cancelled.");
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end


