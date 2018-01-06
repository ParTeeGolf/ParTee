//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewUsersViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate> {

    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    NSMutableArray *arrDialogData;
    
    IBOutlet UISegmentedControl *myMatchesSegments;
    IBOutlet UISegmentedControl *proSegments;
    IBOutlet UISegmentedControl *golferSegments;
    IBOutlet UISegmentedControl *eventManagerSegments;

    NSMutableArray *arrConnections;
    NSMutableArray *arrCourses;
    NSMutableArray *arrUserCourses;
    
    int k;
    NSArray *arrBgImages,*arrFav;
    BOOL isPageRefreshing;

    NSArray *arrConnectionsTemp;

    int _currentPage;
    int _currentDialog;
    
    BOOL shouldLoadNext;
    IBOutlet UILabel *lblNotAvailable;

    IBOutlet UILabel *lblTitle;
    

    IBOutlet UIButton *btnSettingsBig;
    
    BOOL NearMe;
    BOOL Featured;
    BOOL Favorites;
    BOOL Custom;
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
    NSString *choosenUserId;
    
    NSMutableArray *totalParentIds;
    NSMutableArray *featuredParentIds;
    NSMutableArray *courseIds;
    NSMutableArray *userIds;
    
    IBOutlet UIView *doneView;
    IBOutlet UIPickerView *coursePicker;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property BOOL IsFriends;
@property BOOL IsPro;
@property int RoleId;
@property NSString *searchRoleId;

@end
