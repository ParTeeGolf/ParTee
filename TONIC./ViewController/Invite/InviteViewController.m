//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MyMatchesViewController.h"
#import "InviteViewController.h"
#import "ViewUsersViewController.h"
#import "cell_Invite.h"
#define kLimit @"100"
#import "PreviewProfileViewController.h"

@interface InviteViewController ()

@end

@implementation InviteViewController

@synthesize tblList;
@synthesize strIsConnInvite;

- (void)viewDidLoad {
    [super viewDidLoad];
    arrCourseData = [[NSMutableArray alloc] init];
    
    self.navigationController.navigationBarHidden=YES;
    tblList.tableFooterView = [UIView new];
    [lblNotAvailable setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    if(isiPhone4) {
        
        [tblList setFrame:CGRectMake(tblList.frame.origin.x, tblList.frame.origin.y, tblList.frame.size.width, tblList.frame.size.height-88)];
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    //segmentInvitations.selectedSegmentIndex=0;

    if([strIsConnInvite isEqualToString:@"1"]) {
        [segmentInvitations setSelectedSegmentIndex:0];

        [self getAllUsers];
        segmentMode=0;
    }
    else {
        [segmentInvitations setSelectedSegmentIndex:1];

        [self getSpecialInvitations];
        segmentMode=1;
    }
}

-(void) getCourseData {
    
    NSMutableArray *arrCourseIDData = [[NSMutableArray alloc] init];
    
    for(QBCOCustomObject *courseobj in arrData) {
        [arrCourseIDData addObject:[courseobj.fields objectForKey:@"courseId"]];
    }
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"100" forKey:@"limit"];
    
    [getRequest setObject:[[arrCourseIDData valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"_id[in]"];

    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        [[AppDelegate sharedinstance] hideLoader];
        
        arrCourseData = [objects mutableCopy];
        
        [tblList reloadData];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(void) getAllUsers {
    arrData = [[NSMutableArray alloc] init];
    strIsConnInvite=@"1";
    
    // getting connections so can filter out connecton status
    
    NSString *strUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@"100" forKey:@"limit"];
    [getRequest setObject:strUserEmail forKey:@"connReceiverID"];
    [getRequest setObject:@"1" forKey:@"connStatus"];
    [getRequest setObject:@"created_at" forKey:@"sort_desc"];

    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserConnections" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        // response processing
        arrConnections=objects;
        arrConnectionsTemp = objects;

        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (QBCOCustomObject *obj in arrConnections) {
            
            NSString *strSenderId = [obj.fields objectForKey:@"connSenderID"];
            [arrTemp addObject:strSenderId];
        }
        
        arrConnections = [arrTemp copy];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:@"100" forKey:@"limit"];

        [getRequest setObject:[[arrConnections valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[in]"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // response processing
            
            [arrData addObjectsFromArray:[objects mutableCopy]];
            
            if([arrData count]==0) {
                [lblNotAvailable setHidden:NO];
            }
            else {
                [lblNotAvailable setHidden:YES];
            }
            
            isPageRefreshing=NO;
            
            [[AppDelegate sharedinstance] hideLoader];
            [tblList reloadData];
            
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

-(void) getSpecialInvitations {
    strIsConnInvite=@"0";

    arrData = [[NSMutableArray alloc] init];
    
    // getting connections so can filter out connecton status
    
    NSString *strUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@"100" forKey:@"limit"];
    [getRequest setObject:strUserEmail forKey:@"courseReceiverID"];
    [getRequest setObject:@"4" forKey:@"courseStatus"];
    [getRequest setObject:@"created_at" forKey:@"sort_desc"];

    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        arrConnections=objects;
        arrConnectionsTemp = objects;
        
        arrData = [objects mutableCopy];
        
        if([arrData count]==0) {
            [lblNotAvailable setHidden:NO];
            [[AppDelegate sharedinstance] hideLoader];
            [tblList reloadData];

        }
        else {
            [self getCourseData];

//            if(isCourseLoaded==0) {
//                isCourseLoaded=1;
//                
//            }
//            else {
//                [[AppDelegate sharedinstance] hideLoader];
//                [tblList reloadData];
//
//            }
            
            [lblNotAvailable setHidden:YES];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(IBAction)notNowPressed:(id)sender {
    [btnMore setHidden:NO];
    
    //viewProfile
    [UIView animateWithDuration:0.3 animations:^{
        viewMoreMatches.alpha = 0;
    } completion: ^(BOOL finished) {//creates a variable (BOOL) called "finished" that is set to *YES* when animation IS completed.
        viewMoreMatches.hidden = finished;//if animation is finished ("finished" == *YES*), then hidden = "finished" ... (aka hidden = *YES*)
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

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
        
    }];
    
}

//-----------------------------------------------------------------------

-(IBAction) segmentChanged :(UISegmentedControl*) sender {
    
    if(sender.selectedSegmentIndex==1) {
        // Specials
        
        segmentMode=1;
        [self getSpecialInvitations];

        
    }
    else {
        // Connnections
        
        segmentMode=0;
        
        [self getAllUsers];
    }
    
}

//-----------------------------------------------------------------------

-(IBAction) acceptRequest:(UIButton*)sender {
    
    CGPoint center = sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"%d",indexPath.row);
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    QBCOCustomObject *otherObj  = obj;
    
    NSString *strCurrentUserId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserEmail];

    if(segmentMode == 1) {
        
        // Specials
        NSString *strOtherUserId = [obj.fields objectForKey:@"courseSenderID"];
        
        NSArray *arrVal = [NSArray arrayWithObjects:strCurrentUserId,strOtherUserId, nil];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:@"100" forKey:@"limit"];
        [getRequest setObject:[[arrVal valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[in]"];
        [[AppDelegate sharedinstance] showLoader];

        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // do something with retrieved object
            
                if([objects count]>0) {
                    
                    QBCOCustomObject *objTemp = [objects objectAtIndex:0];
                    QBCOCustomObject *currentUserObj;
                    QBCOCustomObject *otherUserObj;
                    
                    NSString *strCurrentUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
                    
                    if([[objTemp.fields objectForKey:@"userEmail"] isEqualToString:strCurrentUserEmail]) {
                        currentUserObj = [objects objectAtIndex:0];
                        otherUserObj = [objects objectAtIndex:1];

                    }
                    else {
                        currentUserObj = [objects objectAtIndex:1];
                        otherUserObj = [objects objectAtIndex:0];
                    }
                    
                        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                        [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        obj.className = @"UserCourses";
                        [obj.fields setObject:@"5" forKey:@"courseStatus"];

                        [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {

                            [arrData removeObject:obj];
                            [tblList reloadData];
                            
                            if([arrData count]==0) {
                                [lblNotAvailable setHidden:NO];
                            }
                            else {
                                [lblNotAvailable setHidden:YES];
                                
                            }
                            
                            NSString *strPush = [otherUserObj.fields objectForKey:@"userPush"];
                            
                            if([strPush isEqualToString:@"1"]) {
                                NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                                
                                NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
                                
                                NSString *message = [NSString stringWithFormat:@"%@ has accepted your request for a course",strName];
                                
                                NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                                NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                                [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                                [aps setObject:@"1" forKey:@"ios_badge"];
                                [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];

                                [aps setObject:message forKey:QBMPushMessageAlertKey];
                                [payload setObject:aps forKey:QBMPushMessageApsKey];
                                
                                QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
                                
                                NSString *strUserId = [NSString stringWithFormat:@"%d",otherUserObj.userID];
                                
                                [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                            
                                    [[AppDelegate sharedinstance] hideLoader];
                                    
                                    [[AppDelegate sharedinstance] displayMessage:@"Request has been accepted successfully"];
                                    
                                } errorBlock:^(QBError *error) {
                                    [[AppDelegate sharedinstance] hideLoader];
                                    [[AppDelegate sharedinstance] displayMessage:@"Request has been accepted successfully"];

                                    // Handle error
                                }];
                                
                            }
                            else {
                                [[AppDelegate sharedinstance] hideLoader];
                                [[AppDelegate sharedinstance] displayMessage:@"Request has been accepted successfully"];

                            }
                            
                        } errorBlock:^(QBResponse *response) {
                            // error handling
                            [[AppDelegate sharedinstance] hideLoader];

                            NSLog(@"Response error: %@", [response.error description]);
                        }];
                        
                }

            } errorBlock:^(QBResponse *response) {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];

                NSLog(@"Response error: %@", [response.error description]);
            }];
    }
    else {
        
        // Show pop up to buy more or upgrade
        
        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
 
        /************ ChetuChange ************/
//        if(![[dictUserData objectForKey:@"userFullMode"] isEqualToString:@"1"]){
//
//            NSString *struserWeeklyConnects =  [dictUserData objectForKey:@"userFreeConnects"];
//            NSString *struserPurchasedConnects =  [dictUserData objectForKey:@"userPurchasedConnects"];
//
//            int weeklyConnects = [struserWeeklyConnects integerValue];
//            int userPurchasedConnects = [struserPurchasedConnects integerValue];
//
//            int totalAvailableConnects = weeklyConnects + userPurchasedConnects;
//
//            if(totalAvailableConnects<1) {
//
//                // Show pop up to buy more or upgrade
//
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PURCHASE CONNECTS" message:@"Sorry, you have no CONNECTS available to accept request.\nDo you want to buy them?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
//                alert.tag=121;
//                [alert show];
//                return;
//            }
//        }
//
        // When a match is done,  decrease 1 connect
        
        
        /************ ChetuChange ************/
        // Connnections
        NSString *strOtherUserId = [obj.fields objectForKey:@"userEmail"];
        
        NSArray *arrVal = [NSArray arrayWithObjects:strCurrentUserId,strOtherUserId, nil];

        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:@"100" forKey:@"limit"];
        [getRequest setObject:[[arrVal valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[in]"];
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {            // do something with retrieved object
            QBCOCustomObject *currentUserObj =[objects objectAtIndex:0];
            
            QBCOCustomObject *otherUserObj =[objects objectAtIndex:1];

            QBCOCustomObject *objTemp = [objects objectAtIndex:0];

            NSString *strCurrentUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
            
            if([[objTemp.fields objectForKey:@"userEmail"] isEqualToString:strCurrentUserEmail]) {
                currentUserObj = [objects objectAtIndex:0];
                otherUserObj = [objects objectAtIndex:1];
                
            }
            else {
                currentUserObj = [objects objectAtIndex:1];
                otherUserObj = [objects objectAtIndex:0];
            }
            
            int userWeeklyConnects = [[currentUserObj.fields objectForKey:@"userFreeConnects"] integerValue];
            int userPurchasedConnects = [[currentUserObj.fields objectForKey:@"userPurchasedConnects"] integerValue];
            
            if(userWeeklyConnects>0) {
                userWeeklyConnects = userWeeklyConnects - 1;
                [currentUserObj.fields setObject:[NSString stringWithFormat:@"%d",userWeeklyConnects]  forKey:@"userFreeConnects"];
            }
            else {
                if(userPurchasedConnects>0)
                    userPurchasedConnects = userPurchasedConnects - 1;
                
                [currentUserObj.fields setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
            }
            
            QBCOCustomObject *objToUpdate;
            
            NSString *strSelectedEmail = [obj.fields objectForKey:@"userEmail"];
            
            for(QBCOCustomObject *connObj in arrConnectionsTemp) {
                
                NSString *strEmail = [connObj.fields objectForKey:@"connReceiverID"];
                
                if([[[AppDelegate sharedinstance] getCurrentUserEmail] isEqualToString:strEmail]) {
                    strEmail= [connObj.fields objectForKey:@"connSenderID"];
                }
                
                if([strSelectedEmail isEqualToString:strEmail]) {
                    objToUpdate = connObj;
                    break;
                }
            }
            
            [objToUpdate.fields setObject:@"2" forKey:@"connStatus"];
            
            [[AppDelegate sharedinstance] showLoader];
            
            [QBRequest updateObject:objToUpdate successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                
                [dictUserData setObject:[NSString stringWithFormat:@"%d",userWeeklyConnects]  forKey:@"userFreeConnects"];
                 [dictUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                
                [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *strPush = [obj.fields objectForKey:@"userPush"];
                
                
                [QBRequest updateObjects:@[currentUserObj,otherUserObj] className:@"UserInfo" successBlock:^(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds) {
                    // response processing
                    
                    [arrData removeObject:obj];
                    
                    if([arrData count]==0) {
                        [lblNotAvailable setHidden:NO];
                    }
                    else {
                        [lblNotAvailable setHidden:YES];
                    }
                    
                    [tblList reloadData];
                    
                    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                    [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
                    
                    QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypePrivate];
                    chatDialog.occupantIDs = @[@(otherUserObj.userID)];

                    [QBRequest createDialog:chatDialog successBlock:^(QBResponse *response, QBChatDialog *createdDialog) {
                        
                            [[QBChat instance] confirmAddContactRequest:otherUserObj.userID completion:^(NSError * _Nullable error) {
                        
                                if([strPush isEqualToString:@"1"]) {
                                    
                                    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                                    
                                    NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
                                    
                                    NSString *message = [NSString stringWithFormat:@"%@ has accepted your connection request",strName];
                                    
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
                                        
                                        [[AppDelegate sharedinstance] hideLoader];
                                        [[AppDelegate sharedinstance] displayMessage:@"Request has been accepted successfully"];
                                        
                                        
                                    } errorBlock:^(QBError *error) {
                                        [[AppDelegate sharedinstance] hideLoader];
                                        [[AppDelegate sharedinstance] displayMessage:@"Request has been accepted successfully"];
                                        
                                    }];
                                }
                                else {
                                    [[AppDelegate sharedinstance] hideLoader];
                                }
                            }];
                        }
                        errorBlock:^(QBResponse *response) {
                        [[AppDelegate sharedinstance] hideLoader];
                        
                    }];
                    
                } errorBlock:^(QBResponse *error) {
                    // error handling
                    [[AppDelegate sharedinstance] hideLoader];
                    
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];

                NSLog(@"Response error: %@", [response.error description]);
                [[AppDelegate sharedinstance] hideLoader];
            }];
            
        }
        errorBlock:^(QBResponse *error) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];

        }];

    }
    
}

//-----------------------------------------------------------------------

-(IBAction) denyRequest:(UIButton*)sender {
    CGPoint center=sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"%d",indexPath.row);
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    QBCOCustomObject *objToUpdate=obj;
    
    if(segmentMode==1) {
        // Specials
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        
        NSString *strUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
        
        NSString *strOtherUserEmail = [obj.fields objectForKey:@"courseSenderID"];
        
        [getRequest setObject:@"100" forKey:@"limit"];
        [getRequest setObject:strOtherUserEmail forKey:@"userEmail"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            if([objects count]>0) {
                
                QBCOCustomObject *specialObject =objToUpdate;
                
                NSString *strIDTOUPDATE = specialObject.ID;
                
                QBCOCustomObject *object1 = [QBCOCustomObject customObject];
                object1.className = @"UserCourses";
                [object1.fields setObject:@"6" forKey:@"courseStatus"];
                object1.ID = strIDTOUPDATE;
                
                [QBRequest updateObject:object1 successBlock:^(QBResponse *response, QBCOCustomObject *object) {

                    [arrData removeObject:obj];
                    [tblList reloadData];

                    if([arrData count]==0) {
                        [lblNotAvailable setHidden:NO];
                    }
                    else {
                        [lblNotAvailable setHidden:YES];
                    }
                    
                    NSString *struserPush;
                    QBCOCustomObject *temp;
                 
                    if([objects count]>0) {
                       
                        temp = [objects objectAtIndex:0];
                        struserPush = [temp.fields objectForKey:@"userPush"];
                    }

                    if([struserPush isEqualToString:@"1"]) {
                        
                        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                        
                        NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
                        
                        NSString *message = [NSString stringWithFormat:@"%@ has denied your request for a course",strName];

                        NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                        NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                        [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                        [aps setObject:message forKey:QBMPushMessageAlertKey];
                        [payload setObject:aps forKey:QBMPushMessageApsKey];
                        [aps setObject:@"1" forKey:@"ios_badge"];
                        [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];

                        QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
                        
                        NSString *strUserId = [NSString stringWithFormat:@"%lu",(unsigned long)temp.userID];
                        
                        [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                            
                            [[AppDelegate sharedinstance] hideLoader];
                            [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                            
                        } errorBlock:^(QBError *error) {
                            [[AppDelegate sharedinstance] hideLoader];
                            [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];

                            // Handle error
                        }];

                    }
                    else {
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                    }
                    
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                
            }
            } errorBlock:^(QBResponse *error) {
                // error handling
            }];
        
    }
    else {
        NSString *strSelectedEmail = [obj.fields objectForKey:@"userEmail"];
        
        for(QBCOCustomObject *connObj in arrConnectionsTemp) {
            
            NSString *strEmail = [connObj.fields objectForKey:@"connReceiverID"];
            
            if([[[AppDelegate sharedinstance] getCurrentUserEmail] isEqualToString:strEmail]) {
                strEmail= [connObj.fields objectForKey:@"connSenderID"];
            }
            
            if([strSelectedEmail isEqualToString:strEmail]) {
                objToUpdate = connObj;
                break;
            }
        }
        
        [objToUpdate.fields setObject:@"3" forKey:@"connStatus"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest updateObject:objToUpdate successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            
            [[QBChat instance] rejectAddContactRequest:obj.userID completion:^(NSError * _Nullable error) {
                NSString *strPush = [obj.fields objectForKey:@"userPush"];
                
                if([strPush isEqualToString:@"1"]) {
                    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                    
                    NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
                    
                    NSString *message = [NSString stringWithFormat:@"%@ has denied your connection request",strName];
                    
                    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                    [aps setObject:message forKey:QBMPushMessageAlertKey];
                    [payload setObject:aps forKey:QBMPushMessageApsKey];
                    [aps setObject:@"1" forKey:@"ios_badge"];
                    [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];
                    [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];
                    
                    QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
                    
                    NSString *strUserId = [NSString stringWithFormat:@"%d",obj.userID];
                    
                    
                    [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                        
                        [arrData removeObject:obj];
                        
                        if([arrData count]==0) {
                            [lblNotAvailable setHidden:NO];
                        }
                        else {
                            [lblNotAvailable setHidden:YES];
                            
                        }
                        
                        [tblList reloadData];
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                        
                    } errorBlock:^(QBError *error) {
                        [arrData removeObject:obj];
                        
                        if([arrData count]==0) {
                            [lblNotAvailable setHidden:NO];
                        }
                        else {
                            [lblNotAvailable setHidden:YES];
                            
                        }
                        
                        [tblList reloadData];
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                        // Handle error
                    }];
                }
                else {
                    [arrData removeObject:obj];
                    [tblList reloadData];
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                }
            }];
            
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
            [[AppDelegate sharedinstance] hideLoader];
        }];

    }
}

#pragma mark - Table view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 61;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    cell_Invite *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_Invite"];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_Invite" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];

    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    if(segmentMode==1) {
        // Specials

        QBCOCustomObject *userObject = [arrData objectAtIndex:indexPath.row];
        
        for(QBCOCustomObject *courseobj in arrCourseData) {
            
            NSString *strCourseID = courseobj.ID;
            
            if([ [userObject.fields objectForKey:@"courseId"] isEqualToString:strCourseID]) {
                
                NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[courseobj.fields objectForKey:@"Name"]];
                [cell.lblUserName setText:str1];
                
                [cell.imageViewUsers setShowActivityIndicatorView:YES];
                [cell.imageViewUsers setIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                if([[[AppDelegate sharedinstance] nullcheck:[courseobj.fields objectForKey:@"ImageUrl"]] length]==0) {
                    cell.imageViewUsers.image =[UIImage imageNamed:@"imgplaceholder_mini.jpg"];
                }
                else
                {
                     [cell.imageViewUsers sd_setImageWithURL:[NSURL URLWithString:[courseobj.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder_mini.jpg"]];
                }

                cell.imageViewUsers.layer.cornerRadius =  cell.imageViewUsers.frame.size.width/2;
                [cell.imageViewUsers.layer setMasksToBounds:YES];
                [cell.imageViewUsers.layer setBorderColor:[UIColor clearColor].CGColor];
                
                break;
            }
        }
    }
    else {
        
        NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userFullMode"]];
        
        if([userFullMode isEqualToString:@"1"]) {
            [cell.imageViewBadge setHidden:NO];
            [cell.viewBG setHidden:NO];
            
        }
        else {
            [cell.imageViewBadge setHidden:YES];
            [cell.viewBG setHidden:YES];
            
        }

        NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userDisplayName"]];
        [cell.lblUserName setText:str1];
        
        [cell.imageViewUsers setShowActivityIndicatorView:YES];
        [cell.imageViewUsers setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell.imageViewUsers sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
        
        cell.imageViewUsers.layer.cornerRadius =  cell.imageViewUsers.frame.size.width/2;
        [cell.imageViewUsers.layer setMasksToBounds:YES];
        [cell.imageViewUsers.layer setBorderColor:[UIColor clearColor].CGColor];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(segmentMode==1) {
        // Specials
        
        PurchaseSpecialsViewController *viewController;
        viewController    = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
        viewController.status = 3;
        
        QBCOCustomObject *userObject = [arrData objectAtIndex:indexPath.row];
        viewController.userObject=userObject;
        
        for(QBCOCustomObject *courseobj in arrCourseData) {
            
            NSString *strCourseID = courseobj.ID;
            
            if([ [userObject.fields objectForKey:@"courseId"] isEqualToString:strCourseID]) {
                
                viewController.courseObject=courseobj;
                
                break;
            }
        }

        
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else {
        
        QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
        NSString *userEmail= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userEmail"]];
        
        PreviewProfileViewController *viewController;
        viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
        viewController.strCameFrom=@"4";
        viewController.arrConnections=[arrConnections copy];
        viewController.strEmailOfUser = userEmail;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
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
            MyMatchesViewController *obj = [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
            obj.isFromConnects=YES;
            [self.navigationController pushViewController:obj animated:NO];
        }
    }
}

@end
