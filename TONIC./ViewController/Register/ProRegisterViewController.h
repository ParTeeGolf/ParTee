//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SZTextView.h"
#import "BSKeyboardControls.h"

@interface ProRegisterViewController : UIViewController <UITextFieldDelegate,UITextViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate,BSKeyboardControlsDelegate> {

    IBOutlet UITextField *txtProType;
    IBOutlet UITextField *txtPhone;
    IBOutlet UITextField *txtWebsite;
    IBOutlet UITextField *txtAlternateProType;
    
    IBOutlet SZTextView *Achievements;
    IBOutlet SZTextView *Offerings;

    NSMutableArray *arrProTypeList;
    
    IBOutlet UIView *proTypeView;
    
    IBOutlet UIPickerView *pickerView;

    QBCOCustomObject *object;
  
    IBOutlet UIScrollView *scrollViewContainer;

    IBOutlet UIButton *btnSendRequest;
}

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@end
