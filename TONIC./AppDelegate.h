//
//  AppDelegate.h
//  SR-DIREKT
//
//  Created by Amolaksingh on 11/05/16.
//  Copyright © 2016 SR-DIREKT. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import <OneSignal/OneSignal.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>
#import "EditProfileViewController.h"
#import "YBHud.h"
#import "MPGNotification.h"
#import <CoreLocation/CoreLocation.h>
#import "Harpy.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,HarpyDelegate,QBChatDelegate,CLLocationManagerDelegate> {
    OneSignal *oneSignal;
    YBHud *hud;
    CLLocationManager *locationManager;
    NSString *strTitleNoti;
    NSString *strBodyNoti;
    UIView * topView;
    NSString *strlat;
    NSString *strlong;
    BOOL hasLink;
    QBCOCustomObject *delegateShareObject;
    QBChatDialog *dialog;
     int currentScreen;
    NSString *strIsMyMatches;
    int isOneSignalPush;
    NSString *strisDevelopment;
    QBChatDialog *sharedchatDialog;
    QBChat *sharedChat;
    QBChat *sharedChatInstance;
    MPGNotification *customnotification;
    
    NSString *strcustomnotificationtimer;
    NSString *strIsChatConnected;

    NSMutableArray *arrSharedOnlineUsers;
    NSMutableArray *arrContactListIDs;
    NSString *strRedirectScreen;
    
}

   @property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) CLLocationCoordinate2D commonone;

@property (strong, nonatomic)NSMutableArray *arrSharedOnlineUsers;
@property (strong, nonatomic) NSMutableArray *arrContactListIDs;
@property (strong, nonatomic)  NSString *strIsChatConnected;

-(NSString *) getCurrentName;
@property (strong,nonatomic)  UIView * topView;


@property (strong,nonatomic)   MPGNotification *customnotification;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) QBChatDialog *sharedchatDialog;
-(void) showLoaderForView:(UIView *) topView;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) OneSignal *oneSignal;
@property (strong, nonatomic) FBSDKLoginManager *login;
@property (strong, nonatomic) NSMutableDictionary *ProIcons;

@property (nonatomic,assign) BOOL isUpdate;
@property (nonatomic,assign) BOOL isBlocked;

@property (nonatomic,strong) NSString *strisDevelopment;
@property (nonatomic,strong) NSString *strcustomnotificationtimer;

@property (nonatomic,assign) int currentScreen;
@property (strong, nonatomic) QBChat *sharedChatInstance;

@property (nonatomic,strong) NSString *strPropertyId;
@property (nonatomic,strong) NSString *strIsMyMatches;

@property (nonatomic,strong) NSMutableDictionary  *dictReportData;
@property (nonatomic,strong) QBCOCustomObject *delegateShareObject;

@property (nonatomic,strong) QBChatDialog *dialog;

- (void)saveImage : (UIImage*)img withName : (NSString*)name;
- (UIImage*)getImage : (NSString*)name;
-(BOOL) isUserLogIn;
-(void)displayCustomNotificationWithTitle:(NSString *) strTitle andMessage:(NSString *) strMessage;
-(void)displayCustomNotification:(NSString *) strMessage;
-(NSString *) getCurrentUserEmail;
+(AppDelegate *)SharedDelegate;
+(AppDelegate*)sharedinstance;
-(NSString *) getCurrentUserId;
-(NSString *) getFullImgUrl:(NSString*) strImgName;
-(NSString *) getSlideFullImgUrl:(NSString*) strName;
-(NSString *) getFullAudioUrl:(NSString*) strImgName;
-(NSString *) getFullVideoUrl:(NSString*) strImgName;
-(BOOL) checkSubstring:(NSString *) substring containedIn:(NSString*) string;
-(NSString *) nullcheckForReport:(NSString *) str;
-(void)displayServerFailureMessage;
-(void)displayServerErrorMessage;
-(void) locationInit;
-(void)displayAlertMessage;
-(void)displayMessage:(NSString *) strMessage;
- (BOOL)connected;
-(void) checkConnection ;
-(BOOL) checkSubstring:(NSString *) substring containedIn:(NSString*) string;
-(NSDictionary *) getDictObjfromKey:(NSString*) strKey;
-(NSString *) getStringObjfromKey:(NSString*) strKey;
-(void) setStringObj:(NSString *) data forKey: (NSString*) strKey;
-(void) setDictObj:(NSDictionary *) data forKey: (NSString*) strKey;
-(void) showLoader;
-(void) hideLoader;
- (void)saveFileData : (NSData*)data withFileName : (NSString*)name atDir:(NSString *) strDirectoryName;
-(BOOL) fileExists : (NSString*)filename  AtDir:(NSString*) strDirectoryName;
-(NSString*)getDirectory:(NSString*) strDirectoryName;
-(BOOL) isUserLogIn;
-(void) setProIcons:(NSMutableDictionary*)proIcons;
-(NSData *) getProIcons:(NSString *)key;

-(NSInteger) getAge : (NSString*) strBday;
-(void) registerForNotifications;
-(NSString *) nullcheck:(NSString *) str;

@end

