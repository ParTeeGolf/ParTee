//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"

@interface ProfileViewController : UIViewController <QBChatDelegate,UITextFieldDelegate,BSKeyboardControlsDelegate,UITextFieldDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIActionSheetDelegate, UIImagePickerControllerDelegate> {

    IBOutlet UIImageView *imgViewBg;
    
    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    NSMutableArray *arrTemp;
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;
    int status; 
    IBOutlet UISegmentedControl *segmentGender;
    NSArray *arrData;

    IBOutlet UIScrollView *scrollViewContainer;
    
    IBOutlet UITextField *txtDisplayName;
    IBOutlet UITextField *txtBday;
    IBOutlet UITextField *txtCity;
    IBOutlet UITextField *txtOccupation;
    IBOutlet UIDatePicker *datePicker;

    NSDictionary *dictUserData;
    NSString *strFName;
    NSString *strLName;
    IBOutlet UILabel *lblPoints;

    NSString *strImgURLL;
    NSString *strImgURLR;
    NSString *strImgURLBase;
    QBCOCustomObject *object;
    int currentImage;
    BOOL needToSave;
}

@property (retain,nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) BSKeyboardControls *keyboardControls;

@property (nonatomic,assign) int status;
@property (nonatomic,strong) QBCOCustomObject *object;


-(IBAction)genderChanged:(id)sender;

-(IBAction)picLPressed:(id)sender;
-(IBAction)picRPressed:(id)sender;
-(IBAction)picBasePressed:(id)sender;


@end
