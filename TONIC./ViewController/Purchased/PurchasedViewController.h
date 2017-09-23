//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PurchasedViewController : UIViewController <UITextFieldDelegate> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UIImageView *imgViewUser1;
    IBOutlet UIImageView *imgViewUser2;
    IBOutlet UIScrollView *scrollViewContainer;

    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;

    IBOutlet UISegmentedControl *segmentGender;
    QBCOCustomObject *shareObject;
    
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPoints;
    IBOutlet UILabel *lblExpiresOn;
    IBOutlet UILabel *lblAddress;
    IBOutlet UIImageView *imageUrl;
    IBOutlet UILabel *lblTitle;
}

@property (nonatomic,strong) QBCOCustomObject *shareObject;

@end
