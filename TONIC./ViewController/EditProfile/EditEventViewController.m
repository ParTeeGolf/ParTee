//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "EditEventViewController.h"


#define startDate 1
#define endDate 2



#define kImageChosen 1
#define kImageDelete 2
#define kImageLoaded 3
#define kImageCancel 3

@interface EditEventViewController ()

@end

@implementation EditEventViewController
@synthesize HUD;


- (void)viewDidLoad {
    [super viewDidLoad];
    imageChosen=kImageCancel;
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.HUD];
    [[AppDelegate sharedinstance] hideLoader];

    [txtStartDate setTag:101];
    [txtEndDate setTag:102];
   
    [description setTag:107];

    txtStartDate.inputView = datePicker;
    txtEndDate.inputView = datePicker;
    eventType.inputView = picker;
    
    [dateView setHidden:YES];
    [dailyView setHidden:YES];
    
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4.5, 0, 4.5);
    
    NSArray *fields = @[txtStartDate, txtEndDate, description, eventType];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];

    [imgViewProfilePic.layer setMasksToBounds:YES];
    [imgViewProfilePic.layer setBorderColor:[UIColor clearColor].CGColor];
    
    titleLabel.text = [self IsEdit] ? @"Edit Event" : @"Add Event";
    
    dateFormat = [[NSDateFormatter alloc] init];
    datePicker.backgroundColor=[UIColor whiteColor];
    [datePicker addTarget:self action:@selector(dateChanged:)
         forControlEvents:UIControlEventValueChanged];
    
    sunday.layer.borderWidth=1.0f;
    sunday.layer.borderColor=[[UIColor blackColor] CGColor];
    
    monday.layer.borderWidth=1.0f;
    monday.layer.borderColor=[[UIColor blackColor] CGColor];

    
    tuesday.layer.borderWidth=1.0f;
    tuesday.layer.borderColor=[[UIColor blackColor] CGColor];

    
    wednesday.layer.borderWidth=1.0f;
    wednesday.layer.borderColor=[[UIColor blackColor] CGColor];
    
    thursday.layer.borderWidth=1.0f;
    thursday.layer.borderColor=[[UIColor blackColor] CGColor];

    
    friday.layer.borderWidth=1.0f;
    friday.layer.borderColor=[[UIColor blackColor] CGColor];
    
    
    saturday.layer.borderWidth=1.0f;
    saturday.layer.borderColor=[[UIColor blackColor] CGColor];
    
    week = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 7; ++i)
    {
        [week addObject:@"false"];
    }
    
    if(isiPhone4) {
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 1000)];

    }
    else {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];

    }
    
    [self bindData];
}

- (void) bindData {


        
    
    description.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"Description"]];


    NSString *strDate = [[self object].fields objectForKey:@"StartDate"];

    
    txtStartDate.text = [strDate substringToIndex:10];
    strDate = [[self object].fields objectForKey:@"EndDate"];
    NSString *type = [[self object].fields objectForKey:@"EventType"];
    
    if([type isEqualToString:@"One Time"])
    {
        [dateView setHidden:NO];
        [eventType setText:@"One Time"];
    }
    else if([type isEqualToString:@"Recurring"])
    {
        [dailyView setHidden:NO];
        [eventType setText:@"Recurring"];
        
        NSMutableArray *objWeek = [[self object].fields objectForKey:@"Week"];
        
        if(objWeek != nil)
        {
            for(int i = 0; i < 7; ++i)
            {
                [week setObject:[[objWeek objectAtIndex:i] boolValue] ? @"true" : @"false" atIndexedSubscript:i];
            }
        }
        

        [self setButtonColor:sunday :[[week objectAtIndex:0] boolValue]];
        [self setButtonColor:monday :[[week objectAtIndex:1] boolValue]];
        [self setButtonColor:tuesday :[[week objectAtIndex:2] boolValue]];
        [self setButtonColor:wednesday :[[week objectAtIndex:3] boolValue]];
        [self setButtonColor:thursday :[[week objectAtIndex:4] boolValue]];
        [self setButtonColor:friday :[[week objectAtIndex:5] boolValue]];
        [self setButtonColor:saturday :[[week objectAtIndex:6] boolValue]];
    }


    txtEndDate.text = [strDate substringToIndex:10];

        [imgViewProfilePic setShowActivityIndicatorView:YES];
        [imgViewProfilePic setIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        NSString *imageUrl ;
        
        if([[[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"ImageUrl"]] length]>0) {

            imageUrl = [NSString stringWithFormat:@"%@", [[self object].fields objectForKey:@"ImageUrl"]];
            [imgViewProfilePic sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"user"]];
        }
    
    eventTitle.text = [[self object].fields objectForKey:@"Title"];
    [[self object].fields setObject:eventTitle.text forKey:@"Title"];
    
    
}





//-----------------------------------------------------------------------

#pragma mark - Custom Methods


- (IBAction)action_UpdateProfile:(id)sender  {
    
    [self.view endEditing:YES];

    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
    [UIView commitAnimations];
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    
    if(![self IsEdit])
    {
        _object = [QBCOCustomObject alloc];
        
        [self object].className = @"CourseEvents";
        [[self object].fields setObject:[self courseId] forKey:@"_parent_id"];
    }

    
        [[self object].fields setObject:txtStartDate.text forKey:@"StartDate"];
        [[self object].fields setObject:txtEndDate.text forKey:@"EndDate"];
        [[self object].fields setObject:description.text forKey:@"Description"];
        [[self object].fields setObject:week forKey:@"Week"];
        [[self object].fields setObject:eventType.text forKey:@"EventType"];
        [[self object].fields setObject:eventTitle.text forKey:@"Title"];
        
        [[AppDelegate sharedinstance] showLoader];
        
        if(imageChosen==kImageChosen) {
            
            NSData *imageData = UIImagePNGRepresentation(imgViewProfilePic.image);
            
            [QBRequest TUploadFile:imageData fileName:@"Event.png" contentType:@"image/png" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {

                
                NSString *url = [blob publicUrl];
                
                [[self object].fields setObject:url forKey:@"ImageUrl"];
                
                imageChosen=kImageCancel;
                [self saveEvent];
                
            } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
                // handle progress
            } errorBlock:^(QBResponse *response) {
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayServerErrorMessage];
                NSLog(@"error: %@", response.error);
            }];
        }
        else {
            // If image is not changed, no need to upload.

            imageChosen=kImageCancel;
            [self saveEvent];
        }
    
}

-(void) saveEvent
{
    if([self IsEdit])
    {
        [QBRequest updateObject:[self object] successBlock:^(QBResponse *response, QBCOCustomObject *object1) {
            // object updated
            
            _object=object1;
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Event successfully saved."];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayServerErrorMessage];
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
    else
    {
        [QBRequest createObject:[self object] successBlock:^(QBResponse *response, QBCOCustomObject *object1) {
            // object updated
            
            _object=object1;
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayMessage:@"Event successfully saved."];
            
            [self.navigationController popViewControllerAnimated:YES];
            
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            [[AppDelegate sharedinstance] displayServerErrorMessage];
            NSLog(@"Response error: %@", [response.error description]);
        }];
    }
}
//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    
        }];
    //
}



//-----------------------------------------------------------------------

-(IBAction)cameraPressed:(id)sender {
    
    [self.view endEditing:YES];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Select image"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraButton = [UIAlertAction
                                   actionWithTitle:@"Camera"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                       {
                                           UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                           picker.delegate = self;
                                           self.imagePickerController = picker;
                                           //                picker.modalPresentationStyle = UIModalPresentationCurrentContext;
                                           picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                           picker.allowsEditing = YES;
                                           
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                               [self presentViewController:self.imagePickerController animated:YES completion:nil];
                                           }];
                                           
                                       }
                                       else {
                                           UIAlertController * ac = [UIAlertController
                                                                     alertControllerWithTitle:kAppName
                                                                     message:@"Device does not supports camera"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                           UIAlertAction* okButton = [UIAlertAction
                                                                      actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          
                                                                      }];
                                           [ac addAction:okButton];
                                           [self presentViewController:ac animated:YES completion:nil];
                                           return;
                                       }
                                   }];
    
    UIAlertAction* libraryButton = [UIAlertAction
                                    actionWithTitle:@"Select from Library"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                        picker.delegate = self;
                                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        picker.allowsEditing = YES;
                                        
                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                            
                                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                                [self presentViewController:picker animated:YES completion:nil];
                                            }
                                            else {
                                                [self presentViewController:picker animated:YES completion:nil];
                                                
                                            }
                                        }];
                                    }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
    
    [alert addAction:cameraButton];
    [alert addAction:libraryButton];
    [alert addAction:cancelButton];
    
    alert.popoverPresentationController.sourceView = sender;
    [self presentViewController:alert animated:YES completion:nil];
    
}



//-----------------------------------------------------------------------


//-----------------------------------------------------------------------

#pragma mark -
#pragma mark Keyboard Controls Delegate

//-----------------------------------------------------------------------

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
    UIView *textFieldview;
    
    textFieldview = field.superview.superview;
    
    if([textFieldview tag]==101) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
        [UIView commitAnimations];
        
        
    }
    else if (field==description) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, textFieldview.center.y)animated:NO];
        [UIView commitAnimations];
        

    }
    
    else if([textFieldview tag]>101) {
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        
        NSLog(@"%ld",(43*([textFieldview tag]%10)));
        
        [scrollViewContainer setContentOffset:CGPointMake(0, 60 + ((([textFieldview tag]-1)%10))) animated:NO];
        [UIView commitAnimations];
        
    }
    
}

//-----------------------------------------------------------------------

- (void)keyboardControlsDonePressed:(BSKeyboardControls *)keyboardControls
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollViewContainer setContentOffset:CGPointMake(0, 0) animated:NO];
    [UIView commitAnimations];
    [self.view endEditing:YES];
}

//-----------------------------------------------------------------------

#pragma mark - UITextFieldDelegate Methods

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    UIView *textFieldview;
    
    textFieldview = textField.superview.superview;
    
    if([textField tag]==101) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        [scrollViewContainer setContentOffset:CGPointMake(0, 0)animated:NO];
        [UIView commitAnimations];
        
    }
    else if([textField tag]>101) {

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:.5];
        
        NSLog(@"%ld",(43*([textField tag]%10)));
        
        [scrollViewContainer setContentOffset:CGPointMake(0, textFieldview.center.y+5) animated:NO];
        [UIView commitAnimations];
        
    }
    
    [self.keyboardControls setActiveField:textField];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    
  
    
    return YES;
}

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    return YES;
}

//-----------------------------------------------------------------------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

//-----------------------------------------------------------------------

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollViewContainer setContentOffset:CGPointMake(0, textView.frame.origin.y)animated:NO];
    [UIView commitAnimations];
    
    [self.keyboardControls setActiveField:textView];
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    imageChosen=kImageChosen;

    // Picking Image from Camera/ Library
    
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    if (!image)
    {
        return;
    }
    
    // Adjusting Image Orientations
    
    imgViewProfilePic.image=image;

    [picker dismissViewControllerAnimated:YES completion:^{}];

}

//-----------------------------------------------------------------------

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    if(imageChosen!=kImageChosen) {
        imageChosen=kImageCancel;
    }
    
    [imgViewProfilePic setAccessibilityIdentifier:@"default"] ;
   
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

-(IBAction)StartDateSelected:(id)sender
{
    dateOption = startDate;
}

-(IBAction)EndDateSelected:(id)sender
{
    dateOption = endDate;
}

-(void)dateChanged:(id)sender{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *string = [formatter stringFromDate:datePicker.date];
    switch(dateOption)
    {
        case startDate:
            txtStartDate.text=string;
            break;
        case endDate:
            txtEndDate.text=string;
            break;
    }
    
}

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) dayPressed:(UIButton*) day
{
    
    if(day == sunday)
    {
        [self configureButton:day :0];
    }
    else if(day == monday)
    {
        [self configureButton:day :1];
    }
    else if(day == tuesday)
    {
        [self configureButton:day :2];
    }
    else if(day == wednesday)
    {
        [self configureButton:day :3];
    }
    else if(day == thursday)
    {
        [self configureButton:day :4];
    }
    else if(day == friday)
    {
        [self configureButton:day :5];
    }
    else if(day == saturday)
    {
        [self configureButton:day :6];;
    }
}

-(void) configureButton: (UIButton *) day : (int) index
{
 
    bool selected = ![[week objectAtIndex:index] boolValue];
    [week setObject:selected ? @"true" : @"false" atIndexedSubscript:index];
    
    [self setButtonColor:day :selected];
    
}

-(void) setButtonColor: (UIButton *) day : (BOOL) selected
{
    UIColor *white = [UIColor whiteColor];
    UIColor *green = [UIColor colorWithRed:((float) 74 / 255.0f)
                                     green:((float) 165 / 255.0f)
                                      blue:((float) 77 / 255.0f)
                                     alpha:1.0f];
    
    day.backgroundColor = selected ? green : white;
    day.tintColor = selected ? white : green;
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
    return 3;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch(row)
    {
        case 1:
            return @"One Time";
            break;
        case 2:
            return @"Recurring";
            break;
    }
    
    return @"";
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %ld", row);
    
    switch(row)
    {
        case 0:
            [dateView setHidden:YES];
            [dailyView setHidden:YES];
            [eventType setText:@""];
            break;
        case 1:
            [dateView setHidden:NO];
            [dailyView setHidden:YES];
            [eventType setText:@"One Time"];
            break;
        case 2:
            [dateView setHidden:YES];
            [dailyView setHidden:NO];
            [eventType setText:@"Recurring"];
            break;
    }
    
}


@end


