//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "OBSlider.h"

@interface SettingsViewController : UIViewController <UITextFieldDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver> {

    IBOutlet UIButton *btnMale;
    IBOutlet UIButton *btnFemale;

    IBOutlet UITextField *nameTxtFld;
    IBOutlet UIButton *btnPush;
    QBCOCustomObject *object;
    NSArray *arrData;

    IBOutlet NSLayoutConstraint *saveBaseViewConstraints;
    IBOutlet UIView *SaveBaseView;
    IBOutlet UIView *locationBaseView;
    IBOutlet UIView *photoGraphBaseView;
    IBOutlet UISwitch *switchPhotograph;
    NSArray *arrTypeList;
    NSMutableArray *arrAgeList;
    NSMutableArray *arrHandicapList;
    
    QBCOCustomObject *object1;
    NSArray *arrData1;
    NSMutableArray *arrCityList;
    NSMutableArray *arrCityStateList;

//    NSMutableArray *tempArraySelcted,*userIdArray,*arrNetworkSelected;
     NSMutableArray *userIdArray,*arrNetworkSelected;
    IBOutlet UITableView *tblNetwork,*tblMembers;
    
    
    
    NSMutableArray *arrStateList;
    NSMutableArray *arrHomeCourseList;

    IBOutlet UIScrollView *scrollViewContainer;

    IBOutlet UISwitch *switchHandicap;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtAge;
    IBOutlet UITextField *txtType;
    IBOutlet UITextField *txtCourse;
    IBOutlet UITextField *txtState;
    IBOutlet UITextField *txtHandicap;
    IBOutlet UIPickerView *pickerView;
    IBOutlet UIView *minMaxView;
    /*********** ChetuChange **********/
    // Hide handicap segment as per suggestion after change to switch
    //  IBOutlet UISegmentedControl *btnNA;
    /*********** ChetuChange **********/
    IBOutlet UISegmentedControl *minMax;
    IBOutlet UIView *HandicapView;
    NSMutableArray *Gender;
    NSString *strPush;
    IBOutlet UIView *viewToolbar,*viewTable;
    NSMutableArray *arrHomeCoursesObjects;
    IBOutlet UIButton *btnAge,*btnType,*btnCity;
    int       buttonTapped;
    NSString *strFromScreen;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnDevOn;
    NSString *isDev;
    IBOutlet OBSlider *myObSliderOutlet;
    IBOutlet UILabel *lblDistanceValue;
    IBOutlet UILabel *lblTitle;
    int pickerOption;
}

@property (nonatomic,strong) NSString *cameFromScreen;
@property Boolean IsPro;

-(IBAction)maleTapped:(id)sender;
-(IBAction)femaleTapped:(id)sender;
-(IBAction)pushTapped:(id)sender;
-(IBAction)saveTapped:(id)sender;

-(IBAction)cityTapped:(id)sender;

@end
