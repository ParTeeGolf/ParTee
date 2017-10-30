//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface MyMatchesViewController : UIViewController <SKProductsRequestDelegate, SKPaymentTransactionObserver,UITextFieldDelegate> {

    NSMutableArray *arrData;
    NSString *strProductId;
    
    BOOL isfullVersionPurchase;
    BOOL featurnedPro;
    long packageNumber;
    
    IBOutlet UITableView *priceTable;
}

@property (nonatomic, strong) NSString *productType;



@end
