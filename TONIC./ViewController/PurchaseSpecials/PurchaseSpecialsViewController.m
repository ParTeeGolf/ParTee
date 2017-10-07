//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "PurchaseSpecialsViewController.h"
#import "HomeViewController.h"
#import "ViewSpecialInvite.h"
#import "CoursePhotoViewController.h"
#import "PreviewProfileViewController.h"
#import "MapViewController.h"
#import "cell_ViewPro.h"
#import "cell_ViewAmenities.h"
#import "cell_ViewEvents.h"

#define kIndexFav 0
#define kIndexMap 1
#define kIndexDirection 2
#define kIndexPhoto 3

NSString *tableType;
NSString *courseId;

@interface PurchaseSpecialsViewController ()

@end

@implementation PurchaseSpecialsViewController
@synthesize courseObject,userObject;
@synthesize status;
@synthesize btnFavImage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    arrAmenities = [[NSMutableArray alloc] init];
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
    }

    self.navigationController.navigationBarHidden=YES;
    
    [amenitiesView setHidden:YES];
    [proView setHidden:YES];
    [eventsView setHidden:YES];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [eventsTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [proTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [amenitiesTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [AppDelegate sharedinstance].delegateShareObject=nil;
    
    [self manageCollectionView];

    
}

-(void) viewWillAppear:(BOOL)animated {
    
    if(status==1)
    {
        QBCOCustomObject *obj = courseObject;
        
        NSMutableArray *userIds = [[NSMutableArray alloc] init];
        
        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
        NSMutableArray *data = [[NSMutableArray alloc] init];
        
        [getRequest setObject: obj.ID forKey:@"_parent_id"];
        
        [QBRequest objectsWithClassName:@"CourseUser" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            
            NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
            
            
            [data addObjectsFromArray:[objects mutableCopy]];
            
            for(QBCOCustomObject *obj in objects)
            {
                NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"UserID"]];
                
                if([str1 length] > 0)
                {
                    [userIds addObject:str1];
                }
            }
            
            arrData = [[NSMutableArray alloc] init];
            NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
            
            [getRequest setObject: userIds forKey:@"_id[in]"];
            
            [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                
                [arrData addObjectsFromArray:[objects mutableCopy]];
                
                tableType = @"ProTable";
                [proTable reloadData];
                
                NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                
                [getRequest setObject: courseId forKey:@"_parent_id"];
                [getRequest setObject: @"Order" forKey:@"sort_asc"];
                [QBRequest objectsWithClassName:@"CourseAmenities" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    
                    NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
                    
                    arrAmenities = [[NSMutableArray alloc] init];
                    
                    [arrAmenities addObjectsFromArray:[objects mutableCopy]];
                    
                    tableType = @"AmenitiesTable";
                    
                    [amenitiesTable reloadData];
                    
                    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
                    
                    [getRequest setObject: courseId forKey:@"_parent_id"];
                    [QBRequest objectsWithClassName:@"CourseEvents" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                        
                        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
                        
                        arrEvents = [[NSMutableArray alloc] init];
                        
                        [arrEvents addObjectsFromArray:[objects mutableCopy]];
                        
                        tableType = @"EventsTable";
                        
                        [eventsTable reloadData];
                        
                        
                        
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
        
        NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Name"]];
        str1 = [str1 uppercaseString];
        [lblName setText:str1];
        
        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Address"]];
        
        courseId = obj.ID;
        
        NSString *strCity= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"City"]];
        NSString *strState= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"State"]];
        NSString *strZipCode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ZipCode"]];
        
        str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
        [lblAddress setText:str1];
        
        NSString *phone = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ContactNumber"]];
        NSString *website = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Website"]];
        NSString *booking = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"booking"]];
        
        str1 = [NSString stringWithFormat:@"Phone: %@\n\nWebsite: %@\n\nTee Times: %@",phone,website,booking];
        
        NSString *numberOfHoles = [obj.fields objectForKey:@"NumberHoles"];
        
        if(numberOfHoles !=  nil)
        {
            str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@ Holes", numberOfHoles]];
        }
        
        NSString *news = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"News"]];
        
        if(![news isEqualToString:@""])
        {
            str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", news]];
        }
        
        NSString *description = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"description"]];
        
        if(![description isEqualToString:@""])
        {
            str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", description]];
        }
        
        aboutTextView.text = str1;
        aboutTextView.editable = NO;
        aboutTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        
        [imageUrl setShowActivityIndicatorView:YES];
        [imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];

        NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
        
        if(!arr || arr.count==0)
            arr = [[NSMutableArray alloc] init];
        
        NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
        
        if([arr containsObject:strCurrentUserID]) {
           // [btnFavImage setImage:[UIImage imageNamed:@"favourite-filled"] forState:UIControlStateNormal];

        }
        else {
          //  [btnFavImage setImage:[UIImage imageNamed:@"favourite-unfilled"] forState:UIControlStateNormal];

        }

        
    }
   else if(status==3) {
        [btnSendInviteBig setHidden:YES];
        
        [lblTitle setText:@"Courses"];
       
       [btnSendInviteBig setHidden:YES];
       [self bindDataForUser];
       
       
    }
    else if (status ==5) {
        [lblTitle setText:@"Accepted"];

        [btnSendInviteBig setHidden:YES];
        
        [self bindDataForUser];
        
    }
    else {
        [self bindData];
        
    }
    
  }

 
-(void) bindDataForUser {
    QBCOCustomObject *obj = courseObject;
    
    NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Name"]];
    str1 = [str1 uppercaseString];
    [lblName setText:str1];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Address"]];
    
    NSString *strCity= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"City"]];
    NSString *strState= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"State"]];
    NSString *strZipCode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ZipCode"]];
    
    str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
    [lblAddress setText:str1];
    
    NSString *phone = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ContactNumber"]];
    NSString *website = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Website"]];
    NSString *booking = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"booking"]];
    
    str1 = [NSString stringWithFormat:@"Phone: %@\n\nWebsite: %@\n\nTee Times: %@",phone,website,booking];
    
    NSString *numberOfHoles = [obj.fields objectForKey:@"NumberHoles"];
    
    if(numberOfHoles !=  nil)
    {
        str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@ Holes", numberOfHoles]];
    }
    
    NSString *news = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"News"]];
    
    if(![news isEqualToString:@""])
    {
        str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", news]];
    }
    
    NSString *description = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"description"]];
    
    if(![description isEqualToString:@""])
    {
        str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", description]];
    }
    
    aboutTextView.text = str1;
    aboutTextView.editable = NO;
    aboutTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    
    NSArray *items = [str1 componentsSeparatedByString:@","];
    NSMutableString * bulletList = [NSMutableString stringWithCapacity:items.count*30];
    
    for (NSString * s in items)
    {
        [bulletList appendFormat:@"\u2022 %@\n", s];
    }

    
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        isFavCourse = YES;
     //   [btnFavImage setImage:[UIImage imageNamed:@"favourite-filled"] forState:UIControlStateNormal];

    }
    else {
        isFavCourse = NO;

     //   [btnFavImage setImage:[UIImage imageNamed:@"favourite-unfilled"] forState:UIControlStateNormal];

    }
    
    [imageUrl setShowActivityIndicatorView:YES];
    [imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
    
    
    NSString *strEmail = [userObject.fields objectForKey:@"courseSenderID"];
    
    NSString *strCurrentUserEmail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    NSString *strOtherUserEmail;
    
    if([strCurrentUserEmail isEqualToString:strEmail]) {
        strOtherUserEmail = [userObject.fields objectForKey:@"courseReceiverID"];
    }
    else {
        strOtherUserEmail = [userObject.fields objectForKey:@"courseSenderID"];
    }

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:strOtherUserEmail forKey:@"userEmail"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        [[AppDelegate sharedinstance] hideLoader];
       
        
        otherUserObj = [objects objectAtIndex:0];
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayServerErrorMessage];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];

}

//-----------------------------------------------------------------------

-(void) bindData {
    QBCOCustomObject *obj = courseObject;
    
    NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Name"]];
    str1 = [str1 uppercaseString];
    [lblName setText:str1];

    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Address"]];
    [lblAddress setText:str1];
    
    NSString *phone = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ContactNumber"]];
    NSString *website = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Website"]];
    NSString *booking = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"booking"]];
    
    str1 = [NSString stringWithFormat:@"Phone: %@\n\nWebsite: %@\n\nTee Times: %@",phone,website,booking];
    
    NSString *numberOfHoles = [obj.fields objectForKey:@"NumberHoles"];
    
    if(numberOfHoles !=  nil)
    {
        str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@ Holes", numberOfHoles]];
    }
    
    NSString *news = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"News"]];
    
    if(![news isEqualToString:@""])
    {
        str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", news]];
    }
    
    NSString *description = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"description"]];
    
    if(![description isEqualToString:@""])
    {
        str1 = [str1 stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", description]];
    }
    
    aboutTextView.text = str1;
    aboutTextView.editable = NO;
    aboutTextView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    [imageUrl setShowActivityIndicatorView:YES];
    [imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [imageUrl sd_setImageWithURL:[NSURL URLWithString:[userObject.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
    
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        isFavCourse = YES;
     //   [btnFavImage setImage:[UIImage imageNamed:@"favourite-filled"] forState:UIControlStateNormal];

    }
    else {
        isFavCourse = NO;
        //[btnFavImage setImage:[UIImage imageNamed:@"favourite-unfilled"] forState:UIControlStateNormal];

    }
}

//-----------------------------------------------------------------------

-(IBAction)viewUser:(id)sender {
    
    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    viewController.strCameFrom=@"5";
    
    if(status==3) {
        viewController.strEmailOfUser = [courseObject.fields objectForKey:@"courseSenderID"];

    }
    else {
        viewController.strEmailOfUser = [otherUserObj.fields objectForKey:@"userEmail"];

    }
    [self.navigationController pushViewController:viewController animated:YES];
    
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

-(IBAction)selectUser:(id)sender {
    
    if(status == 5) {
        PreviewProfileViewController *viewController;
        viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
        viewController.strCameFrom=@"5";
        
        if(status==3) {
            viewController.strEmailOfUser = [userObject.fields objectForKey:@"courseSenderID"];
            
        }
        else {
            viewController.strEmailOfUser = [otherUserObj.fields objectForKey:@"userEmail"];
            
        }
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else if (status==3) {
        
        PreviewProfileViewController *viewController;
        viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
        viewController.strCameFrom=@"5";
        
        if(status==3) {
            viewController.strEmailOfUser = [userObject.fields objectForKey:@"courseSenderID"];
        }
        else {
            viewController.strEmailOfUser = [otherUserObj.fields objectForKey:@"userEmail"];
        }
        
        [self.navigationController pushViewController:viewController animated:YES];
        
//        [[AppDelegate sharedinstance] showLoader];
//        
//        ViewProfileViewController *viewController;
//        viewController    = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
//        
//        NSString *strSenderId = [shareObject.fields objectForKey:@"specialSenderID"];
//        
//        NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
//        [getRequest setObject:strSenderId forKey:@"userEmail"];
//        
//        [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
//            [[AppDelegate sharedinstance] hideLoader];
//            
//            viewController.customShareObj=[objects objectAtIndex:0];
//            viewController.isMyMatch=NO;
//            [self.navigationController pushViewController:viewController animated:YES];
//
//        } errorBlock:^(QBResponse *response) {
//            // error handling
//            [[AppDelegate sharedinstance] hideLoader];
//
//            NSLog(@"Response error: %@", [response.error description]);
//        }];
    }
    else {

        ViewSpecialInvite *vc = [[ViewSpecialInvite alloc] initWithNibName:@"ViewSpecialInvite" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
//        
//        UINavigationController *navigationController =
//        [[UINavigationController alloc] initWithRootViewController:vc];
//        navigationController.navigationBar.barStyle = self.navigationController.navigationBar.barStyle;
//        
//        //now present this navigation controller modally
//        [self presentViewController:navigationController
//                           animated:YES
//                         completion:^{
//                             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//                             
//                         }];
    }
    
}

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction) purchaseTapped:(id)sender {
    
    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    
    // FROM MY, send request
    
    QBCOCustomObject *obj = [AppDelegate sharedinstance].delegateShareObject;
    
    QBCOCustomObject *object = [QBCOCustomObject customObject];
    object.className = @"UserCourses";
    
    // Object fields
    [object.fields setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"courseSenderID"];
    [object.fields setObject:[obj.fields objectForKey:@"userEmail"] forKey:@"courseReceiverID"];
    [object.fields setObject:@"4" forKey:@"courseStatus"];
    [object.fields setObject:courseObject.ID forKey:@"courseId"];

      NSString *strName = [NSString stringWithFormat:@"%@",[dictUserData objectForKey:@"userDisplayName"]];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest createObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        NSString *strPush = [obj.fields objectForKey:@"userPush"];
        
        // Checking if user has push notification ON
        
        if([strPush isEqualToString:@"1"]) {
            
            NSString *message = [NSString stringWithFormat:@"%@ has invited you for a golf course",strName];
            
            NSMutableDictionary *payload = [NSMutableDictionary dictionary];
            NSMutableDictionary *aps = [NSMutableDictionary dictionary];
            [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
            [aps setObject:message forKey:QBMPushMessageAlertKey];
            [payload setObject:aps forKey:QBMPushMessageApsKey];
            [aps setObject:@"1" forKey:@"ios_badge"];
            [aps setObject:@"1" forKey:QBMPushMessageBadgeKey];
            
            QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
            
            NSString *strUserId = [NSString stringWithFormat:@"%lu",(unsigned long)obj.userID];
            
            [QBRequest sendPush:pushMessage toUsers:strUserId successBlock:^(QBResponse *response, QBMEvent *event) {
                
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                
                [self.navigationController popViewControllerAnimated:YES];
                
            } errorBlock:^(QBError *error) {
                
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
                
                [self.navigationController popViewControllerAnimated:YES];

                
                // Handle error
            }];
        }
        else {
            
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Request has been sent successfully"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) manageCollectionView {
   
    
    // Configure layout
    // Configure layout 209 (200) 276
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(60, 86)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//- (void) viewWillLayoutSubviews
//{
//    [super viewWillLayoutSubviews];
//    [self.collectionViewData.collectionViewLayout invalidateLayout];
//}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return arrAmenities.count;
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

    cell.imgViewCup.layer.cornerRadius = cell.imgViewCup.frame.size.width/2;
    [cell.imgViewCup.layer setMasksToBounds:YES];
    [cell.imgViewCup.layer setBorderColor:[UIColor clearColor].CGColor];
    
    cell.imgViewUser.layer.cornerRadius = cell.imgViewUser.frame.size.width/2;
    [cell.imgViewUser.layer setMasksToBounds:YES];
    [cell.imgViewUser.layer setBorderColor:[UIColor clearColor].CGColor];
    
    NSString *strName = [arrAmenities objectAtIndex:indexPath.row];
    
    [cell.imgViewUser setImage:[UIImage imageNamed:strName]];
    [cell.lblUserName setText:strName];
    
    // Return the cell
    return cell;
    
}

-(IBAction)favTapped:(UIButton*)sender  {
    
    QBCOCustomObject *obj =courseObject ;
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        // already fav, so unfav
       
        isFavCourse = YES;
    }
    else {
 
        isFavCourse = NO;
    }

    [self showGrid];
    
}

- (void)showGrid {
    NSInteger numberOfOptions = 4;
    NSArray *items;
    
    NSString *favoriteTitle = isFavCourse==YES ? @"Mark Unfavorite" : @"Mark Favorite";
    
    
    items= @[
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"unfav"] title:favoriteTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"viewmap"] title:@"On Map"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"direction"] title:@"Directions"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"image-placeholder"] title:@"Photos"],
             ];
    
    
    
    RNGridMenu *av = [[RNGridMenu alloc] initWithItems:[items subarrayWithRange:NSMakeRange(0, numberOfOptions)]];
    av.delegate = self;
    av.bounces = YES;
    [av showInViewController:self center:CGPointMake(self.view.bounds.size.width/2.f, self.view.bounds.size.height/2.f)];
}

- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex {
    NSLog(@"Dismissed with item %ld: %@", (long)itemIndex, item.title);
    
    switch(itemIndex)
    {
        case kIndexFav:
            [self actionFav];
            break;
        case kIndexMap:
            [self actionMap];
            break;
        case kIndexDirection:
            [self actionDirection];
            break;
        case kIndexPhoto:
            [self actionPhoto];
            break;
    }
}

-(IBAction) actionPhoto {
    
    CoursePhotoViewController *obj = [[CoursePhotoViewController alloc] initWithNibName:@"CoursePhotoViewController" bundle:nil];
    obj.courseID = courseObject.ID;
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(void) actionMap {
    
    MapViewController *obj = [[MapViewController alloc] initWithNibName:@"MapViewController" bundle:nil];
    obj.dictCourseMapData =courseObject;
    obj.strFromScreen = @"3";
    [self.navigationController pushViewController:obj animated:YES];
    
}

-(void ) actionDirection {
    NSArray *arrCoord = [courseObject.fields objectForKey:@"coordinates"];
    
    strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
    strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
    
    strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
    strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
    
    CLLocationCoordinate2D placeCoord;
    //Set the lat and long.
    placeCoord.latitude=[strlat doubleValue];
    placeCoord.longitude=[strlong doubleValue];
    
    CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
    scrplaceCoord = myposition;
    
    if([arrCoord count]>0) {
        strlat = [arrCoord objectAtIndex:1];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [arrCoord objectAtIndex:0];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        desplaceCoord = placeCoord;
        
    }
    
    //    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%f,%f&daddr=%f,%f", scrplaceCoord.latitude, scrplaceCoord.longitude, desplaceCoord.latitude, desplaceCoord.longitude];
    
    NSString *googleMapUrlString = [NSString stringWithFormat:@"http://maps.apple.com/?saddr=%f,%f&daddr=%f,%f", scrplaceCoord.latitude, scrplaceCoord.longitude, desplaceCoord.latitude, desplaceCoord.longitude];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapUrlString] options:[[NSDictionary alloc] init] completionHandler:nil];
}

-(void) actionInfo {
    QBCOCustomObject *obj=courseObject ;
    
    
    NSString *strInfo = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"description"]];
    
    if([strInfo length]>0) {
        
        
        NSString* messageString = strInfo;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Information"
                                                                                 message:messageString
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        alertController.view.frame = [[UIScreen mainScreen] bounds];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                          }]];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        [[AppDelegate sharedinstance] displayMessage:@"No information available"];
    }
    
}

-(void) actionFav {
    QBCOCustomObject *obj = courseObject ;
    
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        // already fav, so unfav
        [arr removeObject:strCurrentUserID];
        
    }
    else {
        [arr addObject:strCurrentUserID];
        
    }
    
    if(!arr || arr.count==0) {
        [obj.fields setObject:arr forKey:@"userFavID"];
        
        
    }
    else {
        [obj.fields setObject:arr forKey:@"userFavID"];
        
        
    }
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        
        [[AppDelegate sharedinstance] hideLoader];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
    
}

#pragma mark - Table view Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableType isEqualToString:@"AmenitiesTable"])
    {
        return 60.5;
    }
    else if([tableType isEqualToString:@"EventsTable"])
    {
        return 113;
    }
    else
    {
        return 182;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([tableType isEqualToString:@"AmenitiesTable"])
    {
        return arrAmenities.count;
    }
    else if([tableType isEqualToString:@"EventsTable"])
    {
        return arrEvents.count;
    }
    else
    {
        return arrData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([tableType isEqualToString:@"AmenitiesTable"])
    {
        cell_ViewAmenities *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewAmenities"];
        NSArray *topLevelObjects;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewAmenities" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
        
        QBCOCustomObject *obj = [arrAmenities objectAtIndex:indexPath.row];
        
        cell.amenitiesName.text = [obj.fields objectForKey:@"Amenity"];
        
        [cell.imageViewAmenities sd_setImageWithURL:[NSURL URLWithString:[[AppDelegate sharedinstance] getAmenitiesIcons:[obj.fields objectForKey:@"Amenity"]]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [cell.imageViewAmenities setImage:image];
            [cell.imageViewAmenities setContentMode:UIViewContentModeScaleAspectFill];
            [cell.imageViewAmenities setShowActivityIndicatorView:NO];
            
        }];
        
        return cell;
    }
    else if([tableType isEqualToString:@"EventsTable"])
    {
        cell_ViewEvents *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewEvents"];
        NSArray *topLevelObjects;
        
        topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewEvents" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.backgroundColor=[UIColor clearColor];
        cell.contentView.backgroundColor=[UIColor clearColor];
        
        QBCOCustomObject *obj = [arrEvents objectAtIndex:indexPath.row];
        
        [QBRequest downloadFileFromClassName:@"CourseEvents" objectID:obj.ID fileFieldName:@"Image"
                                successBlock:^(QBResponse *response, NSData *loadedData) {
                                    [cell.imageViewEvents setImage:[UIImage imageWithData:loadedData]];
                                   // [cell.imageViewEvents setContentMode:UIViewContentModeScaleAspectFill];
                                    [cell.imageViewEvents setShowActivityIndicatorView:NO];
                                    
                                } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                                    // handle progress
                                } errorBlock:^(QBResponse *error) {
                                    // error handling
                                    NSLog(@"Response error: %@", [error description]);
                                }];
        
        
        
        
        return cell;
    }
    else
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
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if([tableType isEqualToString:@"EventsTable"])
    {
        QBCOCustomObject *obj = [arrEvents objectAtIndex:indexPath.row];
        
        NSString *description = [obj.fields objectForKey:@"Description"];
        
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Event Description"
                                     message:description
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                    }];
        
        [alert addAction:okButton];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    
   
}

-(IBAction) viewProfile: (button_ViewPro*)sender
{
    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    viewController.userID = sender.proID;
    viewController.strCameFrom = @"6";
    
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)segmentSwitch:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    [basicView setHidden:YES];
    [amenitiesView setHidden:YES];
    [proView setHidden:YES];
    [eventsView setHidden:YES];
    
    switch(selectedSegment)
    {
        case 0:
            [basicView setHidden:NO];
            tableType = @"basicTable";
            break;
        case 1:
            [amenitiesView setHidden:NO];
            tableType = @"AmenitiesTable";
            break;
        case 2:
            [proView setHidden:NO];
            tableType = @"ProTable";
            break;
        case 3:
            [eventsView setHidden:NO];
            tableType = @"EventsTable";
            break;

    }
}

-(IBAction)Sharetapped:(id)sender {
    
    NSString *text = @"Check out this awesome course";
 
    UIImage *image = [UIImage imageNamed:@"bigone.png"];
    
    NSURL *url= [NSURL URLWithString:@"https://itunes.apple.com/us/app/partee-find-a-golf-partner/id1244801350?mt=8"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url,image]
     applicationActivities:nil];
    
     controller.popoverPresentationController.sourceView = sender;
    
    [self presentViewController:controller animated:YES completion:nil];
}

@end
