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
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)btnSaveAndSearchAction:(id)sender {
}
- (IBAction)btnBackAction:(id)sender {
      [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)BtnClearSearchAction:(id)sender {
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
