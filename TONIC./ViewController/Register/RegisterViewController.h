//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "SZTextView.h"

@import GooglePlacePicker;

@import GooglePlaces;

@interface RegisterViewController : UIViewController <GMSAutocompleteViewControllerDelegate,BSKeyboardControlsDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    int autocompletePlaceStatus;

    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPwd;
    IBOutlet UITextField *txtBday;
    IBOutlet UITextField *txtState;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtZipCode;
    IBOutlet UITextField *txtHandicap;
    IBOutlet UITextField *txtHomeCourse;
    NSString *strHomeCourseID;
    
    IBOutlet SZTextView *tvInfo;
    NSInteger age ;
    NSArray *arrTypeList;
    NSMutableArray *arrCityList;
    NSMutableArray *arrStateList;
    NSMutableArray *arrHandicapList;
    NSMutableArray *arrHomeCourses;
    
    NSMutableArray *arrHomeCoursesObjects;
    NSString *strlat;
    NSString *strlong;

    NSString *strCurrentUserId;
    
    IBOutlet UIPickerView *pickerView;
    IBOutlet UIDatePicker *datePicker;
    QBCOCustomObject *object;
    NSArray *arrData;
    IBOutlet UIImageView *imgViewProfilePic;

    IBOutlet UIScrollView *scrollViewContainer;
    IBOutlet UISegmentedControl *segmentGender;

    IBOutlet UIButton *btnCreateAccount;
    IBOutlet UIButton *btnBack;
    NSString *strImgURLBase;

    IBOutlet UIButton *DoneBtn;
    IBOutlet UIImageView *doneBtnImg;
    int pickerOption;
    
    IBOutlet UIButton *btnCheckmark;

    IBOutlet UIView *narrowLineView2;
    IBOutlet UIView *narrowLineView1;
    IBOutlet UIButton *btnCheckBig;
    IBOutlet UIButton *checkMarkBtn;
    IBOutlet UIButton *privacyBtn;
    IBOutlet UIButton *agreeBtn;
    IBOutlet UIView *saveBaseVieqw;
    IBOutlet UIView *aboutBaseView;
    IBOutlet UIView *handicapBaseView;
    IBOutlet UIView *zipCodeBaseView;
    IBOutlet UIView *homeCourseBaseView;
    IBOutlet UIView *cityBaseView;
    IBOutlet UIView *stateBaseView;
    IBOutlet UIView *dobBaseView;
    IBOutlet UIView *pwdBaseView;
    IBOutlet UIView *mailBaseView;
    IBOutlet UIView *nameBaseView;
    IBOutlet UIButton *cameraBtn;
}
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (retain,nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;


@end
