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

    NSMutableArray *arrConnections;
    
    int k;
    NSArray *arrBgImages,*arrFav;
    BOOL isPageRefreshing;

    NSArray *arrConnectionsTemp;

    int _currentPage;
    int _currentDialog;
    
    BOOL shouldLoadNext;
    IBOutlet UILabel *lblNotAvailable;
    NSString *strIsMyMatches;
    IBOutlet UILabel *lblTitle;
    

    IBOutlet UIButton *btnSettingsBig;
    
    
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
    
    long segmentMode;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property (strong, nonatomic) NSString *strIsMyMatches;
@property BOOL IsPro;

@end
