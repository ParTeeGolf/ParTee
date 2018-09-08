//
//  EventViewController.h
//  ParTee
//
//  Created by Admin on 24/08/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController < UITableViewDelegate, UITableViewDataSource>
{
    IBOutlet NSLayoutConstraint *viewNextPrevHeightConstraints;
 /************ Information View Outlets ***********/
    IBOutlet UIView *viewBlurInfo;
    IBOutlet UIView *viewInfoBase;
    IBOutlet UILabel *lblEventTitleInfo;
    IBOutlet UILabel *lblStartEndDateInfo;
    IBOutlet UILabel *lblAddressEventInfo;
    IBOutlet UITextView *textViewEventDescInfo;
    IBOutlet UIButton *BtnContactInfo;
    IBOutlet UIButton *BtnWebsiteInfo;
    IBOutlet UIButton *btnCloseInfo;
    IBOutlet NSLayoutConstraint *constraintsInfoBaseViewHeight;
    /************ Information View Outlets ***********/
    
 
}
@property (strong, nonatomic) IBOutlet UITableView *eventTblView;
@property (strong, nonatomic) IBOutlet UILabel *lblNothingFound;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
@property (strong, nonatomic) IBOutlet UIView *nextPrevRecordBaseView;

@end
