//
//  EventPreferncesViewController.h
//  ParTee
//
//  Created by Admin on 08/09/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventPreferncesViewController : UIViewController<UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITextField *nameTxtFld;
@property (strong, nonatomic) IBOutlet UITextField *stateTxtFld;
@property (strong, nonatomic) IBOutlet UITextField *cityTxtFld;
@property (strong, nonatomic) IBOutlet UITextField *typeTxtFld;
@property (strong, nonatomic) IBOutlet UIButton *favSwitch;
@property (strong, nonatomic) IBOutlet UISlider *distanceSlider;
@property (strong, nonatomic) IBOutlet UILabel *distanceLbl;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) IBOutlet UITableView *listTblView;
@property (strong, nonatomic) IBOutlet UIView *viewTblView;
@property (strong, nonatomic) IBOutlet UIView *viewToolBar;

@end
