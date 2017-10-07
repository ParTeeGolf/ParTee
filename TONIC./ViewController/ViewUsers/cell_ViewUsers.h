//
//  cell_AlarmList.h
//  Alarm
//
//  Created by Admin on 18/11/14.
//  Copyright (c) 2014 WLc. All rights reserved.
//

@interface cell_ViewUsers : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblhandicap;
@property (weak, nonatomic) IBOutlet UILabel *lblHomeCourse;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUsers;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBadge;
@property (weak, nonatomic) IBOutlet UIView *viewBG;
@property (weak, nonatomic) IBOutlet UIButton *btnAdd;
@property (weak, nonatomic) IBOutlet UIButton *btnMessageBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblOnlineStatus;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIButton *denyButton;


@end
