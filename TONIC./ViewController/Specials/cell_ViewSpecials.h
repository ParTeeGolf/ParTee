//
//  cell_AlarmList.h
//  Alarm
//
//  Created by Admin on 18/11/14.
//  Copyright (c) 2014 WLc. All rights reserved.
//

@interface cell_ViewSpecials : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblPoints;
@property (weak, nonatomic) IBOutlet UILabel *lblExpiresOn;

@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imageUrl;

@property (weak, nonatomic) IBOutlet UIButton *btnFavImage;
@property (weak, nonatomic) IBOutlet UIView *viewAlpha;

@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UIButton *buttonOptions;



@end
