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

    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    NSMutableArray *arrCoursesData;

    NSArray *arrConnections;

    int k;
    int fromSegment;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblNotAvailable;
    IBOutlet UISegmentedControl *segmentSpecials;
    int segmentMode;
    int _currentPage;


    NSArray *arrConnectionsTemp;
    NSString *strIsMyCourses;
    IBOutlet UILabel *lblScreenTitle;
    BOOL shouldLoadNext;
    
    NSInteger selectedRow;
    BOOL isFavCourse;
    
    QBCOCustomObject *sharedobj ;
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    NSString *strlat;
    NSString *strlong;
    
    BOOL showOnyFav;
    

    IBOutlet UIButton *btnSearchBig;

}
@end
