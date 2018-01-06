//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "PreviewProfileViewController.h"
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
@synthesize courseName;

- (void)viewDidLoad {
    [super viewDidLoad];
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
    
   
        [btnOptions setHidden:![self IsFriend]];
        [btnOptionsBig setHidden:![self IsFriend]];
        
        [btnAdd setHidden:[self IsFriend]];
        [btnAddBg setHidden:[self IsFriend]];
        
        [getRequest setObject:userID forKey:@"_id"];

    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
         [[AppDelegate sharedinstance] hideLoader];
        if(objects.count == 0)
        {
            return;
        }
       
        
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
        
        

        long int age = [[AppDelegate sharedinstance] getAge:[dictUserData.fields objectForKey:@"userBday" ]];
        NSString *strAge = [NSString stringWithFormat:@"%ld",age];
        NSString *strUserName = [NSString stringWithFormat:@"%@",[dictUserData.fields objectForKey:@"userDisplayName"]];
        
        
        NSString *strGender = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userGender"]];
        
        NSString *strHandicap = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userHandicap"]];
        NSString *ageGenderHandicap = [NSString stringWithFormat:@"%@ / %@ / Handicap: %@",strAge, strGender, strHandicap];

        NSString *str_home_coursename = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"home_coursename"]];
        
        if([str_home_coursename isEqualToString:@"N/A"])
        {
            str_home_coursename = @"";
        }
        
        if([str_home_coursename length]==0) {
            str_home_coursename = @"Highland View Golf Course";
        }
        
        [lblHomecourse setTitle:[NSString stringWithFormat:@"Course: %@",str_home_coursename] forState:UIControlStateNormal];
        
        courseName = str_home_coursename;

        NSString *strInfo = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userInfo"]];
        
        NSString *proType = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"ProType"]];
        
        NSString *about = [NSString stringWithFormat:@"%@\n%@\n%@\n\n%@", strUserName, proType, ageGenderHandicap, strInfo];
        
        bio.text = about;
        
        NSString *strEmail = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userEmail"]];
        NSString *strPhone = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Phone"]];
        NSString *strWebsite = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Website"]];

        email.text = [NSString stringWithFormat:@"Email: %@ \n\nPhone: %@\n\nWebsite: %@", strEmail, strPhone, strWebsite];
        email.editable = NO;
        email.dataDetectorTypes = UIDataDetectorTypeAll;
        
        achievments.text = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Achievements"]];
        
        offering.text = [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"Offerings"]];
        
        
        [imgBadge sd_setImageWithURL:[NSURL URLWithString:[[AppDelegate sharedinstance] getProIcons:proType]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [imgBadge setImage:image];
            [imgBadge setContentMode:UIViewContentModeScaleAspectFill];
            [imgBadge setShowActivityIndicatorView:NO];
            
        }];
        
        int currentUserRole = [[AppDelegate sharedinstance] getCurrentRole];
        
        [proButtons setHidden:currentUserRole != -1];
        NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
        [getRequest setObject:dictUserData.ID forKey:@"_parent_id"];
        [getRequest setObject:@"1" forKey:@"RoleId"];
        [getRequest setObject:@"Approved" forKey:@"Status"];
        [getRequest setObject:@"true" forKey:@"Active"];
        [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            [proView setHidden:objects.count == 0];
            lblScreenName.text = objects.count > 0 ? @"Pro" : @"Golfer";
            NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userFullMode"]];
            
            [imgBadge setHidden:objects.count == 0 && ![userFullMode isEqualToString:@"1"]];
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
    
        
        UIAlertAction* cancelButton = [UIAlertAction
                                     actionWithTitle:@"Cancel"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         
                                     }];


        [alert addAction:messageButton];
        [alert addAction:unfriendButton];
        [alert addAction:blockButton];
   
    [alert addAction:cancelButton];
    alert.popoverPresentationController.sourceView = sender;
    [self presentViewController:alert animated:YES completion:nil];
}

//-----------------------------------------------------------------------

-(IBAction) sendRequest:(id)sender {
    [self inviteUser];
}

-(void) inviteUser {
    
    NSMutableDictionary *dictLocalUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    __block long weeklyConnects = [[dictLocalUserData objectForKey:@"userFreeConnects"] integerValue];
    __block long userPurchasedConnects = [[dictLocalUserData objectForKey:@"userPurchasedConnects"] integerValue];
    
    if(![[dictLocalUserData objectForKey:@"userFullMode"] isEqualToString:@"1"]){
        
        long totalAvailableConnects = weeklyConnects + userPurchasedConnects;
        
        if(totalAvailableConnects<1) {
            
            // Show pop up to buy more or upgrade
            
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:@"PURCHASE CONNECTS"
                                         message:@"Sorry, you have no CONNECTS available to send request.\nDo you want to buy them?"
                                         preferredStyle:UIAlertControllerStyleAlert];
            
            
            
            UIAlertAction* yesButton = [UIAlertAction
                                        actionWithTitle:@"YES"
                                        style:UIAlertActionStyleDefault
                                        handler:^(UIAlertAction * action) {
                                            MyMatchesViewController *obj = [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
                                            obj.productType=@"Connects";
                                            [self.navigationController pushViewController:obj animated:NO];
                                        }];
            
            UIAlertAction* noButton = [UIAlertAction
                                       actionWithTitle:@"NO"
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           
                                       }];
            
            [alert addAction:yesButton];
            [alert addAction:noButton];
            
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    
        QBCOCustomObject *obj = dictUserData;//[arrData objectAtIndex:indexPath.row];
        
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"UserConnections";
        
        // Object fields
        [object.fields setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"connSenderID"];
        [object.fields setObject:[obj.fields objectForKey:@"userEmail"] forKey:@"connReceiverID"];
        [object.fields setObject:@"1" forKey:@"connStatus"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            
            NSString *strPush = [obj.fields objectForKey:@"userPush"];
            
            // Checking if user has push notification ON
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
                    
                    NSString *strUserId = [NSString stringWithFormat:@"%ld",obj.userID];
                    
                    [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                        
                        // If weekly connects available, then deduct from it
                        
                        QBCOCustomObject *object = [QBCOCustomObject customObject];
                        object.className = @"UserInfo";
                        object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
                        
                        if(weeklyConnects>0) {
                            weeklyConnects = weeklyConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                        }
                        else {
                            if(userPurchasedConnects>0)
                                userPurchasedConnects = userPurchasedConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        }
                        
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        
                        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            // object updated
                            
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                            
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
                            [object.fields setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                        }
                        else {
                            if(userPurchasedConnects>0)
                                userPurchasedConnects = userPurchasedConnects - 1;
                            [object.fields setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        }
                        
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        
                        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                            // object updated
                            
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                            [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                            
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
                        [object.fields setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                    }
                    else {
                        if(userPurchasedConnects>0)
                            userPurchasedConnects = userPurchasedConnects - 1;
                        [object.fields setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                    }
                    
                    [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",weeklyConnects] forKey:@"userFreeConnects"];
                    [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dictLocalUserData forKey:kuserData];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%ld",weeklyConnects] forKey:@"userFreeConnects"];
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%ld",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",weeklyConnects]  forKey:@"userFreeConnects"];
                        [dictLocalUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                        
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
                     }];
}

-(void) removeContact {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    long otherUserId = self.otherUserObject.userID;

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
    
    [getRequest setObject:courseName forKey:@"Name"];
    
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
    
}

-(IBAction)ApproveFeaturedPro:(id)sender
{
    [self approveAction:YES];
}

-(IBAction)ApprovePro:(UIButton *)sender
{
    [self approveAction:NO];  
}

-(IBAction)DenyPro:(UIButton *)sender
{
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@"1" forKey:@"RoleId"];
    [getRequest setObject:@"true" forKey:@"Active"];
    [getRequest setObject:dictUserData.ID forKey:@"_parent_id"];
    
    [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         QBCOCustomObject *obj = [objects objectAtIndex:0];
         [obj.fields setObject:@"false" forKey:@"Active"];
         
         
         [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
             NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
             
             [getRequest setObject:@"0" forKey:@"RoleId"];
             [getRequest setObject:@"true" forKey:@"Active"];
             [getRequest setObject:dictUserData.ID forKey:@"_parent_id"];
             
             [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
              {
                  QBCOCustomObject *obj = [objects objectAtIndex:0];
                  [obj.fields setObject:@"false" forKey:@"Active"];
                  
                  
                  [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                      
                      QBCOCustomObject *roleObj = [QBCOCustomObject init];
                      
                      roleObj.className = @"UserRoles";
                      [roleObj.fields setObject:dictUserData.ID forKey:@"_parent_id"];
                      [roleObj.fields setObject:sender.titleLabel.text forKey:@"Status"];
                      [roleObj.fields setObject:@"0" forKey:@"RoleId"];
                      [roleObj.fields setObject:@"true" forKey:@"Active"];
                      [roleObj.fields setObject:@"Golfer" forKey:@"Name"];
                      [roleObj.fields setObject:[NSDate date] forKey:@"DateAsRole"];
                      
                      [QBRequest createObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                          [[AppDelegate sharedinstance] hideLoader];
                          [self.navigationController popViewControllerAnimated:YES];
                          
                          
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
         
     } errorBlock:^(QBResponse *response) {
         // error handling
         [[AppDelegate sharedinstance] hideLoader];
         
         NSLog(@"Response error: %@", [response.error description]);
     }];
}

-(void)approveAction: (BOOL) featured
{
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@"1" forKey:@"RoleId"];
    [getRequest setObject:@"true" forKey:@"Active"];
    [getRequest setObject:dictUserData.ID forKey:@"_parent_id"];
    
    [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         if(objects.count == 0)
         {
             return;
         }
         QBCOCustomObject *obj = [objects objectAtIndex:0];
         [obj.fields setObject:@"False" forKey:@"Active"];
         
         
         [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
             QBCOCustomObject *roleObj = [QBCOCustomObject alloc];
             
             roleObj.className = @"UserRoles";
             [roleObj.fields setObject:dictUserData.ID forKey:@"_parent_id"];
             [roleObj.fields setObject:@"Approved" forKey:@"Status"];
             [roleObj.fields setObject:@"1" forKey:@"RoleId"];
             [roleObj.fields setObject:@"true" forKey:@"Active"];
             [roleObj.fields setObject:@"Pro" forKey:@"Name"];
             [roleObj.fields setObject:featured ? @"true" : @"false" forKey:@"Featured"];
             [roleObj.fields setObject:[NSDate date] forKey:@"DateAsRole"];
             
             [QBRequest createObject:roleObj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                 NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                 
                 [getRequest setObject:@"0" forKey:@"RoleId"];
                 [getRequest setObject:@"true" forKey:@"Active"];
                 [getRequest setObject:dictUserData.ID forKey:@"_parent_id"];
                 
                 [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
                  {
                      if(objects.count == 0)
                      {
                          [[AppDelegate sharedinstance] hideLoader];
                          [self.navigationController popViewControllerAnimated:YES];
                          return;
                      }
                      QBCOCustomObject *obj = [objects objectAtIndex:0];
                      [obj.fields setObject:@"False" forKey:@"Active"];
                      
                      
                      [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                          
                          [[AppDelegate sharedinstance] hideLoader];
                          [self.navigationController popViewControllerAnimated:YES];
                          
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


