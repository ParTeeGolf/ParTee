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

#define kIndexFav 0
#define kIndexInfo 1
#define kIndexMap 2
#define kIndexDirection 3
#define kIndexPhoto 4

@interface PurchaseSpecialsViewController ()
{
    
    IBOutlet UIImageView *imgViewHole;
    IBOutlet UILabel *lblHoel;
    NSString *strHoles;
    UIImageView *imgViewUser2;
    UIButton *btnPlus;
    UIButton *btnInfo;
    UIButton *btnSelectUser;
    UIButton *btnViewUser;
    /********* Chetu Change *******/
    // This variable used to create view only when viewdidload called for first time only
    int firstTimeViewLoad;
    /********* Chetu Change *******/
}
@end

@implementation PurchaseSpecialsViewController
@synthesize courseObject,userObject;
@synthesize status;
@synthesize btnFavImage;
@synthesize collectionViewData;

- (void)viewDidLoad {
    [super viewDidLoad];
    strHoles = @"";
    firstTimeViewLoad = 0;
    
    arrAmenities          = [[NSMutableArray alloc] init];
    proTbl.separatorColor = [UIColor clearColor];
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];
    }
    
    self.navigationController.navigationBarHidden=YES;
    
    imgViewUser1.layer.cornerRadius = imgViewUser1.frame.size.width/2;
    imgViewUser1.layer.borderWidth=2.0f;
    [imgViewUser1.layer setMasksToBounds:YES];
    [imgViewUser1.layer setBorderColor:[UIColor whiteColor].CGColor];
    
    [btnInfo setHidden:YES];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
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
            
            if (userIds.count == 0) {
                [proView setHidden:YES];
                [golfPros setHidden:YES];
            }else {
                [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                    
                    [arrData addObjectsFromArray:[objects mutableCopy]];
                    
                    if([arrData count]==0) {
                        
                        [proView setHidden:YES];
                        [golfPros setHidden:YES];
                    }
                    else {
                        [proView setHidden:NO];
                        
                    }
                    
                    [proTable reloadData];
                    [scrollViewContainer setContentSize:CGSizeMake(320, 820)];
                    
                } errorBlock:^(QBResponse *response) {
                    // error handling
                    [[AppDelegate sharedinstance] hideLoader];
                    
                    NSLog(@"Response error: %@", [response.error description]);
                }];
            }
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
        NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Name"]];
        str1 = [str1 uppercaseString];
        [lblName setText:str1];
        
        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Address"]];
        
        NSString *strCity= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"City"]];
        NSString *strState= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"State"]];
        NSString *strZipCode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ZipCode"]];
        
        str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
        [lblAddress setText:str1];
        
        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ContactNumber"]];
        [lblContactNum setTitle:str1 forState:UIControlStateNormal];
        
        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Website"]];
        [lblWebsite setTitle:str1 forState:UIControlStateNormal];
        
        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ForPrivate"]];
        [lblForPrivate setText:str1];
        
        str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"booking"]];
        [lblbooking setTitle:str1 forState:UIControlStateNormal];
        
        NSString *numberOfHolesAvailCourse =  [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"NumberHoles"]];
        NSString *numberOfHolesTemp = [NSString stringWithFormat:@"%@", numberOfHolesAvailCourse];
        int numberOfHoles = [numberOfHolesTemp intValue];
        if (numberOfHoles > 99) {
            lblHoel.font = [UIFont fontWithName:@"Montserrat-Bold" size:13];
        }else if (numberOfHoles > 999){
            lblHoel.font = [UIFont fontWithName:@"Montserrat-Bold" size:9];
        }
        lblHoel.text = numberOfHolesTemp;
        NSArray *items ;
        
        /************ Chetu Change **********/
       
        // Change the amenties data of string into Array data of amenties_tenmp
        str1  = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"amenities_temp"]];
        items = [[[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"amenities_temp"]] copy];
        
        
        //    str1 = [obj.fields objectForKey:@"amenities_temp"];
        //     items =[[obj.fields objectForKey:@"amenities_temp"] copy];
        /************ Chetu Change **********/
        //     str1 = [obj.fields objectForKey:@"Amenities"];
        //     items =[[obj.fields objectForKey:@"Amenities"] copy];
       
        // Add amenties statically to test wheather amenties images showing properly.
  /*
        [arrAmenities addObject:@"ATM"];
                [arrAmenities addObject:@"Bar"];
                [arrAmenities addObject:@"Billiards"];
                [arrAmenities addObject:@"Business Center"];
                [arrAmenities addObject:@"Caddy Hire"];
                [arrAmenities addObject:@"Casino"];
                [arrAmenities addObject:@"Club Fittings"];
                [arrAmenities addObject:@"Club Rental"];
                [arrAmenities addObject:@"Club Repair"];
                [arrAmenities addObject:@"Clubhouse"];
                [arrAmenities addObject:@"Fine Dining"];
                [arrAmenities addObject:@"Drink Cart"];
                [arrAmenities addObject:@"Driving Range"];
                [arrAmenities addObject:@"Event Facilities"];
                [arrAmenities addObject:@"Executive Par 3"];
                [arrAmenities addObject:@"Fitness Center"];
                [arrAmenities addObject:@"Game Room"];
                [arrAmenities addObject:@"Golf Pro"];
                [arrAmenities addObject:@"Handicap Cart"];
                [arrAmenities addObject:@"Locker Room"];
                [arrAmenities addObject:@"Lodging On Site"];
                [arrAmenities addObject:@"Lounge"];
                [arrAmenities addObject:@"Online Tee Times"];
                [arrAmenities addObject:@"Pool"];
                [arrAmenities addObject:@"Pro Shop"];
                [arrAmenities addObject:@"Putting Green"];
                [arrAmenities addObject:@"Restaurant"];
                [arrAmenities addObject:@"Riding Carts"];
                [arrAmenities addObject:@"Showers"];
                [arrAmenities addObject:@"Spa"];
                [arrAmenities addObject:@"Tennis Courts"];
                [arrAmenities addObject:@"Valet Parking"];
                [arrAmenities addObject:@"Webcam"];
                [arrAmenities addObject:@"WiFi"];
       */
  
        if([str1 isKindOfClass:[NSString class]]) {
            if(![str1 isEqualToString:@""]) {
                items= [str1 componentsSeparatedByString:@","];
                
                arrAmenities = [items mutableCopy];
                
                
                if([arrAmenities count]==0) {
                    [collectionViewData setHidden:YES];
                    [self hideOrShowAmenties:YES];
                    [lblNotFound setHidden:NO];
                    
                }
                else {
                    [collectionViewData setHidden:NO];
                    [self hideOrShowAmenties:NO];
                    [lblNotFound setHidden:YES];
                    
                }
                
                [collectionViewData reloadData];
            }else {
                
                amentiesLbl.hidden = YES;
                
            }
            
        }
        
        if([str1 isKindOfClass:[NSArray class]]) {
            if([items count]>0) {
                
                arrAmenities = [items mutableCopy];
                
                if([arrAmenities count]==0) {
                    [collectionViewData setHidden:YES];
                    [self hideOrShowAmenties:YES];
                    [lblNotFound setHidden:NO];
                   
                }
                else {
                    [collectionViewData setHidden:NO];
                    [self hideOrShowAmenties:NO];
                    [lblNotFound setHidden:YES];
                    
                   
                }
                
                [collectionViewData reloadData];
            }
            else {
                amentiesLbl.hidden = YES;
               
            }
            
        }
        
        
        [imageUrl setShowActivityIndicatorView:YES];
        [imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
        
        NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
        
        if(!arr || arr.count==0)
            arr = [[NSMutableArray alloc] init];
        
        NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
        
        
        if([AppDelegate sharedinstance].delegateShareObject) {
            
            [btnPlus setHidden:YES];
            
            imgViewUser2.layer.cornerRadius = imgViewUser2.frame.size.width/2;
            imgViewUser2.layer.borderWidth=2.0f;
            [imgViewUser2.layer setMasksToBounds:YES];
            [imgViewUser2.layer setBorderColor:[UIColor whiteColor].CGColor];
            
            QBCOCustomObject *obj = [AppDelegate sharedinstance].delegateShareObject;
            
            [imgViewUser2 setShowActivityIndicatorView:YES];
            [imgViewUser2 setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [ imgViewUser2 sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"]];
        }
    }
    else if(status==3) {
        [btnInfo setHidden:NO];
        [btnSendInviteBig setHidden:YES];
        [btnSendInviteSmall setHidden:YES];
        
        [lblTitle setText:@"Courses"];
        
        [btnInfo setHidden:NO];
        [btnSendInviteBig setHidden:YES];
        [btnSendInviteSmall setHidden:YES];
        [btnPlus setHidden:YES];
        
        [self bindDataForUser];
        
        
    }
    else if (status ==5) {
        [lblTitle setText:@"Accepted"];
        
        [btnInfo setHidden:NO];
        [btnSendInviteBig setHidden:YES];
        [btnSendInviteSmall setHidden:YES];
        [btnPlus setHidden:YES];
        
        [self bindDataForUser];
        
        if([AppDelegate sharedinstance].delegateShareObject) {
            
            [btnPlus setHidden:YES];
            
            imgViewUser2.layer.cornerRadius = imgViewUser2.frame.size.width/2;
            imgViewUser2.layer.borderWidth=2.0f;
            [imgViewUser2.layer setMasksToBounds:YES];
            [imgViewUser2.layer setBorderColor:[UIColor whiteColor].CGColor];
            
            QBCOCustomObject *obj = [AppDelegate sharedinstance].delegateShareObject;
            
            [imgViewUser2 setShowActivityIndicatorView:YES];
            [imgViewUser2 setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [ imgViewUser2 sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"]];
        }
        
    }
    else {
        [self bindData];
        
        [btnInfo setHidden:YES];
        
        if([AppDelegate sharedinstance].delegateShareObject) {
            [btnPlus setHidden:YES];
            
            imgViewUser2.layer.cornerRadius = imgViewUser2.frame.size.width/2;
            imgViewUser2.layer.borderWidth=2.0f;
            [imgViewUser2.layer setMasksToBounds:YES];
            [imgViewUser2.layer setBorderColor:[UIColor whiteColor].CGColor];
            
            QBCOCustomObject *obj = [AppDelegate sharedinstance].delegateShareObject;
            
            [imgViewUser2 setShowActivityIndicatorView:YES];
            [imgViewUser2 setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            [ imgViewUser2 sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"]];
        }
    }
    
    NSMutableDictionary *dictUserData = [[[NSUserDefaults standardUserDefaults] objectForKey:kuserData] mutableCopy];
    NSString *userImageUrl = [NSString stringWithFormat:@"%@", [dictUserData objectForKey:@"userPicBase"]];
    [ imgViewUser1 sd_setImageWithURL:[NSURL URLWithString:userImageUrl ] placeholderImage:[UIImage imageNamed:@"user"]];
    
    if (firstTimeViewLoad == 0) {
        [self updateConstarintsProgrammatically];
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
    
  
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ContactNumber"]];
    [lblContactNum setTitle:str1 forState:UIControlStateNormal];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Website"]];
    [lblWebsite setTitle:str1 forState:UIControlStateNormal];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"booking"]];
    [lblbooking setTitle:str1 forState:UIControlStateNormal];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ForPrivate"]];
    [lblForPrivate setText:str1];
    
    // Change the amenties data of string into Array data of amenties_tenmp
    //   str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Amenities"]];
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"amenities_temp"]];
    
    NSString *numberOfHolesAvailCourse =  [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"NumberHoles"]];
    numberOfHolesAvailCourse = [NSString stringWithFormat:@"%@", numberOfHolesAvailCourse];
 
    NSString *numberOfHolesTemp = [NSString stringWithFormat:@"%@", numberOfHolesAvailCourse];
    int numberOfHoles = [numberOfHolesTemp intValue];
    if (numberOfHoles > 99) {
        lblHoel.font = [UIFont fontWithName:@"Montserrat-Bold" size:13];
    }else if (numberOfHoles > 999){
        lblHoel.font = [UIFont fontWithName:@"Montserrat-Bold" size:9];
    }
    
    lblHoel.text = [NSString stringWithFormat:@"%@", numberOfHolesAvailCourse];
    NSArray *items = [str1 componentsSeparatedByString:@","];
    NSMutableString * bulletList = [NSMutableString stringWithCapacity:items.count*30];
    
    for (NSString * s in items)
    {
        [bulletList appendFormat:@"\u2022 %@\n", s];
    }
    
    tvAmenities.text = bulletList;
    arrAmenities = [items mutableCopy];
    
    for (NSString *strHole in arrAmenities) {
        
        
        if ([strHole localizedCaseInsensitiveContainsString:@"hole"]) {
            
            strHoles = [NSString stringWithFormat:@"%@\n%@", strHoles, strHole];
        }
    }
    
  
    if([arrAmenities count]==0) {
        [collectionViewData setHidden:YES];
        [self hideOrShowAmenties:YES];
        [lblNotFound setHidden:NO];
      
    }
    else {
        [collectionViewData setHidden:NO];
        [self hideOrShowAmenties:NO];
        [lblNotFound setHidden:YES];
        
    }
    
    [collectionViewData reloadData];
    
    
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        isFavCourse = YES;
    }
    else {
        isFavCourse = NO;
        
    }
    
    imgViewUser2.layer.cornerRadius = imgViewUser2.frame.size.width/2;
    imgViewUser2.layer.borderWidth=2.0f;
    [imgViewUser2.layer setMasksToBounds:YES];
    [imgViewUser2.layer setBorderColor:[UIColor whiteColor].CGColor];
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
        
        [imgViewUser2 setShowActivityIndicatorView:YES];
        [imgViewUser2 setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        otherUserObj = [objects objectAtIndex:0];
        
        [imgViewUser2 sd_setImageWithURL:[NSURL URLWithString:[otherUserObj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"]];
        
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
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ContactNumber"]];
    [lblContactNum setTitle:str1 forState:UIControlStateNormal];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"Website"]];
    [lblWebsite setTitle:str1 forState:UIControlStateNormal];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"ForPrivate"]];
    [lblForPrivate setText:str1];
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"booking"]];
    [lblbooking setTitle:str1 forState:UIControlStateNormal];
    
    // Change the amenties data of string into Array data of amenties_tenmp
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"amenities_temp"]];
    
    NSString *numberOfHolesAvailCourse =  [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"NumberHoles"]];
 
    NSString *numberOfHolesTemp = [NSString stringWithFormat:@"%@", numberOfHolesAvailCourse];
    int numberOfHoles = [numberOfHolesTemp intValue];
    if (numberOfHoles > 99) {
        lblHoel.font = [UIFont fontWithName:@"Montserrat-Bold" size:13];
    }else if (numberOfHoles > 999){
        lblHoel.font = [UIFont fontWithName:@"Montserrat-Bold" size:9];
    }
    
    lblHoel.text = numberOfHolesTemp;
    
    NSArray *items = [str1 componentsSeparatedByString:@","];
    
    NSMutableString * bulletList = [NSMutableString stringWithCapacity:items.count*30];
    
    for (NSString * s in items)
    {
        [bulletList appendFormat:@"\u2022 %@\n", s];
    }
    
    tvAmenities.text = bulletList;
    
    [imageUrl setShowActivityIndicatorView:YES];
    [imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [imageUrl sd_setImageWithURL:[NSURL URLWithString:[userObject.fields objectForKey:@"ImageUrl"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
    
    NSMutableArray *arr = [[obj.fields objectForKey:@"userFavID"] mutableCopy];
    
    if(!arr || arr.count==0)
        arr = [[NSMutableArray alloc] init];
    
    NSString *strCurrentUserID = [[AppDelegate sharedinstance] getCurrentUserId];
    
    if([arr containsObject:strCurrentUserID]) {
        isFavCourse = YES;
     
    }
    else {
        isFavCourse = NO;
        
    }
    
    arrAmenities = [items mutableCopy];
    
    for (NSString *strHole in arrAmenities) {
        
        
        if ([strHole localizedCaseInsensitiveContainsString:@"hole"]) {
            
            strHoles = [NSString stringWithFormat:@"%@\n%@", strHoles, strHole];
        }
    }
   
    if([arrAmenities count]==0) {
        [collectionViewData setHidden:YES];
        [self hideOrShowAmenties:YES];
        [lblNotFound setHidden:NO];
    }
    else {
        [collectionViewData setHidden:NO];
        [self hideOrShowAmenties:NO];
        [lblNotFound setHidden:YES];
    
    }
    
    [collectionViewData reloadData];
}

//update views according to device that have been created using xib
-(void)updateConstarintsProgrammatically {
    CGFloat width = self.view.frame.size.width;
    
    firstTimeViewLoad = 1;
    imgViewUser1.frame = CGRectMake(34, 23, 70, 70);
    _keyImg.frame = CGRectMake((width - 40 )/2,23, 40, 68);
    
    
    imgViewUser2 = [[UIImageView alloc]initWithFrame:CGRectMake(width - 37 - 70, 23, 70, 70)];
    imgViewUser2.image = [UIImage imageNamed:@"Placeholder.png"];
    imgViewUser2.hidden = YES;
    [scrollViewContainer addSubview:imgViewUser2];
    
    btnPlus = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnPlus.frame = CGRectMake(17.5 , 17.5, 35, 35);
    btnPlus.hidden = YES;
    [btnPlus setBackgroundImage:[UIImage imageNamed:@"Plusadd.png"] forState:UIControlStateNormal];
    [imgViewUser2 addSubview:btnPlus];
    
    btnInfo = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnInfo.frame = CGRectMake(width - 20 - 30, 15, 30, 30);
    [btnInfo setBackgroundImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    btnInfo.hidden = true;
    [scrollViewContainer addSubview:btnInfo];
    
    btnViewUser = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnViewUser.frame = CGRectMake(width - 26 - 88, 15, 88, 88);
    [btnViewUser addTarget:self action:@selector(viewUser:) forControlEvents:UIControlEventTouchUpInside];
    [scrollViewContainer addSubview:btnViewUser];
    
    btnSelectUser = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnSelectUser.frame = CGRectMake(width - 20 - 94, 23, 94, 78);
    [btnSelectUser addTarget:self action:@selector(selectUser:) forControlEvents:UIControlEventTouchUpInside];
    [scrollViewContainer addSubview:btnSelectUser];
    
    btnViewUser.hidden = YES;
    btnViewUser.hidden = YES;
    btnSelectUser.hidden = YES;
    
    imageUrl.frame = CGRectMake(0,10 , width, 180);
    narrowLineView1.frame = CGRectMake(0, 10, width, 180);
    imgViewHole.frame = CGRectMake(10, 50, 60, 60);
    lblHoel.frame = CGRectMake(35, 73, 25, 25);
    lblName.frame = CGRectMake(5, 140, width - 10, 30);
    lblAddress.frame = CGRectMake(5, 160, width - 10, 30);
    btnFav.frame = CGRectMake(width - 62, 0, 51, 62);
    btnFavImage.frame = CGRectMake(width - 8 - 16, 27, 8, 27);
    narrowlineView2.frame = CGRectMake(0, imageUrl.frame.origin.y + imageUrl.frame.size.height, width, narrowlineView2.frame.size.height);
    
    phoneLbl.frame = CGRectMake(phoneLbl.frame.origin.x,imageUrl.frame.origin.y + imageUrl.frame.size.height+ 4 , phoneLbl.frame.size.width, phoneLbl.frame.size.height);
    lblContactNum.frame = CGRectMake(lblContactNum.frame.origin.x, phoneLbl.frame.origin.y, width - (lblContactNum.frame.origin.x), lblContactNum.frame.size.height);
    
    websiteLbl.frame = CGRectMake(websiteLbl.frame.origin.x,phoneLbl.frame.origin.y + phoneLbl.frame.size.height + 4, websiteLbl.frame.size.width, websiteLbl.frame.size.height);
    lblWebsite.frame = CGRectMake(lblWebsite.frame.origin.x, websiteLbl.frame.origin.y, width - (lblWebsite.frame.origin.x), lblWebsite.frame.size.height);
    
    teeTimeLbl.frame = CGRectMake(teeTimeLbl.frame.origin.x,websiteLbl.frame.origin.y + websiteLbl.frame.size.height + 4 , teeTimeLbl.frame.size.width, teeTimeLbl.frame.size.height);
    lblbooking.frame = CGRectMake(lblbooking.frame.origin.x, teeTimeLbl.frame.origin.y, width - (lblbooking.frame.origin.x), lblbooking.frame.size.height);
    
    amentiesLbl.frame = CGRectMake(amentiesLbl.frame.origin.x,teeTimeLbl.frame.origin.y + teeTimeLbl.frame.size.height + 4 , amentiesLbl.frame.size.width, amentiesLbl.frame.size.height);
    
    collectionViewData.frame = CGRectMake(collectionViewData.frame.origin.x, amentiesLbl.frame.origin.y + amentiesLbl.frame.size.height + 4 , width, collectionViewData.frame.size.height);
    
    proView.frame = CGRectMake(proView.frame.origin.x,amentiesLbl.frame.origin.y + amentiesLbl.frame.size.height + 17 , self.view.frame.size.width, self.view.frame.size.height - (amentiesLbl.frame.origin.y + amentiesLbl.frame.size.height + 17));
    golfPros.frame = CGRectMake(golfPros.frame.origin.x, golfPros.frame.origin.y, width - (golfPros.frame.origin.x), golfPros.frame.size.height);
    proBaseView.frame = CGRectMake(proBaseView.frame.origin.x, proBaseView.frame.origin.y, width, proBaseView.frame.size.height);
    proTbl.frame = CGRectMake(proTbl.frame.origin.x, proTbl.frame.origin.y, width, proView.frame.size.height - (golfPros.frame.size.height + 90));
    
    
    if([arrAmenities count]==0) {
        
        [self hideOrShowAmenties:YES];
        collectionViewData.hidden = YES;
    }else{
      
        [self hideOrShowAmenties:NO];
        collectionViewData.hidden = NO;
    }
    
    
}
-(void)hideOrShowAmenties:(BOOL)hide
{
    if (hide) {
        
        proView.frame = CGRectMake(proView.frame.origin.x,amentiesLbl.frame.origin.y + amentiesLbl.frame.size.height + 17 , self.view.frame.size.width, self.view.frame.size.height - (amentiesLbl.frame.origin.y + amentiesLbl.frame.size.height + 27));
        golfPros.frame = CGRectMake(golfPros.frame.origin.x, golfPros.frame.origin.y, self.view.frame.size.width - (golfPros.frame.origin.x), golfPros.frame.size.height);
        proBaseView.frame = CGRectMake(proBaseView.frame.origin.x, proBaseView.frame.origin.y, self.view.frame.size.width, proBaseView.frame.size.height);
        proTbl.frame = CGRectMake(proTbl.frame.origin.x, proTbl.frame.origin.y, self.view.frame.size.width, proView.frame.size.height - (golfPros.frame.size.height + 70));
        
    }else{
        
        proView.frame = CGRectMake(proView.frame.origin.x,collectionViewData.frame.origin.y + collectionViewData.frame.size.height + 17 , self.view.frame.size.width, self.view.frame.size.height - (collectionViewData.frame.origin.y + collectionViewData.frame.size.height + 27));
        golfPros.frame = CGRectMake(golfPros.frame.origin.x, golfPros.frame.origin.y, self.view.frame.size.width - (golfPros.frame.origin.x), golfPros.frame.size.height);
        proBaseView.frame = CGRectMake(proBaseView.frame.origin.x, proBaseView.frame.origin.y, self.view.frame.size.width, proBaseView.frame.size.height);
        proTbl.frame = CGRectMake(proTbl.frame.origin.x, proTbl.frame.origin.y, self.view.frame.size.width, proView.frame.size.height - (golfPros.frame.size.height + 70));
    }
    
}
//-----------------------------------------------------------------------

-(void)viewUser:(id)sender {
    
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


-(IBAction)websitepressed:(id)sender {
    
    NSString *strWebsite = lblWebsite.titleLabel.text;
    
    strWebsite = [NSString stringWithFormat:@"http://%@",strWebsite];
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL] options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

-(IBAction)bookingpressed:(id)sender {
    
    NSString *strWebsite = lblbooking.titleLabel.text;
    
    strWebsite = [NSString stringWithFormat:@"http://%@",strWebsite];
    
    NSString *URL =strWebsite;// lblWebsite.titleLabel.text;
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:URL]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URL] options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

-(IBAction)phonepressed:(id)sender {
    
    NSString *strPhn = lblContactNum.titleLabel.text;
    strPhn = [strPhn stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *phoneNumber =[NSString stringWithFormat:@"tel://%@",strPhn];
    
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber] options:[[NSDictionary alloc] init] completionHandler:nil];
    }
}

-(void)selectUser:(id)sender {
    
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
        
        
    }
    else {
        
        ViewSpecialInvite *vc = [[ViewSpecialInvite alloc] initWithNibName:@"ViewSpecialInvite" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        
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
    /********** ChetuChange *************/
    
    [object.fields setObject:@"TEStValue" forKey:@"courseReceiverID"];
    
    /********** ChetuChange *************/
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
    [self.collectionViewData setBackgroundColor:[UIColor clearColor]];
    
    [self.collectionViewData registerClass:[CVCell class] forCellWithReuseIdentifier:@"cvCell"];
    
    // Configure layout
    // Configure layout 209 (200) 276
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setItemSize:CGSizeMake(60, 86)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self.collectionViewData setCollectionViewLayout:flowLayout];
    
    
    [self.collectionViewData setPagingEnabled:NO];
    
    self.collectionViewData.bounces = YES;
    [self.collectionViewData setShowsHorizontalScrollIndicator:YES];
    [self.collectionViewData setShowsVerticalScrollIndicator:YES];
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

-(void) temp {
    
    [self.collectionViewData reloadData];
}

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
    NSString *trimmedString = [strName stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    UIImage *amentyImage = [UIImage imageNamed:trimmedString];
    if (amentyImage == nil) {
       amentyImage = [UIImage imageNamed:@"amenitiesDefault"];
    }
    
    [cell.imgViewUser setImage:amentyImage];
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
    NSInteger numberOfOptions = 5;
    NSArray *items;
    
   
    NSString *favoriteTitle = isFavCourse==YES ? @"Unfavorite" : @"Mark Favorite";
    
    NSString *favImgStr = @"";
 
    if ([favoriteTitle isEqualToString: @"Unfavorite"]) {
        favImgStr = @"fav.png";
    }else {
        favImgStr = @"unfav";
    }
    items= @[
            
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:favImgStr] title:favoriteTitle],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"info-filled"] title:@"Information"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"viewmap"] title:@"On Map"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:@"direction"] title:@"Directions"],
             [[RNGridMenuItem alloc] initWithImage:[UIImage imageNamed:kShareImg] title:kShareTitle]
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
        case kIndexInfo:
            [self actionInfo];
            break;
        case kIndexMap:
            [self actionMap];
            break;
        case kIndexDirection:
            [self actionDirection];
            break;
        case kIndexPhoto:
            // [self actionPhoto];
            [self shareLinkViaSocialApp];
            break;
    }
}
#pragma mark- grid Delegate
/**
 @Description
 * Share artcile link via social networking application available on the device.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)shareLinkViaSocialApp
{
    
    NSLog(@"%@", courseObject);

   
    //  (Title of Event, Date of Event, Location of Event, info text of event.)
    NSString *courseName = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"Name"]];
    NSString *address = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"Address"]];
    NSString *cityName = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"City"]];
    NSString *stateName = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"State"]];
    NSString *zipcode = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"ZipCode"]];
    NSString *phoneNumber = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"ContactNumber"]];
    NSString *websiteName = [[AppDelegate sharedinstance] nullcheck:[courseObject.fields objectForKey:@"Website"]];
    NSArray * activityItems = @[[NSString stringWithFormat:@"Check out this course I found in the ParTee App!\n\n%@\n%@\n%@, %@, %@\n%@\n%@",courseName, address, cityName,stateName,zipcode, phoneNumber, websiteName]];
    NSArray * applicationActivities = nil;
    
    UIActivityViewController * activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:applicationActivities];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        activityController.popoverPresentationController.sourceView = self.view;
        
        [self presentViewController:activityController
                           animated:YES
                         completion:nil];
    }
    else
    {
        [self presentViewController:activityController
                           animated:YES
                         completion:nil];
    }
    
}
-(void) actionPhoto {
    
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
    
    [cell.imageUrl setShowActivityIndicatorView:YES];
    [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    cell.profileButton.layer.cornerRadius = 10;
    cell.profileButton.proID = obj.ID;
    
    [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.imageUrl setImage:image];
        [cell.imageUrl setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageUrl setShowActivityIndicatorView:NO];
        
    }];
    
    [cell.proIcon setImage:[UIImage imageWithData:[[AppDelegate sharedinstance] getProIcons:[obj.fields objectForKey:@"ProType"]]]];
    [cell.proIcon setContentMode:UIViewContentModeScaleAspectFill];
    [cell.proIcon setShowActivityIndicatorView:NO];
    
    return cell;
    
}

-(IBAction) viewProfile: (button_ViewPro*)sender
{
    PreviewProfileViewController *viewController;
    viewController    = [[PreviewProfileViewController alloc] initWithNibName:@"PreviewProfileViewController" bundle:nil];
    
    viewController.userID = sender.proID;
    viewController.strCameFrom = @"6";
    
    [self.navigationController pushViewController:viewController animated:YES];
}

@end

