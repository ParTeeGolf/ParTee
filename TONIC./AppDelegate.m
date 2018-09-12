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
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "MyMatchesViewController.h"
#import "SpecialsViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "PurchasedViewController.h"
#import "ViewProfileViewController.h"
#import "DemoMessagesViewController.h"
#import "ViewUsersViewController.h"
#import "RegisterViewController.h"
#import "PreviewProfileViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "InviteViewController.h"
#import "MoreViewController.h"
#import "CoursePreferencesViewController.h"
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
@synthesize strIsMyMatches;
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

-(void) temp {
 

}

//-----------------------------------------------------------------------

#pragma mark - demoController

//-----------------------------------------------------------------------

- (UIViewController *) demoController
{
   

    if([[AppDelegate    sharedinstance] isUserLogIn]) {
        
//        ViewUsersViewController *viewController    = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
//        ((ViewUsersViewController*)viewController).strIsMyMatches=@"1";
////
//       return viewController;
        
      //  return [[InviteViewController alloc] initWithNibName:@"InviteViewController" bundle:nil];

 //    return [[CoursePreferencesViewController alloc] initWithNibName:@"CoursePreferencesViewController" bundle:nil];
        
    SpecialsViewController *svc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
    svc.strIsMyCourses=@"0";
     return svc;
        
        //        return [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
        
 
        
        
        return [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
        
        
        return [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:nil];
        
        DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
        return vc;
        
        // return [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    }
    
    return [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    
    return [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
    
    
    //return [[InviteViewController alloc] initWithNibName:@"InviteViewController" bundle:nil];
    
    //  return [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
    
    //return [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
    
    
    // return [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    
    
    //return [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    // return [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
    
    //return [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
    
    //    return [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
    
    //    return [[PurchasedViewController alloc] initWithNibName:@"PurchasedViewController" bundle:nil];
    
    // return [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    //    return [[ChatVC alloc] initWithNibName:@"ChatVC" bundle:nil];
    
    //  DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    //  [self.navigationController pushViewController:vc animated:YES];
    
    // return vc;//[[DemoMessagesViewController alloc] initWithNibName:@"DemoMessagesViewController" bundle:nil];
    
}

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
    
    _courseOptionSelected = @"0";
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
    
    strIsMyMatches=@"1";
    
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
    [self setRootViewController];
    [[Harpy sharedInstance] setPresentingViewController:_window.rootViewController];
    [[Harpy sharedInstance] setDelegate:self];
    [[Harpy sharedInstance] setShowAlertAfterCurrentVersionHasBeenReleasedForDays:1];
    [[Harpy sharedInstance] setDebugEnabled:true];

    	[[Harpy sharedInstance] setAlertType:HarpyAlertTypeForce];
    [self temp];
    
    [self locationInit];
    
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
   
      
   
    
     if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
           [locationManager requestWhenInUseAuthorization];
     }else {
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
     }
     [locationManager startUpdatingLocation];
   
    
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
  //   [self checkLocationStatus];
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

//
//    NSString *notificationBody = [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
//    NSString *notificationTitle= [[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"title"];
//
//    UIApplicationState state = [application applicationState];
//
//    if (state == UIApplicationStateActive) {
//
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:notificationTitle message:notificationBody delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//            [alertView show];
//
//    }
//
//    if([[userInfo objectForKey:@"custom"] valueForKey:@"a"] != nil) {
//
//        NSDictionary *dict =[[userInfo objectForKey:@"custom"] valueForKey:@"a"];
//
//        if([dict valueForKey:@"link"] != nil) {
//
//            NSString *strLink = [dict objectForKey:@"link"];
//
//            hasLink=YES;
//
//            [[NSUserDefaults standardUserDefaults] setObject:strLink forKey:knotificationlink];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//
//            NSLog(@"customKey: %@", strLink);
//
//            [self setRootViewController];
//
//        }
//
//    }
//
//}

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

-(void) setRootViewController {
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.navigationController=[[UINavigationController alloc] initWithRootViewController:[self demoController]];
    
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
    
    if([[AppDelegate sharedinstance] getStringObjfromKey:kuserEmail].length == 0)
        return NO;
    
    return YES;
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

- (UINavigationController *)navigationController {
    return [[UINavigationController alloc]
            initWithRootViewController:[self demoController]];
}



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
                
                if([[AppDelegate sharedinstance] checkSubstring:@"has invited you for a golf course" containedIn:strMessage]) {
                    // redirect user to invitation screen
                    
                    strRedirectScreen = kRedirectToInvitationCourse;
                    vc = [[InviteViewController alloc] initWithNibName:@"InviteViewController" bundle:nil];
                    ((InviteViewController*)vc).strIsConnInvite=@"0";

                }
                else if([[AppDelegate sharedinstance] checkSubstring:@"has invited you to connect" containedIn:strMessage]) {
                    // redirect user to invitation screen
                    
                    strRedirectScreen = kRedirectToInvitationUser;
                    vc = [[InviteViewController alloc] initWithNibName:@"InviteViewController" bundle:nil];
                   ((InviteViewController*)vc).strIsConnInvite=@"1";
                    
                }
                else if([[AppDelegate sharedinstance] checkSubstring:@"has accepted your request for a course" containedIn:strMessage]) {
                    // redirect user to My courses
                    
                    strRedirectScreen = kRedirectToMyCourses;
                    
                    vc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                    ((SpecialsViewController*)vc).strIsMyCourses=@"1";

                }
                else if([[AppDelegate sharedinstance] checkSubstring:@"has accepted your connection request" containedIn:strMessage]) {
                    // redirect user to My friends
                    
                    strRedirectScreen = kRedirectToMyFriends;
                    
                    vc   = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                    ((ViewUsersViewController*)vc).strIsMyMatches=@"1";
                }
                else {
                    // redirect user to my friends screen
                    strRedirectScreen = kRedirectToMyFriends;
                    
                    vc   = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                    ((ViewUsersViewController*)vc).strIsMyMatches=@"1";
                    
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

//-----------------------------------------------------------------------

-(NSString *) getCurrentUserId {
    
    NSString *strCurrentUserID=[[NSUserDefaults standardUserDefaults] objectForKey:kuserDBID];
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
    
    [QBRequest objectsWithClassName:@"ProIcons" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSMutableArray *arr = [objects mutableCopy];
        
        NSMutableDictionary *proIcons = [[NSMutableDictionary alloc] init];
        
        for(QBCOCustomObject *obj in arr)
        {
            
            NSString *class = [obj.fields objectForKey:@"class"];
            
            NSString *uid = obj.ID;
            
            bool reload = [arr indexOfObject:obj] + 1 == [arr count];
            
            [QBRequest downloadFileFromClassName:@"ProIcons" objectID:uid fileFieldName:@"icon"
                                    successBlock:^(QBResponse *response, NSData *loadedData) {
                                        [proIcons setObject:loadedData forKey:class];
                                        if(reload)
                                        {
                                            [self setProIcons:proIcons];
                                        }
                                        
                                    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                        // handle progress
                                    } errorBlock:^(QBResponse *error) {
                                        // error handling
                                        NSLog(@"Response error: %@", [error description]);
                                    }];
            
            
            
            
        }
        
        
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
    BOOL isRated = [[NSUserDefaults standardUserDefaults] boolForKey:@"isRated"];
    if(!isRated) {
        
        int usageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kUsageCounter];
        
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
    
//    for(NSString* family in [UIFont familyNames]) {
//        NSLog(@"%@", family);
//        for(NSString* name in [UIFont fontNamesForFamilyName: family]) {
//            NSLog(@"  %@", name);
//        }
//    }
    
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
            
            if([[AppDelegate sharedinstance].sharedChatInstance isConnected]) {
                [[AppDelegate sharedinstance].sharedChatInstance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
                    
                    [[AppDelegate sharedinstance] setStringObj:@"" forKey:kuserEmail];
                    
                    LoginViewController *loginView;
                    
                    loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    
                    self.navigationController=[[UINavigationController alloc] initWithRootViewController:[self demoController]];
                    SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
                    
                    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                                    containerWithCenterViewController: self.navigationController
                                                                    leftMenuViewController:leftMenuViewController
                                                                    rightMenuViewController:nil];
                    container.panMode=NO;

                    self.navigationController.navigationBarHidden=YES;
                    [self.navigationController.navigationBar setTranslucent:NO];
                    self.window.rootViewController = container;
                }];
            }
            else {
                [[AppDelegate sharedinstance] setStringObj:@"" forKey:kuserEmail];
                
                LoginViewController *loginView;
                
                loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                
                self.navigationController=[[UINavigationController alloc] initWithRootViewController:[self demoController]];
                SideMenuViewController *leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
                
                MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                                containerWithCenterViewController: self.navigationController
                                                                leftMenuViewController:leftMenuViewController
                                                                rightMenuViewController:nil];
                container.panMode=NO;
                
                self.navigationController.navigationBarHidden=YES;
                [self.navigationController.navigationBar setTranslucent:NO];
                self.window.rootViewController = container;

                
            }
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
    
    NSInteger years = [[[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                       fromDate:DateOfBirth
                                                         toDate:currentTime options:0]year];
    
    NSInteger months = [[[NSCalendar currentCalendar] components:NSCalendarUnitMonth
                                                        fromDate:DateOfBirth
                                                          toDate:currentTime options:0]month];
    
   
    
    NSLog(@"Number of years: %d",years);
    NSLog(@"Number of Months: %d,",months);
    

    
    
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

- (void)setProIcons:(NSMutableDictionary *)proIcons
{
    ProIcons = proIcons;
}

- (NSData *)getProIcons:(NSString *)key
{
    return [ProIcons objectForKey:key];
}


@end
