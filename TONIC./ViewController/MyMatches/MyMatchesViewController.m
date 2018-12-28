//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MyMatchesViewController.h"
#import "HomeViewController.h"
#import "CVCell.h"
#define kLimit @"100"
#import "ViewUsersViewController.h"
@interface MyMatchesViewController ()

@end

@implementation MyMatchesViewController
@synthesize arrData;
@synthesize collectionViewData;
@synthesize isFromConnects;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [btnPackageTitle1.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnPackageTitle2.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnPackageTitle3.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnPackageTitle4.titleLabel setTextAlignment:NSTextAlignmentCenter];

    [[NSNotificationCenter defaultCenter] removeObserver:self];

    self.automaticallyAdjustsScrollViewInsets = NO;

    self.navigationController.navigationBarHidden=YES;
    
    imgView1.layer.cornerRadius = imgView1.frame.size.width/2;
    [imgView1.layer setMasksToBounds:YES];
    [imgView1.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView2.layer.cornerRadius = imgView2.frame.size.width/2;
    [imgView2.layer setMasksToBounds:YES];
    [imgView2.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView3.layer.cornerRadius = imgView3.frame.size.width/2;
    [imgView3.layer setMasksToBounds:YES];
    [imgView3.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView4.layer.cornerRadius = imgView4.frame.size.width/2;
    [imgView4.layer setMasksToBounds:YES];
    [imgView3.layer setBorderColor:[UIColor clearColor].CGColor];
    
    [scrollViewContainer addSubview:viewMoreMatches];
    scrollViewContainer.hidden=NO;
    
   CGRect frame =  viewMoreMatches.frame;
   frame.origin.y=0;
   viewMoreMatches.frame = frame;
    
    if(isiPhone4) {
        
        CGRect frame =  viewMoreMatches.frame;
        frame.origin.y=0;
        viewMoreMatches.frame = frame;
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 580)];
    }
    
    [self manageCollectionView];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}

-(void) viewWillAppear:(BOOL)animated {
    [AppDelegate sharedinstance].isBlocked=NO;
    
    BOOL isFullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kIAPFULLVERSION];
    
    if(isFullVersion) {
        [btnMore setHidden:YES];
    }
    
    [arrData removeAllObjects];
    [self.collectionViewData reloadData];

    if(isFromConnects) {
        [lblTitle setText:@"CONNECTS"];
        
        [btnMore setHidden:YES];
        
        scrollViewContainer.alpha = 0;
        scrollViewContainer.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            scrollViewContainer.alpha = 1;
        }];
        
        return;
    }
    
    [lblTitle setText:@"MY MATCHES"];
    
    [self getAllUsers];
    
    
}

-(void) getAllUsers {
    
    arrData = [[NSMutableArray alloc] init];
    
    NSString *strUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:@"10000" forKey:@"limit"];
    [getRequest setObject:strUserEmail forKey:@"connSenderID[or]"];
    [getRequest setObject:strUserEmail forKey:@"connReceiverID[or]"];
    [getRequest setObject:@"2" forKey:@"connStatus"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserConnections" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
       
        // response processing
        arrConnections=objects;
        arrConnectionsTemp = objects;

        NSMutableArray *arrTemp = [[NSMutableArray alloc] init];
        
        for (QBCOCustomObject *obj in arrConnections) {
            
            NSString *strSenderId = [obj.fields objectForKey:@"connSenderID"];
            NSString *strRecId = [obj.fields objectForKey:@"connReceiverID"];
            
            if([strSenderId isEqualToString:[[AppDelegate sharedinstance] getCurrentUserEmail]]) {
                [arrTemp addObject:strRecId];
            }
            else if([strRecId isEqualToString:[[AppDelegate sharedinstance] getCurrentUserEmail]]) {
                [arrTemp addObject:strSenderId];
            }
        }
        
        arrConnections = [arrTemp copy];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:kLimit forKey:@"limit"];
        [getRequest setObject:@"created_at" forKey:@"sort_desc"];

        [getRequest setObject:[[arrConnections valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"userEmail[in]"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            
            [arrData addObjectsFromArray:[objects mutableCopy]];
            
            NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
            int currentPoints = [[dictUserData objectForKey:@"userPoints"] integerValue];

            NSString *strPoints = [NSString stringWithFormat:@"%d",currentPoints];

            [dictUserData setObject:strPoints forKey:@"userPoints"];
            [[NSUserDefaults standardUserDefaults] setObject:dictUserData forKey:kuserData];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
            
            if([arrData count]==0) {
                [lblNotAvailable setHidden:NO];
            }
            else {
                [lblNotAvailable setHidden:YES];
            }
            
            [[AppDelegate sharedinstance] hideLoader];
            [self.collectionViewData reloadData];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(void) manageCollectionView {
    [self.collectionViewData registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    
    // Configure layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(156, 260)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionViewData setContentOffset:CGPointZero];
    
    flowLayout.minimumInteritemSpacing = 0.0f;
    flowLayout.minimumLineSpacing=10.f;
    
    [self.collectionViewData setCollectionViewLayout:flowLayout];
    [self.collectionViewData setPagingEnabled:NO];
    
    self.collectionViewData.bounces = YES;
    [self.collectionViewData setShowsHorizontalScrollIndicator:NO];
    [self.collectionViewData setShowsVerticalScrollIndicator:NO];

}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 10, 0);
}

-(void) temp {
    
    [self.collectionViewData reloadData];
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self.collectionViewData.collectionViewLayout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrData.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Setup cell identifier
    static NSString *cellIdentifier = @"cvCell";
    
    CVCell *cell = (CVCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    if((indexPath.row+1)%4==1) {
        [cell.imgViewCup setImage:[UIImage imageNamed:@"2.png"]];
    }
    else   if((indexPath.row+1)%4==2) {
        [cell.imgViewCup setImage:[UIImage imageNamed:@"1.png"]];
        
    }
    else   if((indexPath.row+1)%4==3) {
        [cell.imgViewCup setImage:[UIImage imageNamed:@"4.png"]];

    }
    else   if((indexPath.row+1)%4==0) {
        [cell.imgViewCup setImage:[UIImage imageNamed:@"3.png"]];
        
    }
    
    cell.imgViewCup.layer.cornerRadius = cell.imgViewCup.frame.size.width/2;
    [cell.imgViewCup.layer setMasksToBounds:YES];
    [cell.imgViewCup.layer setBorderColor:[UIColor clearColor].CGColor];

    cell.imgViewUser.layer.cornerRadius = cell.imgViewUser.frame.size.width/2;
    [cell.imgViewUser.layer setMasksToBounds:YES];
    [cell.imgViewUser.layer setBorderColor:[UIColor clearColor].CGColor];
    
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userDisplayName"]];
    [cell.lblUserName setText:str1];
    
    
    [cell.imgViewUser setShowActivityIndicatorView:YES];
    [cell.imgViewUser setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.imgViewUser sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
    
    cell.imgViewUser.layer.cornerRadius =  cell.imgViewUser.frame.size.width/2;
    [cell.imgViewUser.layer setMasksToBounds:YES];
    [cell.imgViewUser.layer setBorderColor:[UIColor clearColor].CGColor];
    
    // Return the cell
    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
    
    ViewProfileViewController *viewController;
    viewController    = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
    
    viewController.arrConnections = [arrConnectionsTemp copy];
    viewController.customShareObj=obj;
    viewController.isMyMatch=YES;
    [self.navigationController pushViewController:viewController animated:YES];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(IBAction)notNowPressed:(id)sender {
    
    if(!isFromConnects)
        [btnMore setHidden:NO];
    
    //viewProfile
    [UIView animateWithDuration:0.3 animations:^{
        scrollViewContainer.alpha = 0;
        
    } completion: ^(BOOL finished) {
        
        if(isFromConnects) {
            
            [self.navigationController popViewControllerAnimated:NO];
            
            return;
        }
        
        //creates a variable (BOOL) called "finished" that is set to *YES* when animation IS completed.
        scrollViewContainer.hidden = finished;//if animation is finished ("finished" == *YES*), then hidden = "finished" ... (aka hidden = *YES*)
    }];

}

//-----------------------------------------------------------------------

-(IBAction) buyConnectsPressed :(id)sender  {
    isfullVersionPurchase=NO;
    
    strProductId=@"com.product.4connect";

    [self purchaseCall];
    
}

//-----------------------------------------------------------------------

-(IBAction) fullVersionPressed :(id)sender  {
   isfullVersionPurchase=YES;
    
    strProductId=@"com.product.fullversion";

    [self purchaseCall];
    
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
        
    }];
}

- (IBAction) matchPressed:(id)sender {
    
    ViewProfileViewController *obj=[[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
    obj.arrData = [arrData copy];
    obj.arrConnections = [arrConnectionsTemp copy];
    [self.navigationController pushViewController:obj animated:YES];
}

- (IBAction)viewMoreMatchesPressed:(id)sender {
    BOOL isFullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kIAPFULLVERSION];

    if(isFullVersion) return;
    
    [btnMore setHidden:YES];
    
    scrollViewContainer.alpha = 0;
    scrollViewContainer.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        scrollViewContainer.alpha = 1;
    }];
}

-(IBAction)btnPack1Pressed:(id)sender {
    packageNumber=1;
    
    isfullVersionPurchase=NO;
    
    strProductId=@"com.product.minconnect";
    
    [self purchaseCall];

}

-(IBAction)btnPack2Pressed:(id)sender {
    packageNumber=2;

    isfullVersionPurchase=NO;
    
    strProductId=@"com.product.50connect";
    
    [self purchaseCall];

    
}

-(IBAction)btnPack3Pressed:(id)sender {
    packageNumber=3;

    isfullVersionPurchase=NO;
    
    strProductId=@"com.product.100connect";
    
    [self purchaseCall];

    
}

-(IBAction)btnPack4Pressed:(id)sender {
    
    isfullVersionPurchase=YES;
    packageNumber=4;

    strProductId=@"com.product.fullversion";
    
    [self purchaseCall];

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
    int count = [response.products count];
    
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
    NSLog(@"received restored transactions: %i", queue.transactions.count);
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
    
    if(isfullVersionPurchase)
    {
     
        QBCOCustomObject *object = [QBCOCustomObject customObject];
        object.className = @"UserInfo";
        object.ID= [[AppDelegate sharedinstance] getStringObjfromKey:kuserInfoID];
        
        [object.fields setObject:[NSString stringWithFormat:@"%d",1]  forKey:@"userFullMode"];
        
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

-(BOOL) prefersStatusBarHidden {
    return NO;
}

@end
