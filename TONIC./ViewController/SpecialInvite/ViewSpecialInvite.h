//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewSpecialInvite : UIViewController <UITextFieldDelegate> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    NSArray *arrConnections;
    
    int k;
    NSArray *arrBgImages,*arrFav;
    BOOL isPageRefreshing;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;
    IBOutlet UIImageView *imgView4;
    IBOutlet UIView *viewMoreMatches;
    IBOutlet UIButton *btnMore;
    int _currentPage;
    
    IBOutlet UISegmentedControl *segmentGender;
    IBOutlet UILabel *lblNotAvailable;
    NSMutableArray *arrSelected;
    NSMutableArray *arrDialogData;
    NSMutableArray *arrFinalData;
    NSMutableArray *arrFinalUserData;
    
    NSMutableArray *arrFinalDialogData;
    int _currentDialog;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;

@end
