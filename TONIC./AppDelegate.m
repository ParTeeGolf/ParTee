//
//  AppDelegate.m
//  SR-DIREKT
//
//  Created by Amolaksingh on 11/05/16.
//  Copyright © 2016 SR-DIREKT. All rights reserved.
//

#define kRedirectToInvitationCourse @"1"
#define kRedirectToInvitationUser @"2"
#define kRedirectToMyFriends @"3"
#define kRedirectToMyCourses @"4"


#import "AppDelegate.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "MyMatchesViewController.h"
#import "SpecialsViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "DemoMessagesViewController.h"
#import "ViewUsersViewController.h"
#import "PreviewProfileViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "CoursePreferencesViewController.h"
#import "AdminViewController.h"
@import CoreLocation;
@import AVFoundation;
@import ImageIO;

@interface AppDelegate ()

@end

static AppDelegate *delegate;

@implementation AppDelegate
@synthesize oneSignal;
@synthesize login;
@synthesize isUpdate;
@synthesize strPropertyId;
@synthesize dictReportData;
@synthesize delegateShareObject;
@synthesize dialog;
@synthesize currentScreen;
@synthesize strisDevelopment;
@synthesize sharedChatInstance;
@synthesize topView;
@synthesize customnotification;
@synthesize strcustomnotificationtimer;

@synthesize arrSharedOnlineUsers;
@synthesize arrContactListIDs;
@synthesize strIsChatConnected;
@synthesize locationManager;
@synthesize commonone;
@synthesize ProIcons;
@synthesize AmenitiesIcons;



//-----------------------------------------------------------------------

#pragma mark - demoController

//-----------------------------------------------------------------------


//-----------------------------------------------------------------------

#pragma mark - demoController

//-----------------------------------------------------------------------

-(void) initialSettings {
    customnotification=nil;
    
    customnotification = [[MPGNotification alloc] init];
    customnotification.title = @"Notification";
    customnotification.backgroundColor = [UIColor colorWithRed:0.000 green:0.655 blue:0.176 alpha:1.00];
    customnotification.duration = 3.0;
    customnotification.swipeToDismissEnabled = NO;
    [customnotification setTitleColor:[UIColor whiteColor]];
    [customnotification setSubtitleColor:[UIColor whiteColor]];
    [customnotification setAnimationType:MPGNotificationAnimationTypeLinear];
    
    customnotification.backgroundTapsEnabled = YES;
    
    NSArray *buttonArray;
    buttonArray = [NSArray arrayWithObjects:@"View",@"Later", nil];

    [customnotification setButtonConfiguration:MPGNotificationButtonConfigrationTwoButton withButtonTitles:buttonArray];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    strcustomnotificationtimer=@"1";
    [GMSPlacesClient provideAPIKey:kGOOGLE_API_KEY];
    [GMSServices provideAPIKey:kGOOGLE_API_KEY];
    
    hud = [[YBHud alloc]initWithHudType:DGActivityIndicatorAnimationTypeBallPulse]; //Initialization
    [hud dismiss];
    
    // Override point for customization after application launch.
  
    self.strisDevelopment=@"0";
    
 //   [NSThread sleepForTimeInterval:2.f];
    
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kIAPFULLVERSION];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    [Fabric with:@[[Crashlytics class]]];
    sharedChatInstance = [QBChat instance];
    
    [[QBChat instance] addDelegate:self];
    [QBSettings setAutoReconnectEnabled:YES];

    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    
    
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"versionapp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSUserDefaults standardUserDefaults] setObject:build forKey:@"buildapp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    dictReportData = [[NSMutableDictionary alloc] init];
    
    [[FBSDKApplicationDelegate sharedInstance] application:application
                             didFinishLaunchingWithOptions:launchOptions];
    
    [QBSettings setApplicationID:56511];
    [QBSettings setAuthKey:@"q4Kpzv77jjG8yD9"];
    [QBSettings setAuthSecret:@"enGtT5bjwYBKArY"];
    [QBSettings setAccountKey:@"jdEtWFB9yQoVzui6uN3y"];
    [QBSettings setLogLevel: QBLogLevelDebug];
    
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    hasLink=NO;
    [self setRootViewController:YES];
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    [[Harpy sharedInstance] setDelegate:self];
    [[Harpy sharedInstance] setShowAlertAfterCurrentVersionHasBeenReleasedForDays:1];
    [[Harpy sharedInstance] setDebugEnabled:true];

    	[[Harpy sharedInstance] setAlertType:HarpyAlertTypeForce];
   
  //  [self locationInit];
    
    [OneSignal initWithLaunchOptions:launchOptions appId:@"c064a937-b4df-4551-aa4e-e31eeba49d23" handleNotificationReceived:^(OSNotification *notification) {
        NSLog(@"Received Notification - %@", notification.payload.notificationID);
        
        NSString* messageTitle = notification.payload.title;
        strTitleNoti=messageTitle;
        
        NSString* message = [notification.payload.body copy];
        strBodyNoti=message;
        
        NSDictionary* additionalData = notification.payload.additionalData;
        isOneSignalPush=1;
        NSLog(@"Title ==> %@ \t body ==> %@",strTitleNoti,strBodyNoti);
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:strTitleNoti message:strBodyNoti delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
        [alert show];
        
        
    } handleNotificationAction:^(OSNotificationResult *result) {
        
    } settings:@{kOSSettingsKeyInAppAlerts : @NO, kOSSettingsKeyAutoPrompt : @YES}];

    [OneSignal sendTags:@{ @"userappversion" :  version} onSuccess:^(NSDictionary *result) {
        
        NSLog(@"sucess");
        
    } onFailure:^(NSError *error) {
        
    }];

    return YES;
}

//-----------------------------------------------------------------------

-(void) registerForNotifications {
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    QBMSubscription *subscription = [QBMSubscription subscription];
    subscription.notificationChannel = QBMNotificationChannelAPNS;
    subscription.deviceUDID = deviceIdentifier;
    subscription.deviceToken = deviceToken;
    
    [QBRequest createSubscription:subscription successBlock:^(QBResponse *response, NSArray *objects) {
        
    } errorBlock:^(QBResponse *response) {
        
    }];
}

- (void) applicationDidEnterBackground:(UIApplication *)application
{
    if([[AppDelegate sharedinstance].sharedChatInstance isConnected]) {
        [[AppDelegate sharedinstance].sharedChatInstance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
            
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    if([[AppDelegate sharedinstance].sharedChatInstance isConnected]) {
        [[AppDelegate sharedinstance].sharedChatInstance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
            
        }];
    }
}

//-----------------------------------------------------------------------

#pragma mark - Location

//-----------------------------------------------------------------------

-(void) locationInit {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    if (![CLLocationManager locationServicesEnabled])
        {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled!"
                                                                message:@"Please enable Location Based Services to show near by courses and golfers!"
                                                               delegate:self
                                                      cancelButtonTitle:@"Settings"
                                                      otherButtonTitles:@"Cancel", nil];
            
            alertView.tag = 100;
            [alertView show];

        }
    else {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [self.locationManager requestWhenInUseAuthorization];
            
            [self checkLocationStatus];
        }
        
    }
    
}

-(void) checkLocationStatus {
    //Checking authorization status
    if ((![CLLocationManager locationServicesEnabled]) || ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied))
    {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled!"
                                                            message:@"Please enable Location Based Services to show near by courses and golfers!"
                                                           delegate:self
                                                  cancelButtonTitle:@"Settings"
                                                  otherButtonTitles:@"Cancel", nil];
        
        //TODO if user has not given permission to device
        if (![CLLocationManager locationServicesEnabled])
        {
            alertView.tag = 100;
        }
        else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {

                alertView.tag = 200;
        }
        
        [alertView show];

        return;
    }
    else
    {
        //Location Services Enabled, let's start location updates
        [locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    
    [AppDelegate sharedinstance].commonone = CLLocationCoordinate2DMake(newLocation.coordinate.latitude,newLocation.coordinate.longitude);
    [locationManager stopUpdatingLocation];
    locationManager.delegate = nil;
    locationManager = nil;
    
    NSString *strLat = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
    NSString *strLong = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];

    [[AppDelegate sharedinstance] setStringObj:strLat forKey:klocationlat];
    [[AppDelegate sharedinstance] setStringObj:strLong forKey:klocationlong];
    
    if([AppDelegate sharedinstance].currentScreen == kScreenRegister) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotLocation" object:nil];

    }
    else if([AppDelegate sharedinstance].currentScreen == kScreenLogin) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotLocationLogin" object:nil];

    }


}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self checkLocationStatus];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 121) {
        if (buttonIndex == 0)
        {
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isRated"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/us/app/partee-golf-connect-with-other-golfers/id1244801350?ls=1&mt=8"]];
            
        }
        
        else if (buttonIndex == 1)
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isRated"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            
        }
        
        return;
        
    }
    else if(alertView.tag == 122) {
        
        if(buttonIndex == 0) {
            [self locationInit];

        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"manualAdd" object:nil];

        }
    }
    else {
        if(buttonIndex == 0)//Settings button pressed
        {
            if (alertView.tag == 100)
            {
                //            NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
                //            if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
                
                //This will open ios devices location settings
                // This will open ios devices location settings in iOS 10
                
                NSString *strWebsite = @"App-Prefs:root=Privacy&path=LOCATION";
                NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
                {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
                }
                else {
                    
                    strWebsite = @"prefs:root=LOCATION_SERVICES";
                    URL =strWebsite;
                    
                    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
                    {
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL]];
                    }
                }
                
            }
            else if (alertView.tag == 200)
            {
                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                    //This will opne particular app location settings
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                    
                }
            }
        }
        else if(buttonIndex == 1)//Cancel button pressed.
        {
            //TODO for cancel
            NSString *strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
            strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
            
             NSString *strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
            strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
            
            if([strlat length]==0)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location will only be used when app is opened"
                                                                message:@"ParTee needs location access to show near by courses and golfers" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Detect automatically",@"Add manually",nil];
                alert.tag=122;
                [alert show];
            }

        }
    }
}

//-----------------------------------------------------------------------

#pragma mark - contact

//-----------------------------------------------------------------------

- (void)chatContactListDidChange:(QBContactList *)contactList{
    
}

- (void)chatDidReceiveContactItemActivity:(NSUInteger)userID isOnline:(BOOL)isOnline status:(NSString *)status{
    
    if(isOnline) {
        // If not contained in shared array, add it
        if(![arrSharedOnlineUsers containsObject:[NSNumber numberWithInteger:userID]]) {
            [arrSharedOnlineUsers addObject:[NSNumber numberWithInteger:userID]];
        }
    }
    else {
        // If  contained in shared array, remove it
        if([arrSharedOnlineUsers containsObject:[NSNumber numberWithInteger:userID]]) {
            [arrSharedOnlineUsers removeObject:[NSNumber numberWithInteger:userID]];
        }
    }
    
    if(self.currentScreen == kScreenusers) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadusers" object:nil];
    }
    
}

- (void)chatDidReceiveContactAddRequestFromUser:(NSUInteger)userID{
    
    //    [[QBChat instance] confirmAddContactRequest:userID completion:^(NSError * _Nullable error) {
    //
    //    }];
}

- (void)chatDidReceiveAcceptContactRequestFromUser:(NSUInteger)userID{
    
}

- (void)chatDidReceiveRejectContactRequestFromUser:(NSUInteger)userID{
    
//    [[QBChat instance] rejectAddContactRequest:29033937 completion:^(NSError * _Nullable error) {
//        
//    }];
}

- (void)chatDidNotConnectWithError:(QB_NULLABLE NSError *)error {
    
    if(error) {
        
    }
}

- (void)chatDidReconnect {
    
}

- (void)chatDidFailWithStreamError:(QB_NULLABLE NSError *)error {
    
    if(error) {
        

    }
}


//-----------------------------------------------------------------------

#pragma mark - chat

//-----------------------------------------------------------------------

- (void)chatDidReceiveMessage:(QBChatMessage *)message {
   
    if(self.currentScreen == kScreenChat) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:message forKey:@"message"];
        
        // reload if same user sent the message or else show as notification
        [[NSNotificationCenter defaultCenter] postNotificationName:@"gotmessage" object:self userInfo:dict];
    }
    else {
        // show as top bar or push
        
        NSString *strMessageText = message.text;
        NSString *strSenderName = [message.customParameters objectForKey:@"senderNick"];
        
 
        NSString *strMessage = [NSString stringWithFormat:@"Message from %@ ",strSenderName];
        
        if(self.currentScreen == kScreenusers) {
            
            if([strcustomnotificationtimer isEqualToString:@"1"]) {
                
                   
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshdialogs" object:nil];
            }
        }

     //   [[AppDelegate sharedinstance] displayMessage:strMessage];
        [[AppDelegate sharedinstance] displayCustomNotificationWithTitle:strMessage andMessage:strMessageText];
    }
    
}



- (void)chatDidReceiveSystemMessage:(QBChatMessage *)message {
    
}

#pragma mark -
#pragma mark Foreground

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    
    [OneSignal sendTags:@{ @"userappversion" :  version} onSuccess:^(NSDictionary *result) {
        
        NSLog(@"sucess");
        
    } onFailure:^(NSError *error) {
        
    }];
    
    if(![[AppDelegate sharedinstance] isUserLogIn]) {
        
        return;
    }
    
    QBUUser *currentUser = [QBSession currentSession].currentUser;
    currentUser.password = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];
   
    if(![[AppDelegate sharedinstance].sharedChatInstance isConnected]) {
        [[AppDelegate sharedinstance] showLoader];
        
        [[AppDelegate sharedinstance].sharedChatInstance connectWithUser:currentUser completion:^(NSError * _Nullable error) {
            //            [[AppDelegate sharedinstance] hideLoader];
            
            if(self.currentScreen == kScreenChat) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"customAmoCode" object:nil];
                
            }
            else if(self.currentScreen == kScreenusers) {
                [self performSelector:@selector(refreshdialogdata) withObject:self afterDelay:1.f];

            }
            else {
                   [[AppDelegate sharedinstance] hideLoader];
            }
        }];
    }
}

-(void) refreshdialogdata {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshdialogs" object:nil];

}

#pragma mark -
#pragma mark push

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler
{
    
    if([[AppDelegate sharedinstance] isUserLogIn]) {
        if(isOneSignalPush==0) {
            NSString *notificationBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            
            // if push is for message and if screen is my friednds/contacts, then refresh the screen
            
            // [[AppDelegate sharedinstance] displayMessage:notificationBody];
            
            [[AppDelegate sharedinstance] displayCustomNotification:notificationBody];
            
            if(self.currentScreen == kScreenusers) {
                
                //       [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshdialogs" object:nil];
                
            }
        }
    }
   
}



- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    BOOL handled = [[FBSDKApplicationDelegate sharedInstance] application:application
                                                                  openURL:url
                                                        sourceApplication:sourceApplication
                                                               annotation:annotation
                    ];
    // Add any custom logic here.
    return handled;
}

//-----------------------------------------------------------------------

-(void) setRootViewController:(BOOL) panMode
{
    if([[AppDelegate    sharedinstance] isUserLogIn]) {
        
        int RoleId = [[AppDelegate sharedinstance] getCurrentRole];
        UIViewController *svc;
        NSMutableDictionary *getRequest;
        
        switch(RoleId)
        {
            case -1:
                svc = [[AdminViewController alloc] initWithNibName:@"AdminViewController" bundle:nil];
                [self managerController:svc:panMode];
                break;
            case 0:
            case 1:
                svc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                ((SpecialsViewController*)svc).DataType = filterCourse;
                [self managerController:svc:panMode];
                break;
            case 2:
            case 3:
                getRequest = [[NSMutableDictionary alloc] init];
                
                [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserGuid] forKey:@"_parent_id"];
                
                [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    
                    NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
                    
                    NSMutableArray *arrCourseIds = [[NSMutableArray alloc] init];
                    
                    for(QBCOCustomObject *obj in objects)
                    {
                        @try
                        {
                            [arrCourseIds addObject:[obj.fields objectForKey:RoleId == 2 ? @"EventManagerCourse" : @"CourseAdminCourse"]];
                        }
                        @catch(NSException *e)
                        {
                            
                        }
                        
                    }
                    
                    SpecialsViewController *vc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                    vc.DataType = filterCourse;
                    vc.courseIds = arrCourseIds;
                    [self managerController:vc:panMode];
                    
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    [[AppDelegate sharedinstance] hideLoader];
                    
                    NSLog(@"Response error: %@", [response.error description]);
                }];
                break;
        }
    }
    else
    {
        [self managerController:[[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil]:panMode];
    }
}

-(void) managerController:(UIViewController *)vc :(BOOL) panMode
{
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.navigationController=[[UINavigationController alloc] initWithRootViewController:vc];
    
    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController: self.navigationController
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    container.panMode=YES;
    
    self.navigationController.navigationBarHidden=YES;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.window makeKeyAndVisible];
    self.window.rootViewController = container;
}

//-----------------------------------------------------------------------

-(BOOL) isUserLogIn {
        return [[AppDelegate sharedinstance] getStringObjfromKey:kuserEmail].length != 0;
}



-(void) excludeFromBackUp {
    NSString *DBPath = [self getDBPath];
    
    NSString *docsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    DBPath= [docsPath stringByAppendingPathComponent:@"BEO.sqlite"];
    
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:[[AppDelegate sharedinstance] getDirectory:kPDFDir]]];
    
}

- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    
    //   assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                    
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    
    if(!success){
        
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        
    }
    
    return success;
}

//-----------------------------------------------------------------------




+(AppDelegate*)sharedinstance
{
    if (delegate==nil) {
        delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        return delegate;
    }
    return delegate;
}

+(AppDelegate*)SharedDelegate
{
    if (delegate==nil) {
        delegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
        return delegate;
    }
    return delegate;
}
-(NSString *) getDBPath
{
    NSArray *path= NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentdirectory = [path objectAtIndex:0];
    
    return [documentdirectory stringByAppendingPathComponent:@"BEO.sqlite"];
}

-(void)copyDatabaseIfNeeded
{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    NSError *error;
    NSString *DBPath = [self getDBPath];
    NSLog(@"dbpath %@",DBPath);
    
    BOOL success = [filemanager fileExistsAtPath:DBPath];
    if (!success) {
        NSString *defaultDBPath = [[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"BEO.sqlite"];
        success = [filemanager copyItemAtPath:defaultDBPath toPath:DBPath error:&error];
        if (!success)
        {
            NSLog(@"Error in creating database");
        }
    }
}

//-----------------------------------------------------------------------

-(void)displayCustomNotification:(NSString *)  strMessage  {
    [self displayCustomNotificationWithTitle:@"Notification" andMessage:strMessage];
}

//-----------------------------------------------------------------------

-(void)displayCustomNotificationWithTitle:(NSString *) strTitle andMessage:(NSString *) strMessage  {
    [self initialSettings];
    
    if(currentScreen==kScreenChat) {
        customnotification.backgroundTapsEnabled = NO;

        [customnotification setButtonConfiguration:MPGNotificationButtonConfigrationZeroButtons withButtonTitles:nil];
    }
    else {
        customnotification.backgroundTapsEnabled = YES;

    }
    [customnotification setIconImage:[UIImage imageNamed:@"Plain White TeeMini" ]];
    customnotification.title = strTitle;
    customnotification.subtitle = strMessage;

    [customnotification setButtonHandler:^(MPGNotification *notification, NSInteger buttonIndex) {
        NSLog(@"buttonIndex : %ld", (long)buttonIndex);
        
        if(buttonIndex==2 ||  buttonIndex == notification.backgroundView.tag) {
            // view
            
            if([[AppDelegate sharedinstance] isUserLogIn]) {
                
                UIViewController *vc;
                
                if([[AppDelegate sharedinstance] checkSubstring:@"has accepted your request for a course" containedIn:strMessage]) {
                    // redirect user to My courses
                    
                    strRedirectScreen = kRedirectToMyCourses;
                    
                    vc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];

                }
                else if([[AppDelegate sharedinstance] checkSubstring:@"has accepted your connection request" containedIn:strMessage]) {
                    // redirect user to My friends
                    
                    strRedirectScreen = kRedirectToMyFriends;
                    
                    vc   = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                    ((ViewUsersViewController*)vc).IsFriends=YES;
                }
                else {
                    // redirect user to my friends screen
                    strRedirectScreen = kRedirectToMyFriends;
                    
                    vc   = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                    ((ViewUsersViewController*)vc).IsFriends=YES;
                    
//                    if(currentScreen==kScreenChat) {
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"hidethekeyboard" object:nil];
//                        
//                    }
                }
                
                UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

                SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
                
                MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                                containerWithCenterViewController:  nav
                                                                leftMenuViewController:leftMenuViewController
                                                                rightMenuViewController:nil];
                container.panMode=YES;
                
                [[AppDelegate sharedinstance].window setRootViewController:container];
                
            }
  
        }
        else {
            // later
            
            
        }
    }];
    
    [customnotification show];
}

//-----------------------------------------------------------------------

-(void)displayMessage:(NSString *) strMessage {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:strMessage delegate:self cancelButtonTitle:nil otherButtonTitles:kOk, nil];
    [alert show];
}

//-----------------------------------------------------------------------

-(void)displayServerFailureMessage {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kNoInternet delegate:self cancelButtonTitle:nil otherButtonTitles:kOk, nil];
    [alert show];
}


//-----------------------------------------------------------------------

-(void)displayServerErrorMessage {
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:kAppName message:kServerError delegate:self cancelButtonTitle:nil otherButtonTitles:kOk, nil];
    [alert show];
}

//-----------------------------------------------------------------------

-(void) showLoader {
    // [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
 //  [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    if(hud) {
        hud.dimAmount = 0.7; //Customization
        
        if(!topView) {
            topView = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
            [hud showInView:topView  animated:YES]; //Display HUD
        }
    }

}

//-----------------------------------------------------------------------

-(void) showLoaderForView:(UIView *) topView1 {
    // [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    //  [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    
    hud = nil;
    
    hud.dimAmount = 0.5; //Customization
    
    if(!topView1) {
        [hud showInView:topView1  animated:YES]; //Display HUD
        
    }
    
    
}

//-----------------------------------------------------------------------

-(void) hideLoader {
    topView=nil;
    
    //[SVProgressHUD  dismiss];
  //  [MBProgressHUD hideAllHUDsForView:self.window animated:YES];
    [hud dismissAnimated:NO];
}

//-----------------------------------------------------------------------

-(void) setDictObj:(NSDictionary *) data forKey: (NSString*) strKey {
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//-----------------------------------------------------------------------

-(void) setStringObj:(NSString *) data forKey: (NSString*) strKey {
    
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:strKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

//-----------------------------------------------------------------------

-(NSString *) getStringObjfromKey:(NSString*) strKey {
    
    NSString *strObj = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    return strObj;
}

//-----------------------------------------------------------------------

-(NSString *) getCurrentName {
    NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];
    NSString *strname = [dictUserDetails objectForKey:@"userDisplayName"];
    return strname;
    
}

-(NSDictionary *) getUserData {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];
    
}

-(void) setCurrentRole :(int) roleId{
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d", roleId] forKey:@"UserRole"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(int) getCurrentRole {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"UserRole"] intValue];
}

//-----------------------------------------------------------------------

-(NSString *) getCurrentUserId {
    
    NSString *strCurrentUserID=[[NSUserDefaults standardUserDefaults] objectForKey:kuserDBID];
    return strCurrentUserID;
    
}

//-----------------------------------------------------------------------

-(NSString *) getCurrentUserGuid {
    
    NSString *strCurrentUserID=[[NSUserDefaults standardUserDefaults] objectForKey:kuserInfoID];
    return strCurrentUserID;
    
}

//-----------------------------------------------------------------------

-(NSString *) getCurrentUserEmail {
    
    NSString *strCurrentUserID=[[NSUserDefaults standardUserDefaults] objectForKey:kuserEmail];
    return strCurrentUserID;
    
}

//-----------------------------------------------------------------------

-(NSDictionary *) getDictObjfromKey:(NSString*) strKey {
    
    NSDictionary *Obj = [[NSUserDefaults standardUserDefaults] objectForKey:strKey];
    return Obj;
}

//-----------------------------------------------------------------------

-(void) checkConnection {
    
    if(![self connected]) {
        [self displayServerFailureMessage];
    }
    
}

//-----------------------------------------------------------------------

-(BOOL)connected {
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)&zeroAddress);
    if(reachability != NULL) {
        //NetworkStatus retVal = NotReachable;
        SCNetworkReachabilityFlags flags;
        if (SCNetworkReachabilityGetFlags(reachability, &flags)) {
            if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
            {
                // if target host is not reachable
                return NO;
            }
            
            if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
            {
                // if target host is reachable and no connection is required
                //  then we'll assume (for now) that your on Wi-Fi
                return YES;
            }
            
            if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
                 (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
            {
                // ... and the connection is on-demand (or on-traffic) if the
                //     calling application is using the CFSocketStream or higher APIs
                
                if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
                {
                    // ... and no [user] intervention is needed
                    return YES;
                }
            }
            
            if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
            {
                // ... but WWAN connections are OK if the calling application
                //     is using the CFNetwork (CFSocketStream?) APIs.
                return YES;
            }
        }
    }
    
    return NO;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    	[[Harpy sharedInstance] checkVersion];
    
    ProIcons = [[NSMutableDictionary alloc] init];
    AmenitiesIcons = [[NSMutableDictionary alloc] init];
    
    [self setProIcons];
    [self setAmenitiesIcons];
    
    BOOL isRated = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRated"];
    if(!isRated) {
        
        long usageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kUsageCounter];
        
        ++usageCounter;
        
        [[NSUserDefaults standardUserDefaults] setInteger:usageCounter forKey:kUsageCounter];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if(usageCounter%150==0) {
            // Show pop up
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rate ParTee"
                                                            message:@"If you enjoy using ParTee, would you mind taking a moment to rate it? It won't take more than a minute. Thanks for your support!" delegate:self cancelButtonTitle:nil otherButtonTitles: @"Rate ParTee",@"Remind me later",nil];
            alert.tag=121;
            [alert show];
            
        }
    }
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [FBSDKAppEvents activateApp];

    if(![self connected]) {
        [self displayServerFailureMessage];
        return;
    }
    
    if(![[AppDelegate sharedinstance] isUserLogIn]) {
        
        return;
    }
    
    if([[AppDelegate sharedinstance] isUserLogIn]) {
        
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        if([strlat length]==0)
        {
            [self setRootViewController:NO];
        }
        
    }

    [[UIApplication sharedApplication] setApplicationIconBadgeNumber: 0];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    [FBSDKAppEvents activateApp];
    
    
}

-(NSString*)getDirectory:(NSString*) strDirectoryName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directroyPath = nil;
    
    directroyPath = [documentsDirectory stringByAppendingPathComponent:strDirectoryName];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:directroyPath];
    
    NSError *error;
    
    if(!fileExists) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directroyPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:&error];
    }
    
    return directroyPath;
}

//-----------------------------------------------------------------------

-(BOOL) fileExists : (NSString*)filename  AtDir:(NSString*) strDirectoryName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *directroyPath = nil;
    directroyPath = [documentsDirectory stringByAppendingPathComponent:strDirectoryName];
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[directroyPath stringByAppendingPathComponent:filename]];
    return fileExists;
}

//-----------------------------------------------------------------------

- (UIImage*)getImage : (NSString*)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:name];
    UIImage *img = [UIImage imageNamed:getImagePath];
    return img;
}

//-----------------------------------------------------------------------

- (void)saveImage : (UIImage*)img withName : (NSString*)name {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:name]; //Add the file name
    NSData *pngData = UIImageJPEGRepresentation(img,1.f);
    [pngData writeToFile:filePath atomically:YES]; //Write the file
    
}


//-----------------------------------------------------------------------

- (void)saveFileData : (NSData*)data withFileName : (NSString*)name atDir:(NSString *) strDirectoryName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    
    NSString *directroyPath = nil;
    directroyPath = [documentsPath stringByAppendingPathComponent:strDirectoryName];
    
    NSString *filePath = [directroyPath stringByAppendingPathComponent:name]; //Add the file name
    [data writeToFile:filePath atomically:YES]; //Write the file
    
}

//-----------------------------------------------------------------------

-(NSString *) nullcheck:(NSString *) str {
    if (str== nil || str == (id)[NSNull null]) {
        
        return @"";
    }
    return str;
    
}

-(NSString *) nullcheckForReport:(NSString *) str {
    if (str== nil || str == (id)[NSNull null]) {
        
        return @"0";
    }
    return str;
    
}

//-----------------------------------------------------------------------

-(BOOL) checkSubstring:(NSString *) substring containedIn:(NSString*) string {
    
    string = [[AppDelegate sharedinstance] nullcheck:string];
    
    if ([string rangeOfString:substring].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}

-(NSInteger) getAge : (NSString*) strBday
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"dd/MM/yyyy"];
    
    NSDate *DateOfBirth=[format dateFromString:strBday];
    
    NSDate *currentTime = [NSDate date];
    
    
    NSLog(@"DateOfBirth======%@",DateOfBirth);
    
    long years = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                       fromDate:DateOfBirth
                                                         toDate:currentTime options:0]year];
    
    long months = [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth
                                                        fromDate:DateOfBirth
                                                          toDate:currentTime options:0]month];
    
   
    
    NSLog(@"Number of years: %ld",years);
    NSLog(@"Number of Months: %ld,",months);
    

    
    
    return years;
    // End of Method
}

#pragma mark - HarpyDelegate
- (void)harpyDidShowUpdateDialog
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidLaunchAppStore
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidSkipVersion
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyUserDidCancel
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)harpyDidDetectNewVersionWithoutAlert:(NSString *)message
{
    NSLog(@"%@", message);
}

- (void)setProIcons
{
    [QBRequest objectsWithClassName:@"ProIcons" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSMutableArray *arr = [objects mutableCopy];
        
        for(QBCOCustomObject *obj in arr)
        {
             [ProIcons setObject:[[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"IconUrl"]]  forKey:[(NSString*)[obj.fields objectForKey:@"class"] lowercaseString]];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

- (void)setAmenitiesIcons
{
    NSMutableDictionary *request = [[NSMutableDictionary alloc] init];
    [request setObject:@"class" forKey:@"sort_asc"];
    [QBRequest objectsWithClassName:@"AmenitiesIcon" extendedRequest:request successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSMutableArray *arr = [objects mutableCopy];
        
        for(QBCOCustomObject *obj in arr)
        {
            [AmenitiesIcons setObject:[obj.fields objectForKey:@"IconUrl"] forKey:[(NSString*)[obj.fields objectForKey:@"Amenities"] lowercaseString]];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

- (NSString *)getProIcons:(NSString *)key
{
    return [ProIcons objectForKey:[key lowercaseString]];
}

- (NSMutableDictionary *)getAllProIcons
{
    return ProIcons;
}

- (NSString *)getAmenitiesIcons:(NSString *)key
{
    return [AmenitiesIcons objectForKey:[key lowercaseString]];
}

- (NSMutableDictionary *)getAllAmenitiesIcons
{
    return AmenitiesIcons;
}


@end
