	//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MyMatchesViewController.h"
#import "HomeViewController.h"
#import "ViewUsersViewController.h"
#import "cell_ViewUsers.h"
#import "cell_ViewPro.h"
#import "PreviewProfileViewController.h"
#import "SettingsViewController.h"
#import "DemoMessagesViewController.h"
#define kLimit @"100"
#define kdialogLimit 100

@interface ViewUsersViewController ()

@end

@implementation ViewUsersViewController
@synthesize tblList;
@synthesize strIsMyMatches;

-(void) showcustomnotification{
    
    [[AppDelegate sharedinstance] displayCustomNotification:@"hello"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadusers) name:@"reloadusers" object:nil];
  

    [AppDelegate sharedinstance].arrContactListIDs = [[NSMutableArray alloc] init];
    [AppDelegate sharedinstance].arrSharedOnlineUsers = [[NSMutableArray alloc] init];
    
    [lblNotAvailable setHidden:YES];
    
    arrData = [[NSMutableArray alloc] init];
    arrDialogData = [[NSMutableArray alloc] init];

    self.navigationController.navigationBarHidden=YES;
    //http://stackoverflow.com/questions/20491084/quickblox-how-to-make-paged-request-of-custom-objects?rq=1
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
    
    [btnSettingsBig setHidden:YES];
    
    if([strIsMyMatches isEqualToString:@"1"])
    {
        [proSegments setHidden:YES];
        [golferSegments setHidden:YES];
        
        [AppDelegate sharedinstance].currentScreen = kScreenusers;

        [AppDelegate sharedinstance].strIsMyMatches = @"1";
        
        segmentMode = [myMatchesSegments selectedSegmentIndex];

        lblTitle.text = @"My Friends";
        [btnSettingsBig setHidden:YES];
        
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
                    [AppDelegate sharedinstance].strIsChatConnected = @"1";
                    
                    arrDialogData = [[NSMutableArray alloc] init];
                    [self getContact];
                }
            }];
        }
    }
    else
    {
        [AppDelegate sharedinstance].currentScreen = kScreenOther;

        [AppDelegate sharedinstance].strIsMyMatches = @"0";
        
        if([self IsPro])
        {
            segmentMode = [proSegments selectedSegmentIndex];

            [btnSettingsBig setHidden:segmentMode != 2 && segmentMode != 1];
        }
        else
        {
            [btnSettingsBig setHidden:NO];
        }
        
        
        lblTitle.text = [self IsPro] ? @"Pros" : @"Golfers";
        [myMatchesSegments setHidden:YES];
        [proSegments setHidden:![self IsPro]];
        [golferSegments setHidden:[self IsPro]];
        
        [self getAllUsers];
    }
}

-(void) refreshdialogs
{
    if([strIsMyMatches isEqualToString:@"1"])
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
    
    [self getDialogs];

}

- (void) getDialogs
{
    
    [AppDelegate sharedinstance].strcustomnotificationtimer = @"2";
    
    _currentDialog=0;
    
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
        
        NSString *strCurrentId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID];
        
        NSNumber *num = [NSNumber numberWithInt:[strCurrentId intValue]];
        
        for(QBChatDialog *obj  in arrDialogData)
        {
            //now go through array and get user id of opponents
            
            if(![[AppDelegate sharedinstance] checkSubstring:@"unfriended" containedIn:obj.lastMessageText ])
            {
                NSMutableArray *arrTemp = [obj.occupantIDs mutableCopy];
                [arrTemp removeObject:num];
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
    
    if(segmentMode == 1)
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
    __block int currentPageNum = currentNum;
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:kLimit forKey:@"limit"];
    
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPageNum];
    
    [getRequest setObject:strPage forKey:@"skip"];
    
    [getRequest setObject:@"created_at" forKey:@"sort_desc"];
    
    if(![self IsPro])
    {
        [getRequest setObject:[[arrConnections valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[nin]"];
    }
    
    NSString *searchType = [self IsPro] ? kuserSearchPro : kuserSearchUser;
    
    NSMutableDictionary *dictUserSearchData = [[[NSUserDefaults standardUserDefaults] objectForKey:searchType] mutableCopy];
    
    if(segmentMode == 1)
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
        
        NSString *role = [self IsPro] ? @"1" : @"0";
        
        [getRequest setObject:role forKey:@"UserRole"];
    }
    else if([self IsPro] && segmentMode == 0)
    {
        [getRequest setObject: @"True" forKey:@"Featured"];
        [getRequest setObject:@"1" forKey:@"UserRole"];
    }
    else
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
    
    if([strHandicap length]!=0 && ![self IsPro])
    {
        NSArray* splitHandicap = [strHandicap componentsSeparatedByString: @":"];
        NSString *handicapRange = [splitHandicap objectAtIndex: 0];
        NSString *includeNA = [splitHandicap objectAtIndex: 1];
        
        NSArray* splitRange = [handicapRange componentsSeparatedByString: @" - "];
        lowerlimit = [[splitRange objectAtIndex: 0] intValue];
        upperlimit = [[splitRange objectAtIndex: 1] intValue];
        
        NSMutableArray *handicapArr = [[NSMutableArray alloc] init];
        
        for(long x = lowerlimit; x <= upperlimit; ++x)
        {
            [handicapArr addObject:[NSString stringWithFormat:@"%ld", x]];
        }
        
        if([includeNA isEqualToString:@"0"])
        {
            [handicapArr addObject:@"N/A"];
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
    
    
   NSString *strinterested_in_home_course = [[AppDelegate sharedinstance] nullcheck:[dictUserSearchData objectForKey:@"Name"]];
    
    if([strinterested_in_home_course length]>0)
    {
        if(![strinterested_in_home_course isEqualToString:@"All"])
        {
            [getRequest setObject:strinterested_in_home_course forKey:@"home_coursename[in]"];
        }
        
    }
    
    NSString *role = [self IsPro] ? @"1" : @"0";
    
    [getRequest setObject:role forKey:@"UserRole"];

    NSString *strGender = [[AppDelegate sharedinstance] nullcheck:[[dictUserSearchData  objectForKey:@"Gender"] lowercaseString]];
    
    if(![strGender isEqualToString:@"all"] && [strGender length] != 0)
    {
        [getRequest setObject:strGender forKey:@"userGender[in]"];
    }
    
    
    
    
    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    
    [getRequest setObject:@16 forKey:@"advertisingBlockCount[lt]"];
    
    NSString *type = [[AppDelegate sharedinstance] nullcheck:[dictUserData  objectForKey:@"Type"]];
    
    if(![type isEqualToString:@"All"] && [type length] !=0)
    {
        if([type isEqualToString:@"Free"])
        {
            type = @"1";
        }
        else if([type isEqualToString:@"Premium"])
        {
            type = @"1";
        }
        
        [getRequest setObject: type forKey:@"user_type"];
    }
    
    
    
    }
    
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
    SettingsViewController *obj = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    obj.cameFromScreen=@"1";
    obj.IsPro = [self IsPro];
    
    if([self IsPro])
    {
         [proSegments setSelectedSegmentIndex:2];
        segmentMode = 2;
    }
    else
    {
        [golferSegments setSelectedSegmentIndex:0];
        segmentMode = 0;
    }
    
    [self.navigationController pushViewController:obj animated:YES];
}

//-----------------------------------------------------------------------

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
    
    if([strIsMyMatches isEqualToString:@"1"]) {
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

    if(![[dictUserData objectForKey:@"userFullMode"] isEqualToString:@"1"]){
        
        int weeklyConnects = [[dictUserData objectForKey:@"userFreeConnects"] intValue];
        int userPurchasedConnects = [[dictUserData objectForKey:@"userPurchasedConnects"] intValue];
        
        int totalAvailableConnects = weeklyConnects + userPurchasedConnects;
        
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
                                            //Handle your yes please button action here
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
                    
                    if([arrData count]==0) {
                        [lblNotAvailable setHidden:NO];
                    }
                    else {
                        [lblNotAvailable setHidden:YES];
                    }
                    
                    int weeklyConnects = [[dictUserData objectForKey:@"userFreeConnects"] intValue];
                    int userPurchasedConnects = [[dictUserData objectForKey:@"userPurchasedConnects"] intValue];
                    
                    // If weekly connects available, then deduct from it
                    
                    QBCOCustomObject *object = [QBCOCustomObject customObject];
                    object.className = @"UserInfo";
                    object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
                    
                    if(weeklyConnects>0) {
                        
                         weeklyConnects = weeklyConnects - 1;
                        [object.fields setObject:[NSString stringWithFormat:@"%d",weeklyConnects]  forKey:@"userFreeConnects"];
                    }
                    else {
                       
                        if(userPurchasedConnects>0) {
                            userPurchasedConnects = userPurchasedConnects - 1;
                        }
                        
                        [object.fields setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects]  forKey:@"userPurchasedConnects"];
                    }
                    
                    [dictUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                    [dictUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];

                    [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    
                    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        // object updated
                        
                        [arrData removeObject:obj];
                        [tblList reloadData];
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                        
                        
                    } errorBlock:^(QBResponse *response) {
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        NSLog(@"Response error: %@", [response.error description]);
                    }];
                    
                } errorBlock:^(QBError *error) {
                    [arrData removeObject:obj];
                    
                    if([arrData count]==0) {
                        [lblNotAvailable setHidden:NO];
                    }
                    else {
                        [lblNotAvailable setHidden:YES];
                    }
                    
                    int weeklyConnects = [[dictUserData objectForKey:@"userFreeConnects"] intValue];
                    int userPurchasedConnects = [[dictUserData objectForKey:@"userPurchasedConnects"] intValue];
                    
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
                    
                    [dictUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                    [dictUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                    [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                    
                    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                        // object updated
                        
                        [arrData removeObject:obj];
                        [tblList reloadData];
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                        
                        
                    } errorBlock:^(QBResponse *response) {
                        
                        [[AppDelegate sharedinstance] hideLoader];
                        NSLog(@"Response error: %@", [response.error description]);
                    }];
                    
                }];
            }
            else {
                
                int weeklyConnects = [[dictUserData objectForKey:@"userFreeConnects"] intValue];
                int userPurchasedConnects = [[dictUserData objectForKey:@"userPurchasedConnects"] intValue];
                
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
                
                [dictUserData setObject:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                [dictUserData setObject:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                
                [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",weeklyConnects] forKey:@"userFreeConnects"];
                [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",userPurchasedConnects] forKey:@"userPurchasedConnects"];
                
                [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                    // object updated
                    
                    [arrData removeObject:obj];
                    [tblList reloadData];
                    
                    [[AppDelegate sharedinstance] hideLoader];
                    [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                    
                    
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

-(void) letotherfeatureswork
{
    
    if([[AppDelegate sharedinstance].strIsChatConnected isEqualToString:@"0"]){
        [self getDialogs];
    }
}

-(void) reloadusers
{
    
    if([strIsMyMatches isEqualToString:@"1"]) {
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

    if([self IsPro])
    {
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
        cell.proType.text = [obj.fields objectForKey:@"ProType"];
        
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
        
        
        
        if([strIsMyMatches isEqualToString:@"0"])
        {
            [cell.acceptButton setHidden:YES];
            [cell.denyButton setHidden:YES];
            
            QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
            
            NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userFullMode"]];
            
            if([userFullMode isEqualToString:@"1"]) {
                
                [cell.viewBG setHidden:NO];
                [cell.imageViewBadge setHidden:NO];
                
                [cell.imageViewBadge setFrame:CGRectMake(216, 17, 20, 26)];
            }
            else {
                [cell.imageViewBadge setHidden:YES];
                [cell.viewBG setHidden:YES];
            }
            
            NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userDisplayName"]];
            NSString *str2 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userHandicap"]];
            str2 = [NSString stringWithFormat:@"Handicap : %@",str2];
            
            [cell.lblUserName setText:str1];
            [cell.lblhandicap setText:str2];
            
            NSString *homeCourse = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"home_coursename"]];
            [cell.lblHomeCourse setText:homeCourse];
            
            [cell.imageViewUsers setShowActivityIndicatorView:YES];
            [cell.imageViewUsers setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell.imageViewUsers sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
            
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
            
            NSArray *arrCoord = [obj.fields objectForKey:@"current_location"];
            
            strlat = [arrCoord objectAtIndex:1];
            strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
            
            strlong = [arrCoord objectAtIndex:0];
            strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
            
            
            //Create a special variable to hold this coordinate info.
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.latitude=[strlat doubleValue];
            placeCoord.longitude=[strlong doubleValue];
            desplaceCoord = placeCoord;
            
            strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
            strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
            
            strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
            strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
            
            //Set the lat and long.
            placeCoord.latitude=[strlat doubleValue];
            placeCoord.longitude=[strlong doubleValue];
            
            CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
            scrplaceCoord = myposition;
            
            CLLocation *loc2;
            CLLocation *loc1;
            
            loc1 = [[CLLocation alloc] initWithLatitude:scrplaceCoord.latitude longitude:scrplaceCoord.longitude];
            loc2 = [[CLLocation alloc] initWithLatitude:desplaceCoord.latitude longitude:desplaceCoord.longitude];
            
            CLLocationDistance distanceInMeters = [loc1 distanceFromLocation:loc2];
            
            NSLog(@" distance in metres %f",distanceInMeters);
            NSLog(@" distance in km %f",(distanceInMeters/1000.f));
            
            double distanceinKm =(distanceInMeters/1000.f);
            distanceinKm = roundf(distanceinKm * 10.0f)/10.0f;
            
            NSString *strDistance = [NSString stringWithFormat:@"%.1f km",distanceinKm];
            NSLog(@" distance in km %@",strDistance);
            
        }
        else
        {
           
            
            [cell.lblhandicap setTextColor:[UIColor whiteColor]];
            
            QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
            
            NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userFullMode"]];
            
            if([userFullMode isEqualToString:@"1"]) {
                [cell.imageViewBadge setHidden:NO];
                
                [cell.viewBG setHidden:NO];
                [cell.imageViewBadge setFrame:CGRectMake(216, 17, 20, 26)];
                
            }
            else {
                [cell.imageViewBadge setHidden:YES];
                [cell.viewBG setHidden:YES];
            }
            
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
    
        switch(segmentMode)
        {
            case 0:
                [cell.acceptButton setHidden:YES];
                [cell.denyButton setHidden:YES];
                break;
            default:
                [cell.btnAdd setHidden:YES];
                [cell.btnMessageBadge setHidden:YES];
                [cell.imageViewBadge setHidden:YES];
                break;
        }
        cell.imageViewUsers.layer.cornerRadius =  cell.imageViewUsers.frame.size.width/2;
        [cell.imageViewUsers.layer setMasksToBounds:YES];
        [cell.imageViewUsers.layer setBorderColor:[UIColor clearColor].CGColor];
    
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([self IsPro])
    {
        return;
    }
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    NSString *userEmail= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userEmail"]];

    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    if([[AppDelegate sharedinstance].strIsMyMatches isEqualToString:@"1"])
    {
        viewController.strCameFrom=@"3";
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
        
    }
    else
    {
        viewController.strCameFrom=@"1";
        viewController.arrConnections=[arrConnections copy];
    }
        
    viewController.strEmailOfUser = userEmail;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

-(IBAction) viewProfile: (button_ViewPro*)sender
{
    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    viewController.userID = sender.proID;
    viewController.strCameFrom = @"6";
    
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
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"PURCHASE CONNECTS" message:@"Sorry, you have no CONNECTS available to accept request.\nDo you want to buy them?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            alert.tag=121;
            [alert show];
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
                            
                            NSString *strUserId = [NSString stringWithFormat:@"%ld",obj.userID];
                            
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
            segmentMode=0;
            [self getContact];
            break;
        case 1:
            segmentMode=1;
            [self getContact];
            break;
        case 2:
            segmentMode=2;
            [self getInviteUsers];
            break;
    }
    
}


-(IBAction) viewUserSegmentChanged :(UISegmentedControl*) sender
{
    
    arrData = [[NSMutableArray alloc] init];
    
    segmentMode = sender.selectedSegmentIndex;
    
    [btnSettingsBig setHidden:YES];
    
    NSArray *segmentAllowSearch = @[@"All", @"Near Me"];
    
    if([segmentAllowSearch containsObject:[sender titleForSegmentAtIndex:segmentMode]])
    {
        [btnSettingsBig setHidden:NO];
    }
    
    [self getAllUsers];
    
}

@end
