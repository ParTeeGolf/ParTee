//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import <MessageUI/MessageUI.h>
#import "EAIntroView.h"

@interface SettingsMainVC : UIViewController <EAIntroDelegate,MFMailComposeViewControllerDelegate,UITextFieldDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver> {



    IBOutlet UIButton *btnPush;
    QBCOCustomObject *object;
    NSArray *arrData;

    NSArray *arrTypeList;
    NSArray *arrAgeList;
    
    QBCOCustomObject *object1;
    NSArray *arrData1;
    NSMutableArray *arrCityList;

    NSMutableArray *tempArraySelcted,*userIdArray,*arrNetworkSelected;

    NSArray *arrStateList;
    IBOutlet UIScrollView *scrollViewContainer;

    NSString *strUserMale;
    NSString *strUserFeMale;

    NSString *strPush;

    
    int buttonTapped;
    NSString *strFromScreen;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnDevOn;

    NSString *isDev;
    
}

@property (nonatomic,strong) NSString *cameFromScreen;


-(IBAction)pushTapped:(id)sender;
-(IBAction)saveTapped:(id)sender;

@end
