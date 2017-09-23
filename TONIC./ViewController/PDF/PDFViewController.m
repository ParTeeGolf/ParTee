//
//  MainViewController.m
//  SilverSpace 
//
//  Created by Jagdish Prajapati on 11/03/15.
//  Copyright (c) 2015 SilverSpace. All rights reserved.
//

#import "PDFViewController.h"


@interface PDFViewController ()

@end

@implementation PDFViewController
@synthesize  strFileName;
@synthesize  strDisplayFileName;
@synthesize isForDocDir;
@synthesize isURL;
@synthesize cameFromScreen;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden=YES;
    
    [tblRooms setBackgroundView:nil];
    [tblRooms setBackgroundColor:[UIColor clearColor]];
    
//    [txtViewNotes.layer setCornerRadius:5.f];
//    [txtViewNotes.layer setBorderWidth:.5f];
    webView.backgroundColor = [UIColor clearColor];
    webView.opaque=NO;
    // Assuming self.webView is our UIWebView
    // We go though all sub views of the UIWebView and set their backgroundColor to white
    UIView *v = webView;
    while (v) {
        v.backgroundColor = [UIColor whiteColor];
        v = [v.subviews firstObject];
    }
}

//-----------------------------------------------------------------------

-(void) viewWillAppear:(BOOL)animated {
    
     if(self.cameFromScreen==kScreenPrivacy) {
        [lblTitle setText:@"Privacy"];
        
        [btnBack setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
        
        self.strFileName=@"PrivacyPolicy";
        NSString *path = [[NSBundle mainBundle] pathForResource:self.strFileName ofType:@"pdf"];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
    else {
        [lblTitle setText:@"Terms and Conditions"];

        [btnBack setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];

        self.strFileName=@"Terms and Conditions";
        NSString *path = [[NSBundle mainBundle] pathForResource:self.strFileName ofType:@"pdf"];
        NSURL *url = [NSURL fileURLWithPath:path];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
  
}

//-----------------------------------------------------------------------

#pragma mark - Action Methods

//-----------------------------------------------------------------------

-(IBAction)backPressed:(id)sender {

    if(self.cameFromScreen==kScreenAffilitates || self.cameFromScreen==kScreenAbout || self.cameFromScreen==kScreenNotifications) {
        
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
            
        }];
        
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];

    }
}

//-----------------------------------------------------------------------

-(IBAction)cancelPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}



@end
