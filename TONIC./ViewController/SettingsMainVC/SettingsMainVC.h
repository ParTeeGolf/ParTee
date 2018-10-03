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

    IBOutlet UIView *supportBaseView;
    IBOutlet UIView *settingBaseView;
    IBOutlet UIButton *versionNextLbl;
    IBOutlet UIButton *versionBtn;
    IBOutlet UIView *versionNarrowView;
    IBOutlet UIButton *privacyBTn;
    IBOutlet UIButton *privacyNextBtn;
    IBOutlet UIView *privacyPolicyNarrowView;
    IBOutlet UIButton *tAcBtn;
    IBOutlet UIButton *tAcNextBtn;
    IBOutlet UIView *tacNarrowLineView;
    IBOutlet UIButton *faqBtnUp;
    IBOutlet UIButton *faqBtn;
    IBOutlet UIView *faqNarrowLineVeiw;
    IBOutlet UIButton *feedBackBtn;
    IBOutlet UIButton *feedBackNextBtn;
    IBOutlet UIView *feedbackNarrowlineView;
    IBOutlet UIButton *rateBtn;
    IBOutlet UIButton *rateNextBtn;
    IBOutlet UIView *rateNarrowLineView;
    IBOutlet UIButton *shareBtnp;
    IBOutlet UIButton *shareBtn;
    IBOutlet UIView *shareNarrowLineView;
    IBOutlet UIButton *walkthroughBtn;
    IBOutlet UIButton *walkthroughNextBtn;
    IBOutlet UIView *walktroughNarrowLineView;
    IBOutlet UILabel *LogoutLbl;
    IBOutlet UIButton *logoutBTn;
    IBOutlet UIView *VersionBaseView;
    IBOutlet UIView *privacyPolicyBaseVieqw;
    IBOutlet UIView *termsUseBaseView;
    IBOutlet UIView *faqBaseView;
    IBOutlet UIView *feedbackBaseview;
    IBOutlet UIView *rateBaseView;
    IBOutlet UIView *shareBaseview;
    IBOutlet UIView *walkThroughBaseView;
    IBOutlet UILabel *supportLbl;
    IBOutlet UIButton *restorePurchaseBtn;
    IBOutlet UIButton *restorePurchaseNextbtn;
    IBOutlet UIView *restorePurchaseNarrowLineView;
    IBOutlet UIView *restorePurchaseBaseView;
    IBOutlet UIButton *changePassBtn;
    IBOutlet UIButton *changePassNextBtn;
    IBOutlet UIView *changePassNarrowLineView;
    IBOutlet UIView *changePassBaseView;
    IBOutlet UIButton *notificationBtn;
    IBOutlet UIView *notificationNarrowLineView;
    IBOutlet UIView *notificationBaseView;
    IBOutlet UILabel *settinglbl;
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
