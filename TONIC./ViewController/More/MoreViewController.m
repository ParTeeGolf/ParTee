//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MoreViewController.h"
#import "HomeViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "cell_ViewSpecials.h"

#define kLimit @"100"

@interface MoreViewController ()

@end

@implementation MoreViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 1500)];

    }
    else {
        [scrollViewContainer setContentSize:CGSizeMake(320, 850)];

    }

}

@end
