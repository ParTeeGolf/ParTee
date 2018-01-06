//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AdminViewController : UIViewController <UITextFieldDelegate,UIActionSheetDelegate> {

    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;

    IBOutlet UISegmentedControl *admindSegments;


    NSMutableArray *arrConnections;
    
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
    
    IBOutlet UILabel *expireLabel;
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
    
    NSMutableArray *parentIds;
    NSMutableArray *arrRoles;
    
    long segmentMode;
}

@property (strong, nonatomic) IBOutlet UITableView *tblList;
@property BOOL IsPro;

@end
