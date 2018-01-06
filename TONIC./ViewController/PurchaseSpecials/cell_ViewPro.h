//
//  cell_AlarmList.h
//  Alarm
//
//  Created by Admin on 18/11/14.
//  Copyright (c) 2014 WLc. All rights reserved.
//

#include "button_ViewPro.h"

@interface cell_ViewPro : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *proType;
@property (weak, nonatomic) IBOutlet UILabel *alternateProType;
@property (weak, nonatomic) IBOutlet UILabel *daysToExpireLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageUrl;
@property (weak, nonatomic) IBOutlet button_ViewPro *profileButton;
@property (weak, nonatomic) IBOutlet UIImageView *proIcon;
@property (weak, nonatomic) UINavigationController *navigationController;

@end
