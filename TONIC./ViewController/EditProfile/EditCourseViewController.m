//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "EditCourseViewController.h"


#define startDate 1
#define endDate 2



#define kImageChosen 1
#define kImageDelete 2
#define kImageLoaded 3
#define kImageCancel 3

@interface EditCourseViewController ()

@end

@implementation EditCourseViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *fields = @[Phone, Website, TeeTimes, Scorecard,description,News,NumberOfHoles];
    
    [self setKeyboardControls:[[BSKeyboardControls alloc] initWithFields:fields]];
    [self.keyboardControls setDelegate:self];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4.5, 0, 4.5);
    
    if(isiPhone4) {
        
        [scrollViewContainer setContentSize:CGSizeMake(320, 1000)];

    }
    else {
        [scrollViewContainer setContentSize:CGSizeMake(320, 750)];

    }
    
    [self bindData];
}

- (void) bindData {
   
    Phone.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"ContactNumber"]];
    Website.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"Website"]];
    TeeTimes.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"booking"]];
    News.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"News"]];
    NumberOfHoles.text = [NSString stringWithFormat:@"%@",[[self object].fields objectForKey:@"NumberHoles"]];
    Scorecard.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"ScoreCard"]];
    description.text = [[AppDelegate sharedinstance] nullcheck:[[self object].fields objectForKey:@"description"]];
 
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

        [[self object].fields setObject:Phone.text forKey:@"Phone"];
        [[self object].fields setObject:Website.text forKey:@"Website"];
        [[self object].fields setObject:TeeTimes.text forKey:@"booking"];
        [[self object].fields setObject:Scorecard.text forKey:@"ScoreCard"];
        [[self object].fields setObject:NumberOfHoles.text forKey:@"NumberHoles"];
        [[self object].fields setObject:News.text forKey:@"News"];
        [[self object].fields setObject:description.text forKey:@"Description"];

    
    [QBRequest updateObject:[self object] successBlock:^(QBResponse *response, QBCOCustomObject *object1) {
        // object updated
        
        _object=object1;
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayMessage:@"Course successfully saved."];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayServerErrorMessage];
        NSLog(@"Response error: %@", [response.error description]);
    }];
        
    
    
}


//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
        [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    
        }];
    //
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma mark Keyboard Controls Delegate

//-----------------------------------------------------------------------

- (void)keyboardControls:(BSKeyboardControls *)keyboardControls selectedField:(UIView *)field inDirection:(BSKeyboardControlsDirection)direction
{
  
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
    UIView *textFieldview;
    
    textFieldview = textView.superview.superview;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:.5];
    [scrollViewContainer setContentOffset:CGPointMake(0, textView.frame.origin.y)animated:NO];
    [UIView commitAnimations];
    
    [self.keyboardControls setActiveField:textView];
}



-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


@end


