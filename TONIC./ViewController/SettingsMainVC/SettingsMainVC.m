//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "SettingsMainVC.h"
#import "HomeViewController.h"
#import "SendMessageCellTableViewCell.h"

#define kButtonCity 1
#define kButtonAge 2
#define kButtonType 3

#define kScreenViewUsers @"1"
#define kScreenMenu @"2"

@interface SettingsMainVC ()

@end

@implementation SettingsMainVC
@synthesize cameFromScreen;



- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateConstraints];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    if([[AppDelegate sharedinstance].strisDevelopment isEqualToString:@"1"]) {
        [btnDevOn setHidden:NO];
    }
    else {
        [btnDevOn setHidden:YES];
    }
    

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    
    [tblMembers setSeparatorColor:[UIColor clearColor]];

    self.navigationController.navigationBarHidden=YES;
    
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 784)];
    }
    else {
        [scrollViewContainer setContentSize:CGSizeMake(320, 784)];
    }
    
    [tblMembers reloadData];
    
   [self bindData];
}
#pragma mark updateConstarints

// Update view frame according to device

-(void)updateConstraints {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat height = screenRect.size.height;
    CGFloat width = screenRect.size.width;
    
    settingBaseView.frame = CGRectMake(0, 0,width , settingBaseView.frame.size.height);
    settinglbl.frame = CGRectMake(15, 12, 214, 40);
    notificationBaseView.frame = CGRectMake(0, notificationBaseView.frame.origin.y, width, 44);
    notificationNarrowLineView.frame = CGRectMake(10, notificationNarrowLineView.frame.origin.y, width - 20, notificationNarrowLineView.frame.size.height);
    btnPush.frame = CGRectMake(width - 40 - 15, btnPush.frame.origin.y, 40, btnPush.frame.size.height);
    notificationBtn.frame = CGRectMake(16, notificationBtn.frame.origin.y, width - 16, notificationBtn.frame.size.height);
    
    restorePurchaseBaseView.frame = CGRectMake(0, restorePurchaseBaseView.frame.origin.y, width, 44);
    restorePurchaseNarrowLineView.frame = CGRectMake(10, notificationNarrowLineView.frame.origin.y, width - 20, restorePurchaseNarrowLineView.frame.size.height);
    restorePurchaseNextbtn.frame = CGRectMake(width - 16 - 18, restorePurchaseNextbtn.frame.origin.y, 18, restorePurchaseNextbtn.frame.size.height);
    restorePurchaseBtn.frame = CGRectMake(16, restorePurchaseBtn.frame.origin.y, width - 16, restorePurchaseBtn.frame.size.height);
    
    changePassBaseView.frame = CGRectMake(0, changePassBaseView.frame.origin.y, width, 44);
    changePassNarrowLineView.frame = CGRectMake(10, changePassNarrowLineView.frame.origin.y, width - 20, changePassNarrowLineView.frame.size.height);
    changePassNextBtn.frame = CGRectMake(width - 16 - 18, changePassNextBtn.frame.origin.y, 18, changePassNextBtn.frame.size.height);
    changePassBtn.frame = CGRectMake(16, changePassBtn.frame.origin.y, width - 16, changePassBtn.frame.size.height);
    
    supportBaseView.frame = CGRectMake(0, supportBaseView.frame.origin.y, width, supportBaseView.frame.size.height);
    
    walkThroughBaseView.frame = CGRectMake(0, walkThroughBaseView.frame.origin.y, width, 44);
    walktroughNarrowLineView.frame = CGRectMake(10, walktroughNarrowLineView.frame.origin.y, width - 20, walktroughNarrowLineView.frame.size.height);
    walkthroughNextBtn.frame = CGRectMake(width - 16 - 18, walkthroughNextBtn.frame.origin.y, 18, walkthroughNextBtn.frame.size.height);
    walkthroughBtn.frame = CGRectMake(16, walkthroughBtn.frame.origin.y, width - 16, walkthroughBtn.frame.size.height);
    
    shareBaseview.frame = CGRectMake(0, shareBaseview.frame.origin.y, width, 44);
    shareNarrowLineView.frame = CGRectMake(10, shareNarrowLineView.frame.origin.y, width - 20, shareNarrowLineView.frame.size.height);
    shareBtn.frame = CGRectMake(width - 16 - 18, shareBtn.frame.origin.y, 18, walkthroughNextBtn.frame.size.height);
    shareBtnp.frame = CGRectMake(16, shareBtnp.frame.origin.y, width - 16, shareBtnp.frame.size.height);
    
    rateBaseView.frame = CGRectMake(0, rateBaseView.frame.origin.y, width, 44);
    rateNarrowLineView.frame = CGRectMake(10, rateNarrowLineView.frame.origin.y, width - 20, rateNarrowLineView.frame.size.height);
    rateNextBtn.frame = CGRectMake(width - 16 - 18, rateNextBtn.frame.origin.y, 18, rateNextBtn.frame.size.height);
    rateBtn.frame = CGRectMake(16, rateBtn.frame.origin.y, width - 16, rateBtn.frame.size.height);
    
    feedbackBaseview.frame = CGRectMake(0, feedbackBaseview.frame.origin.y, width, 44);
    feedbackNarrowlineView.frame = CGRectMake(10, feedbackNarrowlineView.frame.origin.y, width - 20, feedbackNarrowlineView.frame.size.height);
    feedBackNextBtn.frame = CGRectMake(width - 16 - 18, feedBackNextBtn.frame.origin.y, 18, feedBackNextBtn.frame.size.height);
    feedBackBtn.frame = CGRectMake(16, feedBackBtn.frame.origin.y, width - 16, feedBackBtn.frame.size.height);
    
    faqBaseView.frame = CGRectMake(0, faqBaseView.frame.origin.y, width, 44);
    faqNarrowLineVeiw.frame = CGRectMake(10, faqNarrowLineVeiw.frame.origin.y, width - 20, faqNarrowLineVeiw.frame.size.height);
    faqBtn.frame = CGRectMake(width - 16 - 18, faqBtn.frame.origin.y, 18, faqBtn.frame.size.height);
    faqBtnUp.frame = CGRectMake(16, faqBtnUp.frame.origin.y, width - 16, faqBtnUp.frame.size.height);
    
    termsUseBaseView.frame = CGRectMake(0, termsUseBaseView.frame.origin.y, width, 44);
    tacNarrowLineView.frame = CGRectMake(10, tacNarrowLineView.frame.origin.y, width - 20, tacNarrowLineView.frame.size.height);
    tAcNextBtn.frame = CGRectMake(width - 16 - 18, tAcNextBtn.frame.origin.y, 18, tAcNextBtn.frame.size.height);
    tAcBtn.frame = CGRectMake(16, tAcBtn.frame.origin.y, width - 16, tAcBtn.frame.size.height);
    
    privacyPolicyBaseVieqw.frame = CGRectMake(0, privacyPolicyBaseVieqw.frame.origin.y, width, 44);
    privacyPolicyNarrowView.frame = CGRectMake(10, privacyPolicyNarrowView.frame.origin.y, width - 20, privacyPolicyNarrowView.frame.size.height);
    privacyNextBtn.frame = CGRectMake(width - 16 - 18, privacyNextBtn.frame.origin.y, 18, privacyNextBtn.frame.size.height);
    privacyBTn.frame = CGRectMake(16, privacyBTn.frame.origin.y, width - 16, privacyBTn.frame.size.height);
    
    VersionBaseView.frame = CGRectMake(0, VersionBaseView.frame.origin.y, width, 44);
    versionNarrowView.frame = CGRectMake(10, versionNarrowView.frame.origin.y, width - 20, versionNarrowView.frame.size.height);
    versionNextLbl.frame = CGRectMake(width - 18 - 31, versionNextLbl.frame.origin.y, 31, versionNextLbl.frame.size.height);
    versionBtn.frame = CGRectMake(16, versionBtn.frame.origin.y, width - 16, versionBtn.frame.size.height);
    
    supportLbl.frame = CGRectMake(supportLbl.frame.origin.x, supportLbl.frame.origin.y, supportLbl.frame.size.width, supportLbl.frame.size.height);
    
    logoutBTn.frame = CGRectMake(0, logoutBTn.frame.origin.y, width, logoutBTn.frame.size.height);
    LogoutLbl.frame = CGRectMake(0, LogoutLbl.frame.origin.y, width, LogoutLbl.frame.size.height);
    
}
-(void) viewWillAppear:(BOOL)animated {
    
    self.navigationController.navigationBarHidden = YES;
    
    
    if([cameFromScreen isEqualToString:kScreenViewUsers]) {
        [btnBack setBackgroundImage:[UIImage imageNamed:@"ico-back"] forState:UIControlStateNormal];
        [btnBack setFrame:CGRectMake(15, 30, 11, 20)];
        
    }
    else {
        [btnBack setBackgroundImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
        [btnBack setFrame:CGRectMake(15, 34, 20, 16)];
        
    }
    
    [btnBack setBackgroundImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
    [btnBack setFrame:CGRectMake(15, 34, 20, 16)];
}

-(void) savesettings {
    
    [object.fields setObject:strPush  forKey:@"userPush"];
    
    [object.fields setObject:isDev forKey:@"isDevelopment"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        // object updated
        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
        
        [dictUserData setObject:isDev forKey:@"isDevelopment"];
        [dictUserData setObject:strPush forKey:@"userPush"];
        
        [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[AppDelegate sharedinstance] hideLoader];
//        [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) bindData {
    
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        arrData=objects;
        
        if([objects count]>0) {
            
            [AppDelegate sharedinstance].isUpdate=YES;
            
            // If user exists, get info from server
            object =  [arrData objectAtIndex:0];
            
            
            strPush = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"userPush"]];
            
            if([strPush length]>0) {
                
            }
            else {
                strPush=@"1";
            }
            
            if([strPush isEqualToString:@"1"]) {
                
                [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];
            }
            else {
                [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOff"] forState:UIControlStateNormal];

            }
            
           

            
        }
        else {
            
            strPush=@"1";
            
            [btnPush  setImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];

        }
        
        NSString *strDevMode = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"isDevelopment"]];
        isDev = strDevMode;
        
        if([strDevMode isEqualToString:@"1"]) {
            [btnDevOn setTitle:@"Dev-OFF" forState:UIControlStateNormal];
        }
        else {
            [btnDevOn setTitle:@"Dev-ON" forState:UIControlStateNormal];
        }
        
        [self getCityForSelectedState];
    }
    errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
}

-(void) getCityForSelectedState {
    
    NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];

    NSString *strSelectedState = [dictUserDetails objectForKey:@"userState"];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:strSelectedState forKey:@"stateName"];
    
    [QBRequest objectsWithClassName:@"Location" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        [[AppDelegate sharedinstance] hideLoader];
        
        arrData1=objects;
        
        for(int i=0;i<[arrData1 count];i++) {
            
            QBCOCustomObject *obj = [arrData1 objectAtIndex:i];
            
            NSString *strName = [obj.fields objectForKey:@"stateName"];
 
            strName = [obj.fields objectForKey:@"cityName"];
            
            if(![arrCityList containsObject:strName]) {
                [arrCityList addObject:strName];
            }
        }
        
        [arrCityList addObject:@"All"];

    }
    errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
       }];
    

}


- (IBAction) pushTapped:(id)sender {
    
    if([strPush isEqualToString:@"1"]) {
        strPush=@"0";
        [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOff"] forState:UIControlStateNormal];
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        
        
    }
    else {
        strPush=@"1";
        [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];
        [[AppDelegate sharedinstance] registerForNotifications];
    }
    
    [self savesettings];
}

- (IBAction) saveTapped:(id)sender {
    
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
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
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


-(IBAction) changePwdTapped:(id)sender {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    UIAlertView *forgotpasswordAlert = [[UIAlertView alloc]initWithTitle:kAppName message:@"Enter your new password"  delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    forgotpasswordAlert.tag=300;
    
    forgotpasswordAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField* textField = [forgotpasswordAlert textFieldAtIndex:0];
    textField.placeholder=@"Enter password here";
    textField.secureTextEntry=YES;
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
    }
    else if(buttonTapped == kButtonAge) {
     
        if([tempArraySelcted count]>0)
            txtAge.text =  [[tempArraySelcted valueForKey:@"description"] componentsJoinedByString:@","];

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


-(IBAction)devModeChanged:(id)sender {
  
    if([isDev isEqualToString:@"1"]) {
        // move to production
        isDev=@"";
        
        [btnDevOn setTitle:@"Dev-ON" forState:UIControlStateNormal];
    }
    else {
        isDev=@"1";
        // move to dev
        [btnDevOn setTitle:@"Dev-OFF" forState:UIControlStateNormal];

    }
    
    [self savesettings];
}

-(IBAction)Walkthroughtapped:(id)sender {
    
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
}

#pragma mark - EAIntroView delegate

- (void)introDidFinish:(EAIntroView *)introView wasSkipped:(BOOL)wasSkipped {
    if(wasSkipped) {
        NSLog(@"Intro skipped");
    } else {
        NSLog(@"Intro finished");
    }
}


-(IBAction)Feedbacktapped:(id)sender {
    
    if (![MFMailComposeViewController canSendMail]) {
        
        [[AppDelegate sharedinstance] displayMessage:@"Please setup mail on phone to provide the feedback"];
        //Please setup mail on phone to Register and use the SCA app.
        return;
    }
    
    NSString *strAppVersion = [[AppDelegate sharedinstance] getStringObjfromKey:@"versionapp"];
    
    NSString *strMailSubject =[NSString stringWithFormat:@"ParTee App Feedback for version %@",strAppVersion];
    
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    
    NSArray *toRecipients = [NSArray arrayWithObjects:@"feedback@partee.golf",nil];
    [mailer setToRecipients:toRecipients];

    mailer.mailComposeDelegate = self;
    [mailer setSubject:strMailSubject];
//    [mailer setMessageBody:strMailSubject isHTML:NO];
    
    mailer.navigationBar.barStyle = UIBarStyleBlack;
    mailer.navigationBar.tintColor = [UIColor blackColor];
    
    [mailer.navigationBar setTintColor:[UIColor whiteColor]];
    [self presentViewController:mailer animated:YES completion:nil];
}

-(IBAction)Sharetapped:(id)sender {
    
    NSString *text = @"Join the ParTee! Sign up. Make a Friend. Play some golf.";
    NSURL *url;
    UIImage *image = [UIImage imageNamed:@"appicon.png"];
    
    image = [UIImage imageNamed:@"unspecified.png"];
    
    url= [NSURL URLWithString:@"https://itunes.apple.com/us/app/partee-golf-connect-with-other-golfers/id1244801350?ls=1&mt=8"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url,image]
     applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)Ratetapped:(id)sender {
    NSString *strWebsite = @"https://itunes.apple.com/us/app/partee-golf-connect-with-other-golfers/id1244801350?ls=1&mt=8";
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }
}

-(IBAction)FAQtapped:(id)sender {
    NSString *strWebsite = @"https://www.partee.golf/faq";
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
    }
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

-(IBAction)Signouttapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag=121;
    [alert show];

}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark - Mail-Export

//-----------------------------------------------------------------------

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
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
//
//        if(![[selectedType objectAtIndex:indexPath.row] isEqualToString:str])    {
//            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
//            [SendMessageCell.selectbtnimg setHidden:NO];
//            
//        }
//        else
//        {
//            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
//            [SendMessageCell.selectbtnimg setHidden:YES];
//        }
        
    }
    else if(buttonTapped == kButtonAge) {
       str = [arrAgeList objectAtIndex:indexPath.row];
//
//        if(![[selectedAge objectAtIndex:indexPath.row] isEqualToString:str])    {
//            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
//            [SendMessageCell.selectbtnimg setHidden:NO];
//            
//        }
//        else
//        {
//            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
//            [SendMessageCell.selectbtnimg setHidden:YES];
//        }
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

        if ([tempArraySelcted containsObject:str]) {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted removeObject:str];
        }
        else {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            
            [tempArraySelcted addObject:str];
        }
    }
    
    else  if(buttonTapped == kButtonAge){
        [tempArraySelcted removeAllObjects];
        
        str = [arrAgeList objectAtIndex:indexPath.row];
        if (![tempArraySelcted containsObject:str]) {
            
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

//-----------------------------------------------------------------------

#pragma mark - Alert View Methods

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 121)
    {
        if (buttonIndex == 0)
        {
        }
        else if (buttonIndex == 1)
        {
            
            [[AppDelegate sharedinstance] setStringObj:@"" forKey:kuserEmail];
            
            LoginViewController *loginView;
            
            loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
            
            UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:loginView];
            navigationController.viewControllers = controllers;
            
            self.menuContainerViewController.panMode=NO;
            
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
        }
    }
    else if([alertView tag]==300) {
        
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

@end
