//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "SettingsViewController.h"
#import "HomeViewController.h"
#import "CoursePreferencesViewController.h"
#import "CourseCellTableViewCell.h"

#define kButtonCity 1
#define kButtonzipcode 2
#define kButtonType 3
#define kButtonState 4
#define kButtonname 5
#define kButtonamenities 6

#define kPickerState 1
#define kPickerType 2
#define kPickerHoles 3
#define kButtonHoles 7

#define kScreenViewUsers @"1"
#define kScreenMenu @"2"

@interface CoursePreferencesViewController ()
{
    int currentPage;
    NSString *selectedState;
    
    NSMutableArray *tempCitySelctedArr;
    NSMutableArray *tempAmentiesSelctedArr;
    
    int tempCurrentPage;
    NSMutableArray *tempCourseArr;
    QBCOCustomObject *courseObject;
    int objCountUpdated;
    int CountUpdated;
    int updateCountObj;
    
    IBOutlet UITextField *txtFldHolesCourses;
}
@end

@implementation CoursePreferencesViewController
@synthesize cameFromScreen;

- (void)viewDidLoad {
    [super viewDidLoad];
    objCountUpdated = 0;
    tempCurrentPage = 0;
    CountUpdated = 0;
    updateCountObj = 0;
    
    tempCourseArr = [[NSMutableArray alloc]init];
    
    
    tempCitySelctedArr           = [[NSMutableArray alloc]init];
    tempAmentiesSelctedArr       = [[NSMutableArray alloc]init];
    
    
    currentPage = 0;
    UIImage *thumb = [UIImage imageNamed:@"filledcircle"];
    [myObSliderOutlet setThumbImage:thumb forState:UIControlStateNormal];
    [myObSliderOutlet setThumbImage:thumb forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    
    if([[AppDelegate sharedinstance].strisDevelopment isEqualToString:@"1"]) {
        [btnDevOn setHidden:NO];
    }
    else {
        [btnDevOn setHidden:YES];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    [pickerView setHidden:YES];
    
    [tblMembers setSeparatorColor:[UIColor clearColor]];
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    
    self.navigationController.navigationBarHidden=YES;
    
    arrTypeList = [[NSMutableArray alloc] init];
    arrCityList = [[NSMutableArray alloc] init];
    arrCityStateList = [[NSMutableArray alloc] init];
    arrStateList = [[NSMutableArray alloc] init];
    arrHomeCourseList = [[NSMutableArray alloc] init];
    arramenitiesList = [[NSMutableArray alloc] init];
    arrHolesList = [[NSMutableArray alloc]init];
   // [self setUpAmenitiesList];
    
    //  tempArraySelcted=[[NSMutableArray alloc]init];
    
    if(isiPhone4) {
        [scrollViewContainer setContentSize:CGSizeMake(320, 650)];
    }
    
    [tblMembers reloadData];
    myObSliderOutlet.value =0;
    
    //  [self bindData];
    // Get the state details from quickblox table.
 // [self getStateList];
    [self getAmentiesList];
    
}

-(void) viewWillAppear:(BOOL)animated {
    self.menuContainerViewController.panMode = NO;
    
    /*
     if([cameFromScreen isEqualToString:kScreenViewUsers]) {
     [btnBack setBackgroundImage:[UIImage imageNamed:@"ico-back"] forState:UIControlStateNormal];
     [btnBack setFrame:CGRectMake(15, 30, 11, 20)];
     
     }
     else {
     [btnBack setBackgroundImage:[UIImage imageNamed:@"Menu.png"] forState:UIControlStateNormal];
     [btnBack setFrame:CGRectMake(15, 34, 20, 16)];
     
     }*/
    
}

#pragma mark- Get State List
/**
 @Description
 * This method will fetch Amenties list from quickblox table.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getAmentiesList {
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:kCourseAmenties extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
       
        
        for (QBCOCustomObject *obj  in objects) {
            
            [arramenitiesList addObject:[obj.fields objectForKey:@"Amenties"]];
        }
      
        // sort the state list.
        [arramenitiesList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arramenitiesList insertObject:@"Any" atIndex:0];
        
        [self getHolesList];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark- Get State List
/**
 @Description
 * This method will fetch Amenties list from quickblox table.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getHolesList {
    
    [QBRequest objectsWithClassName:kCourseHoles extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
       
        for (QBCOCustomObject *obj  in objects) {
            
            [arrHolesList addObject:[obj.fields objectForKey:@"NoOfHoles"]];
        }
        
        // sort the state list.
      
        
        [arrHolesList insertObject:@"All" atIndex:0];
        
        [self getStateList];
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}


#pragma mark- Get State List
/**
 @Description
 * This method will fetch state list from quickblox table.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getStateList {
    
   // [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:kEventStateTblName extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            NSString *strState = [obj.fields objectForKey:kEventStateName];
            
            if(![arrStateList containsObject:strState])
            {
                [arrStateList addObject:strState];
            }
            
        }
        // sort the state list.
        [arrStateList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arrStateList insertObject:kEventAll atIndex:0];
        
        [self getTypeList];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}
#pragma mark- Get City List
/**
 @Description
 * This method will fetch city list from GolfCourses table based on state selected.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getcityList
{
    [[AppDelegate sharedinstance] showLoader];
    
    NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
    [getRequestObjectCount setObject: selectedState forKey:kCourseState];
    
    [getRequestObjectCount setObject:kAdEventLimit forKey:kEventLimitParam];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kAdEventLimit intValue] * currentPage];
    
    [getRequestObjectCount setObject:strPage forKey:@"skip"];
    
    [QBRequest objectsWithClassName:kEventGolfCourse extendedRequest:getRequestObjectCount successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            if(![arrCityList containsObject:[obj.fields objectForKey:kCourseCity]])
            {
                [arrCityList addObject:[obj.fields objectForKey:kCourseCity]];
            }
        }
        
        currentPage++;
        if (objects.count < 100) {
            
            [arrCityList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            
            [arrCityList insertObject:kEventAll atIndex:0];
            [tblMembers reloadData];
            tblMembers.allowsMultipleSelection = YES;
            
            [[AppDelegate sharedinstance] hideLoader];
            
        }else {
            [self getcityList];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}

-(void)getTypeList {
    
    [QBRequest objectsWithClassName:@"CourseType" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        arrData=[objects mutableCopy];
        
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            
            NSString *strType = [obj.fields objectForKey:@"CourseType"];
            if(![arrTypeList containsObject:strType])
            {
                [arrTypeList addObject:strType];
            }
            
        }
        
        [arrTypeList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [arrTypeList insertObject:@"All" atIndex:0];
        
        [self bindData];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
}




-(void) bindData {
    
    /*
     [[AppDelegate sharedinstance] showLoader];
     NSMutableDictionary *getRequestObjectCount = [NSMutableDictionary dictionary];
     //  [getRequestObjectCount setObject:@"1" forKey:@"count"];
     //  [getRequestObjectCount setObject: @"" forKey:@"State"];
     
     [getRequestObjectCount setObject:@"100" forKey:@"limit"];
     NSString *strPage = [NSString stringWithFormat:@"%d",[@"100" intValue] * currentPage];
     
     [getRequestObjectCount setObject:strPage forKey:@"skip"];
     
     [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
     
     NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
     arrData=[objects mutableCopy];
     
     for(int i=0;i<[objects count];i++) {
     QBCOCustomObject *obj = [arrData objectAtIndex:i];
     NSString *strType = [obj.fields objectForKey:@"CourseType"];
     NSString *strState = [obj.fields objectForKey:@"State"];
     NSString *strCity = [obj.fields objectForKey:@"City"];
     
     NSArray *cityState = @[strCity, strState];
     
     if(![arrTypeList containsObject:strType])
     {
     [arrTypeList addObject:strType];
     }
     
     if(![arrStateList containsObject:strState])
     {
     [arrStateList addObject:strState];
     }
     
     if(![arrCityStateList containsObject:cityState])
     {
     [arrCityStateList addObject:cityState];
     }
     }
     
     [arrStateList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
     [arrTypeList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
     
     [arrStateList insertObject:@"All" atIndex:0];
     [arrTypeList insertObject:@"All" atIndex:0];
     
     
     
     } errorBlock:^(QBResponse *response) {
     // error handling
     [[AppDelegate sharedinstance] hideLoader];
     
     NSLog(@"Response error: %@", [response.error description]);
     }];
     
     */
    
    //  [[AppDelegate sharedinstance] showLoader];
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        // response processing
        
        // checking user there in custom user table or not.
        arrData = objects;
        
        //    [[AppDelegate sharedinstance] hideLoader];
        
        if([objects count]>0) {
            
            [AppDelegate sharedinstance].isUpdate=YES;
            
            // If user exists, get info from server
            object =  [arrData objectAtIndex:0];
            
            NSString *strLocation = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_distance"]];
            
            if([strLocation length]==0 || myObSliderOutlet.value>99 || [strLocation isEqualToString:@"150"]) {
                
                [lblDistanceValue setText:@"∞"];
                myObSliderOutlet.value = 150;
            }
            else {
                myObSliderOutlet.value = [strLocation integerValue];
                [lblDistanceValue setText:[NSString stringWithFormat:@"%d mi.",(int)myObSliderOutlet.value]];
            }
            
            strPush = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_isFav"]];
            
            if (self.isFromFavCourseSearch == 1) {
                strPush=@"1";
                [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];
                
            }else {
                if([strPush isEqualToString:@"1"]) {
                    
                    [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];
                }
                else {
                    [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOff"] forState:UIControlStateNormal];
                    
                }
            }
            
            
            
            NSString *strState = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_state"]];
            NSString *str_cf_city= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_city"]];
            
            NSString *strcf_name = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_name"]];
            NSString *strcf_zipcode= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_zipcode"]];
            NSString *strcf_HolesAvailable = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_Holes"]];
            
            if([strcf_HolesAvailable length]==0) {
                [txtFldHolesCourses setText:@"All"];
            }else {
                [txtFldHolesCourses setText:strcf_HolesAvailable];
            }
            
            
            if([strcf_zipcode length]==0 || [strcf_zipcode isEqualToString:@"All"] ) {
                [txtCourseZipcode setText:@"All"];
                
            }
            else {
                [txtCourseZipcode setText:strcf_zipcode];
            }
            
            
            if([str_cf_city length]==0) {
                [txtCity setText:@"All"];
                
            }
            else {
                [txtCity setText:str_cf_city];
            }
            
            if([strState length]==0) {
                [txtState setText:@"All"];
                selectedState = strState;
            }
            else {
                selectedState = strState;
                [txtState setText:strState];
            }
            
            if([strcf_name length]==0) {
                [txtCourseName setText:@"All"];
            }
            else {
                [txtCourseName setText:strcf_name];
            }
            
            NSString *strType = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_type"]];
            
            if([strType length] == 0)
            {
                strType = @"All";
            }
            
            [txtType setText:strType];
            
        }
        else {
            
            strPush=@"1";
            
            [btnPush  setImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];
            
        }
        
        NSString *strDevMode = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"isDevelopment"]];
        isDev = strDevMode;
        
        if([strDevMode isEqualToString:@"1"]) {
            
            [btnDevOn setTitle:@"Dev-OFF" forState:UIControlStateNormal];
        }
        else {
            [btnDevOn setTitle:@"Dev-ON" forState:UIControlStateNormal];
            
        }
        NSString *strcf_amenities= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_amenities"]];
        NSArray *items = [strcf_amenities componentsSeparatedByString:@","];
        for (id amenities in items) {
            [tempAmentiesSelctedArr addObject:amenities];
        }
        
        NSString *strcf_city= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:@"cf_city"]];
        NSArray *cityItems = [strcf_city componentsSeparatedByString:@","];
        for (id city in cityItems) {
            [tempCitySelctedArr addObject:city];
        }
        
        
        
        [tblMembers reloadData];
        if([strcf_amenities length]==0) {
            
            [txtAmenities setText:@"Any"];
        }
        else {
            [txtAmenities setText:strcf_amenities];
            
        }
        
        if ([txtState.text isEqualToString:@"All"]) {
            [[AppDelegate sharedinstance] hideLoader];
        }else {
            [self getcityList];
            
        }
    }
     
     
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
    
    
    
}


- (IBAction) pushTapped:(id)sender {
    
    if([strPush isEqualToString:@"1"]) {
        strPush=@"0";
        [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOff"] forState:UIControlStateNormal];
        
    }
    else {
        strPush=@"1";
        [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOn"] forState:UIControlStateNormal];
    }
}

- (IBAction) saveTapped:(id)sender {
    
    [self savesettings];
 //    [[AppDelegate sharedinstance] showLoader];
   //   [self getData];
}

////-----------------------------------------------------------------------
///************* Updated Amenties data string to amenties_temp data. **********/
-(void) getData
{

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];

    [getRequest setObject:@"100" forKey:@"limit"];
    NSString *strPage = [NSString stringWithFormat:@"%d",[@"100" intValue] * tempCurrentPage];

    [getRequest setObject:strPage forKey:@"skip"];

    [QBRequest objectsWithClassName:@"GolfCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {

        if (objects.count == 0) {
              [[AppDelegate sharedinstance] hideLoader];
        }else {
            NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
            tempCourseArr = [[NSMutableArray alloc] init];
            [tempCourseArr addObjectsFromArray:[objects mutableCopy]];
            [self updateGolfCourses:tempCourseArr];
            CountUpdated = (int)tempCourseArr.count;
        }

    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];

        NSLog(@"Response error: %@", [response.error description]);
    }];

}

-(void) updateGolfCourses:(NSMutableArray *)tempCourseArr1 {


    [self upadteobj:[tempCourseArr objectAtIndex:0]];

}

-(void)upadteobj:(QBCOCustomObject *) tempObj
{

         NSArray *amentyArr = [ [[AppDelegate sharedinstance] nullcheck:[tempObj.fields objectForKey:@"Amenities"]] componentsSeparatedByString: @","];


         NSMutableArray *copy = [amentyArr mutableCopy];
         if ([copy containsObject:@"N/A"]) {
             [copy removeObject:@"N/A"];
         }
         NSMutableArray *tempCopyArr = [copy mutableCopy];

    
    
    
    for (id holeStr in tempCopyArr) {

        if ([holeStr localizedCaseInsensitiveContainsString:@"hole"]) {

            [copy removeObject:holeStr];
        }
    }

    NSMutableArray *FinalAmentyArr = [[NSMutableArray alloc]init];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    for (NSString *amentyStr in tempCopyArr) {
        
        NSString *trimmed = [amentyStr stringByTrimmingCharactersInSet:whitespace];
        [FinalAmentyArr addObject:trimmed];
    }
    
//    if ([copy containsObject:@"Chipping Green"]) {
//        [copy removeObject:@"Chipping Green"];
//    }
 
    if ([FinalAmentyArr containsObject:@"Chipping Green"] ||
        [FinalAmentyArr containsObject:@"4 Restaurants"] ||
        [FinalAmentyArr containsObject:@"Beverage Service"] ||
        [FinalAmentyArr containsObject:@"Changing Area"] ||
        [FinalAmentyArr containsObject:@"Club Rentals"] ||
        [FinalAmentyArr containsObject:@"Cold Towel"] ||
        [FinalAmentyArr containsObject:@"Couple's League"] ||
        [FinalAmentyArr containsObject:@"Desert"] ||
        [FinalAmentyArr containsObject:@"Events"] ||
        [FinalAmentyArr containsObject:@"Golf Shop"] ||
        [FinalAmentyArr containsObject:@"Gym"] ||
        [FinalAmentyArr containsObject:@"Locker Rooms"] ||
        [FinalAmentyArr containsObject:@"Men's League"] ||
        [FinalAmentyArr containsObject:@"Parkland"] ||
        [FinalAmentyArr containsObject:@"Ping Pong"] ||
        [FinalAmentyArr containsObject:@"Pub"] ||
        [FinalAmentyArr containsObject:@"Reception Hall"] ||
        [FinalAmentyArr containsObject:@"Resort"] ||
        [FinalAmentyArr containsObject:@"Seaside"] ||
        [FinalAmentyArr containsObject:@"Senior League"] ||
        [FinalAmentyArr containsObject:@"Snack Bar"] ||
        [FinalAmentyArr containsObject:@"Television"] ||
        [FinalAmentyArr containsObject:@"Twilight"] ||
        [FinalAmentyArr containsObject:@"Umbrella"] ||
        [FinalAmentyArr containsObject:@"Vending Machine"] ||
        [FinalAmentyArr containsObject:@"Web Special Tee Times"] ||
        [FinalAmentyArr containsObject:@"Weddings"] ||
        [FinalAmentyArr containsObject:@"Women's League"]) {
        
        
        [FinalAmentyArr removeObject:@"Chipping Green"];
        [FinalAmentyArr removeObject:@"4 Restaurants"];
        [FinalAmentyArr removeObject:@"Beverage Service"];
        [FinalAmentyArr removeObject:@"Changing Area"];
        [FinalAmentyArr removeObject:@"Club Rentals"];
        [FinalAmentyArr removeObject:@"Cold Towel"];
        [FinalAmentyArr removeObject:@"Couple's League"];
        [FinalAmentyArr removeObject:@"Desert"];
        [FinalAmentyArr removeObject:@"Events"];
        [FinalAmentyArr removeObject:@"Golf Shop"];
        [FinalAmentyArr removeObject:@"Gym"];
        [FinalAmentyArr removeObject:@"Locker Rooms"];
        [FinalAmentyArr removeObject:@"Men's League"];
        [FinalAmentyArr removeObject:@"Parkland"];
        [FinalAmentyArr removeObject:@"Ping Pong"];
        [FinalAmentyArr removeObject:@"Pub"];
        [FinalAmentyArr removeObject:@"Reception Hall"];
        [FinalAmentyArr removeObject:@"Resort"];
        [FinalAmentyArr removeObject:@"Seaside"];
        [FinalAmentyArr removeObject:@"Senior League"];
        [FinalAmentyArr removeObject:@"Snack Bar"];
        [FinalAmentyArr removeObject:@"Television"];
        [FinalAmentyArr removeObject:@"Twilight"];
        [FinalAmentyArr removeObject:@"Umbrella"];
        [FinalAmentyArr removeObject:@"Vending Machine"];
        [FinalAmentyArr removeObject:@"Web Special Tee Times"];
        [FinalAmentyArr removeObject:@"Weddings"];
        [FinalAmentyArr removeObject:@"Women's League"];
        
    }
  
         amentyArr = FinalAmentyArr;


          NSString *amentyStr =  [[amentyArr valueForKey:@"description"] componentsJoinedByString:@","];

         [tempObj.fields setObject:amentyArr forKey:@"amenities_temp"];
         [tempObj.fields setObject:amentyStr forKey:@"Amenities"];
         [QBRequest updateObject:tempObj successBlock:^(QBResponse *response, QBCOCustomObject *object) {

              objCountUpdated++;

             if (tempCourseArr.count == objCountUpdated) {
                    tempCurrentPage++;
                    objCountUpdated = 0;
                    updateCountObj = (int)tempCourseArr.count;
                    [self getData];


             }else {
                 NSLog(@"Object updated is : %d", objCountUpdated);
                 NSLog(@"Continue");


                 [self upadteobj:[tempCourseArr objectAtIndex:objCountUpdated]];

             }

         } errorBlock:^(QBResponse *response) {
             // error handling
             [[AppDelegate sharedinstance] hideLoader];

             NSLog(@"Response error: %@", [response.error description]);
         }];


}

/************* Updated Amenties data string to amenties_temp data. **********/
//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender {
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:kBackBtnAlertTitle
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* saveSearchButton = [UIAlertAction
                                       actionWithTitle:kBackSaveSearchBtnAlertTitle
                                       style:UIAlertActionStyleDefault
                                       handler:^(UIAlertAction * action) {
                                           [self savesettings];
                                       }];
    
    UIAlertAction* startOverButton = [UIAlertAction
                                      actionWithTitle:kBackStartOverBtnAlertTitle
                                      style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction * action) {
                                          
                                          [txtType setText:@"All"];
                                          [txtCourseName setText:@"All"];
                                          [txtCity setText:@"All"];
                                          [txtState setText:@"All"];
                                          [txtCourseZipcode setText:@"All"];
                                          [txtAmenities setText:@"Any"];
                                          [txtFldHolesCourses setText:@"All"];
                                          [lblDistanceValue setText:@"∞"];
                                          myObSliderOutlet.value=150;
                                          
                                          strPush=@"0";
                                          [self savesettings];
                                          //   [self.navigationController popViewControllerAnimated:YES];
                                      }];
    
    [alert addAction:saveSearchButton];
    [alert addAction:startOverButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
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

-(IBAction) nameTapped:(id)sender {
    
}

//-----------------------------------------------------------------------

-(IBAction) cityTapped:(id)sender {
    
    buttonTapped = kButtonCity;
    
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) stateTapped:(id)sender {
    buttonTapped = kButtonState;
    pickerOption = kPickerState;
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) zipcodeTapped:(id)sender {
    
    
    buttonTapped = kButtonzipcode;
    
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) amenitiesTapped:(id)sender {
    buttonTapped = kButtonamenities;
    [self changeData];
    
}

//-----------------------------------------------------------------------

-(IBAction) typeTapped:(id)sender {
    
    buttonTapped = kButtonType;
    pickerOption = kPickerType;
    [self changeData];
    
}
- (IBAction)selectHolesCourse:(id)sender {
    buttonTapped = kButtonHoles;
    pickerOption = kPickerHoles;
    [self changeData];
}

//-----------------------------------------------------------------------

-(IBAction) selectiondoneTapped:(id)sender {
    
    [viewTable setHidden:YES];
    [viewToolbar setHidden:YES];
    [pickerView setHidden:YES];
    
    if(buttonTapped == kButtonCity) {
        if([tempCitySelctedArr count]>0)
        {
            if([tempCitySelctedArr containsObject:@"All"] && [tempCitySelctedArr count]>1)
            {
                txtCity.text = @"All";
            }
            else
            {
                txtCity.text =  [[tempCitySelctedArr valueForKey:@"description"] componentsJoinedByString:@","];
            }
        }else if ([tempCitySelctedArr count] == 0){
            txtCity.text = @"All";
        }
        
        txtCourse.text = @"All";
        
    }
    else if(buttonTapped == kButtonamenities)  {
        
        if([tempAmentiesSelctedArr count]>0)
        {
            if([tempAmentiesSelctedArr containsObject:@"Any"] )
            {
                txtAmenities.text = @"Any";
            }
            else
            {
                txtAmenities.text =  [[tempAmentiesSelctedArr valueForKey:@"description"] componentsJoinedByString:@","];
            }
        }else if ([tempAmentiesSelctedArr count] == 0){
            txtAmenities.text = @"Any";
        }
        
        
    }
    
}

//-----------------------------------------------------------------------

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) savesettings {
    
    [object.fields setObject:txtCity.text forKey:@"cf_city"];
    [object.fields setObject:txtState.text forKey:@"cf_state"];
    [object.fields setObject:txtCourseName.text forKey:@"cf_name"];
    [object.fields setObject:txtCourseZipcode.text forKey:@"cf_zipcode"];
    [object.fields setObject:txtAmenities.text forKey:@"cf_amenities"];
    [object.fields setObject:strPush  forKey:@"cf_isFav"];
    [object.fields setObject:txtType.text forKey:@"cf_type"];
    [object.fields setObject:txtFldHolesCourses.text forKey:@"cf_Holes"];
    // convert miles to metres
    
    [object.fields setObject:[NSString stringWithFormat:@"%d",(int)myObSliderOutlet.value] forKey:@"cf_distance"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
        
        NSMutableDictionary *dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kcoursePreferencesData] mutableCopy];
        
        if(!dictcoursePreferencesData) {
            dictcoursePreferencesData =[[NSMutableDictionary alloc] init];
        }
        
        [dictcoursePreferencesData setObject:txtCity.text forKey:@"cf_city"];
        [dictcoursePreferencesData setObject:txtState.text forKey:@"cf_state"];
        [dictcoursePreferencesData setObject:txtCourseName.text forKey:@"cf_name"];
        [dictcoursePreferencesData setObject:txtCourseZipcode.text forKey:@"cf_zipcode"];
        [dictcoursePreferencesData setObject:txtType.text forKey:@"cf_type"];
        [dictcoursePreferencesData setObject:txtAmenities.text forKey:@"cf_amenities"];
        [dictcoursePreferencesData setObject:strPush  forKey:@"cf_isFav"];
        [dictcoursePreferencesData setObject:[NSString stringWithFormat:@"%d",(int)myObSliderOutlet.value] forKey:@"cf_distance"];
        [dictcoursePreferencesData setObject:@"3" forKey:@"cf_courseOption"];
        [dictcoursePreferencesData setObject:txtFldHolesCourses.text forKey:@"cf_Holes"];
        
        [[NSUserDefaults standardUserDefaults] setObject:dictcoursePreferencesData forKey:kcoursePreferencesData];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // if([cameFromScreen isEqualToString:kScreenViewUsers])
        {
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}

-(void) changeData {
    //  [tempArraySelcted removeAllObjects];
    
    //   NSString *strStateSelected;
    
    [txtCourseName resignFirstResponder];
    [txtCourseZipcode resignFirstResponder];
    
    [viewTable setHidden:YES];
    [pickerView setHidden:YES];
    [viewToolbar setHidden:NO];
    
    switch(buttonTapped)
    {
        case kButtonCity:
            
            if ([txtState.text isEqualToString:@"All"]) {
                [viewTable setHidden:YES];
                [pickerView setHidden:YES];
                [viewToolbar setHidden:YES];
                [[AppDelegate sharedinstance] displayMessage:@"Please Select State first."];
                
            }else {
                [viewTable setHidden:NO];
                
            }
            
            
            //            strStateSelected = txtState.text;
            //            selectedState = strStateSelected;
            //            currentPage = 0;
            //            if([arrCityList count]>0)
            //                [arrCityList removeAllObjects];
            //            [self getcityList];
            
            /*
             
             if([arrCityList count]>0)
             [arrCityList removeAllObjects];
             
             for(NSArray *obj in arrCityStateList)
             {
             
             NSString *strName = obj[1];
             
             if([strName isEqualToString:strStateSelected])
             {
             if(![arrCityList containsObject:obj[0]])
             {
             [arrCityList addObject: obj[0]];
             }
             }
             }
             
             [arrCityList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
             
             [arrCityList insertObject:@"All" atIndex:0];
             
             tblMembers.allowsMultipleSelection = YES;
             [viewTable setHidden:NO];
             */
            break;
        case kButtonState:
            [pickerView selectRow:0 inComponent:0 animated:YES];
            [pickerView setHidden:NO];
            break;
        case kButtonamenities:
            
            if ([txtAmenities.text isEqualToString:@"Any"]) {
                [tempAmentiesSelctedArr removeAllObjects];
            }
        //    [self setUpAmenitiesList];
            
            tblMembers.allowsMultipleSelection = YES;
            [viewTable setHidden:NO];
            break;
        case kButtonType:
            [pickerView selectRow:0 inComponent:0 animated:YES];
            [pickerView setHidden:NO];
            
            break;
            
        case kButtonHoles:
            [pickerView selectRow:0 inComponent:0 animated:YES];
            [pickerView setHidden:NO];
            break;
    }
    
    [pickerView reloadAllComponents];
    [tblMembers reloadData];
    
}

//-----------------------------------------------------------------------
#pragma mark - Reset Search parameters
-(IBAction)resetFilters:(id)sender {
    
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:kClearSearchAlertTitle
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesBtn = [UIAlertAction
                             actionWithTitle:kYesAlertBtnTitle
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 
                                 [txtType setText:@"All"];
                                 [txtCourseName setText:@"All"];
                                 [txtCity setText:@"All"];
                                 [txtState setText:@"All"];
                                 [txtCourseZipcode setText:@"All"];
                                 [txtAmenities setText:@"Any"];
                                 [lblDistanceValue setText:@"∞"];
                                 myObSliderOutlet.value=150;
                                 [tempCitySelctedArr removeAllObjects];
                                 [tempAmentiesSelctedArr removeAllObjects];
                                 
                                 
                                 strPush=@"0";
                                 [btnPush  setBackgroundImage:[UIImage imageNamed:@"toggleOff"] forState:UIControlStateNormal];
                                 
                             }];
    
    UIAlertAction* noBtn = [UIAlertAction
                            actionWithTitle:kNoAlertBtnTitle
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                
                            }];
    
    [alert addAction:yesBtn];
    [alert addAction:noBtn];
    [self presentViewController:alert animated:YES completion:nil];
    //[self savesettings];
}

//-----------------------------------------------------------------------

-(IBAction)sliderValueChanged:(id)sender {
    
    if(myObSliderOutlet.value == myObSliderOutlet.maximumValue) {
        [lblDistanceValue setText:@"∞"];
    }
    else {
        lblDistanceValue.text = [NSString stringWithFormat:@"%d mi.",(int)myObSliderOutlet.value];
    }
    
}




//-----------------------------------------------------------------------

#pragma mark -
#pragma mark - Tableview

//-----------------------------------------------------------------------

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(buttonTapped == kButtonCity) {
        
        return [arrCityList count];
        
    }
    else if(buttonTapped == kButtonType) {
        
        return [arrTypeList count];
        
    }
    
    else if(buttonTapped == kButtonState) {
        
        return [arrStateList count];
        
    }
    else if(buttonTapped == kButtonamenities) {
        
        return [arramenitiesList count];
        
    }
    return 0;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CourseCellTableViewCell";
    CourseCellTableViewCell *SendMessageCell =(CourseCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SendMessageCell.backgroundView=nil;
    SendMessageCell.backgroundColor=[UIColor clearColor];
    
    [SendMessageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    if (SendMessageCell == nil) {
        NSArray *cell = [[NSBundle mainBundle]loadNibNamed:@"CourseCellTableViewCell" owner:self options:nil];
        SendMessageCell = [cell objectAtIndex:0];
    }
    
    NSString *str;
    
    if(buttonTapped == kButtonCity) {
        str = [arrCityList objectAtIndex:indexPath.row];
        if([tempCitySelctedArr containsObject:str])    {
            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            [SendMessageCell.selectbtnimg setHidden:NO];
        }else
        {
            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
            [SendMessageCell.selectbtnimg setHidden:YES];
        }
        
    }
    else if(buttonTapped == kButtonType) {
        str = [arrTypeList objectAtIndex:indexPath.row];
    }
    else if(buttonTapped == kButtonState) {
        str = [arrStateList objectAtIndex:indexPath.row];
    }
    else if(buttonTapped == kButtonamenities) {
        str = [arramenitiesList objectAtIndex:indexPath.row];
        if([tempAmentiesSelctedArr containsObject:str])    {
            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
            [SendMessageCell.selectbtnimg setHidden:NO];
        }else
        {
            [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
            [SendMessageCell.selectbtnimg setHidden:YES];
        }
    }
    
    
    
    //        [SendMessageCell setBackgroundColor:[UIColor colorWithRed:0/255 green:0/255 blue:0/55 alpha:0.5]];
    
    [SendMessageCell.selectbtnimg setTag:indexPath.row];
    
    //    [SendMessageCell.selectbtnimg addTarget:self
    //                                     action:@selector(checkBtnClicked:)
    //                           forControlEvents:UIControlEventTouchUpInside];
    
    // SendMessageCell.lblName.textColor=PlaceholderRGB;
    
    SendMessageCell.lblName.text = str;//[[arrMembers objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    return SendMessageCell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CourseCellTableViewCell *ObjCirCell =(CourseCellTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    [ObjCirCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *str;
    
    if(buttonTapped == kButtonCity) {
        str = [arrCityList objectAtIndex:indexPath.row];
        
        if ([tempCitySelctedArr containsObject:@"All"]) {
            
            if (![str isEqualToString:@"All"]) {
                [tempCitySelctedArr removeObject:@"All"];
                if ([tempCitySelctedArr containsObject:str]) {
                    [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
                    
                    [tempCitySelctedArr removeObject:str];
                }
                else {
                    /**************** Chetu Change ************/
                    if (tempCitySelctedArr.count >= 10) {
                        [self showAlert:kMaxTenCitiesSelectAlertTitle];
                        
                    }else {
                        [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
                        [tempCitySelctedArr addObject:str];
                    }
                    /**************** Chetu Change ************/
                }
            }else {
                [tempCitySelctedArr removeAllObjects];
                [tempCitySelctedArr addObject:@"All"];
                txtCity.text = @"All";
            }
            
            
        }else {
            if ([str isEqualToString:@"All"]) {
                [tempCitySelctedArr removeAllObjects];
                [tempCitySelctedArr addObject:str];
                [tblMembers reloadData];
            }else {
                if ([tempCitySelctedArr containsObject:str]) {
                    [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
                    
                    [tempCitySelctedArr removeObject:str];
                }
                else {
                    /**************** Chetu Change ************/
                    if (tempCitySelctedArr.count >= 10) {
                        [self showAlert:kMaxTenCitiesSelectAlertTitle];
                        
                    }else {
                        
                        
                        [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
                        [tempCitySelctedArr addObject:str];
                    }
                    /**************** Chetu Change ************/
                }
            }
            
        }
        
    }
    
    else  if(buttonTapped == kButtonamenities){
        
        str = [arramenitiesList objectAtIndex:indexPath.row];
        
        
        if ([tempAmentiesSelctedArr containsObject:@"Any"]) {
            if (![str isEqualToString:@"Any"]) {
                [tempAmentiesSelctedArr removeObject:@"Any"];
                if ([tempAmentiesSelctedArr containsObject:str]) {
                    [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
                    
                    [tempAmentiesSelctedArr removeObject:str];
                }
                else {
                    
                    if (tempAmentiesSelctedArr.count >= 10) {
                        [self showAlert:kMaxTenAmentiesSelectAlertTitle];
                    }else {
                        [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
                        
                        [tempAmentiesSelctedArr addObject:str];
                    }
                    
                }
            }else{
                
                [tempAmentiesSelctedArr removeAllObjects];
                [tempAmentiesSelctedArr addObject:@"Any"];
                txtCity.text = @"Any";
            }
        }else{
            
            if ([str isEqualToString:@"Any"]) {
                [tempAmentiesSelctedArr removeAllObjects];
                [tempAmentiesSelctedArr addObject:str];
                [tblMembers reloadData];
                
            }else {
                if ([tempAmentiesSelctedArr containsObject:str]) {
                    [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
                    
                    [tempAmentiesSelctedArr removeObject:str];
                }
                else {
                    
                    if (tempAmentiesSelctedArr.count >= 10) {
                        [self showAlert:kMaxTenAmentiesSelectAlertTitle];
                    }else {
                        [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
                        
                        [tempAmentiesSelctedArr addObject:str];
                    }
                    
                }
            }
        }
        
        
        
    }
    else  if(buttonTapped == kButtonType){
        //        [tempArraySelcted removeAllObjects];
        //
        //        str = [arrTypeList objectAtIndex:indexPath.row];
        //        if (![tempArraySelcted containsObject:str]) {
        //
        //            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
        //
        //            [tempArraySelcted addObject:str];
        //        }
    }
    else  if(buttonTapped == kButtonState) {
        //        [tempArraySelcted removeAllObjects];
        //
        //        str = [arrStateList objectAtIndex:indexPath.row];
        //
        //        if ([tempArraySelcted containsObject:str]) {
        //            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"unchecked_circle.png"] forState:UIControlStateNormal];
        //
        //            [tempArraySelcted removeObject:str];
        //        }
        //        else {
        //            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:@"blue_chk.png"] forState:UIControlStateNormal];
        //
        //            [tempArraySelcted addObject:str];
        //        }
    }
    
    
    [tblMembers reloadData];
}

#pragma mark - Show alert With Title
// Alert used while user select cities and amenties more than 10.
-(void)showAlert:(NSString *)titleStr
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:titleStr
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:kOkAlertBtnTitle
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                   
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    self.menuContainerViewController.panMode = YES;
}

-(void) setUpAmenitiesList {
    arramenitiesList = [[NSMutableArray alloc] init];
    
    [arramenitiesList addObject:@"Women's League"];
    // We need to remove the 18/27/36 holes from the list of amenties.
    
    //    [arramenitiesList addObject:@"18 holes"];
    [arramenitiesList addObject:@"19th Hole"];
    //   [arramenitiesList addObject:@"27 holes"];
    //   [arramenitiesList addObject:@"36 holes"];
    [arramenitiesList addObject:@"ATM"];
    [arramenitiesList addObject:@"Bar"];
    
    [arramenitiesList addObject:@"Beverage Service"];
    [arramenitiesList addObject:@"Billiards"];
    [arramenitiesList addObject:@"Business Lounge"];
    [arramenitiesList addObject:@"Caddy Hire"];
    [arramenitiesList addObject:@"Casino"];
    [arramenitiesList addObject:@"Changing Area"];
    [arramenitiesList addObject:@"Chipping Green"];
    [arramenitiesList addObject:@"Clubhouse"];
    [arramenitiesList addObject:@"Club Fittings"];
    [arramenitiesList addObject:@"Club Rental"];
    [arramenitiesList addObject:@"Club Repair"];
    [arramenitiesList addObject:@"Cold Towel"];
    [arramenitiesList addObject:@"Couple's League"];
    [arramenitiesList addObject:@"Desert"];
    [arramenitiesList addObject:@"Dining"];
    
    [arramenitiesList addObject:@"Drink Cart"];
    [arramenitiesList addObject:@"Driving Range"];
    [arramenitiesList addObject:@"Events"];
    [arramenitiesList addObject:@"Event Facilities"];
    [arramenitiesList addObject:@"Executive Par 3"];
    [arramenitiesList addObject:@"Fitness Center"];
    
    [arramenitiesList addObject:@"Game Room"];
    [arramenitiesList addObject:@"Golf Pro"];
    [arramenitiesList addObject:@"Golf Shop"];
    [arramenitiesList addObject:@"Gym"];
    
    [arramenitiesList addObject:@"Handicap Cart"];
    [arramenitiesList addObject:@"Locker Room"];
    [arramenitiesList addObject:@"Lodging On Site"];
    
    [arramenitiesList addObject:@"Lounge"];
    [arramenitiesList addObject:@"Men's League"];
    [arramenitiesList addObject:@"Online Tee Times"];
    [arramenitiesList addObject:@"Parkland"];
    [arramenitiesList addObject:@"Ping Pong"];
    [arramenitiesList addObject:@"Pool"];
    [arramenitiesList addObject:@"Pro Shop"];
    [arramenitiesList addObject:@"Pub"];
    [arramenitiesList addObject:@"Putting Green"];
    
    [arramenitiesList addObject:@"4 Restaurants"];
    [arramenitiesList addObject:@"Restaurant"];
    [arramenitiesList addObject:@"Reception Hall"];
    [arramenitiesList addObject:@"Resort"];
    [arramenitiesList addObject:@"Riding Carts"];
    [arramenitiesList addObject:@"Seaside"];
    [arramenitiesList addObject:@"Senior League"];
    [arramenitiesList addObject:@"Showers"];
    [arramenitiesList addObject:@"Snack Bar"];
    [arramenitiesList addObject:@"Spa"];
    
    [arramenitiesList addObject:@"Television"];
    [arramenitiesList addObject:@"Twilight"];
    [arramenitiesList addObject:@"Umbrella"];
    [arramenitiesList addObject:@"Valet Parking"];
    [arramenitiesList addObject:@"Vending Machine"];
    
    [arramenitiesList addObject:@"Webcam"];
    [arramenitiesList addObject:@"Weddings"];
    [arramenitiesList addObject:@"WiFi"];
    
    [arramenitiesList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // [arramenitiesList addObject:@"Any"];
    [arramenitiesList insertObject:@"Any" atIndex:0];
    
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

//-----------------------------------------------------------------------

#pragma mark - UIPickerViewDataSource

//-----------------------------------------------------------------------


// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    switch(pickerOption)
    {
        case kPickerState:
            return arrStateList.count;
            break;
        case kPickerType:
            return arrTypeList.count;
            break;
        case kPickerHoles:
            return arrHolesList.count;
            break;
    }
    
    return 10;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch(pickerOption)
    {
        case kPickerState:
            return arrStateList[row];
            break;
        case kPickerType:
            return arrTypeList[row];
            break;
        case kPickerHoles:
            return arrHolesList[row];
            break;
    }
    
    return @"";
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", row);
    
    switch (pickerOption)
    {
        case kPickerState:
            txtState.text = [arrStateList objectAtIndex:row];
            selectedState = [arrStateList objectAtIndex:row];
            txtCity.text = @"All";
            //   strStateSelected = txtState.text;
            selectedState = txtState.text;
            currentPage = 0;
            [tempCitySelctedArr removeAllObjects];
            if([arrCityList count]>0)
                [arrCityList removeAllObjects];
            
            
            if ([selectedState isEqualToString:@"All"]) {
                
            }else {
                [self getcityList];
            }
            
            break;
            
        case kPickerType:
            txtType.text = [arrTypeList objectAtIndex:row];
            break;
        case kPickerHoles:
            txtFldHolesCourses.text = [arrHolesList objectAtIndex:row];
           
            break;
    }
    
}

@end
