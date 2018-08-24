//
//  EventViewController.h
//  ParTee
//
//  Created by Admin on 24/08/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController < UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) IBOutlet UITableView *eventTblView;
@property (strong, nonatomic) IBOutlet UILabel *lblNothingFound;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIView *nextPrevRecordBaseView;

@end
