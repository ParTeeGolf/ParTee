//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "RoleViewController.h"
#import "AdminViewController.h"

@interface RoleViewController ()

@end

@implementation RoleViewController
@synthesize roles;
int roleId;


- (void)viewDidLoad {
    [super viewDidLoad];
    
    QBCOCustomObject *obj = [[self roles] objectAtIndex:0];
    roleId = [[obj.fields objectForKey:@"RoleId"] intValue];
    
    self.navigationController.navigationBarHidden=YES;
    
    [rolePicker reloadAllComponents];
    
}

-(void) viewWillAppear:(BOOL)animated {
    
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
    return [self roles].count;
}

//-----------------------------------------------------------------------

#pragma - mark UIPickerView delegate method

//-----------------------------------------------------------------------

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    QBCOCustomObject *obj = [[self roles] objectAtIndex:row];
    return [obj.fields objectForKey:@"Name"];
}


//-----------------------------------------------------------------------

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    QBCOCustomObject *obj = [self roles][row];
    roleId = [[obj.fields objectForKey:@"RoleId"] intValue];
}

-(IBAction) SetRoleAndContinue
{
    [[AppDelegate sharedinstance] setCurrentRole:roleId];
    
    UIViewController *viewController;
    NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
    
    switch(roleId)
    {
        case -1:
            viewController    = [[AdminViewController alloc] initWithNibName:@"AdminViewController" bundle:nil];
            [self managerController:viewController:YES];
            break;
        case 0:
        case 1:
            viewController    = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
            ((SpecialsViewController*)viewController).DataType = filterCourse;
            [self managerController:viewController:YES];
            break;
        case 2:
        case 3:
            getRequest = [[NSMutableDictionary alloc] init];
            
            [getRequest setObject:[[AppDelegate sharedinstance] getCurrentUserGuid] forKey:@"_parent_id"];
            
            [QBRequest objectsWithClassName:@"UserCourses" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
                
                NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
                
                NSMutableArray *arrCourseIds = [[NSMutableArray alloc] init];
                
                for(QBCOCustomObject *obj in objects)
                {
                    @try
                    {
                        [arrCourseIds addObject:[obj.fields objectForKey:roleId == 2 ? @"EventManagerCourse" : @"CourseAdminCourse"]];
                    }
                    @catch(NSException *e)
                    {
                        
                    }
                }
                
                SpecialsViewController *vc = [[SpecialsViewController alloc] initWithNibName:@"SpecialsViewController" bundle:nil];
                vc.DataType = filterCourse;
                vc.courseIds = arrCourseIds;
                [self managerController:vc:YES];
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];
                
                NSLog(@"Response error: %@", [response.error description]);
            }];
            break;
    }
    
    
}

-(void) managerController:(UIViewController *)vc :(BOOL)panMode
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    
    SideMenuViewController *leftMenuViewController;
    leftMenuViewController = [[SideMenuViewController alloc] initWithNibName:@"SideMenuViewController" bundle:nil];
    MFSideMenuContainerViewController *container = [MFSideMenuContainerViewController
                                                    containerWithCenterViewController:nav
                                                    leftMenuViewController:leftMenuViewController
                                                    rightMenuViewController:nil];
    container.panMode=panMode;
    
    [[AppDelegate sharedinstance].window setRootViewController:container];
}

@end
