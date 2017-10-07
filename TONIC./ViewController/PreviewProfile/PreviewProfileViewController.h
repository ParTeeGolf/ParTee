//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BSKeyboardControls.h"
#import "SZTextView.h"

@interface PreviewProfileViewController : UIViewController <UIActionSheetDelegate> {
    NSArray *arrConnections;

    IBOutlet UIButton *lblHomecourse;

    QBCOCustomObject *dictUserData;

    IBOutlet UIImageView *imgViewProfilePic;
    IBOutlet UIImageView *imgBadge;

    IBOutlet UIScrollView *scrollViewContainer;
    
    IBOutlet UIButton *btnOptions;
    IBOutlet UIButton *btnOptionsBig;

    NSString *strImgURLBase;
    
    IBOutlet UIButton *btnAdd;
    IBOutlet UIButton *btnAddBg;
    IBOutlet UILabel *lblScreenName;
    IBOutlet UITextView *email;
    IBOutlet UITextView *achievments;
    IBOutlet UITextView *offering;
    IBOutlet UITextView *bio;
    IBOutlet UISegmentedControl *proView;

}
@property (nonatomic,strong) QBChatDialog *sharedChatDialog;
@property (nonatomic,strong) QBCOCustomObject *otherUserObject;

@property (nonatomic,strong)   NSArray *arrConnections;

@property (strong,nonatomic) NSString *strCameFrom;
@property (strong,nonatomic) NSString *strEmailOfUser;
@property (strong,nonatomic) NSString *userID;
@property (strong,nonatomic) NSString *courseName;

@property (strong, nonatomic) MBProgressHUD *HUD;

@end
