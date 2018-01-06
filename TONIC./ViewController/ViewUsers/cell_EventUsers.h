//
//  cell_AlarmList.h
//  Alarm
//
//  Created by Admin on 18/11/14.
//  Copyright (c) 2014 WLc. All rights reserved.
//

#import "button_ViewEvent.h"

@interface cell_EventUsers : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblHomeCourse;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewUsers;
@property (weak, nonatomic) IBOutlet UIView *viewBG;

@property (weak, nonatomic) IBOutlet button_ViewEvent *addButton;
@property (weak, nonatomic) IBOutlet button_ViewEvent *removeButton;


@end
