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

    int _currentPage;
    
    
    NSInteger selectedRow;
    BOOL isFavCourse;
    BOOL shouldLoadNext;
    BOOL showOnyFav;
    
    QBCOCustomObject *sharedobj ;
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
    
    IBOutlet UIButton *btnSearchBig;
    IBOutlet UIButton *menuButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *mapButton;
    IBOutlet UIButton *addButton;
    IBOutlet UITableView *tblList;
    IBOutlet UILabel *lblNotAvailable;
    IBOutlet UILabel *lblScreenTitle;
    IBOutlet UISegmentedControl *segmentSpecials;
    
    NSMutableArray *arrCourses;
    NSMutableArray *arrEvents;
    NSMutableArray *arrCourseEvent;
    NSMutableArray *arrFavorites;
    NSMutableArray *arrData;
    NSMutableArray *arrCoursesData;
    NSMutableArray *arrPhotos;
    
    NSArray *arrConnections;
    NSArray *arrBgImages,*arrFav;

}

@property int DataType;
@property int roleId;
@property NSMutableArray *courseIds ;

@end
