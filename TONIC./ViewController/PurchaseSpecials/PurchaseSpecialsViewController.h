//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CVCell.h"
#import "RNGridMenu.h"
#import <QuartzCore/QuartzCore.h>
@interface PurchaseSpecialsViewController : UIViewController <RNGridMenuDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,UITextFieldDelegate> {
    BOOL isFavCourse;

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
    
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPoints;
    IBOutlet UILabel *lblExpiresOn;
    IBOutlet UILabel *lblAddress;
    IBOutlet UIImageView *imageUrl;
    IBOutlet UILabel *lblTitle;

    QBCOCustomObject *courseObject;
    QBCOCustomObject *userObject;
    QBCOCustomObject *otherUserObj;
    UICollectionView *collectionViewData;

    int status;

    NSString *strlat;
    NSString *strlong;
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;
    
    IBOutlet UIButton *btnPlus;
    
    IBOutlet UIButton *btnInfo;

    IBOutlet UIButton *btnRequest;

    IBOutlet UIButton *lblContactNum;
    IBOutlet UIButton *lblWebsite;
    IBOutlet UIButton *lblbooking;

    IBOutlet UILabel *lblForPrivate;

    IBOutlet UITextView *tvAmenities;
    
    IBOutlet UIButton *btnSendInviteSmall;
    IBOutlet UIButton *btnSendInviteBig;
    IBOutlet UIButton *btnFavImage;
    
    NSMutableArray *arrAmenities;
    
    IBOutlet UIButton *btnNext;
    IBOutlet UILabel *lblNotFound;
    
    IBOutlet UIView *proView;
    IBOutlet UITableView *proTable;
    
    NSMutableArray *arrData;

    
}
@property (nonatomic, strong) IBOutlet UICollectionView *collectionViewData;

@property (strong, nonatomic) IBOutlet UIButton *btnFavImage;

@property (nonatomic,assign) int status;

-(IBAction)viewUser:(id)sender;

-(IBAction)selectUser:(id)sender;

-(IBAction)bookingpressed:(id)sender;
-(IBAction)phonepressed:(id)sender;
-(IBAction)websitepressed:(id)sender;

@property (nonatomic,strong) QBCOCustomObject *userObject;
@property (nonatomic,strong) QBCOCustomObject *courseObject;

@end
