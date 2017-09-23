//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectssViewController : UIViewController <UITextFieldDelegate> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UIImageView *imgViewUser1;
    IBOutlet UIImageView *imgViewUser2;
    IBOutlet UITableView *tblList;
    NSMutableArray *arrData;
    NSArray *arrConnections;
    IBOutlet UIScrollView *scrollViewContainer;
    QBCOCustomObject *object;

    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;

    IBOutlet UISegmentedControl *segmentGender;
    IBOutlet UIButton *btnMenu;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *lblNotAvailable;
    
    IBOutlet UILabel *lblPoints;

    IBOutlet UILabel *lblWeeklyConnects;
    IBOutlet UILabel *lblPurchasedConnects;

}

@property (nonatomic,assign) int status;

-(IBAction)getMoreConnects:(id)sender;
@end
