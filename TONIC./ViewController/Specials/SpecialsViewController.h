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

@interface SpecialsViewController : UIViewController <UITextFieldDelegate,RNGridMenuDelegate> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UIImageView *imgViewUser1;
    IBOutlet UIImageView *imgViewUser2;
    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    NSMutableArray *arrCoursesData;

    NSArray *arrConnections;

    int k;
    int fromSegment;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;

    IBOutlet UIButton *btnMenu;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *lblNotAvailable;
    IBOutlet UISegmentedControl *segmentSpecials;
    int segmentMode;
    int _currentPage;

    IBOutlet UILabel *lblPoints;
    NSArray *arrConnectionsTemp;
    NSString *strIsMyCourses;
    IBOutlet UILabel *lblScreenTitle;
    BOOL shouldLoadNext;
    
    NSInteger selectedRow;
    BOOL isFavCourse;
    
    QBCOCustomObject *sharedobj ;
   /*********** ChetuChnage ************/
    IBOutlet UIView *loadRecordBaseV;
    IBOutlet NSLayoutConstraint *recordLoadBaseViewHeightConst;
    /*********** ChetuChnage ************/
    IBOutlet UIImageView *searchImgView;
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
    
    BOOL showOnyFav;
    
    IBOutlet UIButton *btnSearchSmall;
    IBOutlet UIButton *btnSearchBig;

}

@property (nonatomic,assign) int status;
@property(nonatomic,strong) NSString *strIsMyCourses;
@end
