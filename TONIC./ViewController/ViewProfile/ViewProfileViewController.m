//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "ViewProfileViewController.h"
#import "ReportViewController.h"
#import "DemoMessagesViewController.h"

@interface ViewProfileViewController ()

@end

@implementation ViewProfileViewController
@synthesize isMyMatch;

@synthesize customShareObj;
@synthesize arrData;
@synthesize arrConnections;
@synthesize HUD;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
    }
  
    [self getMutualFriendCount];

    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    
    self.navigationController.navigationBarHidden=YES;

    imgView1.layer.cornerRadius = imgView1.frame.size.width/2;
    
    viewMutualFriends.layer.cornerRadius = viewMutualFriends.frame.size.width/2;
    viewMutualFriends.layer.borderColor=[UIColor whiteColor].CGColor;
    viewMutualFriends.layer.borderWidth=1.f;
    
    [imgView1.layer setMasksToBounds:YES];
    [imgView1.layer setBorderColor:[UIColor clearColor].CGColor];
    
    NSString *word1=lblMessage.text;
    NSMutableString *toBespaced=[NSMutableString new];
    
    [btnMore setHidden:YES];
    
    imgViewOuter.layer.cornerRadius =  imgViewOuter.frame.size.width/2;
    [imgViewOuter.layer setMasksToBounds:YES];
    [imgViewOuter.layer setBorderColor:[UIColor clearColor].CGColor];
    
    for (NSInteger i=0; i<word1.length; i+=1) {
        NSString *two=[word1 substringWithRange:NSMakeRange(i, 1)];
        [toBespaced appendFormat:@"%@   ",two ];
    }
    
    lblMessage.text = toBespaced;
    

    k=-1;
 
    if(!isMyMatch) {
        [[AppDelegate sharedinstance] showLoader];
        
        [viewProfile setHidden:YES];
    }
    else {
        [viewProfile setHidden:NO];
    }
    
    self.navigationController.navigationBarHidden=YES;
    
    //[self.view addSubview:viewLocation];
    
    //    CGRect frame =  viewLocation.frame;
    //    frame.origin.y=67;
    //    viewLocation.frame = frame;
    
    QBCOCustomObject *dictUserData = self.customShareObj;
    
    NSString *struserOccupation= [[AppDelegate sharedinstance] nullcheck:[dictUserData.fields objectForKey:@"userOccupation"]];
    [btnLblOccupation setTitle:struserOccupation forState:UIControlStateNormal];
    
    long int age = [[AppDelegate sharedinstance] getAge:[dictUserData.fields objectForKey:@"userBday" ]];
    
    [btnLblNameOuter setTitle:[dictUserData.fields objectForKey:@"userDisplayName"] forState:UIControlStateNormal];
    NSString *strName = [NSString stringWithFormat:@"%@, %ld",[dictUserData.fields objectForKey:@"userDisplayName"],age];
    NSString *strAge = [NSString stringWithFormat:@" %ld",age];

    NSString *strUserName = [NSString stringWithFormat:@"%@,",[dictUserData.fields objectForKey:@"userDisplayName"]];
    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:[strUserName uppercaseString]];

    UIFont *font1 = [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0f];
    
    NSRange boldRange = [strName rangeOfString:strUserName];
    [yourAttributedString addAttribute: NSFontAttributeName value:font1 range:boldRange];

    [yourAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:strAge]];
    [yourAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [yourAttributedString length])];
    
    [btnLblName setAttributedTitle:yourAttributedString forState:UIControlStateNormal];
    
//    [btnLblName setTitle:strName forState:UIControlStateNormal];
    
    
  ///  [btnLblName setTitle:btnLblName.titleLabel.text.capitalizedString forState:UIControlStateNormal];

    //   [[AppDelegate sharedinstance] showLoader];
    
    [imgViewBg setShowActivityIndicatorView:YES];
    [imgViewBg setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    NSString *imageUrl = [NSString stringWithFormat:@"%@", [dictUserData.fields objectForKey:@"userPicBase"]];
    //  [imgViewBg sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    [imgView1 setShowActivityIndicatorView:YES];
    [imgView1 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData.fields objectForKey:@"userPicBase"]];
    [imgView1 sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    [imgViewOuter setShowActivityIndicatorView:YES];
    [imgViewOuter setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData.fields objectForKey:@"userPicBase"]];
    [imgViewOuter sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    
    [imgView2 setShowActivityIndicatorView:YES];
    [imgView2 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData.fields objectForKey:@"userPicRight"]];
    [imgView2 sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    [imgView3 setShowActivityIndicatorView:YES];
    [imgView3 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData.fields objectForKey:@"userPicLeft"]];
    
    //  imageUrl = [NSString stringWithFormat:@"%@", @"http://www.desicomments.com/wp-content/uploads/Nimrat-Kaur-And-Akshay-Kumar-Image-DC021.jpg"];
    [imgView3 sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    k=-1;
    NSMutableArray *arrTemp=[[NSMutableArray alloc] init];
    
    arrBgImages=[arrTemp copy];
    
    
    
    [self performSelector:@selector(manage) withObject:nil afterDelay:1.5f];
}

-(void) viewWillAppear:(BOOL)animated {
    
    if([AppDelegate sharedinstance].isBlocked){
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//-----------------------------------------------------------------------

-(void) getMutualFriendCount {
    NSDictionary *params = @{
                             @"fields": @"context.fields(mutual_friends.fields(picture.width(200).height(200)).limit(10))",
                             };
    
    NSString *strFBID= [[AppDelegate sharedinstance] nullcheck:[self.customShareObj.fields objectForKey:@"userFBID"]];

    NSString *strConnId = [NSString stringWithFormat:@"/%@",strFBID];
    
    /* make the API call */
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:strConnId
                                  parameters:params
                                  HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        
        NSDictionary *dictResult = (NSDictionary *)result;
        
        int countMutualFriends= [[[[[dictResult objectForKey:@"context"] objectForKey:@"mutual_friends"]objectForKey:@"summary"] objectForKey:@"total_count" ] intValue];
        NSLog(@"Mutual friends count : %d",countMutualFriends);
        
        NSString *strText = [NSString stringWithFormat:@"%d",countMutualFriends];
        [btnMutualFriends setTitle:strText forState:UIControlStateNormal];
        
    }];
}

-(void) manage {
    
    if(!isMyMatch)
        [[AppDelegate sharedinstance] hideLoader];
    
    [self animateImages];
}

//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//-----------------------------------------------------------------------

-(void) animateImages {
    
    if(k<3)
        k++;
    else
        k=0;
    
    UIImage * toImage;
    
    if(k==1) {
        
        toImage=imgView2.image;
    }
    else if(k==2)  {
        toImage=imgView3.image;
        
    }
    else  {
        toImage=imgView1.image;
    }
    
    //        UIImage * toImage =[arrBgImages objectAtIndex:k];
    
    int dur=3.f;
    
    [UIView transitionWithView:imgViewBg
                      duration:dur
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        imgViewBg.image = toImage;
                        
                        if(k==0) {
                            
                            [btncircle1 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                            [btncircle2 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            [btncircle3 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            
                        }
                        else if(k==1) {
                            [btncircle2 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                            [btncircle1 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            [btncircle3 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            
                        }
                        else if(k==2) {
                            [btncircle3 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                            [btncircle1 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            [btncircle2 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            
                        }
                        else {
                            [btncircle1 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                            [btncircle2 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            [btncircle3 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                            
                        }
                        
                    } completion:^(BOOL finished) {
                        
                        [self performSelector:@selector(animateImages) withObject:self afterDelay:0.f];
                        
                    }];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)morePressed:(id)sender {
    [btnMore setHidden:YES];

    viewProfile.alpha = 0;
    viewProfile.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        viewProfile.alpha = 1;
    }];
}

-(IBAction)chatPresssed:(id)sender {

    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    vc.otherUserObject = customShareObj;
    vc.arrConnections = arrConnections;
    
    UINavigationController *navigationController =
    [[UINavigationController alloc] initWithRootViewController:vc];
    navigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    
    //now present this navigation controller modally
    [self presentViewController:navigationController
                       animated:YES
                     completion:^{
                         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                         
                     }];
    
  //  [self startChatProcess];
    
//    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
//    
//    UINavigationController *navigationController =
//    [[UINavigationController alloc] initWithRootViewController:vc];
//    navigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
//    
//    //now present this navigation controller modally
//    [self presentViewController:navigationController
//                       animated:YES
//                     completion:^{
//                         [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//
//                     }];
}

-(void) startChatProcess {
    
    self.HUD.labelText=@"Initiating chat process ...";
    [self.HUD show:YES];
    
    NSInteger currentUserQuickbloxId = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    NSString *strSessToken = [QBSession currentSession].sessionDetails.token;
    
    NSInteger otherUserId = customShareObj.userID;
    
    NSInteger nameForChatRoom = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    nameForChatRoom = nameForChatRoom + otherUserId;
    
    QBUUser *user = [QBUUser user];
    
    user.password = strSessToken;
    user.ID = currentUserQuickbloxId;
    
    if([[QBChat instance] isConnected]) {
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
        
        NSMutableDictionary *filterRequest = [[NSMutableDictionary alloc] init];
        
        filterRequest[@"name"] = [NSString stringWithFormat:@"%ld",nameForChatRoom];
        
        self.HUD.labelText=@"Connecting ...";
        
        [QBRequest dialogsForPage:page extendedRequest:filterRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
            
            if([dialogObjects count]==0) {
                
                // Create dialog, if first time chatting
                
                QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypeGroup];
                chatDialog.name =  [NSString stringWithFormat:@"%ld",nameForChatRoom];
                chatDialog.occupantIDs = @[@(currentUserQuickbloxId), @(otherUserId)];
                
                [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                    
                    [AppDelegate sharedinstance].dialog = createdDialog;
                    [self openChat];
                    
                } errorBlock:^(QBResponse *response) {
                    [[AppDelegate sharedinstance] hideLoader];
                }];
            }
            else {
                QBChatDialog *dialog = [dialogObjects objectAtIndex:0];
                [AppDelegate sharedinstance].dialog = dialog;
                [self openChat];
                
            }
        } errorBlock:^(QBResponse *response) {
            [[AppDelegate sharedinstance] hideLoader];
        }];

    }
    else {
        
        // connect to Chat
        [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
            
            QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
            
            NSMutableDictionary *filterRequest = [[NSMutableDictionary alloc] init];
            
            filterRequest[@"name"] = [NSString stringWithFormat:@"%ld",nameForChatRoom];
            
            self.HUD.labelText=@"Connecting ...";
            
            [QBRequest dialogsForPage:page extendedRequest:filterRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
                
                if([dialogObjects count]==0) {
                    
                    // Create dialog, if first time chatting
                    
                    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypeGroup];
                    chatDialog.name =  [NSString stringWithFormat:@"%ld",nameForChatRoom];
                    chatDialog.occupantIDs = @[@(currentUserQuickbloxId), @(otherUserId)];
                    
                    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                        
                        [AppDelegate sharedinstance].dialog = createdDialog;
                        [self openChat];
                        
                    } errorBlock:^(QBResponse *response) {
                        [[AppDelegate sharedinstance] hideLoader];
                    }];
                }
                else {
                    QBChatDialog *dialog = [dialogObjects objectAtIndex:0];
                    [AppDelegate sharedinstance].dialog = dialog;
                    [self openChat];
                }
            } errorBlock:^(QBResponse *response) {
                [[AppDelegate sharedinstance] hideLoader];
            }];
        }];
    }
}

-(void) openChat
{
        [[AppDelegate sharedinstance] hideLoader];
    
        [self.HUD show:NO];
        [self.HUD hide:YES];
    
        DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
        vc.otherUserObject = customShareObj;
        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:vc];
        navigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
    
    //    //now present this navigation controller modally
        [self presentViewController:navigationController
                           animated:YES
                         completion:^{
                             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
                         }];
}

-(void) getChatDialogId {
    
    QBUUser *user = [QBUUser user];
    user.password = [[AppDelegate sharedinstance] getStringObjfromKey:kuserAccessToken];
    user.ID =  [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];

    long nameForChatRoom = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    nameForChatRoom = nameForChatRoom + customShareObj.userID;
    
    // connect to Chat
    [[QBChat instance] connectWithUser:user completion:^(NSError * _Nullable error) {
        
        QBResponsePage *page = [QBResponsePage responsePageWithLimit:100 skip:0];
        
        NSMutableDictionary *filterRequest = [[NSMutableDictionary alloc] init];
        filterRequest[@"name"] = [NSString stringWithFormat:@"%ld",nameForChatRoom];
        
        [QBRequest dialogsForPage:page extendedRequest:filterRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
            
            if([dialogObjects count]==0) {
                
                // Create room
                
                
            }
            
        } errorBlock:^(QBResponse *response) {
            
        }];
    }];
    
    [QBRequest logInWithUserEmail:@"user1@demo.com" password:@"12345678" successBlock:^(QBResponse *response, QBUUser *user) {
        
                QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypeGroup];
                chatDialog.name = @"Chat with Bob, Sam, Garry";
                chatDialog.occupantIDs = @[@(16347628), @(17301512)];
        
                [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
        
                } errorBlock:^(QBResponse *response) {
                    
                }];
        
    } errorBlock:^(QBResponse *response) {
        
    }];
    
}

-(IBAction) makeSpecial:(id)sender {
    
    SpecialsViewController *viewController;
    viewController    = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
    viewController.status=1;
    [self.navigationController pushViewController:viewController animated:YES];
    
    
}

-(IBAction)viewProfilePressed:(id)sender {
    
    [btnMore setHidden:NO];

    //viewProfile
    [UIView animateWithDuration:0.3 animations:^{
        viewProfile.alpha = 0;
    } completion: ^(BOOL finished) {//creates a variable (BOOL) called "finished" that is set to *YES* when animation IS completed.
        viewProfile.hidden = finished;//if animation is finished ("finished" == *YES*), then hidden = "finished" ... (aka hidden = *YES*)
    }];
}


-(IBAction)blockReportPressed:(id)sender {
    ReportViewController *viewController;
    viewController    = [[ReportViewController alloc] initWithNibName:@"ReportViewController" bundle:nil];
    viewController.customShareObj=customShareObj;
    viewController.arrConnections=[arrConnections copy];
    [self.navigationController pushViewController:viewController animated:YES];

}

-(IBAction) removePressed:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure want to remove?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag=121;
    [alert show];
    return;

}

//-----------------------------------------------------------------------

#pragma mark - Alert Delegate

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 121)
    {
        if (buttonIndex == 0)
        {
        }
        else if (buttonIndex == 1)
        {
            [self removeUser];
        }
    }
    
}

-(void) removeUser {
    QBCOCustomObject *obj = customShareObj;//[arrData objectAtIndex:indexPath.row];
    obj.className = @"UserInfo";

    QBCOCustomObject *objToUpdate;
    NSString *strSelectedEmail = [obj.fields objectForKey:@"userEmail"];

    for(QBCOCustomObject *connObj in arrConnections) {
        
        NSString *strEmail = [connObj.fields objectForKey:@"connReceiverID"];
        
        if([[[AppDelegate sharedinstance] getCurrentUserEmail] isEqualToString:strEmail]) {
            strEmail= [connObj.fields objectForKey:@"connSenderID"];
        }
        
        if([strSelectedEmail isEqualToString:strEmail]) {
            objToUpdate = connObj;
            break;
        }
    }
    
    objToUpdate.className = @"UserConnections";
    [objToUpdate.fields setObject:@"4" forKey:@"connStatus"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:objToUpdate successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        NSString *strPush = [obj.fields objectForKey:@"userPush"];

        if([strPush isEqualToString:@"1"]) {
            NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
            
            NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
            
            NSString *message = [NSString stringWithFormat:@"%@ has removed you from matches",strName];
            
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
                
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Removed successfully from CONTACTS"];
                [self.navigationController popViewControllerAnimated:YES];
                
            } errorBlock:^(QBError *error) {
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Removed successfully from CONTACTS"];
                [self.navigationController popViewControllerAnimated:YES];
                // Handle error
            }];
        }
        else {
            
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Removed successfully from CONTACTS"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
    }];

}

@end
