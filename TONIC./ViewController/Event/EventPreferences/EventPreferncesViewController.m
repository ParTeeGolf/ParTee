//
//  EventPreferncesViewController.m
//  ParTee
//
//  Created by Admin on 08/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "EventPreferncesViewController.h"
#import "CourseCellTableViewCell.h"

@interface EventPreferncesViewController ()
{
    // array for city
    NSMutableArray *arrCityList;
    // array for state
    NSMutableArray *arrStateList;
    // array of golf courses.
    NSArray *arrData;
    // array of city and state corresponding
    NSMutableArray *arrCityStateList;
    QBCOCustomObject *object;
    NSString *strPush;
    int buttonTapped;
    NSMutableArray *tempArraySelcted;
    int pickerOption;
    // var whetaher state selected or city.
    int cityOrStateSelected;
}
@end

@implementation EventPreferncesViewController
/***************** Synthesize Property ***********/
@synthesize distanceSlider;
@synthesize distanceLbl;
@synthesize nameTxtFld;
@synthesize stateTxtFld;
@synthesize cityTxtFld;
@synthesize typeTxtFld;
@synthesize favSwitch;
@synthesize pickerView;
@synthesize listTblView;
@synthesize viewToolBar;
@synthesize viewTblView;
/***************** Synthesize Property ***********/

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *thumb = [UIImage imageNamed:kEventPreFilledCircle];
    [distanceSlider setThumbImage:thumb forState:UIControlStateNormal];
    [distanceSlider setThumbImage:thumb forState:UIControlStateHighlighted];
    [[NSNotificationCenter defaultCenter] postNotificationName:kEventPreRefreshContent object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [viewToolBar setHidden:YES];
    [viewToolBar setHidden:YES];
    [listTblView setSeparatorColor:[UIColor clearColor]];
    self.navigationController.navigationBarHidden=YES;
    
    /************** Initialize Array used *********/
    arrCityList = [[NSMutableArray alloc] init];
    arrCityStateList = [[NSMutableArray alloc] init];
    arrStateList = [[NSMutableArray alloc] init];
    tempArraySelcted = [[NSMutableArray alloc]init];
    /************** Initialize Array used *********/
    
    [pickerView setBackgroundColor:[UIColor whiteColor]];
    distanceSlider.value =0;
    [self getGolfCourseDetails];
}

-(void)viewWillAppear:(BOOL)animated {
    self.menuContainerViewController.panMode = NO;
}
#pragma mark - GetGolfCourseDetails
/**
 @Description
 * This method fetch the details courses from golf course table from quickblox to fecth the city or state from first 100 records.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void) getGolfCourseDetails {
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:kEventGolfCourse extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        arrData=[objects mutableCopy];
        
        // Get the details of city and state available.
        for(int i=0;i<[objects count];i++) {
            QBCOCustomObject *obj = [arrData objectAtIndex:i];
            NSString *strState = [obj.fields objectForKey:kEventPreState];
            NSString *strCity = [obj.fields objectForKey:kEventPreCity];
            NSArray *cityState = @[strCity, strState];
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
        [arrStateList insertObject:kEventAll atIndex:0];
        [self getUserDetails];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    
    
    
}
#pragma mark - GetUserDetails
/**
 @Description
 * This method fetch the details of user that have logged in.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void)getUserDetails {
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:kuserEmail];
    
    [QBRequest objectsWithClassName:kUserInfoTbl extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        // checking user there in custom user table or not.
        arrData=objects;
        
        [[AppDelegate sharedinstance] hideLoader];
        
        if([objects count]>0) {
            
            [AppDelegate sharedinstance].isUpdate=YES;
            
            // If user exists, get info from server
            object =  [arrData objectAtIndex:0];
            
          // convert distance in mile
            NSString *strLocation = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:kEventDistance]];
            
            if([strLocation length]==0 || distanceSlider.value>99 || [strLocation isEqualToString:@"150"]) {
                
                [distanceLbl setText:@"∞"];
                distanceSlider.value = 150;
            }
            else {
                distanceSlider.value = [strLocation integerValue];
                
                [distanceLbl setText:[NSString stringWithFormat:@"%d mi.",(int)distanceSlider.value]];
            }
            
            strPush = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:kEventFav]];
            
            if([strPush isEqualToString:kEventOneStr]) {
                
                [favSwitch  setBackgroundImage:[UIImage imageNamed:kEventPreToggleOn] forState:UIControlStateNormal];
            }
            else {
                [favSwitch  setBackgroundImage:[UIImage imageNamed:kEventPreToggleOff] forState:UIControlStateNormal];
                
            }
            
            NSString *strState = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:kEventState]];
            NSString *str_cf_city= [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:kEventCity]];
            NSString *strcf_name = [[AppDelegate sharedinstance] nullcheck:[object.fields objectForKey:kEventTitleName]];
            
            
            if([str_cf_city length]== kZeroValue) {
                [cityTxtFld setText:kEventAll];
                
            }
            else {
                [cityTxtFld setText:str_cf_city];
            }
            
            if([strState length]== kZeroValue) {
                [stateTxtFld setText:kEventAll];
            }
            else {
                [stateTxtFld setText:strState];
            }
            
            if([strcf_name length]== kZeroValue) {
                [nameTxtFld setText:kEventAll];
            }
            else {
                [nameTxtFld setText:strcf_name];
            }
            
            
        }
        else {
            
            strPush = kEventOneStr;
            
            [favSwitch  setImage:[UIImage imageNamed:kEventPreToggleOn] forState:UIControlStateNormal];
            
        }
    }
                         errorBlock:^(QBResponse *response) {
                             // error handling
                             [[AppDelegate sharedinstance] hideLoader];
                             
                             NSLog(@"Response error: %@", [response.error description]);
                         }];
}
#pragma mark - Save Button Action
/**
 @Description
 * This Method save all the data provided by the user in order to search the event  and also save into user default data and popup this controller after that it will filter out the event based on perfernces set by the user.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)btnSaveAndSearchAction:(id)sender {
    [self savesettings];
    
}
#pragma mark - Back Button Action
/**
 @Description
 * This Method pop this controller after shown the popup that have two button yes or No. If user press yes the event will be filter out based on preferences while if user pressed no then all events will be shown in event screen.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
#pragma mark- Back button Action
- (IBAction)btnBackAction:(id)sender {
    
    [nameTxtFld resignFirstResponder];
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
                                          
                                          
                                          [nameTxtFld setText:kEventAll];
                                          [cityTxtFld setText:kEventAll];
                                          [stateTxtFld setText:kEventAll];
                                          [distanceLbl setText:@"∞"];
                                          distanceSlider.value=150;
                                          
                                          strPush = @"0";
                                          [self savesettings];
                                          //   [self.navigationController popViewControllerAnimated:YES];
                                      }];
    
    [alert addAction:saveSearchButton];
    [alert addAction:startOverButton];
    
    [self presentViewController:alert animated:YES completion:nil];
    
    //  [self.navigationController popViewControllerAnimated:YES];
}
-(void) viewWillDisappear:(BOOL)animated {
    self.menuContainerViewController.panMode = YES;
}
#pragma mark - TextField Delagate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    int tagvalue = (int)textField.tag;
    if (tagvalue == 1) {
        [textField resignFirstResponder];
        if ([textField.text isEqualToString:kEmptyStr]) {
            nameTxtFld.text = kEventAll;
        }
    }
    
    return YES;
}
#pragma mark -  Clear Search Action
/**
 @Description
 * This Method clears all the parameters to initial value and also ask first to clear parameters through popup or alert.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
#pragma mark- Clear search action
- (IBAction)BtnClearSearchAction:(id)sender {
    
    [nameTxtFld setText:nameTxtFld.text];
    [nameTxtFld resignFirstResponder];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:kClearSearchAlertTitle
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesBtn = [UIAlertAction
                             actionWithTitle:kYesAlertBtnTitle
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action) {
                                 
                                 [nameTxtFld setText:kEventAll];
                                 [cityTxtFld setText:kEventAll];
                                 [stateTxtFld setText:kEventAll];
                                 [distanceLbl setText:@"∞"];
                                 distanceSlider.value=150;
                                 [nameTxtFld resignFirstResponder];
                                 [nameTxtFld setText:nameTxtFld.text];
                                 strPush=@"0";
                                 [favSwitch  setBackgroundImage:[UIImage imageNamed:kEventPreToggleOff] forState:UIControlStateNormal];
                                 
                             }];
    
    UIAlertAction* noBtn = [UIAlertAction
                            actionWithTitle:kNoAlertBtnTitle
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                
                            }];
    
    [alert addAction:yesBtn];
    [alert addAction:noBtn];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - NameFldAction
/**
 @Description
 * This Method set the value for name
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */

- (IBAction)nameFldAction:(id)sender {
    [nameTxtFld becomeFirstResponder];
}
#pragma mark - TypeFldAction
/**
 @Description
 * This Method set the value for type.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)typeFldAction:(id)sender {
    [self ComingSoon];
}
#pragma mark - FavBtnAction
/**
 @Description
 * This Method set Set the swicth to on and off for favourite.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)favBtnAction:(id)sender {
    
    // on and off fav switch to filter out the fav events
    if([strPush isEqualToString:kEventOneStr]) {
        strPush=@"0";
        [favSwitch  setBackgroundImage:[UIImage imageNamed:kEventPreToggleOff] forState:UIControlStateNormal];
    }
    else {
        strPush=kEventOneStr;
        [favSwitch  setBackgroundImage:[UIImage imageNamed:kEventPreToggleOn] forState:UIControlStateNormal];
    }
}
#pragma mark - DistanceSliderChanged
/**
 @Description
 * This Method called when distance slider value changed.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)distanceSliderChanged:(id)sender {
    if(distanceSlider.value == distanceSlider.maximumValue) {
        [distanceLbl setText:@"∞"];
    }
    else {
        distanceLbl.text = [NSString stringWithFormat:@"%d mi.",(int)distanceSlider.value];
    }
}
#pragma mark - checkBtnAction
/**
 @Description
 * This Method called when check button pressed availble on toolbar.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)checkBtn:(id)sender {
}
#pragma mark - DoneBtnAction
/**
 @Description
 * This Method called when user selects done button after selecting state or city from the tableview and pickerview.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */

- (IBAction)doneBtnAction:(id)sender {
    
    // Hide all the bottom views and set the value for state and city as well.
    [viewTblView setHidden:YES];
    [viewToolBar setHidden:YES];
    [pickerView setHidden:YES];
    // First user need to select state the city other wise all will be the default value for city field.
    if(cityOrStateSelected == 1) {
        if([tempArraySelcted count]>0)
        {
            if([tempArraySelcted containsObject:kEventAll] && [tempArraySelcted count]>1)
            {
                cityTxtFld.text = kEventAll;
            }
            else
            {
                cityTxtFld.text =  [[tempArraySelcted valueForKey:kEventPreDesc] componentsJoinedByString:@","];
            }
        }
        
        nameTxtFld.text = kEventAll;
        
    }
    
}
#pragma mark - StateFldAction
/**
 @Description
 * This Method open the picker view to choose the state of the events.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)stateFldAction:(id)sender {
    cityOrStateSelected = 0;
    [self changeData];
}
#pragma mark - CityfldAction
/**
 @Description
 * This Method open the tableView to choose the city of the events.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)cityfldAction:(id)sender {
    
    cityOrStateSelected = 1;
    [self changeData];
}

-(void) changeData {
    
    [tempArraySelcted removeAllObjects];
    NSString *strStateSelected;
    [nameTxtFld resignFirstResponder];
    [viewToolBar setHidden:NO];
    
    if (cityOrStateSelected == kZeroValue) {
        // Hide tableView and reload pickerview to slect state.
        [viewTblView setHidden:YES];
        [listTblView setHidden:YES];
        [pickerView setHidden:NO];
        [pickerView reloadAllComponents];
    }else if (cityOrStateSelected == 1) {
        // Hide pickerview and reload tableView to slect state.
        [viewTblView setHidden:NO];
        [listTblView setHidden:NO];
        [pickerView setHidden:YES];
        
        strStateSelected = stateTxtFld.text;
        
        if([arrCityList count]>kZeroValue)
            [arrCityList removeAllObjects];
      // get the details of city within state from arrCityStateList
        for(NSArray *obj in arrCityStateList)
        {
            NSString *strName = obj[1];
            
            if([strName isEqualToString:strStateSelected])
            {
                if(![arrCityList containsObject:obj[kZeroValue]])
                {
                    [arrCityList addObject: obj[kZeroValue]];
                }
            }
        }
        [arrCityList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        
        [arrCityList insertObject:kEventAll atIndex:kZeroValue];
        
        listTblView.allowsMultipleSelection = YES;
        [viewTblView setHidden:NO];
        [listTblView reloadData];
        [pickerView setHidden:NO];
    }
    
}
/**
 @Description
 * This Method show the fetaure comming soon popup.
 * @author Chetu India
 * @return void nothing will return by this method.
 */
-(void) ComingSoon  {
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:kAppName
                                 message:kFeatureSoonAlertTitle
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okBtn = [UIAlertAction
                            actionWithTitle:kOkAlertBtnTitle
                            style:UIAlertActionStyleDefault
                            handler:^(UIAlertAction * action) {
                                
                            }];
    
    [alert addAction:okBtn];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}
#pragma mark - Savesettings NsDefault
/**
 @Description
 * This Method save the all values selected by the user to nsuerdefault and save to userinfo table these valuse on quickblox too.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
-(void) savesettings {
    // set the values to object that we need to update on userinfo table.
    [object.fields setObject:cityTxtFld.text forKey:kEventCity];
    [object.fields setObject:stateTxtFld.text forKey:kEventState];
    [object.fields setObject:nameTxtFld.text forKey:kEventTitleName];
    [object.fields setObject:strPush  forKey:kEventFav];
    
    // convert miles to metres
    
    [object.fields setObject:[NSString stringWithFormat:@"%d",(int)distanceSlider.value] forKey:kEventDistance];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayMessage:@"Details successfully saved"];
        
        NSMutableDictionary *dictcoursePreferencesData = [[[NSUserDefaults standardUserDefaults] objectForKey:kcoursePreferencesData] mutableCopy];
        
        if(!dictcoursePreferencesData) {
            dictcoursePreferencesData =[[NSMutableDictionary alloc] init];
        }
        
        [dictcoursePreferencesData setObject:cityTxtFld.text forKey:kEventCity];
        [dictcoursePreferencesData setObject:stateTxtFld.text forKey:kEventState];
        [dictcoursePreferencesData setObject:nameTxtFld.text forKey:kEventTitleName];
        [dictcoursePreferencesData setObject:strPush  forKey:kEventFav];
        [dictcoursePreferencesData setObject:[NSString stringWithFormat:@"%d",(int)distanceSlider.value] forKey:kEventDistance];
        // save these values to nsuerdefault
        [[NSUserDefaults standardUserDefaults] setObject:dictcoursePreferencesData forKey:kEventPreferencesData];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.navigationController popViewControllerAnimated:YES];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
}
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
#pragma mark - UIPickerViewDataSource

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    
    return 1;
}
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return arrStateList.count;
    
    return 10;
}
//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return arrStateList[row];
    
    return @"";
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    stateTxtFld.text = [arrStateList objectAtIndex:row];
    cityTxtFld.text = kEventAll;
    
    
}
#pragma mark - UITableViewDataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (cityOrStateSelected == 1) {
        return [arrCityList count];
    }
    
    return kZeroValue;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = kEventPreCourseCell;
    CourseCellTableViewCell *SendMessageCell =(CourseCellTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SendMessageCell.backgroundView=nil;
    SendMessageCell.backgroundColor=[UIColor clearColor];
    
    [SendMessageCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    if (SendMessageCell == nil) {
        NSArray *cell = [[NSBundle mainBundle]loadNibNamed:kEventPreCourseCell owner:self options:nil];
        SendMessageCell = [cell objectAtIndex:0];
    }
    
    NSString *str;
    
    str = [arrCityList objectAtIndex:indexPath.row];
    // this will show or hide the right checkbox button on the city that user have slected.
    if([tempArraySelcted containsObject:str])    {
        [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:kEventPreBlueChk] forState:UIControlStateNormal];
        [SendMessageCell.selectbtnimg setHidden:NO];
    }
    else
    {
        [SendMessageCell.selectbtnimg setImage:[UIImage imageNamed:kEventPreUnchecked] forState:UIControlStateNormal];
        [SendMessageCell.selectbtnimg setHidden:YES];
    }
    
    [SendMessageCell.selectbtnimg setTag:indexPath.row];
    
    SendMessageCell.lblName.text = str;//[[arrMembers objectAtIndex:indexPath.row] objectForKey:@"Name"];
    
    return SendMessageCell;
    
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // find the cell that user selected as city
    CourseCellTableViewCell *ObjCirCell =(CourseCellTableViewCell *) [tableView cellForRowAtIndexPath:indexPath];
    
    [ObjCirCell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSString *str;
    
    str = [arrCityList objectAtIndex:indexPath.row];
    // this will show or hide the right checkbox button on the city that user have slected.
    if ([tempArraySelcted containsObject:str]) {
        [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:kEventPreUnchecked] forState:UIControlStateNormal];
        // remove city form list of city that have selected by the user.
        [tempArraySelcted removeObject:str];
    }
    else {
        
        if (tempArraySelcted.count >= 10) {
            [self showAlert:kMaxTenCitiesSelectAlertTitle];
            
        }else {
            [ObjCirCell.selectbtnimg setImage:[UIImage imageNamed:kEventPreBlueChk] forState:UIControlStateNormal];
             // Add city form list of city that have selected by the user.
            [tempArraySelcted addObject:str];
        }
    }
  [listTblView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end