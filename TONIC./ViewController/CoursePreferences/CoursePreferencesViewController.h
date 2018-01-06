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

@interface CoursePreferencesViewController : UIViewController <UITextFieldDelegate,SKProductsRequestDelegate, SKPaymentTransactionObserver> {

    IBOutlet UIButton *btnMale;
    IBOutlet UIButton *btnFemale;

    IBOutlet UIButton *btnPush;
    QBCOCustomObject *object;
    NSArray *arrData;

    NSMutableArray *arrTypeList;
    
    QBCOCustomObject *object1;
    NSArray *arrData1;
    NSMutableArray *arrCityList;
    NSMutableArray *arrCityStateList;

    NSMutableArray *tempArraySelcted,*userIdArray,*arrNetworkSelected;
    IBOutlet UITableView *tblNetwork,*tblMembers;

    NSMutableArray *arrStateList;
    NSMutableArray *arrHomeCourseList;
    NSMutableArray *arrNameList;
    NSMutableArray *arrzipcodeList;
    NSMutableArray *arramenitiesList;
    NSMutableArray *arrAgeList;
    NSMutableArray *arrHandicapList;

    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtType;
    IBOutlet UITextField *txtState;
    IBOutlet UITextField *txtCourseName;
    IBOutlet UITextField *txtCourseZipcode;
    IBOutlet UITextField *txtAmenities;
    IBOutlet UISwitch *favoriteSwitch;
    
    IBOutlet UITextField *txtCityEvent;
    IBOutlet UITextField *txtStateEvent;
    IBOutlet UITextField *txtCourseNameEvent;
    IBOutlet UITextField *txtCourseZipcodeEvent;
    IBOutlet UITextField *txtStartDate;
    IBOutlet UITextField *txtEndDate;
    
    IBOutlet UITextField *txtCityGolfer;
    IBOutlet UITextField *txtStateGolfer;
    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtCourseGolfer;
    IBOutlet UITextField *txtTypeGolfer;
    IBOutlet UITextField *txtHandicap;
    IBOutlet UISwitch *handicapSwitch;
    IBOutlet UIButton *handicapButton;
    IBOutlet UIView *handicapView;
    IBOutlet UIButton *btnNA;


    NSString *strUserMale;
    NSString *strUserFeMale;

    NSString *strPush;
    IBOutlet UIView *viewToolbar,*viewTable;
    IBOutlet UITextField *txtAge;
    NSMutableArray *arrHomeCoursesObjects;

    IBOutlet UIButton *btnAge,*btnType,*btnCity,*btnName,*btnCourseAmenities,*btnCourseZipcode;
    
    int buttonTapped;
    NSString *strFromScreen;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnDevOn;

    NSString *isDev;
    
    IBOutlet UIPickerView *pickerView;
    
    IBOutlet UIView *courseView;
    IBOutlet UIView *eventView;
    IBOutlet UIView *golferView;
    
    IBOutlet UILabel *searchTitle;
    IBOutlet UIDatePicker *datePicker;
    
    int dateOption;
    
    NSMutableArray *Gender;
    
    int pickerOption;
    
}

@property (nonatomic,strong) NSString *cameFromScreen;

@property int SearchType;


-(IBAction)pushTapped:(id)sender;
-(IBAction)saveTapped:(id)sender;

-(IBAction)cityTapped:(id)sender;

@end
