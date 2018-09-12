//
//  EventPreferncesViewController.m
//  ParTee
//
//  Created by Admin on 08/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "EventPreferncesViewController.h"

@interface EventPreferncesViewController ()

@end

@implementation EventPreferncesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
}

/**
 @Description
 * This Method save all the data provided by the user in order to search the event  and also save into user default data and popup this controller after that it will filter out the event based on perfernces set by the user.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
#pragma mark- Save And search Action
- (IBAction)btnSaveAndSearchAction:(id)sender {
}
/**
 @Description
 * This Method pop this controller after shown the popup that have two button yes or No. If user press yes the event will be filter out based on preferences while if user pressed no then all events will be shown in event screen.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
#pragma mark- Back button Action
- (IBAction)btnBackAction:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}
/**
 @Description
 * This Method clears all the parameters to initial value and also ask first to clear parameters through popup or alert.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
#pragma mark- Clear search action
- (IBAction)BtnClearSearchAction:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}



@end
