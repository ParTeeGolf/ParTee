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
    NSArray *arrAgeList;
    
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
    
    
    IBOutlet UIScrollView *scrollViewContainer;

    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtAge;
    IBOutlet UITextField *txtType;
    IBOutlet UITextField *txtCourse;
    IBOutlet UITextField *txtState;
    
    IBOutlet UITextField *txtCourseName;
    IBOutlet UITextField *txtCourseZipcode;
    IBOutlet UITextField *txtAmenities;

    NSString *strUserMale;
    NSString *strUserFeMale;

    NSString *strPush;
    IBOutlet UIView *viewToolbar,*viewTable;
    NSMutableArray *arrHomeCoursesObjects;

    IBOutlet UIButton *btnAge,*btnType,*btnCity,*btnName,*btnCourseAmenities,*btnCourseZipcode;
    
    int buttonTapped;
    NSString *strFromScreen;
    IBOutlet UIButton *btnBack;
    IBOutlet UIButton *btnDevOn;

    NSString *isDev;
    
    IBOutlet UIPickerView *pickerView;
    
    int pickerOption;
    
}

@property (nonatomic,strong) NSString *cameFromScreen;


-(IBAction)pushTapped:(id)sender;
-(IBAction)saveTapped:(id)sender;

-(IBAction)cityTapped:(id)sender;

@end
