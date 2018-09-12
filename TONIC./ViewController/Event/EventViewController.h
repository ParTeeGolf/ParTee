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
    // constrrints used to hide nextPrevBaseView if it have value 0 then all the objects will adjust automatically by default its value is 30.
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
    
    /************ Advertiesment View Outlets ***********/
    IBOutlet UIView *viewAdvertiseInfoPopup;
    IBOutlet UILabel *lblAdvTitle;
    IBOutlet UITextView *txtViewAdvdesc;
    IBOutlet UIButton *btnWebsiteAdv;
    IBOutlet UIButton *btnCloseAdv;
    IBOutlet NSLayoutConstraint *constraintHeightTxtViewAdvDesc;
    /************ Advertiesment View Outlets ***********/
}
// Evnet table view that will show the list of events.
@property (strong, nonatomic) IBOutlet UITableView *eventTblView;
// This label will display nothing found if no one event exist for the prefernces.
@property (strong, nonatomic) IBOutlet UILabel *lblNothingFound;
// segment control used to filetr out the events from table based on favourite, featured , near me and all events.
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentControl;
// This is base view that contain next,prev and << button to fetch the require records
@property (strong, nonatomic) IBOutlet UIView *nextPrevRecordBaseView;

@end
