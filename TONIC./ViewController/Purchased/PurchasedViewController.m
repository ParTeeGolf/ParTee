//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "PurchasedViewController.h"
#import "HomeViewController.h"

@interface PurchasedViewController ()

@end

@implementation PurchasedViewController
@synthesize shareObject;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
   
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
    }
    
    imgViewUser1.layer.cornerRadius = imgViewUser1.frame.size.width/2;
    imgViewUser1.layer.borderWidth=0.0f;
    [imgViewUser1.layer setMasksToBounds:YES];
    [imgViewUser1.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    imgViewUser2.layer.cornerRadius = imgViewUser2.frame.size.width/2;
    imgViewUser1.layer.borderWidth=0.0f;
    [imgViewUser2.layer setMasksToBounds:YES];
    [imgViewUser2.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self bindData];
}

- (void) bindData {
    
    QBCOCustomObject *obj = shareObject;
    
    NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"specialInfoName"]];
    [lblName setText:str1];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"specialInfoPoints"]];
    [lblPoints setText:str1];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"specialInfoAddress"]];
    [lblAddress setText:str1];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"specialInfoexpiresOn"]];
    [lblExpiresOn setText:str1];
    
    [imageUrl setShowActivityIndicatorView:YES];
    [imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"specialInfoImageUrl"]] placeholderImage:[UIImage imageNamed:@""]];
    
    NSString *strReceiverId = [obj.fields objectForKey:@"specialReceiverID"];
    
    NSString *strCurrentUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    
    [imgViewUser1 setShowActivityIndicatorView:YES];
    [imgViewUser1 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    
    NSString *imagestrUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicBase"]];
    [imgViewUser1 sd_setImageWithURL:[NSURL URLWithString:imagestrUrl] ];
    
    if([strCurrentUserEmail isEqualToString:strReceiverId]) {
        // if current user is receiver, show sender profile
        
        NSString *strSenderId = [obj.fields objectForKey:@"specialSenderID"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:@"10000" forKey:@"limit"];
        [getRequest setObject:@"created_at" forKey:@"sort_desc"];
        [getRequest setObject:strSenderId forKey:@"userEmail"];
        
        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            // do something with retrieved object
            [[AppDelegate sharedinstance] hideLoader];
            
            [imgViewUser2 setShowActivityIndicatorView:YES];
            [imgViewUser2 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            QBCOCustomObject *temp = [objects objectAtIndex:0];
            
            [imgViewUser2 sd_setImageWithURL:[NSURL URLWithString:[temp.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];

            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
    else {
        // if current user is sender, show receiver profile
        NSString *strRecId = [obj.fields objectForKey:@"specialReceiverID"];

        [[AppDelegate sharedinstance] showLoader];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        [getRequest setObject:@"10000" forKey:@"limit"];
        [getRequest setObject:@"created_at" forKey:@"sort_desc"];
        [getRequest setObject:strRecId forKey:@"userEmail"];
        
        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            [[AppDelegate sharedinstance] hideLoader];
            
            QBCOCustomObject *temp = [objects objectAtIndex:0];
            
            [imgViewUser2 sd_setImageWithURL:[NSURL URLWithString:[temp.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
            
            [imgViewUser2 setShowActivityIndicatorView:YES];
            [imgViewUser2 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
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

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
