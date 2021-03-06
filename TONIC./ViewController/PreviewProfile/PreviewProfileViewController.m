//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "PreviewProfileViewController.h"
#import "HomeViewController.h"
#import "PDFViewController.h"
#import "ReportViewController.h"
#import "DemoMessagesViewController.h"
#define kPickerBday 1
#define kPickerCity 2
#define kPickerState 3

#define kImageChosen 1
#define kImageDelete 2
#define kImageLoaded 3
#define kImageCancel 3

#define kScreenViewUsers @"1"
#define kScreenViewMatch @"3"
#define kScreenViewInvitation @"4"
#define kScreenViewAccepted @"5"
#define kScreenViewPro @"6"

#define kScreenOthers @"2"

@interface PreviewProfileViewController ()

@end

@implementation PreviewProfileViewController
@synthesize HUD;
@synthesize strCameFrom,strEmailOfUser;
@synthesize arrConnections;
@synthesize sharedChatDialog;
@synthesize otherUserObject;
@synthesize userID;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateConstarints];
    [self.navigationController setNavigationBarHidden:YES];
    
    [scrollViewContainer setContentSize:CGSizeMake(320, 1500)];
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [[AppDelegate sharedinstance] hideLoader];
    [imgBadge setHidden:YES];

    [imgViewProfilePic setContentMode:UIViewContentModeCenter];
    
    [achievments setHidden:YES];
    [offering setHidden:YES];
    [email setHidden:YES];
    
    [self bindData];
}

-(void) viewWillAppear:(BOOL)animated {
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 650)];
    }
}

- (void) bindData {

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    if([strCameFrom isEqualToString:kScreenViewMatch]) {
        [getRequest setObject:strEmailOfUser forKey:@"userEmail"];
        
        [btnOptions setHidden:NO];
        [btnOptionsBig setHidden:NO];
        
        [btnAdd setHidden:YES];
        [btnAddBg setHidden:YES];

        
    }
    else if([strCameFrom isEqualToString:kScreenViewUsers]) {
        [btnOptions setHidden:YES];
        [btnOptionsBig setHidden:YES];
        scrollViewContainer.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
        [btnAdd setHidden:NO];
        [btnAddBg setHidden:NO];
        
        [getRequest setObject:strEmailOfUser forKey:@"userEmail"];

        [lblScreenName setText:@"Golfers"];

    }
    else if([strCameFrom isEqualToString:kScreenViewInvitation]) {
        [btnOptions setHidden:YES];
        [btnOptionsBig setHidden:YES];
        
        [btnAdd setHidden:YES];
        [btnAddBg setHidden:YES];
        
        [getRequest setObject:strEmailOfUser forKey:@"userEmail"];
        
        [lblScreenName setText:@"Invitation"];
    }
    else if([strCameFrom isEqualToString:kScreenViewAccepted]) {
        [btnOptions setHidden:YES];
        [btnOptionsBig setHidden:YES];
        
        [btnAdd setHidden:YES];
        [btnAddBg setHidden:YES];
        
        [getRequest setObject:strEmailOfUser forKey:@"userEmail"];
        
        [lblScreenName setText:@"Preview"];
    }
    else if([strCameFrom isEqualToString:kScreenViewPro]) {
        [btnOptions setHidden:YES];
        [btnOptionsBig setHidden:YES];
        
        [btnAdd setHidden:YES];
        [btnAddBg setHidden:YES];
        
        [getRequest setObject:userID forKey:@"_id"];
        
        [lblScreenName setText:@"Preview"];
    }
    else  {
        [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
        
        [btnAdd setHidden:YES];
        [btnAddBg setHidden:YES];
        
        [btnOptions setHidden:YES];
        [btnOptionsBig setHidden:YES];
        
    }
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        [[AppDelegate sharedinstance] hideLoader];
        
        // response processing
        dictUserData =  [objects objectAtIndex:0];
        
        NSString *imageUrl ;

        if([[[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userPicBase"]] length]>0) {
            imageUrl = [NSString stringWithFormat:@"%@", [dictUserData.fields objectForKey:@"userPicBase"]];
            
            [imgViewProfilePic setShowActivityIndicatorView:YES];
            [imgViewProfilePic setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            [imgViewProfilePic sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [imgViewProfilePic setImage:image];
                [imgViewProfilePic setContentMode:UIViewContentModeScaleAspectFit];
                [imgViewProfilePic setShowActivityIndicatorView:NO];

            }];
            

            
        }
        else {
            [imgViewProfilePic setImage:[UIImage imageNamed:@"user"]];
        }
        
        NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userFullMode"]];
        
        if([userFullMode isEqualToString:@"1"]) {
            [imgBadge setHidden:NO];
        }
        else {
            [imgBadge setHidden:YES];
        }
        
        
        
        long int age = [[AppDelegate sharedinstance] getAge:[dictUserData.fields objectForKey:@"userBday" ]];
        NSString *strAge = [NSString stringWithFormat:@"%ld",age];

        NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData.fields objectForKey:@"userDisplayName"]];
        NSString *strUserName = [NSString stringWithFormat:@"%@",[dictUserData.fields objectForKey:@"userDisplayName"]];

        NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:strUserName];
        UIFont *font1 = [UIFont fontWithName:@"Montserrat-Regular" size:23.0f];
        NSRange boldRange = [strName rangeOfString:strUserName];
        [yourAttributedString addAttribute: NSFontAttributeName value:font1 range:boldRange];
        [yourAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [yourAttributedString length])];
        [lblName setAttributedText:yourAttributedString ];
        
        NSString *strState = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userState"]];
        NSString *strCity = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userCity"]];
        NSString *strZipCode = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userZipcode"]];

        strCity = [NSString stringWithFormat:@"%@, %@ - %@",strCity,strState,strZipCode];
        lblLoc.text = strCity;
        
        NSString *strGender = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userGender"]];
        
        NSString *strHandicap = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userHandicap"]];
        lblHandicap.text = [NSString stringWithFormat:@"%@ / %@ / Handicap: %@",strAge, strGender, strHandicap];

        NSString *str_home_coursename = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"home_coursename"]];
        
        if([str_home_coursename isEqualToString:@"N/A"])
        {
            str_home_coursename = @"";
        }
        
        if([str_home_coursename length]==0) {
            str_home_coursename = @"Highland View Golf Course";
        }
        
        lblHomecourse.text = str_home_coursename;

        NSString *strInfo = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userInfo"]];
        bio.text = strInfo;
        
        NSString *strEmail = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userEmail"]];
        NSString *strPhone = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Phone"]];
        NSString *strWebsite = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Website"]];

        email.text = [NSString stringWithFormat:@"Email: %@ \nPhone: %@\nWebsite: %@", strEmail, strPhone, strWebsite];
        email.editable = NO;
        email.dataDetectorTypes = UIDataDetectorTypeAll;
        
        achievments.text = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Achievements"]];
        
        offering.text = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Offerings"]];
        proType.text = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"ProType"]];
        
        [imgBadge setImage:[UIImage imageWithData:[[AppDelegate sharedinstance] getProIcons:proType.text]]];
        [imgBadge setContentMode:UIViewContentModeScaleAspectFill];
        [imgBadge setShowActivityIndicatorView:NO];
        
        long role = [[[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"UserRole"]] longLongValue];
        
        if(role != 1)
        {
            [proView setHidden:YES];
        }
        else
        {
            [imgBadge setHidden:NO];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayServerErrorMessage];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{

    [self.navigationController popViewControllerAnimated:YES];
}

//-----------------------------------------------------------------------

-(IBAction) morePressed:(id)sender {
    
    
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Choose an option"
                                     message:@""
                                     preferredStyle:UIAlertControllerStyleActionSheet];
        
        
        
        UIAlertAction* messageButton = [UIAlertAction
                                     actionWithTitle:@"Messages"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [self sendMessage];
                                     }];
        
        UIAlertAction* unfriendButton = [UIAlertAction
                                         actionWithTitle:@"Unfriend"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [self removeContact];
                                         }];
        
        UIAlertAction* blockButton = [UIAlertAction
                                         actionWithTitle:@"Block & Report"
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action) {
                                             [self blockUser];
                                         }];
        
        UIAlertAction* sendButton = [UIAlertAction
                                      actionWithTitle:@"Send Invitation"
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          [self sendMessage];
                                      }];
        
        UIAlertAction* cancelButton = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         
                                     }];
    if([[AppDelegate sharedinstance].strIsMyMatches isEqualToString:@"1"])
    {
        [alert addAction:messageButton];
        [alert addAction:unfriendButton];
    }
    else
    {
        [alert addAction:sendButton];
    }
    
    [alert addAction:blockButton];
    [alert addAction:cancelButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

//-----------------------------------------------------------------------

-(IBAction) sendRequest:(id)sender {
    [self inviteUser];
}

-(void) inviteUser {
    
    NSMutableDictionary *dictLocalUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    __block int weeklyConnects = [[dictLocalUserData objectForKey:@"userFreeConnects"] integerValue];
    __block  int userPurchasedConnects = [[dictLocalUserData objectForKey:@"userPurchasedConnects"] integerValue];
 
    /************* ChetuChange *************/
    
//    if(![[dictLocalUserData objectForKey:@"userFullMode"] isEqualToString:@"1"]){
//
//        int totalAvailableConnects = weeklyConnects + userPurchasedConnects;
//
//        if(totalAvailableConnects<1) {
//
//            // Show pop up to buy more or upgrade
//
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PURCHASE CONNECTS" message:@"Sorry, you have no CONNECTS available to send request.\nDo you want to buy them?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
//            alert.tag=121;
//            [alert show];
//            return;
//        }
//    }
//
     /************* ChetuChange *************/
    
        QBCOCustomObject *obj = dictUserData;
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"UserConnections";
        
        // Object fields
     /********** ChetuChange not only comment due to crash here *************/
    // Find the user connections details form quickblox user connections table.
        [object.fields setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"connSenderID"];
        [object.fields setObject:[obj.fields objectForKey:@"userEmail"] forKey:@"connReceiverID"];
        [object.fields setObject:@"1" forKey:@"connStatus"];
    /********** ChetuChange not only comment due to crash here *************/
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            
            NSString *strPush = [obj.fields objectForKey:@"userPush"];

            NSUInteger opponentID = obj.userID;

            [[AppDelegate  sharedinstance].sharedChatInstance addUserToContactListRequest:opponentID  completion:^(NSError * _Nullable error) {

                if([strPush isEqualToString:@"1"]) {
                    
                    NSString *strName = [NSString stringWithFormat:@"%@",[dictLocalUserData objectForKey:@"userDisplayName"]];
                    
                    NSString *message = [NSString stringWithFormat:@"%@ has invited you to connect",strName];
                    
                    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                    [aps setObject:message forKey:QBMPushMessageAlertKey];
                    [payload setObject:aps forKey:QBMPushMessageApsKey];
                    [aps setObject:@"1" forKey:@"ios_badge"];
                    [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];
                    
                    QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
                    
                    NSString *strUserId = [NSString stringWithFormat:@"%d",obj.userID];
                    
                    [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                        
                        // If weekly connects available, then deduct from it
                        
                        QBCOCustomObject *object = [QBCOCustomObject customObject];
                        object.className = @"UserInfo";
                        object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
                        
                        if(weeklyConnects>0) {
                            weeklyConnects = weeklyConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                        }
                        else {
                            if(userPurchasedConnects>0)
                                userPurchasedConnects = userPurchasedConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        }
                        
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        
                        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            // object updated
                            
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:dictLocalUserData forKey:kuserData];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [[AppDelegate sharedinstance] hideLoader];
                            [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                            [self.navigationController popViewControllerAnimated:YES];
                            
                        } errorBlock:^(QBResponse *response) {
                            
                            [[AppDelegate sharedinstance] hideLoader];
                            NSLog(@"Response error: %@", [response.error description]);
                        }];
                        
                        
                    } errorBlock:^(QBError *error) {
                        // If weekly connects available, then deduct from it
                        
                        QBCOCustomObject *object = [QBCOCustomObject customObject];
                        object.className = @"UserInfo";
                        object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
                        
                        if(weeklyConnects>0) {
                            weeklyConnects = weeklyConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                        }
                        else {
                            if(userPurchasedConnects>0)
                                userPurchasedConnects = userPurchasedConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        }
                        
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        
                        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            // object updated
                            
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                            
                            [[NSUserDefaults standardUserDefaults] setObject:dictLocalUserData forKey:kuserData];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                            
                            [[AppDelegate sharedinstance] hideLoader];
                            [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                            [self.navigationController popViewControllerAnimated:YES];
                            
                        } errorBlock:^(QBResponse *response) {
                            
                            [[AppDelegate sharedinstance] hideLoader];
                            NSLog(@"Response error: %@", [response.error description]);
                        }];
                        // Handle error
                    }];
                }
                else {
                    
                    // If weekly connects available, then deduct from it
                    
                    QBCOCustomObject *object = [QBCOCustomObject customObject];
                    object.className = @"UserInfo";
                    object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
                    
                    
                    if(weeklyConnects>0) {
                        weeklyConnects = weeklyConnects - 1;
                        [object.fields setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                    }
                    else {
                        if(userPurchasedConnects>0)
                            userPurchasedConnects = userPurchasedConnects - 1;
                        [object.fields setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                    }
                    
                    [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                    [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dictLocalUserData forKey:kuserData];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        
                        // object updated
                        [[NSUserDefaults standardUserDefaults] setObject:dictLocalUserData forKey:kuserData];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                        
                        [self.navigationController popViewControllerAnimated:YES];
                        
                        
                    } errorBlock:^(QBResponse *response) {
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        NSLog(@"Response error: %@", [response.error description]);
                    }];
                }
                
            }];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
            [[AppDelegate sharedinstance] hideLoader];
        }];
}
#pragma mark updateConstarints

// Update view frame according to device
-(void)updateConstarints {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat width = screenRect.size.width;
    
    lblName.frame = CGRectMake(lblName.frame.origin.x, lblName.frame.origin.y, lblName.frame.size.width, lblName.frame.size.height);
    proType.frame = CGRectMake(proType.frame.origin.x, proType.frame.origin.y, proType.frame.size.width, proType.frame.size.height);
    lblHandicap.frame = CGRectMake(lblHandicap.frame.origin.x, lblHandicap.frame.origin.y, lblHandicap.frame.size.width, lblHandicap.frame.size.height);
    imgBadge.frame = CGRectMake(width - 54 - 8, imgBadge.frame.origin.y, imgBadge.frame.size.width, imgBadge.frame.size.height);
    dimpleImg.frame = CGRectMake(0, dimpleImg.frame.origin.y, width, dimpleImg.frame.size.height);
    imgViewProfilePic.frame = CGRectMake(0, imgViewProfilePic.frame.origin.y, width, imgViewProfilePic.frame.size.height);
    
    lblHomecourse.frame = CGRectMake(8, lblHomecourse.frame.origin.y, width - 16, lblHomecourse.frame.size.height);
    CourseBtn.frame = CGRectMake(8, CourseBtn.frame.origin.y, width - 16, CourseBtn.frame.size.height);
    proView.frame = CGRectMake(8, proView.frame.origin.y, width - 16, proView.frame.size.height);
    achievments.frame = CGRectMake(8, achievments.frame.origin.y, width - 16, achievments.frame.size.height);
    offering.frame = CGRectMake(8, offering.frame.origin.y, width - 16, offering.frame.size.height);
    email.frame = CGRectMake(8, email.frame.origin.y, width - 16, email.frame.size.height);
    bio.frame = CGRectMake(8, email.frame.origin.y, width - 16, email.frame.size.height);
    
    
}
-(void) blockUser {
    
//    customShareObj
    
    ReportViewController *viewController;
    viewController  = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    viewController.customShareObj=dictUserData;
    viewController.arrConnections=[arrConnections copy];
    viewController.dictUserData = dictUserData;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

-(void) sendMessage {
    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];

    vc.otherUserObject=self.otherUserObject;
    vc.sharedChatDialog = self.sharedChatDialog;
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    
    //now present this navigation controller modally
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                     }];
}

-(void) removeContact {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    [[AppDelegate sharedinstance] showLoader];
    
    int otherUserId = self.otherUserObject.userID;

    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypePrivate];
    chatDialog.occupantIDs = @[@(otherUserId)];
    
    QBChatMessage *qmessage = [QBChatMessage message];
    NSString *strname = [[AppDelegate sharedinstance] getCurrentName];
    
    [qmessage setText:[NSString stringWithFormat:@"unfriended"]];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    params[@"senderNick"] =strname;
    [qmessage setCustomParameters:params];
    
    QBChatDialog *dialog = [AppDelegate sharedinstance].sharedchatDialog;

    [dialog sendMessage:qmessage completionBlock:^(NSError * _Nullable error) {
        
        [[[AppDelegate sharedinstance] sharedChatInstance] removeUserFromContactList:self.otherUserObject.userID completion:^(NSError * _Nullable error) {

            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Unfriended successfully"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}




- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    [bio setHidden:YES];
    [achievments setHidden:YES];
    [offering setHidden:YES];
    [email setHidden:YES];
    
    switch(selectedSegment)
    {
        case 0:
            [bio setHidden:NO];
            break;
        case 1:
            [achievments setHidden:NO];
            break;
        case 2:
            [offering setHidden:NO];
            break;
        case 3:
            [email setHidden:NO];
            break;
    }
    

}

- (IBAction)courseTapped:(id)sender
{
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:userID forKey:@"UserID"];
    
    [QBRequest objectsWithClassName:@"CourseUser" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
    {
        
        QBCOCustomObject *obj = [objects objectAtIndex:0];
        
        NSString *str1 = obj.parentID;
       
        [getRequest setObject:str1 forKey:@"_id"];
        
        [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
         {
             
             QBCOCustomObject *obj = [objects objectAtIndex:0];
             
             PurchaseSpecialsViewController *viewController    = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
             
             viewController.status=1;
             
             viewController.courseObject = obj;
             
             [self.navigationController pushViewController:viewController animated:YES];
             
         } errorBlock:^(QBResponse *response) {
             // error handling
             [[AppDelegate sharedinstance] hideLoader];
             
             NSLog(@"Response error: %@", [response.error description]);
         }];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(BOOL) prefersStatusBarHidden {
    return NO;
}

@end


