//
//  SideMenuViewController.m
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import "SideMenuViewController.h"
#import "MFSideMenu.h"
#import "cell_Menu.h"
#import "NewsFeedVc.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "MyMatchesViewController.h"
#import "SpecialsViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "PurchasedViewController.h"
#import "ViewProfileViewController.h"
#import "LoginViewController.h"
#import "ConnectssViewController.h"
#import "EditProfileViewController.h"
#import "EventViewController.h"
#import "InviteViewController.h"
#import "ViewUsersViewController.h"

#define kIndexHome 0
#define kIndexYourDetails 1
#define kIndexContactUs 2
#define kIndexReferaFriend 3
#define kIndexAffiliates 4
#define kIndexEvaluateMaxOffer 5
#define kIndexAbout 6
#define kIndexLogout 7

#import "LoginViewController.h"

@implementation SideMenuViewController

BOOL collapseRow = true;
BOOL hideCell = true;

long prevTag = -1;
long currentTag = 1;

-(void) viewDidLoad {
    
  
    [scrollViewContainer setContentSize:CGSizeMake(scrollViewContainer.frame.size.width, 750)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshContent) name:@"refreshContent" object:nil];

    imgViewPic.image = [UIImage imageNamed:@"missing-profile-photo.png"];
    
    imgViewPic.layer.cornerRadius = imgViewPic.frame.size.width/2;
    imgViewPic.layer.borderWidth=2.0f;
    [imgViewPic.layer setMasksToBounds:YES];
    [imgViewPic.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    numOfRows=13;
    
    [tblView reloadData];
}

-(void) viewWillAppear:(BOOL)animated {
    [[UIApplication sharedApplication]setStatusBarHidden:NO];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    
    scrollViewContainer.frame = CGRectMake(0, 0, self.view.frame.size.width, screenHeight);
    self.view.frame = CGRectMake(0, 0, screenRect.size.width, screenHeight);
    tblView.frame = CGRectMake(0, tblView.frame.origin.y, screenRect.size.width, screenHeight);
    
//    scrollViewContainer.backgroundColor = [UIColor redColor];
//    self.view.backgroundColor = [UIColor greenColor];
//    tblView.backgroundColor = [UIColor yellowColor];
}

-(void) refreshContent {

        NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
        NSString *Points= [[AppDelegate sharedinstance] nullcheck:[dictUserData objectForKey:@"userPoints"]];
    
        if([Points length]==0) {
            Points = @"10";
        }
    
        //[lblPoints setText:Points];
    
        [lblName setText: [[AppDelegate sharedinstance] nullcheck:[dictUserData objectForKey:@"userDisplayName"]]];
        
        [imgViewPic setShowActivityIndicatorView:YES];
        [imgViewPic setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicBase"]];
        [imgViewPic sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"user"]];
    
    
    numOfRows=13;
    
     [tblView reloadData];
    
 }

-(IBAction)profilePressed:(id)sender {
    UIViewController *viewController;
    viewController    = [[EditProfileViewController alloc] initWithNibName:@"EditProfileViewController" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
}

-(IBAction)morePressed:(id)sender {
    
    UIViewController *viewController;
    viewController    = [[SettingsMainVC alloc] initWithNibName:@"SettingsMainVC" bundle:nil];
    
    UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:viewController];
    navigationController.viewControllers = controllers;
    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    
}

-(IBAction)Sharetapped:(id)sender {
    
    NSString *text = @"Join the ParTee! Sign up. Make a Friend. Play some golf.";
    NSURL *url;
    UIImage *image = [UIImage imageNamed:@"appicon.png"];
    
    image = [UIImage imageNamed:@"unspecified.png"];
    
    url= [NSURL URLWithString:@"https://itunes.apple.com/us/app/partee-golf-connect-with-other-golfers/id1244801350?ls=1&mt=8"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url,image]
     applicationActivities:nil];
    
    [self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)logoutPressed:(id)sender  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"Are you sure want to logout?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    alert.tag=121;
    [alert show];
    
}

-(void) ComingSoon  {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kAppName message:@"This Feature Coming Soon!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    alert.tag=121;
    [alert show];
    
}

-(IBAction)sharePressed:(id)sender {
    
    NSString *text = @"Join the ParTee! Sign up. Make a Friend. Play some golf.";
    NSURL *url;
    UIImage *image = [UIImage imageNamed:@"appicon.png"];
    
    image = [UIImage imageNamed:@"unspecified.png"];
    
    url= [NSURL URLWithString:@"https://itunes.apple.com/us/app/partee-golf-connect-with-other-golfers/id1244801350?ls=1&mt=8"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url,image]
     applicationActivities:nil];

    [self presentViewController:controller animated:YES completion:nil];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return numOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    switch(indexPath.row)
    {
        case 0:
            return collapseRow ? 52.0 : 30.0;
            break;
        case 1:
        case 2:
        case 3:
        case 4:
            return collapseRow ? 0 : 30.0;
            break;
            
    }
    
    return 52.0;
}

- (UIButton *)ComingSoonButton: (CGFloat)originX  originY: (CGFloat)originY  hideButton: (BOOL)hideButton tag: (long)tag
{
    UIButton *btnImage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    //set the position of the button
    btnImage.frame = CGRectMake(originX + 200, originY + 10, 20, 20);
    btnImage.layer.cornerRadius = 10;
    [btnImage setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [btnImage addTarget:self action:@selector(ComingSoon) forControlEvents:UIControlEventTouchUpInside];
    UIImage *image = [UIImage imageNamed:@"info-filled.png"];
    [btnImage setImage:image forState:UIControlStateNormal];
    /************ ChetuChange *************/
  //  [btnImage setTintColor:[UIColor redColor]];
    [btnImage setTintColor:[UIColor greenColor]];
     /************ ChetuChange *************/
    
    btnImage.hidden = hideButton;
    btnImage.tag = tag;
    
    return btnImage;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_Menu *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_Menu"];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_Menu" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    tblView.separatorColor=[UIColor clearColor];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    
  
 
    switch(indexPath.row)
    {
        case 0:
            cell.lbl_Name.text = @"MY...";
            break;
        case 1:
            cell.lbl_Name.text = @"\tFRIENDS";
            cell.hidden = hideCell;
            break;
        case 2:
            cell.lbl_Name.text = @"\tINVITATIONS";
            cell.hidden = hideCell;
//            if(![self.view viewWithTag:2])
//
//            {
//                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:2]];
//            }
            break;
        case 3:
            cell.lbl_Name.text = @"\tTEE TIMES";
            cell.hidden = hideCell;
            if(![self.view viewWithTag:3])
                
            {
                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:3]];
            }
            break;
        case 4:
            cell.lbl_Name.text = @"\tEVENTS";
            cell.hidden = hideCell;
            if(![self.view viewWithTag:4])
                
            {
                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:4]];
            }
            break;
        case 5:
            cell.lbl_Name.text = @"GOLFERS";
            break;
        case 6:
            cell.lbl_Name.text = @"COURSES";
            break;
        case 7:
           cell.lbl_Name.text = @"PROS";
            break;
        case 8:
            cell.lbl_Name.text = @"EVENTS";
//            if(![self.view viewWithTag:8])
//
//            {
//                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:8]];
//            }
            break;
        case 9:
           // cell.lbl_Name.text = @"PARTEE LINE BLOG";
            cell.lbl_Name.text = @"NEWS FEED";
        //    cell.hidden = hideCell;
//            if(![self.view viewWithTag:9])
//
//            {
//                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:9]];
//            }

            break;
        case 10:
            cell.lbl_Name.text = @"30 SECOND LESSONS";
            if(![self.view viewWithTag:10])
                
            {
                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:10]];
            }

            break;
        case 11:
            cell.lbl_Name.text = @"PARTEE PARTNERS";
            if(![self.view viewWithTag:11])
                
            {
                [cell.contentView addSubview: [self ComingSoonButton:cell.frame.origin.x originY:cell.frame.origin.y hideButton:false tag:11]];
            }
            
            break;
        case 12:
            cell.lbl_Name.text = @"";
            if(![self.view viewWithTag:101])
                
            {
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            //set the position of the button
            button.frame = CGRectMake(cell.frame.origin.x + 20, cell.frame.origin.y, 100, 30);
            button.layer.cornerRadius = 10;
            [button setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [button setTitle:@"More" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(morePressed:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 101;
            button.backgroundColor = [UIColor colorWithRed:((float) 74 / 255.0f)
                                                     green:((float) 165 / 255.0f)
                                                      blue:((float) 77 / 255.0f)
                                                     alpha:1.0f];
            [cell.contentView addSubview:button];
            
            UIButton *btnImage = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            
            //set the position of the button
            btnImage.frame = CGRectMake(cell.frame.origin.x + 200, cell.frame.origin.y, 30, 30);
            btnImage.layer.cornerRadius = 10;
            [btnImage setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
            [btnImage addTarget:self action:@selector(Sharetapped:) forControlEvents:UIControlEventTouchUpInside];
            UIImage *image = [UIImage imageNamed:@"share"];
            [btnImage setImage:image forState:UIControlStateNormal];
            [btnImage setTintColor:[UIColor whiteColor]];
            [cell.contentView addSubview:btnImage];
            }
            
            break;
            
    }
    
    return cell;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *viewController;
   
    switch(indexPath.row)
    {
        case 0:
            collapseRow = !collapseRow;
            hideCell = !hideCell;
            if (collapseRow) {
                    [scrollViewContainer setContentSize:CGSizeMake(scrollViewContainer.frame.size.width, 750)];
            }else{
              [scrollViewContainer setContentSize:CGSizeMake(scrollViewContainer.frame.size.width, 750)];
            }
           
            [tblView reloadData];
            break;
        case 1:
            viewController    = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
            ((ViewUsersViewController*)viewController).strIsMyMatches=@"1";
            [AppDelegate sharedinstance].strIsMyMatches=@"1";
            break;
        case 2:
            viewController    = [[InviteViewController alloc] initWithNibName:@"InviteViewController" bundle:nil];
            ((InviteViewController*)viewController).strIsConnInvite=@"1";
     //        [self ComingSoon];
            break;
        case 3:
//            viewController    = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
//            ((SpecialsViewController*)viewController).strIsMyCourses=@"1";
            [self ComingSoon];
            break;
        case 4:
            [self ComingSoon];
            break;
        case 5:
            viewController    = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
            ((ViewUsersViewController*)viewController).strIsMyMatches=@"0";
            [AppDelegate sharedinstance].strIsMyMatches=@"0";
            ((ViewUsersViewController*)viewController).IsPro=false;
            break;
        case 6:
            viewController    = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
            ((SpecialsViewController*)viewController).strIsMyCourses=@"0";
            [[AppDelegate sharedinstance] setStringObj:@"0" forKey:@"courseOptions"];
            break;
        case 7:
            viewController    = [[ViewUsersViewController alloc] initWithNibName:@"ViewUsersViewController" bundle:nil];
            ((ViewUsersViewController*)viewController).strIsMyMatches=@"0";
            ((ViewUsersViewController*)viewController).IsPro=true;
            [AppDelegate sharedinstance].strIsMyMatches=@"0";
            break;
        case 8:
            viewController    = [[EventViewController alloc] initWithNibName:@"EventViewController" bundle:nil];
            break;
        case 9:
         //  [self ComingSoon];
            viewController    = [[NewsFeedVc alloc] initWithNibName:@"NewsFeedVc" bundle:nil];
            break;
        case 10:
            [self ComingSoon];
            break;
        case 11:
            [self ComingSoon];
            break;
    }
    
    if(viewController != NULL)
    {
        UINavigationController *navigationController = (UINavigationController*)self.menuContainerViewController.centerViewController;
        NSArray *controllers = [NSArray arrayWithObject:viewController];
        navigationController.viewControllers = controllers;
        [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];
    }
    
}

//-----------------------------------------------------------------------

#pragma mark - Alert Delegate

//-----------------------------------------------------------------------

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 121)
    {
        if (buttonIndex == 0)
        {
        }
        else if (buttonIndex == 1)
        {
            
            if([[AppDelegate sharedinstance].sharedChatInstance isConnected]) {
                [[AppDelegate sharedinstance].sharedChatInstance disconnectWithCompletionBlock:^(NSError * _Nullable error) {
                    
                    [[AppDelegate sharedinstance] setStringObj:@"" forKey:kuserEmail];
                    
                    LoginViewController *loginView;
                    
                    loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                    
                    UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                    NSArray *controllers = [NSArray arrayWithObject:loginView];
                    navigationController.viewControllers = controllers;
                    
                    self.menuContainerViewController.panMode=NO;
                    
                    [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

                }];
            }
            else {
                [[AppDelegate sharedinstance] setStringObj:@"" forKey:kuserEmail];
                
                LoginViewController *loginView;
                
                loginView = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
                
                UINavigationController *navigationController = self.menuContainerViewController.centerViewController;
                NSArray *controllers = [NSArray arrayWithObject:loginView];
                navigationController.viewControllers = controllers;
                
                self.menuContainerViewController.panMode=NO;
                
                [self.menuContainerViewController setMenuState:MFSideMenuStateClosed];

            }
          }
    }
}

@end
