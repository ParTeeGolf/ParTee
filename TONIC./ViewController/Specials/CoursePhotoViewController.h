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

@interface CoursePhotoViewController : UIViewController <UITextFieldDelegate,RNGridMenuDelegate> {

    IBOutlet UITableView *tblList1;
    NSMutableArray *arrData1;


}

@property(nonatomic,strong) NSString *courseID;
@end
