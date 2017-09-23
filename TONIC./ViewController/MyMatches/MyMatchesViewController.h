//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MyMatchesViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver,UITextFieldDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout> {

    IBOutlet UIImageView *imgViewBg;
    IBOutlet UIScrollView *scrollViewContainer;

    int k;
    NSArray *arrBgImages,*arrFav;

    IBOutlet UILabel *lblMessage;
    
    IBOutlet UIImageView *imgView1;
    IBOutlet UIImageView *imgView2;
    IBOutlet UIImageView *imgView3;
    IBOutlet UIImageView *imgView4;
    IBOutlet UIView *viewMoreMatches;
    IBOutlet UIButton *btnMore;
    NSMutableArray *arrData;
    UICollectionView *collectionViewData;
    IBOutlet UISegmentedControl *segmentGender;
    NSArray *arrConnections;
    NSArray *arrConnectionsTemp;

    IBOutlet UILabel *lblNotAvailable;
    
    NSString *strProductId;
    BOOL isFromConnects;
    IBOutlet UILabel *lblTitle;

    BOOL isfullVersionPurchase;
    
    
    IBOutlet UIButton *btnPackageTitle1;
    IBOutlet UIButton *btnPackageTitle2;
    IBOutlet UIButton *btnPackageTitle3;
    IBOutlet UIButton *btnPackageTitle4;

    int packageNumber;
}

-(IBAction)btnPack1Pressed:(id)sender;
-(IBAction)btnPack2Pressed:(id)sender;
-(IBAction)btnPack3Pressed:(id)sender;
-(IBAction)btnPack4Pressed:(id)sender;

@property (nonatomic,assign) BOOL isFromConnects;

@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionViewData;


@end
