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

@interface EditProfileViewController : UIViewController <BSKeyboardControlsDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate,GMSAutocompleteViewControllerDelegate, UIPickerViewDelegate> {
    
    IBOutlet UITextField *txtName;
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPwd;
    IBOutlet UITextField *txtRePwd;
    IBOutlet UITextField *txtBday;
    IBOutlet UITextField *txtState;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtHandicap;
    IBOutlet SZTextView *tvInfo;
    IBOutlet UIView *viewSave;
    NSString *strHomeCourseID;

    NSMutableArray *arrHomeCourses;
    
    NSMutableArray *arrHomeCoursesObjects;
    
    IBOutlet UITextField *txtHomeCourse;
    
    QBCOCustomObject *object;
    NSArray *arrData;
    
    NSArray *arrTypeList;
    NSMutableArray *arrCityList;
    NSMutableArray *arrStateList;
    NSMutableArray *arrHandicapList;

    int imageChosen;

    IBOutlet UIPickerView *pickerView;
    IBOutlet UIDatePicker *datePicker;

    IBOutlet UIImageView *imgViewProfilePic;

    IBOutlet UIScrollView *scrollViewContainer;
    IBOutlet UISegmentedControl *segmentGender;

    IBOutlet UIButton *btnCreateAccount;
    IBOutlet UIButton *btnBack;
    NSString *strImgURLBase;

    IBOutlet UIButton *saveButton;
    IBOutlet UIButton *proButton;
    
    IBOutlet UIView *registerView;
    IBOutlet UIView *editView;
    
    IBOutlet UIButton *menu;
    IBOutlet UIButton *preview;
    IBOutlet UIButton *doneButton;
    IBOutlet UIButton *btnCheckmark;
    
    IBOutlet UILabel *titleLabel;
    NSString *strlat;
    NSString *strlong;
    NSString *strCurrentUserId;
    int autocompletePlaceStatus;
    int pickerOption;
    NSDateFormatter *dateFormat;
    
    IBOutlet UIView *cityView;
    IBOutlet UIView *homeCourseView;
}
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (retain,nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;


@end
