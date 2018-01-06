	//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MyMatchesViewController.h"
#import "ViewUsersViewController.h"
#import "CoursePreferencesViewController.h"
#import "cell_ViewUsers.h"
#import "cell_ViewPro.h"
#import "cell_EventUsers.h"
#import "PreviewProfileViewController.h"
#import "DemoMessagesViewController.h"
#define kLimit @"100"
#define kdialogLimit 100

@interface ViewUsersViewController ()

@end

@implementation ViewUsersViewController
@synthesize tblList;


-(void) showcustomnotification{
    
    [[AppDelegate sharedinstance] displayCustomNotification:@"hello"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadusers) name:@"reloadusers" object:nil];
  
    [AppDelegate sharedinstance].arrContactListIDs = [[NSMutableArray alloc] init];
    [AppDelegate sharedinstance].arrSharedOnlineUsers = [[NSMutableArray alloc] init];
    
    [lblNotAvailable setHidden:YES];
    [doneView setHidden:YES];
    [coursePicker setHidden:YES];
    
    arrData = [[NSMutableArray alloc] init];
    arrDialogData = [[NSMutableArray alloc] init];
    arrCourses = [[NSMutableArray alloc] init];
    arrUserCourses = [[NSMutableArray alloc] init];

    self.navigationController.navigationBarHidden=YES;
    _currentPage = 0;

    tblList.separatorColor = [UIColor clearColor];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshdialogs) name:@"refreshdialogs" object:nil];
    
    btnSettingsBig.layer.cornerRadius = btnSettingsBig.bounds.size.width / 2;
    btnSettingsBig.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [AppDelegate sharedinstance].currentScreen = kScreenOther;
}

-(BOOL) prefersStatusBarHidden {
    return NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    _currentPage=0;
    
    arrData = [[NSMutableArray alloc] init];
    [AppDelegate sharedinstance].strIsChatConnected = @"0";
    
    _RoleId = [[AppDelegate sharedinstance] getCurrentRole];
    
    [proSegments setHidden:[self IsFriends] || ![self IsPro] || [self RoleId] == 3 || [self RoleId] == -1];
    [golferSegments setHidden:[self IsFriends] || [self RoleId] == 3|| [self RoleId] == -1];
    [myMatchesSegments setHidden:![self IsFriends] || [self RoleId] == 3 || [self RoleId] == -1];
    [eventManagerSegments setHidden:[self IsFriends] || ([self RoleId] != 3 && [self RoleId] != -1)];
    
    totalParentIds = [[NSMutableArray alloc] init];
    featuredParentIds = [[NSMutableArray alloc] init];
    
    if([self IsFriends])
    {
        lblTitle.text = @"My Friends";
        [btnSettingsBig setHidden:YES];
    }
    else if([self IsPro])
    {
        lblTitle.text = @"Pros";
    }
    else if([self RoleId] == 3 || [self RoleId] == -1)
    {
        lblTitle.text = [[self searchRoleId] isEqualToString:@"2"] ? @"Event Managers" : @"Course Admin";
    }
    else
    {
        lblTitle.text = @"Golfers";
    }
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[self IsPro] ? @"1" : @"0" forKey:@"RoleId"];
    [getRequest setObject:@"Approved" forKey:@"Status"];
    [getRequest setObject:@"true" forKey:@"Active"];
    
    [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         
         for(QBCOCustomObject *obj in objects)
         {
             if([[obj.fields objectForKey:@"Featured"] boolValue])
             {
                [featuredParentIds addObject:obj.parentID];
             }

             [totalParentIds addObject:obj.parentID];
         }

         if([self IsFriends])
         {
             QBUUser *currentUser = [QBSession currentSession].currentUser;
             currentUser.password = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];

             if([[[AppDelegate sharedinstance] sharedChatInstance] isConnected])
             {
                 arrDialogData = [[NSMutableArray alloc] init];
                 
                 [self getContact];
             }
             
             else
             {
                 // if chat is not connecting, other features should work
                 [self performSelector:@selector(letotherfeatureswork) withObject:nil afterDelay:10.f];

                 [[AppDelegate sharedinstance] showLoader];
                 
                 // connect to Chat
                 [[AppDelegate sharedinstance].sharedChatInstance connectWithUser:currentUser completion:^(NSError * _Nullable error) {
                     
                     if(!error)
                     {
                         arrDialogData = [[NSMutableArray alloc] init];
                         [self getContact];
                     }
                 }];
             }
         }
         else
         {
             [self getAllUsers];
         }
     } errorBlock:^(QBResponse *response)
     {
         // Handle error here
         [[AppDelegate sharedinstance] hideLoader];
         
     }];
    
    
}

-(void) refreshdialogs
{
    if([self IsFriends])
    {
        arrDialogData = [[NSMutableArray alloc] init];

        [self getContact];
    }
}

- (void) getContact
{
    [AppDelegate sharedinstance].arrContactListIDs = [[NSMutableArray alloc] init];
    
    NSArray *arrContactList =  [[AppDelegate sharedinstance]sharedChatInstance].contactList.contacts;
    
    for(QBContactListItem *contact in arrContactList)
    {
        
        BOOL isOnline = contact.isOnline;
        NSInteger userIdValue = contact.userID;

        [[AppDelegate sharedinstance].arrContactListIDs addObject:[NSNumber numberWithInteger:contact.userID]];
        
        if(isOnline)
        {
            NSLog(@"User %ld is online",(long)userIdValue);
            if(![[AppDelegate sharedinstance].arrSharedOnlineUsers containsObject:[NSNumber numberWithInteger:contact.userID]])
            {
                [[AppDelegate sharedinstance].arrSharedOnlineUsers addObject:[NSNumber numberWithInteger:contact.userID]];
                
            }
        }
        else {
            if([[AppDelegate sharedinstance].arrSharedOnlineUsers containsObject:[NSNumber numberWithInteger:contact.userID]])
            {
                [[AppDelegate sharedinstance].arrSharedOnlineUsers removeObject:[NSNumber numberWithInteger:contact.userID]];

            }

        }
    }
    _currentDialog=0;
    [self getDialogs];

}

- (void) getDialogs
{
    arrData = [[NSMutableArray alloc] init];
    
    [[AppDelegate sharedinstance] showLoader];
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    extendedRequest[@"sort_desc"] = @"last_message_date_sent";

    QBResponsePage *page = [QBResponsePage responsePageWithLimit:kdialogLimit skip:_currentDialog];
    
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page)
    {
        
        _currentDialog += dialogObjects.count;
        
        [arrDialogData addObjectsFromArray:dialogObjects];
        
        if (page.totalEntries > _currentDialog)
        {
            
            [self getDialogs];
            return;
        }
        
        NSMutableArray *arrOccupants  = [[NSMutableArray alloc] init];
        
        NSNumber *currentId = [NSNumber numberWithInt:[[[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID] intValue]];
        
        for(QBChatDialog *obj  in arrDialogData)
        {
            //now go through array and get user id of opponents
            
            if(![[AppDelegate sharedinstance] checkSubstring:@"unfriended" containedIn:obj.lastMessageText ])
            {
                NSMutableArray *arrTemp = [obj.occupantIDs mutableCopy];
                [arrTemp removeObject:currentId];
                [arrOccupants addObject:[arrTemp objectAtIndex:0]];
            }
        }

        NSLog(@"%@",[[arrOccupants valueForKey:@"description"] componentsJoinedByString:@","]);
        
        [self getUserFromDialogs:0 withArray:arrOccupants];

        
     }
    errorBlock:^(QBResponse *response)
    {
         [[AppDelegate sharedinstance] hideLoader];
    }];
}

-(void) getUserFromDialogs:(int) dialogUserPageNum withArray:(NSMutableArray *)arrOccupants
{
    __block int currentPageNum = dialogUserPageNum;
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:kLimit forKey:@"limit"];
    
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPageNum];
    
    [getRequest setObject:strPage forKey:@"skip"];
    
    if(myMatchesSegments.selectedSegmentIndex == 0)
    {
        getRequest = [self NearMeGetRequest:getRequest];
    }

    [getRequest setObject:[[arrOccupants valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"user_id[in]"];
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
    {
        
        for(QBCOCustomObject *userobj in objects)
        {
            NSInteger userId = userobj.userID;
            
            NSInteger idxOfuser =  [arrOccupants indexOfObject:[NSNumber numberWithInteger:userId]];
            
            QBChatDialog *dictDialog = [arrDialogData objectAtIndex:idxOfuser];
            
            [arrData addObject:userobj];
            [arrDialogData addObject:dictDialog];
        }
        
        
        if(objects.count >= [kLimit integerValue]) {
            
            [self getUserFromDialogs:++currentPageNum withArray:arrOccupants];
            return;
        }
        
        [lblNotAvailable setHidden:[arrData count]!=0];
        
        [[AppDelegate sharedinstance] hideLoader];
        
        [self performSelector:@selector(resettimer) withObject:nil afterDelay:2];
        
        [tblList reloadData];
        
        
    } errorBlock:^(QBResponse *response)
    {
        // Handle error here
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
}

-(void) resettimer
{
    [AppDelegate sharedinstance].strcustomnotificationtimer = @"1";
}

-(void) getAllUsers
{
    // getting connections so can filter out connecton status
    [arrData removeAllObjects];
    NSString *strUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:strUserEmail forKey:@"connSenderID[or]"];
    [getRequest setObject:strUserEmail forKey:@"connReceiverID[or]"];
    [getRequest setObject:kLimit forKey:@"limit"];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * _currentPage];
    
    [getRequest setObject:strPage forKey:@"skip"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserConnections" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
    {
        // response processing
        

        arrConnections = [[NSMutableArray alloc] init];
        
        [arrConnections addObjectsFromArray:[objects mutableCopy]];
        
        shouldLoadNext=[objects count]>=[kLimit integerValue];
       
        if(shouldLoadNext)
        {
            ++_currentPage;
            [self getAllUsers];
            return;
        }
        
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (QBCOCustomObject *obj in arrConnections)
        {
            
            NSString *strSenderId = [obj.fields objectForKey:@"connSenderID"];
            NSString *strRecId = [obj.fields objectForKey:@"connReceiverID"];

            if([strSenderId isEqualToString:[[AppDelegate sharedinstance] getCurrentUserEmail]])
            {
                [arrTemp addObject:strRecId];
            }
            else if([strRecId isEqualToString:[[AppDelegate sharedinstance] getCurrentUserEmail]])
            {
                [arrTemp addObject:strSenderId];
            }
        }
        
        [arrTemp addObject:strUserEmail];
        
        arrConnections = [arrTemp mutableCopy];
        
        [self getPagedUsers:0];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];

        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(void) getPagedUsers:(int) currentNum
{
    
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentNum];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:kLimit forKey:@"limit"];
    [getRequest setObject:strPage forKey:@"skip"];
    if(_RoleId != 2 && _RoleId != 3 && _RoleId != -1)
    {
        [getRequest setObject:[[arrConnections valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[nin]"];
    }
    [getRequest setObject:@"created_at" forKey:@"sort_desc"];
    
    NSString *searchType = [self IsPro] ? kSearchPro : kSearchUser;
    
    NSMutableDictionary *dictUserSearchData = [[[NSUserDefaults standardUserDefaults] objectForKey:searchType] mutableCopy];
    
    switch(_RoleId)
    {
        case 0:
        case 1:
            if([self IsPro])
            {
                switch(proSegments.selectedSegmentIndex)
                {
                    case 0:
                        [getRequest setObject: featuredParentIds forKey:@"_id[in]"];
                        break;
                    case 1:
                       [getRequest setObject: totalParentIds forKey:@"_id[in]"];
                        getRequest = [self NearMeGetRequest: getRequest];
                        break;
                    case 2:
                        [getRequest setObject: totalParentIds forKey:@"_id[in]"];
                        getRequest = [self customGetRequest:dictUserSearchData :getRequest];
                        break;
                }
                
            }
            else
            {
                [getRequest setObject: totalParentIds forKey:@"_id[in]"];
                switch(golferSegments.selectedSegmentIndex)
                {
                    case 0:
                         getRequest = [self customGetRequest:dictUserSearchData :getRequest];
                    case 1:
                        getRequest = [self NearMeGetRequest: getRequest];
                        break;
                }
            }
            [self getUserInfo:getRequest:currentNum];
            break;
        case -1:
        case 3:
            switch(eventManagerSegments.selectedSegmentIndex)
        {
            case 0:
                getRequest = [self customGetRequest:dictUserSearchData :getRequest];
                [getRequest setObject: totalParentIds forKey:@"_id[in]"];
                [self getUserInfo:getRequest:currentNum];
                break;
            case 1:
                [self getAdminViewUsers];
                break;
                
                
        }
            break;
    }
}

-(NSMutableDictionary *) NearMeGetRequest: (NSMutableDictionary *) getRequest
{
    NSString *strlat1 = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat1 = [[AppDelegate sharedinstance] nullcheck:strlat1];
    
    NSString *strlong1 = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong1 = [[AppDelegate sharedinstance] nullcheck:strlong1];
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    NSString *strFilterDistance = [NSString stringWithFormat:@"%f,%f;%f",[strlong floatValue],[strlat floatValue],160934.0f];
    [getRequest setObject:strFilterDistance forKey:@"current_location[near]"];
    return getRequest;
}

-(void) getUserInfo: (NSMutableDictionary *)getRequest :(int) currentNum
{
    __block int currentPageNum = currentNum;
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         [arrData addObjectsFromArray:[objects mutableCopy]];
         
         if(objects.count >= [kLimit integerValue])
         {
             [self getPagedUsers:++currentPageNum];
             return;
         }
         
         [lblNotAvailable setHidden:[arrData count]!=0];
         
         isPageRefreshing=NO;
         
         [[AppDelegate sharedinstance] hideLoader];
         
         [tblList reloadData];
         
     }
                         errorBlock:^(QBResponse *response)
     {
         [[AppDelegate sharedinstance] hideLoader];
         
         NSLog(@"Response error: %@", [response.error description]);
     }];
}

-(NSMutableDictionary *) customGetRequest: (NSMutableDictionary *) dictUserSearchData : (NSMutableDictionary *) getRequest
    {
        // Age condition
        NSString *strAge = [dictUserSearchData objectForKey:@"Age"];
        
        NSInteger upperlimit = 0, lowerlimit=0;
        
        if([strAge length] != 0)
        {
            NSArray* splitAge = [strAge componentsSeparatedByString: @"-"];
            lowerlimit = [[splitAge objectAtIndex: 0] intValue] - 1;
            upperlimit = [[splitAge objectAtIndex: 1] intValue] + 1;
            
            if(lowerlimit>0)
            {
                [getRequest setObject:[NSNumber numberWithInteger:upperlimit] forKey:@"userAge[lt]"];
                [getRequest setObject:[NSNumber numberWithInteger:lowerlimit] forKey:@"userAge[gt]"];
            }
        }
        
        
        NSString *strHandicap = [dictUserSearchData objectForKey:@"Handicap"];
        
        if([strHandicap length]!=0 && ![self IsPro] && ![strHandicap isEqualToString:@"All"])
        {
            NSArray* splitRange = [strHandicap componentsSeparatedByString: @" - "];
            lowerlimit = [[splitRange objectAtIndex: 0] intValue];
            upperlimit = [[splitRange objectAtIndex: 1] intValue];
            
            NSMutableArray *handicapArr = [[NSMutableArray alloc] init];
            
            for(long x = upperlimit; x <= lowerlimit; ++x)
            {
                [handicapArr addObject:[NSString stringWithFormat:@"%ld", x]];
            }
            
            
            [getRequest setObject:handicapArr forKey:@"userHandicap[in]"];
            [getRequest setObject:@"userHandicap" forKey:@"sort_asc"];
            
        }
        
        NSString *strType = [dictUserSearchData  objectForKey:@"Type"] ;
        
        if([strType length] != 0 && ![strType isEqualToString:@"All"] && [self IsPro])
        {
            [getRequest setObject: strType forKey:@"ProType[in]"];
        }
        
        NSString *strState =[[AppDelegate sharedinstance] nullcheck:[dictUserSearchData objectForKey:@"State"]];
        
        if(![strState isEqualToString:@"All"] && [strState length] != 0)
        {
            [getRequest setObject:strState forKey:@"userState[in]"];
        }
        
        NSArray *arrCity = [dictUserSearchData objectForKey:@"City"];
        
        if(![arrCity containsObject:@"All"] && [arrCity count] != 0)
        {
            [getRequest setObject:arrCity forKey:@"userCity[in]"];
        }
        
        
        NSString *strinterested_in_home_course = [[AppDelegate sharedinstance] nullcheck:[dictUserSearchData objectForKey:@"Course"]];
        
        if([strinterested_in_home_course length]>0)
        {
            if(![strinterested_in_home_course isEqualToString:@"All"])
            {
                [getRequest setObject:strinterested_in_home_course forKey:@"home_coursename[in]"];
            }
            
        }
        
        NSString *strName = [[AppDelegate sharedinstance] nullcheck:[dictUserSearchData objectForKey:@"Name"]];
        
        if([strName length]>0)
        {
            if(![strName isEqualToString:@""])
            {
                [getRequest setObject:strName forKey:@"userDisplayName[ctn]"];
            }
            
        }
        
        NSString *strGender = [[AppDelegate sharedinstance] nullcheck:[[dictUserSearchData  objectForKey:@"Gender"] lowercaseString]];
        
        if(![strGender isEqualToString:@"all"] && [strGender length] != 0)
        {
            [getRequest setObject:strGender forKey:@"userGender[in]"];
        }
        
        [getRequest setObject:@16 forKey:@"advertisingBlockCount[lt]"];
    

        return getRequest;
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


//-----------------------------------------------------------------------

- (IBAction) action_Menu:(id)sender
{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
    
}

-(IBAction)settingsTapped:(id)sender
{
    CoursePreferencesViewController *obj = [[CoursePreferencesViewController alloc] initWithNibName:@"CoursePreferencesViewController" bundle:nil];
    obj.SearchType = [self IsPro] ? filterPro : filterGolfer;
    
    if([self IsPro])
    {
        [proSegments setSelectedSegmentIndex:2];
    }
    else
    {
        [golferSegments setSelectedSegmentIndex:0];
    }
    
    [self.navigationController pushViewController:obj animated:YES];
}

//-----------------------------------------------------------------------

-(void) connectsMessage
{
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
}

-(void) successMessage:(NSString *) message
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    
    
    UIAlertAction* okButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                   
                                }];

    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction) sendRequest:(UIButton*)sender
{
    CGPoint center=sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    
    if([arrData count]==0) {
        NSLog(@"issue in arrdata count");
        return;
    }
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    NSUInteger opponentID = obj.userID;
    
    NSLog(@"%ld",(long)indexPath.row);
    
    if([self IsFriends]) {
        // send to messages screen
        
        NSNumber *opponentnum = [NSNumber numberWithInteger:obj.userID];
        
            NSMutableArray *arrOccupants  = [[NSMutableArray alloc] init];
            
            NSString *strCurrentId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID];
            
            NSNumber *num = [NSNumber numberWithInt:[strCurrentId intValue]];
            
            for(QBChatDialog *obj  in arrDialogData) {
                //now go through array and get user id of opponents
                
                NSMutableArray *arrTemp = [obj.occupantIDs mutableCopy];
                
                [arrTemp removeObject:num];
                [arrOccupants addObject:[arrTemp objectAtIndex:0]];
            }

        NSInteger idx =  [arrOccupants indexOfObject:opponentnum];
        
        QBChatDialog *dialog = [arrDialogData objectAtIndex:idx];

        DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
        vc.sharedChatDialog = dialog;
        [AppDelegate sharedinstance].sharedchatDialog = dialog;
        
        vc.otherUserObject = obj;
        vc.arrConnections=[arrConnectionsTemp copy];

        UINavigationController *navigationController =
        [[UINavigationController alloc] initWithRootViewController:vc];
        navigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
        
        
        //now present this navigation controller modally
        [self presentViewController:navigationController
                           animated:YES
                         completion:^{
                             [self preferredStatusBarStyle];
                             return;

                         }];
        
        return;
    }
    
    // Show pop up to buy more or upgrade

    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];

    
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"UserConnections";
    
    // Object fields
    [object.fields setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"connSenderID"];
    [object.fields setObject:[obj.fields objectForKey:@"userEmail"] forKey:@"connReceiverID"];
    [object.fields setObject:@"1" forKey:@"connStatus"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        [[AppDelegate  sharedinstance].sharedChatInstance addUserToContactListRequest:opponentID  completion:^(NSError * _Nullable error) {
            
            NSString *strPush = [obj.fields objectForKey:@"userPush"];
            
            // Checking if user has push notification ON
            
            if([strPush isEqualToString:@"1"]) {
                
                NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
                
                NSString *message = [NSString stringWithFormat:@"%@ has invited you to connect",strName];
                
                NSMutableDictionary *payload = [NSMutableDictionary dictionary];
                NSMutableDictionary *aps = [NSMutableDictionary dictionary];
                [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
                [aps setObject:message forKey:QBMPushMessageAlertKey];
                [payload setObject:aps forKey:QBMPushMessageApsKey];
                [aps setObject:@"1" forKey:@"ios_badge"];
                [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];
                
                QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
                
                NSString *strUserId = [NSString stringWithFormat:@"%lu",(unsigned long)obj.userID];
                
                [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                    
                    [arrData removeObject:obj];
                    
    
                    [lblNotAvailable setHidden:[arrData count]==0];
                   
                    
                   
                    
                    [arrData removeObject:obj];
                    [tblList reloadData];
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                    
                } errorBlock:^(QBError *error) {
                    [arrData removeObject:obj];
                    
                    [lblNotAvailable setHidden:[arrData count]!=0];
                    
                        
                        [arrData removeObject:obj];
                        [tblList reloadData];
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                    
                    
                }];
            }
            else {
                
                
                    
                    [arrData removeObject:obj];
                    [tblList reloadData];
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                    
                    
               
            }
            }];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
    }];
}

-(void) letotherfeatureswork
{
    
    if([[AppDelegate sharedinstance].strIsChatConnected isEqualToString:@"0"]){
        [self getDialogs];
    }
}

-(void) reloadusers
{
    
    if([self IsFriends]) {
        [tblList reloadData];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self IsPro] ? 182 : 61;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_EventUsers *eventCell;
    switch(_RoleId)
    {
        case 0:
        case 1:
            if([self IsPro])
            {
                [btnSettingsBig setHidden:proSegments.selectedSegmentIndex != 2 && proSegments.selectedSegmentIndex != 1];
                cell_ViewPro *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewPro"];
                NSArray *topLevelObjects;
                
                topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewPro" owner:self options:nil];
                // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
                
                cell = [topLevelObjects objectAtIndex:0];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.backgroundColor=[UIColor clearColor];
                cell.contentView.backgroundColor=[UIColor clearColor];
                cell.navigationController = self.navigationController;
                
                QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
                
                [cell.profileButton addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
                
                cell.lblName.text = [obj.fields objectForKey:@"userDisplayName"];
                cell.proType.text = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ProType"]];
                cell.alternateProType.text = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"AlternateProType"]];
                
                [cell.imageUrl setShowActivityIndicatorView:YES];
                [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                
                cell.profileButton.layer.cornerRadius = 10;
                cell.profileButton.proID = obj.ID;
                
                [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [cell.imageUrl setImage:image];
                    [cell.imageUrl setContentMode:UIViewContentModeScaleAspectFill];
                    [cell.imageUrl setShowActivityIndicatorView:NO];
                    
                }];
                
                [cell.proIcon sd_setImageWithURL:[NSURL URLWithString:[[AppDelegate sharedinstance] getProIcons:[obj.fields objectForKey:@"ProType"]]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    [cell.proIcon setImage:image];
                    [cell.proIcon setContentMode:UIViewContentModeScaleAspectFill];
                    [cell.proIcon setShowActivityIndicatorView:NO];
                    
                }];
                return cell;
                
            }
            else
            {
                cell_ViewUsers *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewUsers"];
                NSArray *topLevelObjects;
                
                topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewUsers" owner:self options:nil];
                // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
                
                cell = [topLevelObjects objectAtIndex:0];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
                
                NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userFullMode"]];
                
                [cell.imageViewBadge setHidden:![userFullMode isEqualToString:@"1"]];
                [cell.viewBG setHidden:![userFullMode isEqualToString:@"1"]];
                [cell.imageViewBadge setFrame:CGRectMake(216, 17, 20, 26)];
                
                NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userDisplayName"]];
                NSString *str2 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userHandicap"]];
                str2 = [NSString stringWithFormat:@"Handicap : %@",str2];
                
                NSString *homeCourse = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"home_coursename"]];
                [cell.lblHomeCourse setText:homeCourse];
                
                [cell.lblUserName setText:str1];
                [cell.lblhandicap setText:str2];
                [cell.imageViewUsers setShowActivityIndicatorView:YES];
                [cell.imageViewUsers setIndicatorStyle:UIActivityIndicatorViewStyleGray];
                [cell.imageViewUsers sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
                
                
                
                if(![self IsFriends])
                {
                    [cell.acceptButton setHidden:YES];
                    [cell.denyButton setHidden:YES];
                    
                    [btnSettingsBig setHidden:golferSegments.selectedSegmentIndex != 0];
                    [cell.btnMessageBadge setHidden:YES];
                    [cell.btnAdd setFrame:CGRectMake(251, 12, 35, 35)];
                    [cell.btnAdd setImage:[UIImage imageNamed:@"Plusadd"] forState:UIControlStateNormal];
                    
                    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userDisplayName"]];
                    str2 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userHandicap"]];
                    
                    NSInteger spamBlockCount = [[obj.fields objectForKey:@"spamBlockCount"] integerValue];
                    NSInteger contentBlockCount = [[obj.fields objectForKey:@"contentBlockCount"] integerValue];
                    NSInteger stolenBlockCount = [[obj.fields objectForKey:@"stolenBlockCount"] integerValue];
                    NSInteger abusiveBlockCount = [[obj.fields objectForKey:@"abusiveBlockCount"] integerValue];
                    NSInteger otherBlockCount = [[obj.fields objectForKey:@"otherBlockCount"] integerValue];
                    NSInteger advertisingBlockCount = [[obj.fields objectForKey:@"advertisingBlockCount"] integerValue];
                    
                    NSInteger totalBlockCount = spamBlockCount + contentBlockCount + stolenBlockCount + abusiveBlockCount + otherBlockCount + advertisingBlockCount;
                    
                    if(totalBlockCount>4)
                    {
                        UIFont *font = [UIFont fontWithName:@"Montserrat-Light" size:12];
                        
                        [cell.lblhandicap setTextColor:[UIColor colorWithRed:1.000 green:0.894 blue:0.000 alpha:1.00]];
                        [cell.lblhandicap setFont:font];
                        
                        [cell.lblhandicap setText:[NSString stringWithFormat:@"%ld times reported",(long)totalBlockCount]];
                        
                    }
                    else
                    {
                        [cell.lblhandicap setTextColor:[UIColor whiteColor]];
                        
                    }
                    
                    [cell.lblOnlineStatus setHidden:YES];
                }
                else
                {
                    [btnSettingsBig setHidden:myMatchesSegments.selectedSegmentIndex == 1];
                    switch(myMatchesSegments.selectedSegmentIndex)
                    {
                        case 0:
                        case 1:
                            [cell.acceptButton setHidden:YES];
                            [cell.denyButton setHidden:YES];
                            
                            break;
                        default:
                            [cell.btnAdd setHidden:YES];
                            [cell.btnMessageBadge setHidden:YES];
                            [cell.imageViewBadge setHidden:YES];
                            break;
                    }
                    
                    [cell.lblhandicap setTextColor:[UIColor whiteColor]];
                    
                    [cell.btnMessageBadge setHidden:YES];
                    [cell.btnAdd setFrame:CGRectMake(251, 12, 35, 35)];
                    
                    [cell.btnMessageBadge setHidden:NO];
                    [cell.btnAdd setImage:[UIImage imageNamed:@"speech-bubble"] forState:UIControlStateNormal];
                    [cell.btnAdd setFrame:CGRectMake(256, 17, 25, 25)];
                    
                   
                    
                    if([arrDialogData count] != 0)
                    {
                        QBChatDialog *dialogObj;
                        
                        for(QBChatDialog *dialog in arrDialogData)
                        {
                            if(dialog.userID == obj.userID)
                            {
                                dialogObj = dialog;
                                break;
                            }
                        }
                        
                        if(dialogObj.unreadMessagesCount==0)
                        {
                            [cell.btnMessageBadge setHidden:YES];
                        }
                        else
                        {
                            [cell.btnMessageBadge setHidden:NO];
                            [cell.btnMessageBadge setTitle:[NSString stringWithFormat:@"%lu",(unsigned long)dialogObj.unreadMessagesCount] forState:UIControlStateNormal];
                        }
                        
                        NSString *strCurrentId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID];
                        
                        NSNumber *num = [NSNumber numberWithInt:[strCurrentId intValue]];
                        
                        NSMutableArray *arrTemp = [dialogObj.occupantIDs mutableCopy];
                        [arrTemp removeObject:num];
                        
                        cell.lblOnlineStatus.layer.cornerRadius=5.f;
                        cell.lblOnlineStatus.clipsToBounds = YES;
                        cell.lblOnlineStatus.layer.borderColor=[UIColor whiteColor].CGColor;
                        cell.lblOnlineStatus.layer.borderWidth = 1.5f;
                        
                        if([[AppDelegate sharedinstance].arrSharedOnlineUsers containsObject:[arrTemp objectAtIndex:0]] )
                        {
                            [cell.lblOnlineStatus setBackgroundColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.247 alpha:1.00]];
                        }
                        else
                        {
                            [cell.lblOnlineStatus setBackgroundColor:[UIColor redColor]];
                        }
                        
                        [cell.lblOnlineStatus setHidden:NO];
                    }
                    
                }
                
               
                cell.imageViewUsers.layer.cornerRadius =  cell.imageViewUsers.frame.size.width/2;
                [cell.imageViewUsers.layer setMasksToBounds:YES];
                [cell.imageViewUsers.layer setBorderColor:[UIColor clearColor].CGColor];
                
                return cell;
            }
           
            break;
        case -1:
        case 3:
            [btnSettingsBig setHidden:eventManagerSegments.selectedSegmentIndex != 0];
            eventCell = [tableView dequeueReusableCellWithIdentifier:@"cell_EventUsers"];
            NSArray *topLevelObjects;
            
            topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_EventUsers" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            
            eventCell = [topLevelObjects objectAtIndex:0];
            eventCell.selectionStyle = UITableViewCellSelectionStyleNone;
            eventCell.addButton.layer.cornerRadius = 10;
            eventCell.removeButton.layer.cornerRadius = 10;

            
            [eventCell.addButton setHidden:eventManagerSegments.selectedSegmentIndex == 1];
            [eventCell.removeButton setHidden:eventManagerSegments.selectedSegmentIndex == 0];
            
            QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
            eventCell.lblUserName.text = [obj.fields objectForKey:@"userDisplayName"];
            eventCell.lblHomeCourse.text = [obj.fields objectForKey:@"CourseName"];
            
            switch(eventManagerSegments.selectedSegmentIndex)
            {
                case 0:
                    eventCell.addButton.userId = obj.ID;
                    break;
                case 1:
                    eventCell.removeButton.userId = obj.parentID;
                    eventCell.removeButton.courseId = [obj.fields objectForKey:[[self searchRoleId] isEqualToString:@"2"] ? @"EventManagerCourse" : @"CourseAdminCourse"];
                    break;
            }
            
            
            eventCell.imageViewUsers.layer.cornerRadius = eventCell.imageViewUsers.bounds.size.width / 2;
            
            [eventCell.imageViewUsers sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [eventCell.imageViewUsers setImage:image];
                [eventCell.imageViewUsers setContentMode:UIViewContentModeScaleAspectFill];
                [eventCell.imageViewUsers setShowActivityIndicatorView:NO];
                
            }];
            
            return eventCell;
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self IsPro])
    {
        return;
    }
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];

    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    if([self IsFriends])
    {
        viewController.arrConnections=[arrConnectionsTemp copy];
        
        QBChatDialog *dialogObj = [arrDialogData objectAtIndex:indexPath.row];
        [AppDelegate sharedinstance].sharedchatDialog = dialogObj;
        
        QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
        
        NSNumber *opponentnum = [NSNumber numberWithInteger:obj.userID];
        
        NSMutableArray *arrOccupants  = [[NSMutableArray alloc] init];
        
        NSString *strCurrentId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID];
        
        NSNumber *num = [NSNumber numberWithInt:[strCurrentId intValue]];
        for(QBChatDialog *obj  in arrDialogData) {
            //now go through array and get user id of opponents
            
            NSMutableArray *arrTemp = [obj.occupantIDs mutableCopy];
            
            [arrTemp removeObject:num];
            [arrOccupants addObject:[arrTemp objectAtIndex:0]];
        }
        
        NSInteger idx =  [arrOccupants indexOfObject:opponentnum];
        
        QBChatDialog *dialog = [arrDialogData objectAtIndex:idx];

        viewController.sharedChatDialog = dialog;
        [AppDelegate sharedinstance].sharedchatDialog = dialog;
        
        viewController.otherUserObject = obj;
        viewController.arrConnections=[arrConnectionsTemp copy];
        viewController.IsFriend = YES;
        
    }
    else
    {
        viewController.arrConnections=[arrConnections copy];
    }
    
    if([eventManagerSegments isHidden])
    {
        viewController.userID = obj.ID;
    }
    else
    {
        viewController.userID = [eventManagerSegments selectedSegmentIndex] == 0 ? obj.ID : obj.parentID;
    }
    
    [self.navigationController pushViewController:viewController animated:YES];
    
}

-(IBAction) viewProfile: (button_ViewPro*)sender
{
    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    viewController.userID = sender.proID;
    viewController.IsFriend = [self IsFriends];
    
    [self.navigationController pushViewController:viewController animated:YES];
}

-(void) getInviteUsers
{    
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
        arrConnections=[objects mutableCopy];
        arrConnectionsTemp = objects;
        
        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (QBCOCustomObject *obj in arrConnections)
        {
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
            
            [lblNotAvailable setHidden:[arrData count]!=0];
            
            isPageRefreshing=NO;
            
            [[AppDelegate sharedinstance] hideLoader];
            [tblList reloadData];
            
        }
        errorBlock:^(QBResponse *response)
        {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
    }
    errorBlock:^(QBResponse *response)
    {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(IBAction) acceptRequest:(UIButton*)sender
{
    
    CGPoint center = sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"%ld",(long)indexPath.row);
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    
    NSString *strCurrentUserId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserEmail];
    
    
    
    // Show pop up to buy more or upgrade
    
    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    
    if(![[dictUserData objectForKey:@"userFullMode"] isEqualToString:@"1"]){
        
        NSString *struserWeeklyConnects =  [dictUserData objectForKey:@"userFreeConnects"];
        NSString *struserPurchasedConnects =  [dictUserData objectForKey:@"userPurchasedConnects"];
        
        long weeklyConnects = [struserWeeklyConnects integerValue];
        long userPurchasedConnects = [struserPurchasedConnects integerValue];
        
        long totalAvailableConnects = weeklyConnects + userPurchasedConnects;
        
        if(totalAvailableConnects<1) {
            
            // Show pop up to buy more or upgrade
            
            [self connectsMessage];
            return;
        }
    }
    
    // When a match is done,  decrease 1 connect
    
    // Connnections
    NSString *strOtherUserId = [obj.fields objectForKey:@"userEmail"];
    
    NSArray *arrVal = [NSArray arrayWithObjects:strCurrentUserId,strOtherUserId, nil];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:@"100" forKey:@"limit"];
    [getRequest setObject:[[arrVal valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[in]"];
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
    {            // do something with retrieved object
        QBCOCustomObject *currentUserObj =[objects objectAtIndex:0];
        
        QBCOCustomObject *otherUserObj =[objects objectAtIndex:1];
        
        QBCOCustomObject *objTemp = [objects objectAtIndex:0];
        
        NSString *strCurrentUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
        
        if([[objTemp.fields objectForKey:@"userEmail"] isEqualToString:strCurrentUserEmail])
        {
            currentUserObj = [objects objectAtIndex:0];
            otherUserObj = [objects objectAtIndex:1];
            
        }
        else
        {
            currentUserObj = [objects objectAtIndex:1];
            otherUserObj = [objects objectAtIndex:0];
        }
        
        long userWeeklyConnects = [[currentUserObj.fields objectForKey:@"userFreeConnects"] integerValue];
        long userPurchasedConnects = [[currentUserObj.fields objectForKey:@"userPurchasedConnects"] integerValue];
        
        if(userWeeklyConnects>0)
        {
            userWeeklyConnects = userWeeklyConnects - 1;
            [currentUserObj.fields setObject:[NSString stringWithFormat:@"%ld",userWeeklyConnects]  forKey:@"userFreeConnects"];
        }
        else
        {
            if(userPurchasedConnects>0)
            {
                userPurchasedConnects = userPurchasedConnects - 1;
            }
            
            [currentUserObj.fields setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
        }
        
        QBCOCustomObject *objToUpdate;
        
        NSString *strSelectedEmail = [obj.fields objectForKey:@"userEmail"];
        
        for(QBCOCustomObject *connObj in arrConnectionsTemp)
        {
            
            NSString *strEmail = [connObj.fields objectForKey:@"connReceiverID"];
            
            if([[[AppDelegate sharedinstance] getCurrentUserEmail] isEqualToString:strEmail])
            {
                strEmail= [connObj.fields objectForKey:@"connSenderID"];
            }
            
            if([strSelectedEmail isEqualToString:strEmail])
            {
                objToUpdate = connObj;
                break;
            }
        }
        
        [objToUpdate.fields setObject:@"2" forKey:@"connStatus"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest updateObject:objToUpdate successBlock:^(QBResponse *response, QBCOCustomObject *object)
        {
            
            [dictUserData setObject:[NSString stringWithFormat:@"%ld",userWeeklyConnects]  forKey:@"userFreeConnects"];
            [dictUserData setObject:[NSString stringWithFormat:@"%ld",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
            
            [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString *strPush = [obj.fields objectForKey:@"userPush"];
            
            
            [QBRequest updateObjects:@[currentUserObj,otherUserObj] className:@"UserInfo" successBlock:^(QBResponse *response, NSArray *objects, NSArray *notFoundObjectsIds)
            {
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
                            
                            NSString *strUserId = [NSString stringWithFormat:@"%ld",(unsigned long)obj.userID];
                            
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
                errorBlock:^(QBResponse *response)
                {
                    [[AppDelegate sharedinstance] hideLoader];
                }];
                
            } errorBlock:^(QBResponse *error)
            {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];
                
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
        }
        errorBlock:^(QBResponse *response)
        {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
            [[AppDelegate sharedinstance] hideLoader];
        }];
        
    }
    errorBlock:^(QBResponse *error)
    {
         // error handling
         [[AppDelegate sharedinstance] hideLoader];
         
     }];
}

-(IBAction) denyRequest:(UIButton*)sender
{
    CGPoint center=sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"%ld",(long)indexPath.row);
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    QBCOCustomObject *objToUpdate=obj;
    
    
    NSString *strSelectedEmail = [obj.fields objectForKey:@"userEmail"];
    
    for(QBCOCustomObject *connObj in arrConnectionsTemp)
    {
        
        NSString *strEmail = [connObj.fields objectForKey:@"connReceiverID"];
        
        if([[[AppDelegate sharedinstance] getCurrentUserEmail] isEqualToString:strEmail])
        {
            strEmail= [connObj.fields objectForKey:@"connSenderID"];
        }
        
        if([strSelectedEmail isEqualToString:strEmail])
        {
            objToUpdate = connObj;
            break;
        }
    }
    
    [objToUpdate.fields setObject:@"3" forKey:@"connStatus"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:objToUpdate successBlock:^(QBResponse *response, QBCOCustomObject *object)
    {
        
        [[QBChat instance] rejectAddContactRequest:obj.userID completion:^(NSError * _Nullable error)
        {
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
                
                NSString *strUserId = [NSString stringWithFormat:@"%ld",(long)obj.userID];
                
                [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                    
                    [arrData removeObject:obj];
                    
                    [lblNotAvailable setHidden:[arrData count]!=0];
                    
                    [tblList reloadData];
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                    
                }
                errorBlock:^(QBError *error)
                {
                    [arrData removeObject:obj];
                    
                    [lblNotAvailable setHidden:[arrData count]!=0];
                    
                    [tblList reloadData];
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
                    // Handle error
                }];
            }
            else
            {
                [arrData removeObject:obj];
                [tblList reloadData];
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Request has been denied successfully"];
            }
        }];
        
        
        
    }
    errorBlock:^(QBResponse *response)
    {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
    }];
    
    
}

-(IBAction) segmentChanged :(UISegmentedControl*) sender {
    
    arrData = [[NSMutableArray alloc] init];
    
    switch(sender.selectedSegmentIndex)
    {
        case 0:
        case 1:
            [self getContact];
            break;
        case 2:
            [self getInviteUsers];
            break;
    }
    
}


-(IBAction) viewUserSegmentChanged :(UISegmentedControl*) sender
{
    arrData = [[NSMutableArray alloc] init];
    NSArray *segmentAllowSearch = @[@"All", @"Near Me"];
    [btnSettingsBig setHidden:![segmentAllowSearch containsObject:[sender titleForSegmentAtIndex:[sender selectedSegmentIndex]]]];
    [self getAllUsers];
}

-(IBAction) EventManagerSegmentChanged :(UISegmentedControl*) sender
{
    arrData = [[NSMutableArray alloc] init];
    switch(sender.selectedSegmentIndex)
    {
        case 0:
            [self getAllUsers];
            break;
        case 1:
            [self getInviteUsers];
            break;
    }

}

-(void) getAdminViewUsers
{
    NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
    if(_RoleId != -1)
    {
        [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserGuid] forKey:@"_parent_id"];
    }
    [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         courseIds = [[NSMutableArray alloc] init];
         for(QBCOCustomObject *obj in objects)
         {
             @try
             {
                 [courseIds addObject:[obj.fields objectForKey:_RoleId == 2 ? @"EventManagerCourse" : @"CourseAdminCourse"]];
             }
             @catch(NSException *e)
             {
                 
             }
  
         }
         NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
         [getRequest setObject:courseIds forKey:[[self searchRoleId] isEqualToString:@"2"] ? @"EventManagerCourse[in]" : @"CourseAdminCourse[in]"];
         
         [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
          {
              arrUserCourses = [objects mutableCopy];
              userIds = [[NSMutableArray alloc] init];
              for(QBCOCustomObject *obj in objects)
              {
                  [userIds addObject:obj.parentID];
              }
              NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
              [getRequest setObject:userIds forKey:@"_id[in]"];
              [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
               {
                   for(QBCOCustomObject *obj1 in arrUserCourses)
                   {
                       for(QBCOCustomObject *obj2 in objects)
                       {
                           if([obj1.parentID isEqualToString:obj2.ID])
                           {
                               [obj1.fields setObject:[obj2.fields objectForKey:@"userDisplayName"] forKey:@"userDisplayName"];
                               [obj1.fields setObject:[obj2.fields objectForKey:@"userPicBase"] forKey:@"userPicBase"];
                               break;
                           }
                       }
                   }
                   
                   NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
                   [getRequest setObject:courseIds forKey:@"_id[in]"];
                   [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
                    {
                        for(QBCOCustomObject *obj1 in arrUserCourses)
                        {
                            for(QBCOCustomObject *obj2 in objects)
                            {
                                if([[obj1.fields objectForKey:[[self searchRoleId] isEqualToString:@"2"] ? @"EventManagerCourse" : @"CourseAdminCourse"] isEqualToString:obj2.ID])
                                {
                                    [obj1.fields setObject:[obj2.fields objectForKey:@"Name"] forKey:@"CourseName"];
                                    break;
                                }
                            }
                        }
                        arrData = [arrUserCourses mutableCopy];
                        [[AppDelegate sharedinstance] hideLoader];
                        [tblList reloadData];
                    } errorBlock:^(QBResponse *response)
                    {
                        // Handle error here
                        [[AppDelegate sharedinstance] hideLoader];
                        
                    }];
               } errorBlock:^(QBResponse *response)
               {
                   // Handle error here
                   [[AppDelegate sharedinstance] hideLoader];
                   
               }];
          } errorBlock:^(QBResponse *response)
          {
              // Handle error here
              [[AppDelegate sharedinstance] hideLoader];
              
          }];
        
     } errorBlock:^(QBResponse *response)
     {
         // Handle error here
         [[AppDelegate sharedinstance] hideLoader];
         
     }];
    
}


-(IBAction) AddButtonTapped: (button_ViewEvent *) sender
{
    choosenUserId = sender.userId;
    if(_RoleId == -1)
    {
        [self getGolfCourses:nil];
    }
    else
    {
        NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
        [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserGuid] forKey:@"_parent_id"];
        [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
         {
             courseIds = [[NSMutableArray alloc] init];
             for(QBCOCustomObject *obj in objects)
             {
                 @try
                 {
                     [courseIds addObject:[obj.fields objectForKey:_RoleId == 2 ? @"EventManagerCourse" : @"CourseAdminCourse"]];
                 }
                 @catch(NSException *e)
                 {
                     
                 }
                 
             }
             NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
             [getRequest setObject:courseIds forKey:@"_id[in]"];
             [self getGolfCourses:getRequest];
             
         } errorBlock:^(QBResponse *response)
         {
             // Handle error here
             [[AppDelegate sharedinstance] hideLoader];
             
         }];
    }
    
}

-(void) getGolfCourses: (NSMutableDictionary *) getRequest
{
    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         arrCourses = [objects mutableCopy];
         [coursePicker reloadAllComponents];
         [coursePicker setHidden:NO];
         [doneView setHidden:NO];
         
     } errorBlock:^(QBResponse *response)
     {
         // Handle error here
         [[AppDelegate sharedinstance] hideLoader];
         
     }];
}

-(IBAction) doneButtonPressed
{
    [doneView setHidden:YES];
    [coursePicker setHidden:YES];
    if(arrCourses.count == 0)
    {
        return;
    }
    QBCOCustomObject *obj = [QBCOCustomObject alloc];
    
    obj.className = @"UserCourses";
    obj.parentID = choosenUserId;
    long index = [coursePicker selectedRowInComponent:0];
    QBCOCustomObject *courseObj = arrCourses[index];
    [obj.fields setObject:courseObj.ID forKey:[[self searchRoleId] isEqualToString:@"2"] ? @"EventManagerCourse" : @"CourseAdminCourse"];
    
    [QBRequest createObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *newObject)
     {
         NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
         [getRequest setObject:[self searchRoleId] forKey:@"RoleId"];
         [getRequest setObject:@"Approved" forKey:@"Status"];
         [getRequest setObject:@"true" forKey:@"Active"];
         [getRequest setObject:choosenUserId forKey:@"_parent_id"];
         [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
          {
              if(objects.count == 0)
              {
                  QBCOCustomObject *obj = [QBCOCustomObject alloc];
                  
                  obj.className = @"UserRoles";
                  obj.parentID = choosenUserId;
                  [obj.fields setObject:[self searchRoleId] forKey:@"RoleId"];
                  [obj.fields setObject:@"Approved" forKey:@"Status"];
                  [obj.fields setObject:@"true" forKey:@"Active"];
                  [obj.fields setObject:@"Event Manager" forKey:@"Name"];
                  [obj.fields setObject:[NSDate date] forKey:@"DateAsRole"];
                  
                  [QBRequest createObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *newObject)
                   {
                       [self successMessage:[[self searchRoleId] isEqualToString:@"2"] ? @"Event Manager sucessfully saved." : @"Course Admin sucessfully saved."];
                   }errorBlock:^(QBResponse *response)
                   {
                       // Handle error here
                       [[AppDelegate sharedinstance] hideLoader];
                       
                   }];
              }
              else
              {
                  [self successMessage:[[self searchRoleId] isEqualToString:@"2"] ? @"Event Manager sucessfully saved." : @"Course Admin sucessfully saved."];
              }
            
              
          } errorBlock:^(QBResponse *response)
          {
              // Handle error here
              [[AppDelegate sharedinstance] hideLoader];
              
          }];
         
     }
                 errorBlock:^(QBResponse *response) {
                     // error handling
                     [[AppDelegate sharedinstance] hideLoader];
                     
                     NSLog(@"Response error: %@", [response.error description]);
                 }];

}

-(IBAction) removeButtonPressed: (button_ViewEvent *) button
{
         NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
         [getRequest setObject:button.courseId forKey:[[self searchRoleId] isEqualToString:@"2"] ? @"EventManagerCourse" : @"CourseAdminCourse"];
         [getRequest setObject:button.userId forKey:@"_parent_id"];
         [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
          {
              for(QBCOCustomObject *obj in objects)
              {
                  [QBRequest deleteObjectWithID:obj.ID className:@"UserCourses" successBlock:^(QBResponse * _Nonnull response) {
                      [self getAdminViewUsers];
                  } errorBlock:^(QBResponse * _Nonnull response) {
                      
                  }
                   ];
              }
          } errorBlock:^(QBResponse *response)
          {
              // Handle error here
              [[AppDelegate sharedinstance] hideLoader];
              
          }];
         
  
    
}

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
    return arrCourses.count;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [((QBCOCustomObject *)arrCourses[row]).fields objectForKey:@"Name"];
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}



@end
