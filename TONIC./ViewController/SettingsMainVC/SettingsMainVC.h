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

    IBOutlet UIButton *btnMale;
    IBOutlet UIButton *btnFemale;

    IBOutlet UIButton *btnPush;
    QBCOCustomObject *object;
    NSArray *arrData;

    NSArray *arrTypeList;
    NSArray *arrAgeList;
    
    QBCOCustomObject *object1;
    NSArray *arrData1;
    NSMutableArray *arrCityList;

    NSMutableArray *tempArraySelcted,*userIdArray,*arrNetworkSelected;
    IBOutlet UITableView *tblNetwork,*tblMembers;

    NSArray *arrStateList;
    IBOutlet UIScrollView *scrollViewContainer;

    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtAge;
    IBOutlet UITextField *txtType;

    NSString *strUserMale;
    NSString *strUserFeMale;

    NSString *strPush;
    IBOutlet UIView *viewToolbar,*viewTable;

    IBOutlet UIButton *btnAge,*btnType,*btnCity;
    
    int buttonTapped;
    NSString *strFromScreen;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnDevOn;

    NSString *isDev;
    
}
@property(nonatomic,weak) IBOutlet EAIntroView *introView;
@property (nonatomic,strong) NSString *cameFromScreen;

-(IBAction)maleTapped:(id)sender;
-(IBAction)femaleTapped:(id)sender;
-(IBAction)pushTapped:(id)sender;
-(IBAction)saveTapped:(id)sender;

-(IBAction)cityTapped:(id)sender;

@end
