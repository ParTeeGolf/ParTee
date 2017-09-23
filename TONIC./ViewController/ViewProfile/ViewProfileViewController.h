//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewProfileViewController : UIViewController <UITextFieldDelegate,QBChatDelegate> {

    IBOutlet UIImageView *imgViewBg;
    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    IBOutlet UIScrollView *scrollViewContainer;

    IBOutlet UIButton *btncircle1;
    IBOutlet UIButton *btncircle2;
    IBOutlet UIButton *btncircle3;

    IBOutlet UIView *viewProfile;
    IBOutlet UIButton *btnMore;
    
    IBOutlet UIImageView *imgViewOuter;
    IBOutlet UIButton *btnLblNameOuter;

    IBOutlet UIButton *btnMutualFriends;
    
    IBOutlet UIView *viewMutualFriends;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;
    QBCOCustomObject *customShareObj;
    IBOutlet UIButton *btnLblName;
    IBOutlet UIButton *btnLblOccupation;
    BOOL isMyMatch;
    NSArray *arrData;
    NSArray *arrConnections;
}

@property (strong, nonatomic) MBProgressHUD *HUD;

@property (nonatomic,strong)   NSArray *arrData;
@property (nonatomic,strong)   NSArray *arrConnections;

@property (nonatomic,strong) QBCOCustomObject *customShareObj;
@property (nonatomic,assign) BOOL isMyMatch;

-(IBAction)viewProfilePressed:(id)sender;
-(IBAction)blockReportPressed:(id)sender;

-(IBAction) voteForCity :(id)sender;

@end
