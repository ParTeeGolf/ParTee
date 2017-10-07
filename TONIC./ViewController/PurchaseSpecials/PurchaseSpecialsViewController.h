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

    
    IBOutlet UIScrollView *scrollViewContainer;

    int k;
    NSArray *arrBgImages,*arrFav;
    
    IBOutlet UILabel *lblName;
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
    
    IBOutlet UIButton *btnSendInviteBig;
    IBOutlet UIButton *btnFavImage;
    
    NSMutableArray *arrAmenities;
    NSMutableArray *arrEvents;
    
    IBOutlet UIView *proView;
    IBOutlet UITableView *proTable;
    
    IBOutlet UIView *basicView;
    IBOutlet UIView *amenitiesView;
    IBOutlet UITableView *amenitiesTable;
    IBOutlet UIView *eventsView;
    IBOutlet UITableView *eventsTable;
    IBOutlet UITextView *aboutTextView;
    
    NSMutableArray *arrData;

    
}


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
