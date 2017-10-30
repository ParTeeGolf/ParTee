//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MyMatchesViewController.h"
#import "CVCell.h"
#import "cell_ViewPrices.h"
#define kLimit @"100"
#import "ViewUsersViewController.h"
@interface MyMatchesViewController ()

@end

@implementation MyMatchesViewController
@synthesize productType;

NSMutableArray *colorArr;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    colorArr = [[NSMutableArray alloc] init];
    [colorArr addObject:[UIColor cyanColor]];
    [colorArr addObject:[UIColor yellowColor]];
    [colorArr addObject:[UIColor purpleColor]];
    [colorArr addObject:[UIColor greenColor]];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void) viewWillAppear:(BOOL)animated {
    
     [priceTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self getProduct];
}

-(void) getProduct {
    
    arrData = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:productType forKey:@"Type"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"Products" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        
        arrData = [objects mutableCopy];
         [priceTable reloadData];
       
        [[AppDelegate sharedinstance] hideLoader];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(IBAction)notNowPressed:(id)sender {
            
            [self.navigationController popViewControllerAnimated:NO];

}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark - IAP

//-----------------------------------------------------------------------

-(void) purchaseCall {
    
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        //If you have more than one in-app purchase, and would like
        //to have the user purchase a different product, simply define
        //another function and replace kRemoveAdsProductIdentifier with
        //the identifier for the other product
        
        [self.view makeToast:@"You will get confirmation after purchase"
                    duration:1.0
                    position:CSToastPositionCenter];

        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:strProductId]];

        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
        //this is called the user cannot make payments, most likely due to parental controls
        
    }
}

//-----------------------------------------------------------------------

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    long count = [response.products count];
    
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];

    }
    else if(!validProduct){
        NSLog(@"No products available");
        [[AppDelegate sharedinstance] displayMessage:@"No products available"];
        
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (IBAction)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (IBAction) restore{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];

}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    NSLog(@"%@",error);
    
    [[AppDelegate sharedinstance] displayMessage:error.localizedDescription];;
    
}
    
- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            
            isfullVersionPurchase=YES;
            
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];

            break;
        }
    }
}



- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                [self.view makeToast:@"Purchasing in progress"
                            duration:1.0
                            position:CSToastPositionCenter];
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                    [self.view makeToast:@"Transaction got cancelled"
                                duration:1.0
                                position:CSToastPositionCenter];
                    break;

                    
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

//-----------------------------------------------------------------------

- (void) doRemoveAds {
    
    if([productType isEqualToString:@"Connects"])
    {
        if(isfullVersionPurchase)
        {
            
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"UserInfo";
            object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
            
            [object.fields setObject:[NSString stringWithFormat:@"%d",1]  forKey:@"userFullMode"];
            
            //    [object.fields setObject:[NSString stringWithFormat:@"%d",currentPurchasedConnects]  forKey:@"userPurchasedConnects"];
            
            [[AppDelegate sharedinstance] showLoader];
            
            [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                // object updated
                
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIAPFULLVERSION];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                [dictUserData setObject:[NSString stringWithFormat:@"%d",1] forKey:@"userFullMode"];
                [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[AppDelegate sharedinstance] displayMessage:@"Successfully upgraded to full version"];
                [[AppDelegate sharedinstance] hideLoader];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
                
                UIViewController *viewController;
                viewController    = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
                ((ViewUsersViewController*)viewController).strIsMyMatches=@"0";
                
                UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:viewController];
                navigationController.viewControllers = controllers;
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
                
                
            } errorBlock:^(QBResponse *response) {
                
                [[AppDelegate sharedinstance] hideLoader];
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
        }
        else {
            
            int currentPurchasedConnects = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userPurchasedConnects"] intValue];
            
            if(packageNumber==1) {
                currentPurchasedConnects = currentPurchasedConnects + 5;
            }
            else if(packageNumber==2) {
                currentPurchasedConnects = currentPurchasedConnects + 15;
                
            }
            else if(packageNumber==3) {
                currentPurchasedConnects = currentPurchasedConnects + 30;
                
            }
            
            QBCOCustomObject *object = [QBCOCustomObject customObject];
            object.className = @"UserInfo";
            object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
            
            [object.fields setObject:[NSString stringWithFormat:@"%d",currentPurchasedConnects]  forKey:@"userPurchasedConnects"];
            
            [[AppDelegate sharedinstance] showLoader];
            
            [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
                // object updated
                
                NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
                [dictUserData setObject:[NSString stringWithFormat:@"%d",currentPurchasedConnects]  forKey:@"userPurchasedConnects"];
                [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[AppDelegate sharedinstance] setStringObj:[NSString stringWithFormat:@"%d",currentPurchasedConnects]  forKey:@"userPurchasedConnects"];
                
                [[AppDelegate sharedinstance] displayMessage:@"Successfully purchased connects"];
                [[AppDelegate sharedinstance] hideLoader];
                
            } errorBlock:^(QBResponse *response) {
                
                [[AppDelegate sharedinstance] hideLoader];
                NSLog(@"Response error: %@", [response.error description]);
            }];
            
        }
    }
    else
    {
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"UserInfo";
        object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
        
        [object.fields setObject:@"1"  forKey:@"UserRole"];
        [object.fields setObject:featurnedPro ? @"true" : @"false" forKey:@"Featured"];
        [object.fields setObject:@"Pending" forKey:@"Status"];
        [object.fields setObject:[NSDate date] forKey:@"DateAsPro"];
        
        
        //    [object.fields setObject:[NSString stringWithFormat:@"%d",currentPurchasedConnects]  forKey:@"userPurchasedConnects"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
            // object updated
            
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kIAPFULLVERSION];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
            [dictUserData setObject:@"2" forKey:@"UserRole"];
            [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[AppDelegate sharedinstance] displayMessage:@"Pro Request Sent"];
            [[AppDelegate sharedinstance] hideLoader];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
            
            UIViewController *viewController;
            viewController    = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
            ((ViewUsersViewController*)viewController).strIsMyMatches=@"0";
            
            UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
            NSArray *controllers = [NSArray arrayWithObject:viewController];
            navigationController.viewControllers = controllers;
            [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
            
            
        } errorBlock:^(QBResponse *response) {
            
            [[AppDelegate sharedinstance] hideLoader];
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
  
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 113;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    

        cell_ViewPrices *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewPrices"];
        NSArray *topLevelObjects;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewPrices" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    int colorIndex = indexPath.row % 4;
    
        QBCOCustomObject *obj = [arrData objectAtIndex:colorIndex];
        
        [cell.priceTag setTitle:[obj.fields objectForKey:@"Price"] forState:UIControlStateNormal] ;
     [cell.Description setTitle:[obj.fields objectForKey:@"Description"] forState:UIControlStateNormal] ;
    
    UIColor *color = [colorArr objectAtIndex:indexPath.row];
        cell.priceTag.layer.cornerRadius = 10;
        cell.Description.layer.cornerRadius = 10;
        cell.Description.backgroundColor = color;
    
    UIImage *stencil = [[UIImage imageNamed:@"connect-1"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [cell.icon setImage:stencil];
        cell.icon.tintColor = color;
        
        
        return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    strProductId=[obj.fields objectForKey:@"ProductName"];
    if([productType isEqualToString:@"Connects"])
    {
        packageNumber = indexPath.row + 1;
        
        isfullVersionPurchase=packageNumber = packageNumber == 4;;
    }
    else
    {
        featurnedPro = indexPath.row == 0;
    }
    
    [self purchaseCall];
}

-(BOOL) prefersStatusBarHidden {
    return NO;
}

@end
