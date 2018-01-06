//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RNGridMenu.h"
#import <QuartzCore/QuartzCore.h>

@interface EditAmenitiesViewController : UIViewController <UITextFieldDelegate,RNGridMenuDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate> {

    IBOutlet UITableView *tblList1;
    NSMutableArray *arrCurrentAmenities;
    NSMutableArray *arrAmenities;
    IBOutlet UIButton *addButton;
    IBOutlet UIButton *backButton;

}

@property(nonatomic,strong) NSString *courseID;
@property long sequence;
@end
