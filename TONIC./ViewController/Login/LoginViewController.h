//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "EAIntroView.h"
@import GooglePlacePicker;

@import GooglePlaces;

@interface LoginViewController : UIViewController <GMSAutocompleteViewControllerDelegate,EAIntroDelegate,BSKeyboardControlsDelegate,UITextFieldDelegate> {
    
    IBOutlet UITextField *txtEmail;
    IBOutlet UITextField *txtPwd;
    NSString *strlat;
    NSString *strlong;
    
    IBOutlet UIScrollView *scrollViewContainer;
    QBCOCustomObject *object;

    IBOutlet UIButton *btnLogin;
    IBOutlet UIButton *btnCreateAccount;
    IBOutlet UIButton *btnForgotPwd;
    
    int autocompletePlaceStatus;
}

@property (nonatomic, strong) BSKeyboardControls *keyboardControls;


@end
