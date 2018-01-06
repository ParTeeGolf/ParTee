	//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "AdminViewController.h"
#import "cell_ViewPro.h"
#import "PreviewProfileViewController.h"
#import "DemoMessagesViewController.h"
#define kLimit @"100"
#define kdialogLimit 100

@interface AdminViewController ()

@end

@implementation AdminViewController
@synthesize tblList;

-(void) showcustomnotification{
    
    [[AppDelegate sharedinstance] displayCustomNotification:@"hello"];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [lblNotAvailable setHidden:YES];
    
    arrData = [[NSMutableArray alloc] init];
    arrRoles = [[NSMutableArray alloc] init];
    

    self.navigationController.navigationBarHidden=YES;


    tblList.separatorColor = [UIColor clearColor];

    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [AppDelegate sharedinstance].currentScreen = kScreenOther;
}

-(BOOL) prefersStatusBarHidden {
    return NO;
}

-(void) viewWillAppear:(BOOL)animated
{
    _currentPage=0;
    
    [self refreshdialogs];
    
}

-(IBAction) refreshdialogs
{
    arrData = [[NSMutableArray alloc] init];
    parentIds = [[NSMutableArray alloc] init];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    long segmentIndex = [admindSegments selectedSegmentIndex];
    
    switch(segmentIndex)
    {
        case 0:
            [getRequest setObject:@"Pending" forKey:@"Status"];
            break;
        case 1:
            [getRequest setObject:@"Approved" forKey:@"Status"];
            break;
    }
    
    [getRequest setObject:@"true" forKey:@"Active"];
    [getRequest setObject:@"1" forKey:@"RoleId"];
    
    [QBRequest objectsWithClassName:@"UserRoles" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         arrRoles = [objects mutableCopy];
         
         for(QBCOCustomObject *obj in objects)
         {
             [parentIds addObject:obj.parentID];
         }
         
         [arrData removeAllObjects];
         [self getContact];
         
     } errorBlock:^(QBResponse *response)
     {
         // Handle error here
         [[AppDelegate sharedinstance] hideLoader];
         
     }];

}

- (void) getContact
{
    if(parentIds == nil)
    {
        return;
    }
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    
    [getRequest setObject:parentIds forKey:@"_id[in]"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page)
     {
         NSDate *today = [NSDate date];
         
         for(QBCOCustomObject *userobj in objects)
         {
             NSString *dateString;
             for(QBCOCustomObject *role in arrRoles)
             {
                 if(role.parentID == userobj.ID)
                 {
                     dateString =  [role.fields objectForKey:@"DateAsRole"];
                     break;
                 }
             }
             
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
             [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
             NSDate *date = [dateFormatter dateFromString:dateString];
             
             NSDateComponents *component = [[NSDateComponents alloc] init];
             component.year = 1;
             NSCalendar *calendar = [NSCalendar currentCalendar];
             NSDate *expireDate = [calendar dateByAddingComponents:component toDate: date options:0];
             
             
             long days = [[[NSCalendar currentCalendar] components:NSCalendarUnitDay
                                                           fromDate:today
                                                             toDate:expireDate options:0]day];
             
             if([admindSegments selectedSegmentIndex] == 1)
             {
                 if(days <= 30)
                 {
                     [userobj.fields setObject:[NSString stringWithFormat:@"%ld", days] forKey:@"DaysToExpire"];
                     [arrData addObject:userobj];
                 }
                 
             }
             else
             {
                 [arrData addObject:userobj];
             }
             
         }
         
         [lblNotAvailable setHidden:[arrData count]!=0];
         
         [[AppDelegate sharedinstance] hideLoader];
         
         [tblList reloadData];
         
         
     } errorBlock:^(QBResponse *response)
     {
         // Handle error here
         [[AppDelegate sharedinstance] hideLoader];
         
     }];
}





-(void) resettimer
{
    [AppDelegate sharedinstance].strcustomnotificationtimer = @"1";
}





- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


//-----------------------------------------------------------------------

- (IBAction) action_Menu:(id)sender
{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
    
}


-(void) reloadusers
{
        [tblList reloadData];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 182;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

        cell_ViewPro *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewPro"];
        NSArray *topLevelObjects;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewPro" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
        cell.navigationController = self.navigationController;
        
        QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
        
        [cell.profileButton addTarget:self action:@selector(viewProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        cell.lblName.text = [obj.fields objectForKey:@"userDisplayName"];
        cell.proType.text = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ProType"]];
        cell.alternateProType.text = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"AlternateProType"]];
    
        NSString *days = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"DaysToExpire"]];
    
        if(days.length != 0)
        {
            if([days intValue] <= 0)
            {
                [cell.daysToExpireLabel setText:@"Expired"];
                [cell.daysToExpireLabel setBackgroundColor:[UIColor redColor]];
                [cell.daysToExpireLabel setTintColor:[UIColor whiteColor]];
                
            }
            else
            {
                [cell.daysToExpireLabel setText:[NSString stringWithFormat:@"%@ days", days]];
                [cell.daysToExpireLabel setBackgroundColor:[UIColor orangeColor]];
                [cell.daysToExpireLabel setTintColor:[UIColor blackColor]];
            }
      
        }
        else
        {
            [cell.daysToExpireLabel setHidden:YES];
        }
        
        [cell.imageUrl setShowActivityIndicatorView:YES];
        [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        
        cell.profileButton.layer.cornerRadius = 10;
        cell.profileButton.proID = obj.ID;
        
        [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [cell.imageUrl setImage:image];
            [cell.imageUrl setContentMode:UIViewContentModeScaleAspectFill];
            [cell.imageUrl setShowActivityIndicatorView:NO];
            
        }];
        
        [cell.proIcon sd_setImageWithURL:[NSURL URLWithString:[[AppDelegate sharedinstance] getProIcons:[obj.fields objectForKey:@"ProType"]]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [cell.proIcon setImage:image];
            [cell.proIcon setContentMode:UIViewContentModeScaleAspectFill];
            [cell.proIcon setShowActivityIndicatorView:NO];
            
        }];
        
        
        return cell;
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

-(IBAction) viewProfile: (button_ViewPro*)sender
{
    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    viewController.userID = sender.proID;
    viewController.IsPro = true;
    viewController.administrationType = sender.administrationType;
    viewController.strCameFrom = @"6";
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
