//
//  SideMenuViewController.h
//  MFSideMenuDemo
//
//  Created by Michael Frederick on 3/19/12.

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ProfileViewController.h"
#import "SettingsViewController.h"
#import "MyMatchesViewController.h"
#import "SpecialsViewController.h"
#import "PurchaseSpecialsViewController.h"
#import "PurchasedViewController.h"
#import "ViewProfileViewController.h"
#import "SettingsMainVC.h"

@interface SideMenuViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MFMailComposeViewControllerDelegate> {
    IBOutlet UITableView *tblView;
    NSMutableArray *arrMenuItems;
    NSMutableArray *arrImage;
    AppDelegate *appDel;
    BOOL isFree;
    IBOutlet UIImageView *imgViewPic;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblPoints;
    IBOutlet UIScrollView *scrollViewContainer;

    
    int numOfRows;
    
}
@property ACAccount* facebookAccount;

-(void)Action_BecomeActivate;

@end
