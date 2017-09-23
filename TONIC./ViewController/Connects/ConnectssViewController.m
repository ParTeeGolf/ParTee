//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "ConnectssViewController.h"
#import "HomeViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "cell_ViewSpecials.h"

#define kLimit @"100"

@interface ConnectssViewController ()

@end

@implementation ConnectssViewController
@synthesize status;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    self.navigationController.navigationBarHidden=YES;
    tblList.tableFooterView = [UIView new];
    [lblNotAvailable setHidden:YES];

    imgViewUser1.layer.cornerRadius = imgViewUser1.frame.size.width/2;
    imgViewUser1.layer.borderWidth=2.0f;
    [imgViewUser1.layer setMasksToBounds:YES];
    [imgViewUser1.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    arrData = [[NSMutableArray alloc] init];
    [tblList reloadData];
    
   // [self getData];
}

-(void) viewWillAppear:(BOOL)animated {
    
    if(status==1) {
        [btnBack setHidden:NO];
        [btnMenu setHidden:YES];
        
    }
    else {
        [btnBack setHidden:YES];
        [btnMenu setHidden:NO];
    }
    
//    NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];
//
//    NSString *struserWeeklyConnects =  [dictUserDetails objectForKey:@"userFreeConnects"];
//    NSString *struserPurchasedConnects =  [dictUserDetails objectForKey:@"userPurchasedConnects"];
//
//    [lblWeeklyConnects setText:struserWeeklyConnects];
//    [lblPurchasedConnects setText:struserPurchasedConnects];

    [self bindData];
}

-(IBAction)getMoreConnects:(id)sender {
    
    MyMatchesViewController *obj = [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
    obj.isFromConnects=YES;
    [self.navigationController pushViewController:obj animated:NO];
    
}

-(void) bindData {
    
    [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        [[AppDelegate sharedinstance] hideLoader];
        
        // checking user there in custom user table or not.
        
        if([objects count]>0) {
            QBCOCustomObject *userobj = [objects objectAtIndex:0];
            [lblWeeklyConnects setText:[userobj.fields objectForKey:@"userFreeConnects"]];
            [lblPurchasedConnects setText:[userobj.fields objectForKey:@"userPurchasedConnects"]];
            
        }
    }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    if(status==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            
        }];
    }
}

//-----------------------------------------------------------------------

- (IBAction)action_gotoMyMatches:(id)sender {
    UIViewController *viewController;
    viewController    = [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
}

-(IBAction)specialTapped:(id)sender {
    PurchaseSpecialsViewController *obj = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
    [self.navigationController pushViewController:obj animated:YES];
    
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
