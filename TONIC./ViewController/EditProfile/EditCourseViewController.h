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

@interface EditCourseViewController : UIViewController <BSKeyboardControlsDelegate,UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate> {
    
    IBOutlet UITextField *Phone;
    IBOutlet UITextField *Website;
    IBOutlet UITextField *TeeTimes;
    IBOutlet UITextField *Scorecard;
    IBOutlet UITextField *NumberOfHoles;
    
    IBOutlet SZTextView *description;
    IBOutlet SZTextView *News;


    IBOutlet UIDatePicker *datePicker;
    IBOutlet UIPickerView *picker;
    IBOutlet UIView *dateView;
    IBOutlet UIView *dailyView;
    

    IBOutlet UIScrollView *scrollViewContainer;
    

    IBOutlet UIButton *btnCreateAccount;
    IBOutlet UIButton *backButton;

}
@property (strong, nonatomic) MBProgressHUD *HUD;



@property (nonatomic, strong) BSKeyboardControls *keyboardControls;
@property (nonatomic, strong) QBCOCustomObject *object;


@end
