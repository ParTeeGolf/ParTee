//
//  EventViewController.m
//  ParTee
//
//  Created by Admin on 24/08/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import "EventViewController.h"
#import "cell_ViewSpecials.h"

@interface EventViewController ()

@end

@implementation EventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.eventTblView.hidden = true;
    self.lblNothingFound.hidden = false;
    
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - SideMenuBtnAction
- (IBAction)sideMenuAction:(id)sender {
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
}
#pragma mark - MapScreenSideMenuAction
- (IBAction)mapSideMenuAction:(id)sender {
}
#pragma mark - SegmentChangedAction

- (IBAction)segmentChangedAction:(id)sender {
}
#pragma mark - SearchEventAction
- (IBAction)searchBottomBtnAction:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_ViewSpecials *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewSpecials"];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewSpecials" owner:self options:nil];
   
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
       }

@end
