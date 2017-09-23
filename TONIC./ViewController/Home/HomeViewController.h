//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController <UITextFieldDelegate> {

    IBOutlet UIImageView *imgViewBg;
    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    IBOutlet UIScrollView *scrollViewContainer;

    IBOutlet UIButton *btncircle1;
    IBOutlet UIButton *btncircle2;
    IBOutlet UIButton *btncircle3;

    IBOutlet UIView *viewLocation;
  
    IBOutlet UIButton *btnLblName;
    IBOutlet UIButton *btnLblOccupation;

    IBOutlet UILabel *lblPoints;
    
    UIImage *img1;
    UIImage *img2;
    UIImage *img3;

    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;

}


-(IBAction) voteForCity :(id)sender;

@end
