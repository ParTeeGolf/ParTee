//
//  ArticleDetailsVC.m
//  ParTee
//
//  Created by Admin on 08/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "ArticleDetailsVC.h"

@interface ArticleDetailsVC ()

@end

@implementation ArticleDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
#pragma mark - Back Button Action
/**
 @Description
 * This Method pop this controller after shown the popup that have two button yes or No. If user press yes the event will be filter out based on preferences while if user pressed no then all events will be shown in event screen.
 * @author Chetu India
 * @param sender  the object on which action is perofrmed.
 * @return void nothing will return by this method.
 */
- (IBAction)backSideMenuAction:(id)sender {
    
       [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
