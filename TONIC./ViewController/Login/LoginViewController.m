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
#import "SKPSMTPMessage.h"
#import "NSData+Base64Additions.h"

@interface LoginViewController ()<SKPSMTPMessageDelegate>
{
    /********* Chetu Change *******/
    // This variable used to create view only when viewdidload called for first time only
    int firstTimeViewLoad;
     /********* Chetu Change *******/
}
@property (nonatomic, strong) UITextField * pwdtxtfld;
@property (nonatomic, strong) UITextField * mailtxtfld;
@property (nonatomic, strong) UIScrollView *scrollViewContainer;
@end

@implementation LoginViewController
@synthesize mailtxtfld;
@synthesize pwdtxtfld;
@synthesize scrollViewContainer;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    firstTimeViewLoad = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotLocationLogin) name:@"gotLocationLogin" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(manualAdd) name:@"manualAdd" object:nil];  
   
}

-(void) viewWillAppear:(BOOL)animated {
    
    
    if (firstTimeViewLoad == 0) {
        [self createViewProgrammatically];
    }
    
    
    NSArray *fields = @[ mailtxtfld,pwdtxtfld];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    
    
//    if(isiPhone4) {
//        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
//        
//    }
    
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

#pragma mark create View

-(void)createViewProgrammatically {
    
    
    firstTimeViewLoad = 1;
    
    // get device size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // set background image
    UIImageView *backgroundImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    backgroundImgView.image = [UIImage imageNamed:@"background.png"];
    [self.view addSubview:backgroundImgView];
    
    // create scrollview in order to manage keybord
    scrollViewContainer = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    scrollViewContainer.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollViewContainer];
    
    // create upperbaseview that will contain keyimage and login label on it
    UIView *upperBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 216)];
    upperBaseView.backgroundColor = [UIColor clearColor];
    [scrollViewContainer addSubview:upperBaseView];
    
    UIImageView *keyImgView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 60)/2, 60, 60, 102)];
    keyImgView.image = [UIImage imageNamed:@"Plain White Tee.png"];
    [upperBaseView addSubview:keyImgView];
    
    UILabel *loginLbl = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width  - 106 )/2,keyImgView.frame.size.height + keyImgView.frame.origin.y , 106, 54)];
    loginLbl.text = @"Login";
    loginLbl.textAlignment = NSTextAlignmentCenter;
    loginLbl.textColor = [UIColor whiteColor];
    loginLbl.font = [UIFont fontWithName:@"Oswald-Regular" size:30];
    [upperBaseView addSubview:loginLbl];
    
    // create lowerbaseview that contain email and password textfield and forgot password button and also crate signup button
    UIView *lowerBaseView = [[UIView alloc]initWithFrame:CGRectMake(0, 216, self.view.frame.size.width, (screenHeight - 216))];
    lowerBaseView.backgroundColor = [UIColor whiteColor];
    [scrollViewContainer addSubview:lowerBaseView];
    
    /************ email BaseView  *************/
    UIView *emailTxtFldBaseView = [[UIView alloc]initWithFrame:CGRectMake(50, 40, self.view.frame.size.width - 100, 60)];
    emailTxtFldBaseView.backgroundColor = [UIColor clearColor];
    [lowerBaseView addSubview:emailTxtFldBaseView];
    
    UIImageView *mailIconImg = [[UIImageView alloc]initWithFrame:CGRectMake(16, (emailTxtFldBaseView.frame.size.height - 11)/2, 15, 11)];
    mailIconImg.image = [UIImage imageNamed:@"ico-mail.png"];
    [emailTxtFldBaseView addSubview:mailIconImg];
    
    mailtxtfld = [[UITextField alloc]initWithFrame:CGRectMake(46, 14, emailTxtFldBaseView.frame.size.width - 60, 21)];
    mailtxtfld.delegate = self;
    mailtxtfld.placeholder = @"Enter your email";
    mailtxtfld.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
    mailtxtfld.keyboardType = UIKeyboardTypeEmailAddress;
    [emailTxtFldBaseView addSubview:mailtxtfld];
    
    UIView *narrowLineView = [[UIView alloc]initWithFrame:CGRectMake(46, 42,emailTxtFldBaseView.frame.size.width - 60 , 0.5)];
    narrowLineView.backgroundColor = [UIColor grayColor];
    [emailTxtFldBaseView addSubview:narrowLineView];
    
    /************ PassWord BaseView  *************/
    
    UIView *pawdTxtFldBaseView = [[UIView alloc]initWithFrame:CGRectMake(50, emailTxtFldBaseView.frame.size.height + emailTxtFldBaseView.frame.origin.y, self.view.frame.size.width - 100, 60)];
    pawdTxtFldBaseView.backgroundColor = [UIColor clearColor];
    [lowerBaseView addSubview:pawdTxtFldBaseView];
    
    UIImageView *pawdIconImg = [[UIImageView alloc]initWithFrame:CGRectMake(16, (emailTxtFldBaseView.frame.size.height - 11)/2, 15, 11)];
    pawdIconImg.image = [UIImage imageNamed:@"ico-pwd.png"];
    [pawdTxtFldBaseView addSubview:pawdIconImg];
    
    pwdtxtfld = [[UITextField alloc]initWithFrame:CGRectMake(46, 14, pawdTxtFldBaseView.frame.size.width - 60, 21)];
    pwdtxtfld.delegate = self;
    pwdtxtfld.secureTextEntry = true;
    pwdtxtfld.placeholder = @"Enter your password";
    pwdtxtfld.font = [UIFont fontWithName:@"Montserrat-Regular" size:12];
    pwdtxtfld.keyboardType = UIKeyboardTypeEmailAddress;
    [pawdTxtFldBaseView addSubview:pwdtxtfld];
    
    UIView *narrowLineView2 = [[UIView alloc]initWithFrame:CGRectMake(46, 42,pawdTxtFldBaseView.frame.size.width - 60 , 0.5)];
    narrowLineView2.backgroundColor = [UIColor grayColor];
    [pawdTxtFldBaseView addSubview:narrowLineView2];
    /************ PassWord BaseView  *************/
    
    // create orimageview
    UIImageView *signinImgView = [[UIImageView alloc]initWithFrame:CGRectMake(50,pawdTxtFldBaseView.frame.size.height + pawdTxtFldBaseView.frame.origin.y , lowerBaseView.frame.size.width - 100, 46)];
    signinImgView.image = [UIImage imageNamed:@"roundrect.png"];
    [lowerBaseView addSubview:signinImgView];
    
    // create signin button
    UIButton *signInBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    signInBtn.frame = CGRectMake(50,pawdTxtFldBaseView.frame.size.height + pawdTxtFldBaseView.frame.origin.y , lowerBaseView.frame.size.width - 100, 46);
    [signInBtn addTarget:self action:@selector(LoginBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [signInBtn setTitle:@"SIGN IN" forState:UIControlStateNormal];
    [signInBtn.titleLabel setFont: [UIFont fontWithName:@"Oswald-Regular" size:17]];
    [signInBtn setTintColor:[UIColor whiteColor]];
    signInBtn.titleLabel.textColor = [UIColor whiteColor];
    signInBtn.backgroundColor = [UIColor clearColor];
    [lowerBaseView addSubview:signInBtn];
    
    
    // create frogot password button
    UIButton *forgotPassbtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    forgotPassbtn.frame = CGRectMake(lowerBaseView.frame.size.width - 50 - 120, signInBtn.frame.size.height + signInBtn.frame.origin.y + 4, 120, 21);
    forgotPassbtn.backgroundColor = [UIColor clearColor];
    forgotPassbtn.titleLabel.textColor = [UIColor grayColor];
    forgotPassbtn.tintColor = [UIColor grayColor];
    forgotPassbtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [forgotPassbtn setTitle:@"Forgot Password?" forState:UIControlStateNormal];
    forgotPassbtn.titleLabel.font = [UIFont fontWithName:@"Oswald-Regular" size:17];
    [forgotPassbtn addTarget:self action:@selector(forgotBtnTapped:) forControlEvents:UIControlEventTouchUpInside];
    [lowerBaseView addSubview:forgotPassbtn];
    
    
    UIView *narrowLineBaseview = [[UIView alloc]initWithFrame:CGRectMake(lowerBaseView.frame.size.width - 50 - 117, forgotPassbtn.frame.size.height + forgotPassbtn.frame.origin.y, 110, 0.5)];
    narrowLineBaseview.backgroundColor = [UIColor grayColor];
    [lowerBaseView addSubview:narrowLineBaseview];
    
    
    UIImageView *orImgView = [[UIImageView alloc]initWithFrame:CGRectMake(50,signInBtn.frame.size.height + signInBtn.frame.origin.y + 33 , lowerBaseView.frame.size.width - 100, 35)];
    orImgView.image = [UIImage imageNamed:@"OR-1.png"];
    [lowerBaseView addSubview:orImgView];
    
    
    UIImageView *createAccountImgView = [[UIImageView alloc]initWithFrame:CGRectMake(50,orImgView.frame.size.height + orImgView.frame.origin.y + 17 , lowerBaseView.frame.size.width - 100, 46)];
    createAccountImgView.image = [UIImage imageNamed:@"roundrect.png"];
    [lowerBaseView addSubview:createAccountImgView];
    
     // create signup button
    UIButton *createAccountBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    createAccountBtn.frame = CGRectMake(50,orImgView.frame.size.height + orImgView.frame.origin.y + 17 , lowerBaseView.frame.size.width - 100, 46);
    [createAccountBtn addTarget:self action:@selector(createAccountBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    [createAccountBtn setTitle:@"CREATE AN ACCOUNT" forState:UIControlStateNormal];
    createAccountBtn.titleLabel.textColor = [UIColor whiteColor];
    [createAccountBtn setTintColor:[UIColor whiteColor]];
    
    createAccountBtn.titleLabel.font =  [UIFont fontWithName:@"Oswald-Regular" size:17];
    createAccountBtn.backgroundColor = [UIColor clearColor];
    [lowerBaseView addSubview:createAccountBtn];
    
    // manage ui according to device
    if (isiPhone6Plus) {
        lowerBaseView.frame = CGRectMake(0, self.view.frame.size.height - 400, self.view.frame.size.width, 400);
        
    }else if (isiPhone5) {
        lowerBaseView.frame = CGRectMake(0, self.view.frame.size.height - 360, self.view.frame.size.width, 360);
        
    }else if (isiPhone4) {
        
        lowerBaseView.frame = CGRectMake(0, self.view.frame.size.height - 320, self.view.frame.size.width, 320);
        
        emailTxtFldBaseView.frame = CGRectMake(50, 0, self.view.frame.size.width - 100, 60);
        pawdTxtFldBaseView.frame = CGRectMake(50, emailTxtFldBaseView.frame.size.height + emailTxtFldBaseView.frame.origin.y, self.view.frame.size.width - 100, 60);
        signinImgView.frame = CGRectMake(50,pawdTxtFldBaseView.frame.size.height + pawdTxtFldBaseView.frame.origin.y , lowerBaseView.frame.size.width - 100, 46);
        
        signInBtn.frame = CGRectMake(50,pawdTxtFldBaseView.frame.size.height + pawdTxtFldBaseView.frame.origin.y , lowerBaseView.frame.size.width - 100, 46);
        forgotPassbtn.frame = CGRectMake(lowerBaseView.frame.size.width - 50 - 120, signInBtn.frame.size.height + signInBtn.frame.origin.y + 4, 120, 21);
        narrowLineBaseview.frame = CGRectMake(lowerBaseView.frame.size.width - 50 - 117, forgotPassbtn.frame.size.height + forgotPassbtn.frame.origin.y, 110, 0.5);
        orImgView.frame = CGRectMake(50,signInBtn.frame.size.height + signInBtn.frame.origin.y + 33 , lowerBaseView.frame.size.width - 100, 35);
        createAccountImgView.frame = CGRectMake(50,orImgView.frame.size.height + orImgView.frame.origin.y + 17 , lowerBaseView.frame.size.width - 100, 46);
        createAccountBtn.frame = CGRectMake(50,orImgView.frame.size.height + orImgView.frame.origin.y + 17 , lowerBaseView.frame.size.width - 100, 46);
    }else if (isiPhone6) {
        lowerBaseView.frame = CGRectMake(0, self.view.frame.size.height - 380, self.view.frame.size.width, 380);
        
    }else {
        lowerBaseView.frame = CGRectMake(0, self.view.frame.size.height - 440, self.view.frame.size.width, 440);
        
    }
    
    upperBaseView.frame = CGRectMake(0, 0, self.view.frame.size.width,self.view.frame.size.height - lowerBaseView.frame.size.height );
    keyImgView.frame = CGRectMake((self.view.frame.size.width - 60)/2, (upperBaseView.frame.size.height - 156)/2, 60, 102);
    loginLbl.frame = CGRectMake((self.view.frame.size.width  - 106 )/2,keyImgView.frame.size.height + keyImgView.frame.origin.y , 106, 54);
    scrollViewContainer.contentSize = CGSizeMake(self.view.frame.size.width, lowerBaseView.frame.size.height + lowerBaseView.frame.origin.y);
    
    // manage ui for ipad aswell as iphone 4.
    if (isiPhone4) {
        
        keyImgView.frame = CGRectMake((self.view.frame.size.width - 50)/2, 20, 50, 86);
        loginLbl.frame = CGRectMake((self.view.frame.size.width  - 106 )/2,keyImgView.frame.size.height + keyImgView.frame.origin.y , 106, 44);
        
        scrollViewContainer.contentSize = CGSizeMake(self.view.frame.size.width, lowerBaseView.frame.size.height + lowerBaseView.frame.origin.y);
    }
    
}

-(BOOL) validateData {
    
    if([[[AppDelegate sharedinstance] nullcheck:mailtxtfld.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    NSString *errorMessage;
    
    NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
    NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
 
    if (![emailPredicate evaluateWithObject:mailtxtfld.text]){
        errorMessage = @"Please enter a valid email address";
        
        [[AppDelegate sharedinstance] displayMessage:errorMessage];
        return NO;
    }
    
    if([[[AppDelegate sharedinstance] nullcheck:pwdtxtfld.text] length]==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill all the details"];
        return NO;
    }
    
    return YES;
    
}

//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//-----------------------------------------------------------------------

-(void)LoginBtnPressed:(id)sender {
    
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
        
        [QBRequest logInWithUserEmail:mailtxtfld.text password:pwdtxtfld.text successBlock:^(QBResponse *response, QBUUser *user) {
            
            NSString *email = user.email;
            [[AppDelegate sharedinstance] setStringObj:email forKey:kuserEmail];
            [[AppDelegate sharedinstance] setStringObj:pwdtxtfld.text forKey:kuserPassword];
            
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
             /********** ChetuChange *************/
             
             NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
             [getRequest setObject: @"User" forKey:@"Default"];
        
            /********** ChetuChange *************/
             
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
         [dictUserDetails setObject:[[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"Golfers_name"]] forKey:@"Golfers_name"];
         
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

-(void)createAccountBtnPressed:(UIButton *)sender {
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    RegisterViewController *viewController =[[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}

//-----------------------------------------------------------------------
-(void)forgotBtnTapped:(UIButton *)sender {
    
   
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
    
    
//    NSLog(@"Start Sending");
//    SKPSMTPMessage *emailMessage = [[SKPSMTPMessage alloc] init];
//    emailMessage.delegate = self;
//    emailMessage.fromEmail = @"mohittyagics@gmail.com"; //sender email address
//    emailMessage.toEmail = @"niteshg@chetu.com";  //receiver email address
//    emailMessage.relayHost = @"smtp.gmail.com";
//  //emailMessage.ccEmail =@"your cc address";
//  //emailMessage.bccEmail =@"your bcc address";
//  //emailMessage.relayPorts =
//    emailMessage.requiresAuth = YES;
//    emailMessage.login = @"mohittyagics@gmail.com"; //sender email address
//    emailMessage.pass = @"8218Mkt940178"; //sender email password
//    emailMessage.subject =@"Test application";
//    emailMessage.wantsSecure = YES;
//    emailMessage.delegate = self; // you must include <SKPSMTPMessageDelegate> to your class
//    NSString *messageBody = @"your email body message";
//    //for example :   NSString *messageBody = [NSString stringWithFormat:@"Tour Name: %@\nName: %@\nEmail: %@\nContact No: %@\nAddress: %@\nNote: %@",selectedTour,nameField.text,emailField.text,foneField.text,addField.text,txtView.text];
//    // Now creating plain text email message
//    NSDictionary *plainMsg = [NSDictionary
//                              dictionaryWithObjectsAndKeys:@"text/plain",kSKPSMTPPartContentTypeKey,
//                              messageBody,kSKPSMTPPartMessageKey,@"8bit",kSKPSMTPPartContentTransferEncodingKey,nil];
//    emailMessage.parts = [NSArray arrayWithObjects:plainMsg,nil];
//    //in addition : Logic for attaching file with email message.
//    /*
//     NSString *filePath = [[NSBundle mainBundle] pathForResource:@"filename" ofType:@"JPG"];
//     NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//     NSDictionary *fileMsg = [NSDictionary dictionaryWithObjectsAndKeys:@"text/directory;\r\n\tx-
//     unix-mode=0644;\r\n\tname=\"filename.JPG\"",kSKPSMTPPartContentTypeKey,@"attachment;\r\n\tfilename=\"filename.JPG\"",kSKPSMTPPartContentDispositionKey,[fileData encodeBase64ForData],kSKPSMTPPartMessageKey,@"base64",kSKPSMTPPartContentTransferEncodingKey,nil];
//     emailMessage.parts = [NSArray arrayWithObjects:plainMsg,fileMsg,nil]; //including plain msg and attached file msg
//     */
//    [emailMessage send];
//    // sending email- will take little time to send so its better to use indicator with message showing sending...

    
}

-(void)messageSent:(SKPSMTPMessage *)message{
    NSLog(@"delegate - message sent");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message sent." message:nil delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}
// On Failure
-(void)messageFailed:(SKPSMTPMessage *)message error:(NSError *)error{
    // open an alert with just an OK button
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
    NSLog(@"delegate - error(%d): %@", [error code], [error localizedDescription]);
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
           [scrollViewContainer setContentOffset:CGPointMake(0, textField.center.y+60)animated:NO];
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
    
  //  [self loginTemp];
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


