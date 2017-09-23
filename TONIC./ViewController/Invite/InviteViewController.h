//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InviteViewController : UIViewController <UITextFieldDelegate> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    int _currentPage;
    BOOL isPageRefreshing;
    NSArray *arrConnections;
    NSArray *arrConnectionsTemp;

    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;
    IBOutlet UIImageView *imgView4;
    IBOutlet UIView *viewMoreMatches;
    IBOutlet UIButton *btnMore;
    
    IBOutlet UISegmentedControl *segmentInvitations;
    int segmentMode;
    
    IBOutlet UILabel *lblNotAvailable;
    QBCOCustomObject *courseObject;
    int isCourseLoaded;
    
    NSMutableArray *arrCourseData;
    
    NSString *strIsConnInvite;
}

@property (strong, nonatomic)  NSString *strIsConnInvite;
@property (strong, nonatomic) IBOutlet UITableView *tblList;

@end
