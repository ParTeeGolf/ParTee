//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController <UITextFieldDelegate> {

    IBOutlet UIImageView *imgViewBg;
    
    int k;
    NSArray *arrBgImages,*arrFav;
    QBCOCustomObject *dictUserData;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;

    IBOutlet UISegmentedControl *segmentGender;

    IBOutlet UIButton *btnABUSIVE;
    IBOutlet UIButton *btnINAPPROPRIATE;
    IBOutlet UIButton *btnSTOLEN;
    IBOutlet UIButton *btnSPAM;
    IBOutlet UIButton *btnadvertisement;

    int isAbusive;
    int isadvertisement;
    int isINAPPROPRIATE;
    int isSTOLEN;
    int isSPAM;
}
@property (nonatomic,strong)     QBCOCustomObject *dictUserData;
@property (nonatomic,strong) QBCOCustomObject *otherUserObject;

@property (nonatomic,strong)   NSArray *arrData;
@property (nonatomic,strong)   NSArray *arrConnections;

@property (nonatomic,strong) QBCOCustomObject *customShareObj;

-(IBAction)btnABUSIVEPressed:(id)sender;
-(IBAction)btnadvertisementPressed:(id)sender;

-(IBAction)btnINAPPROPRIATEPressed:(id)sender;
-(IBAction)btnSTOLENPressed:(id)sender;
-(IBAction)btnSPAMPressed:(id)sender;

-(IBAction)reportPressed:(id)sender;

@end
