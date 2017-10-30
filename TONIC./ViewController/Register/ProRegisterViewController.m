//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "ProRegisterViewController.h"


@interface ProRegisterViewController ()

@end

@implementation ProRegisterViewController

-(void) viewWillAppear:(BOOL)animated {
    
   

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableDictionary *proTypes = [[AppDelegate sharedinstance] getAllProIcons];
    
    arrProTypeList = [[NSMutableArray alloc] init];
    
    for(NSString *key in proTypes.allKeys)
    {
        [arrProTypeList addObject:[[key capitalizedString] stringByReplacingOccurrencesOfString:@"Pga" withString:@"PGA"]];
    }
    
    [arrProTypeList insertObject:@"" atIndex:0];
    
    [pickerView reloadAllComponents];
   
    [proTypeView setHidden:YES];

    btnSendRequest.layer.cornerRadius = 20; // this value vary as per your desire
    btnSendRequest.clipsToBounds = YES;

    self.navigationController.navigationBarHidden=YES;
    
    self.menuContainerViewController.panMode = NO;
    
    NSArray *fields = @[ txtAlternateProType,txtPhone,txtWebsite,Achievements,Offerings];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
  
}

-(IBAction)DoneButtonPressed:(id)sender
{
    [proTypeView setHidden:YES];
}

-(IBAction)proTypeButtonPressed:(id)sender
{
    [proTypeView setHidden:NO];
}

//-----------------------------------------------------------------------

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [UIView commitAnimations];
    [self.view endEditing:YES];
}



-(BOOL) validateData {

    int totalLength = [[[AppDelegate sharedinstance] nullcheck:txtProType.text] length] +
    [[[AppDelegate sharedinstance] nullcheck:txtWebsite.text] length] +
    [[[AppDelegate sharedinstance] nullcheck:txtPhone.text] length] +
    [[[AppDelegate sharedinstance] nullcheck:Achievements.text] length] +
    [[[AppDelegate sharedinstance] nullcheck:Offerings.text] length];
    
    
    if(totalLength==0) {
        [[AppDelegate sharedinstance] displayMessage:@"Please fill in all required fields."];
        return NO;
    }
 
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
    return arrProTypeList.count;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {

    return [arrProTypeList objectAtIndex:row];
}

//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", row);
    
    txtProType.text = [arrProTypeList objectAtIndex:row];
}



-(void)  localSave {
    NSMutableDictionary *dictUserDetails = [[[AppDelegate sharedinstance] getUserData] mutableCopy];
    
    
    [dictUserDetails setObject:txtProType.text forKey:@"ProType"];
    [dictUserDetails setObject:txtPhone.text forKey:@"Phone"];
    [dictUserDetails setObject:txtWebsite.text forKey:@"Website"];
    [dictUserDetails setObject:Achievements.text forKey:@"Achievements"];
    [dictUserDetails setObject:Offerings.text forKey:@"Offerings"];
    [dictUserDetails setObject:txtAlternateProType.text forKey:@"AlternateProType"];
    
    [[NSUserDefaults standardUserDefaults] setObject:dictUserDetails forKey:kuserData];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

-(IBAction) RequestSent {

    if(![self validateData])
    {
        return;
    }
    
    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserEmail] forKey:@"userEmail"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        // response processing
        object =  [objects objectAtIndex:0];
    
    [object.fields setObject:txtProType.text forKey:@"ProType"];
    [object.fields setObject:txtPhone.text forKey:@"Phone"];
    [object.fields setObject:txtWebsite.text forKey:@"Website"];
    [object.fields setObject:Achievements.text forKey:@"Achievements"];
    [object.fields setObject:Offerings.text forKey:@"Offerings"];
    [object.fields setObject:txtAlternateProType.text forKey:@"AlternateProType"];
                
    [[AppDelegate sharedinstance] showLoader];
    [QBRequest updateObject:object successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        [self localSave];
        
        [[AppDelegate sharedinstance] hideLoader];
        
        MyMatchesViewController *viewController    = [[MyMatchesViewController alloc] initWithNibName:@"MyMatchesViewController" bundle:nil];
        viewController.productType = @"Pro";
        [self.navigationController pushViewController:viewController animated:YES];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayServerErrorMessage];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
    

  
    }errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayServerErrorMessage];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];
  
}

-(IBAction)cancelRegistration:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
@end


