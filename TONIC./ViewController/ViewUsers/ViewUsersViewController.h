//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewUsersViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    NSMutableArray *arrDialogData;
    NSMutableArray *arrFinalData;
    NSMutableArray *arrFinalUserData;
    NSMutableArray *arrFinalDialogData;

    NSMutableArray *arrConnections;
    
    int k;
    NSArray *arrBgImages,*arrFav;
    BOOL isPageRefreshing;

    IBOutlet UILabel *lblMessage;
    NSArray *arrConnectionsTemp;

    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;
    IBOutlet UIImageView *imgView4;
    IBOutlet UIView *viewMoreMatches;
    IBOutlet UIButton *btnMore;
    int _currentPage;
    int _currentDialog;
    
    BOOL shouldLoadNext;
    IBOutlet UILabel *lblNotAvailable;
    NSString *strIsMyMatches;
    IBOutlet UILabel *lblTitle;
    
    IBOutlet UIButton *btnSettingsSmall;
    IBOutlet UIButton *btnSettingsBig;
    
    IBOutlet UISegmentedControl *segmentControll;
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) NSString *strIsMyMatches;
@property BOOL IsPro;

@end
