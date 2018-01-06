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

@interface EditEventViewController : UIViewController <BSKeyboardControlsDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    
    IBOutlet UITextField *txtStartDate;
    IBOutlet UITextField *txtEndDate;
    
    IBOutlet SZTextView *description;
    

    int imageChosen;

    NSDateFormatter *dateFormat;
    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIPickerView *picker;
    
    IBOutlet UIView *dateView;
    IBOutlet UIView *dailyView;
    
    IBOutlet UITextField *eventType;
    IBOutlet UITextField *eventTitle;

    IBOutlet UIImageView *imgViewProfilePic;

    IBOutlet UIScrollView *scrollViewContainer;
    

    IBOutlet UIButton *btnCreateAccount;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *titleLabel;
    
    IBOutlet UIButton *sunday;
    IBOutlet UIButton *monday;
    IBOutlet UIButton *tuesday;
    IBOutlet UIButton *wednesday;
    IBOutlet UIButton *thursday;
    IBOutlet UIButton *friday;
    IBOutlet UIButton *saturday;
    IBOutlet UIButton *backButton;
    NSMutableArray *week;
    NSString *strImgURLBase;

    int dateOption;
}
@property (strong, nonatomic) MBProgressHUD *HUD;

@property (retain,nonatomic) UIImagePickerController *imagePickerController;

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (nonatomic, strong) QBCOCustomObject *object;
@property (nonatomic, strong) NSString *courseId;
@property BOOL IsEdit;


@end
