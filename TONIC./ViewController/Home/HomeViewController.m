//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];

    if(isiPhone4) {
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
    }
    
    NSString *word1=lblMessage.text;
    NSMutableString *toBespaced=[NSMutableString new];
    
    for (NSInteger i=0; i<word1.length; i+=1) {
        NSString *two=[word1 substringWithRange:NSMakeRange(i, 1)];
        [toBespaced appendFormat:@"%@   ",two ];
    }
    
    lblMessage.text = toBespaced;
    
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    
    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    
    NSString *struserOccupation= [[AppDelegate sharedinstance] nullcheck:[dictUserData objectForKey:@"userOccupation"]];
    [btnLblOccupation setTitle:struserOccupation forState:UIControlStateNormal];

    long int age = [[AppDelegate sharedinstance] getAge:[dictUserData objectForKey:@"userBday" ]];
    
    NSString *strUserName = [NSString stringWithFormat:@"%@,",[dictUserData objectForKey:@"userDisplayName"]];
    NSString *strAge = [NSString stringWithFormat:@" %ld",age];

    NSString *strName = [NSString stringWithFormat:@"%@, %ld",[dictUserData objectForKey:@"userDisplayName"],age];

    NSMutableAttributedString *yourAttributedString = [[NSMutableAttributedString alloc] initWithString:[strUserName uppercaseString] ];

    UIFont *font1 = [UIFont fontWithName:@"SFUIDisplay-Semibold" size:20.0f];
    
    NSRange boldRange = [strName rangeOfString:strUserName];
    [yourAttributedString addAttribute: NSFontAttributeName value:font1 range:boldRange];
    
    [yourAttributedString appendAttributedString:[[NSMutableAttributedString alloc] initWithString:strAge]];
    [yourAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, [yourAttributedString length])];
    
    [btnLblName setAttributedTitle:yourAttributedString forState:UIControlStateNormal];



    [[AppDelegate sharedinstance] showLoader];
    
    [imgViewBg setShowActivityIndicatorView:YES];
    [imgViewBg setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    NSString *imageUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicBase"]];
    
    [imgView1 setShowActivityIndicatorView:YES];
    [imgView1 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicBase"]];
    [imgView1 sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    [imgView2 setShowActivityIndicatorView:YES];
    [imgView2 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicRight"]];
    [imgView2 sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    [imgView3 setShowActivityIndicatorView:YES];
    [imgView3 setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicLeft"]];

    NSString *Points= [[AppDelegate sharedinstance] nullcheck:[dictUserData objectForKey:@"userPoints"]];
    if([Points length]==0) {
        Points = @"10";
    }
    [lblPoints setText:Points];

    [imgView3 sd_setImageWithURL:[NSURL URLWithString:imageUrl] ];
    
    k=-1;
    NSMutableArray *arrTemp=[[NSMutableArray alloc] init];
    
    arrBgImages=[arrTemp copy];
    
    [self performSelector:@selector(manage) withObject:nil afterDelay:1.5f];
    
}

-(void) manage {
    [[AppDelegate sharedinstance] hideLoader];
    [self animateImages];
}
//-----------------------------------------------------------------------

#pragma mark - Custom Methods

//-----------------------------------------------------------------------

-(void) animateImages {

        if(k<3)
            k++;
        else
            k=0;
    
    UIImage * toImage;
    
    if(k==1) {
    
        toImage=imgView2.image;
    }
    else if(k==2)  {
        toImage=imgView3.image;

    }
    else  {
        toImage=imgView1.image;
    }
    
    
        int dur=3.f;
    
        [UIView transitionWithView:imgViewBg
                          duration:dur
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            imgViewBg.image = toImage;
                            
                            if(k==0) {
                                
                                [btncircle1 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                                [btncircle2 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                                [btncircle3 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                                
                            }
                            else if(k==1) {
                                [btncircle2 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                                [btncircle1 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                                [btncircle3 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                                
                            }
                            else {
                                [btncircle3 setImage:[UIImage imageNamed:@"Dot-select"] forState:UIControlStateNormal];
                                [btncircle1 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                                [btncircle2 setImage:[UIImage imageNamed:@"Dot"] forState:UIControlStateNormal];
                                
                            }
                            
                        } completion:^(BOOL finished) {
                            
                            [self performSelector:@selector(animateImages) withObject:self afterDelay:0.f];
                            
                        }];

}

- (IBAction)action_Login:(id)sender {
    
//    if(![[AppDelegate sharedinstance] connected]) {
//        [[AppDelegate sharedinstance] displayServerFailureMessage];
//        return;
//    }
// 
//        [[AppDelegate sharedinstance] showLoader];
//
//        // FB login
//        FBSDKLoginManager *login =[AppDelegate sharedinstance].login;
//        if(!login) {
//            [AppDelegate sharedinstance].login = [[FBSDKLoginManager alloc] init];
//        }
//        
//        login.loginBehavior = FBSDKLoginBehaviorWeb;
//        [login
//         logInWithReadPermissions: @[@"public_profile",@"email"]
//         fromViewController:self
//         handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
//             
//             if (error) {
//                 [[AppDelegate sharedinstance] hideLoader];
//                 [[AppDelegate sharedinstance] displayMessage:[error localizedDescription]];
//                 NSLog(@"Process error");
//             } else if (result.isCancelled) {
//                 [[AppDelegate sharedinstance] hideLoader];
//                 
//                 NSLog(@"Cancelled");
//             } else {
//                 NSLog(@"Logged in");
//                 
//                 [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
//                                                    parameters:@{@"fields": @"gender,first_name, last_name, picture, email"}]
//                  startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//                      if (!error) {
//
//                          NSDictionary *dictData = result;
//                          
//                          NSString *strEmail = [dictData objectForKey:@"email"];
//                          
//                          [[AppDelegate sharedinstance] setStringObj:strEmail forKey:kuserEmail];
//                        
//                          NSString *strFBToken =  [FBSDKAccessToken currentAccessToken].tokenString;
//                          
//                          [QBRequest logInWithSocialProvider:@"facebook" accessToken:strFBToken accessTokenSecret:nil successBlock:^(QBResponse *response, QBUUser *user) {
//                              // Login succeded
//                              [[AppDelegate sharedinstance] hideLoader];
//
//                              
//                          } errorBlock:^(QBResponse *response) {
//                              // Handle error
//                          }];
//                          
//                      }
//
//                      }];
//                  }
//                  }];

}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    UIViewController *viewController;
    viewController    = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

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
    
    
//-----------------------------------------------------------------------

#pragma mark - Alert View Methods

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if([alertView tag]==300) {
        
        NSString *email = [alertView textFieldAtIndex:0].text;
        
        if (buttonIndex == 0) {
            
        } else {
            NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trimmed = [email stringByTrimmingCharactersInSet:whitespace];
            
            NSString *errorMessage;
            
            if([trimmed length]==0 ) {
                errorMessage = @"Please enter a valid email address";
                [[[UIAlertView alloc] initWithTitle:kAppName message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                return;
            } else {
                
                NSString *regex = @"[^@]+@[A-Za-z0-9.-]+\\.[A-Za-z]+";
                NSPredicate *emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                
                if (![emailPredicate evaluateWithObject:trimmed]){
                    errorMessage = @"Please enter a valid email address";
                    [[[UIAlertView alloc] initWithTitle:kAppName message:errorMessage delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil] show];
                    return;
                }
                else {
                    
                    [[AppDelegate sharedinstance] showLoader];
                    
                    // Reset User's password with email
                    [QBRequest resetUserPasswordWithEmail:trimmed successBlock:^(QBResponse *response) {
                        // Reset was successful
                        
                        [[AppDelegate sharedinstance] hideLoader];

                        [[AppDelegate sharedinstance] displayMessage:@"Password reset instructions has been mailed."];
                        
                    } errorBlock:^(QBResponse *response) {
                        // Error
                        [[AppDelegate sharedinstance] hideLoader];

                        if([response status]==404) {
                            
                            [[AppDelegate sharedinstance] displayMessage:@"Email not registered"];
                        }
                    }];
                }
            }
        }
    }
    
}

-(BOOL) prefersStatusBarHidden {
    return NO;
}

@end
