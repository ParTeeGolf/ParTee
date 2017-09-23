//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MyMatchesViewController.h"
#import "HomeViewController.h"
#import "ViewSpecialInvite.h"
#import "cell_SpecialInvite.h"

#define kLimit @"1"
#define kdialogLimit 100

@interface ViewSpecialInvite ()

@end

@implementation ViewSpecialInvite
@synthesize tblList;

- (void)viewDidLoad {
    [super viewDidLoad];
    [lblNotAvailable setHidden:YES];

    self.navigationController.navigationBarHidden=YES;

    _currentPage = 0;
    tblList.tableFooterView = [UIView new];
    arrSelected=[[NSMutableArray alloc] init];
    
    if(isiPhone4) {
        
        [tblList setFrame:CGRectMake(tblList.frame.origin.x, tblList.frame.origin.y, tblList.frame.size.width, tblList.frame.size.height-88)];
    }
    
    [[AppDelegate sharedinstance] showLoader];
    
    [self getDialogs];
    
}

- (void) getDialogs
{
    _currentDialog=0;
    
    arrData = [[NSMutableArray alloc] init];
    arrDialogData = [[NSMutableArray alloc] init];
    arrFinalData = [[NSMutableArray alloc] init];
    arrFinalUserData = [[NSMutableArray alloc] init];
    arrFinalDialogData = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *extendedRequest = [NSMutableDictionary dictionary];
    extendedRequest[@"sort_desc"] = @"last_message_date_sent";
    
    QBResponsePage *page = [QBResponsePage responsePageWithLimit:kdialogLimit skip:_currentDialog];
    
    [QBRequest dialogsForPage:page extendedRequest:extendedRequest successBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, QBResponsePage *page) {
        
        _currentDialog += dialogObjects.count;
        
        [arrDialogData addObjectsFromArray:dialogObjects];
        
        if (page.totalEntries > _currentDialog) {
            
            [self getDialogs];
            return;
        }
        
        NSMutableArray *arrOccupants  = [[NSMutableArray alloc] init];
        
        NSString *strCurrentId = [[AppDelegate sharedinstance] getStringObjfromKey:kuserDBID];
        
        NSNumber *num = [NSNumber numberWithInt:[strCurrentId intValue]];
        
        for(QBChatDialog *obj  in arrDialogData) {
            //now go through array and get user id of opponents
            
       if(![[AppDelegate sharedinstance] checkSubstring:@"unfriended" containedIn:obj.lastMessageText ])
            {
                NSMutableArray *arrTemp = [obj.occupantIDs mutableCopy];
                [arrTemp removeObject:num];
                [arrOccupants addObject:[arrTemp objectAtIndex:0]];
            }
        }
        
        NSLog(@"%@",[[arrOccupants valueForKey:@"description"] componentsJoinedByString:@","]);
        
        [self getUserFromDialogs:0 withArray:arrOccupants];
        
        
    } errorBlock:^(QBResponse *response) {
        [[AppDelegate sharedinstance] hideLoader];

    }];
}

-(void) getUserFromDialogs:(int) dialogUserPageNum withArray:(NSMutableArray *)arrOccupants{
    __block int currentPageNum = dialogUserPageNum;

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
    [getRequest setObject:kLimit forKey:@"limit"];
    NSString *strPage = [NSString stringWithFormat:@"%d",[kLimit intValue] * currentPageNum];
    
    [getRequest setObject:strPage forKey:@"skip"];
    //        [getRequest setObject:@"ID" forKey:@"sort_desc"];
    
    [getRequest setObject:[[arrOccupants valueForKey:@"description"] componentsJoinedByString:@","] forKey:@"user_id[in]"];
    
    [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {            // do something with retrieved object
        
        
        for(QBCOCustomObject *userobj in objects) {
            
            NSInteger userId = userobj.userID;
            
            NSInteger idxOfuser =  [arrOccupants indexOfObject:[NSNumber numberWithInteger:userId]];
            
            QBChatDialog *dictDialog = [arrDialogData objectAtIndex:idxOfuser];
            
            [arrFinalUserData addObject:userobj];
            [arrFinalDialogData addObject:dictDialog];
        }
        
        if(!arrData) {
            arrData = [[NSMutableArray alloc] init];
        }
        
        if(objects.count >= [kLimit integerValue]) {
            
            [self getUserFromDialogs:++currentPageNum withArray:arrOccupants];
            return;
        }

        arrData = [arrFinalUserData mutableCopy];
        
        if([arrData count]==0) {
            [lblNotAvailable setHidden:NO];
        }
        else {
            [lblNotAvailable setHidden:YES];
        }
        [[AppDelegate sharedinstance] hideLoader];

        [tblList reloadData];
        
    } errorBlock:^(QBResponse *response) {
        // Handle error here
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (IBAction) donePressed:(id)sender  {
 
    if([arrSelected count]>0 || arrData.count==0) {
        [AppDelegate sharedinstance].delegateShareObject = [arrSelected objectAtIndex:0];
      // [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        [[AppDelegate sharedinstance] displayMessage:@"Please select a contact"];
    }
    
}

//-----------------------------------------------------------------------

- (IBAction) action_Menu:(id)sender{
    
    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
        
    }];
    
}


-(IBAction)backPressed:(id)sender {
    [AppDelegate sharedinstance].delegateShareObject=nil;
    [self.navigationController popViewControllerAnimated:YES];

    //[self dismissViewControllerAnimated:YES completion:nil];
    
}

//-----------------------------------------------------------------------

-(IBAction) sendSpecialRequest:(UIButton*)sender {
    
    CGPoint center=sender.center;
    
    CGPoint rootViewPoint = [sender.superview convertPoint:center toView:tblList];
    NSIndexPath *indexPath = [tblList indexPathForRowAtPoint:rootViewPoint];
    NSLog(@"%d",indexPath.row);
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];

    [arrSelected removeAllObjects];
    [arrSelected addObject:obj];
    [tblList reloadData];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 61;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_SpecialInvite *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_SpecialInvite"];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_SpecialInvite" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:0];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    
    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];

    NSString *str1;
    
    if([arrSelected containsObject:obj]) {
        [cell.btnSendRequest setBackgroundImage:[UIImage imageNamed:@"accept"] forState:UIControlStateNormal];
    }
    else {
        [cell.btnSendRequest setBackgroundImage:[UIImage imageNamed:@"uncheck"] forState:UIControlStateNormal];
    }
    
    str1 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userDisplayName"]];
    
    [cell.lblUserName setText:str1];
    
    NSString *str2 = [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userHandicap"]];
    str2 = [NSString stringWithFormat:@"Handicap : %@",str2];
    [cell.lblhandicap setText:str2];
    
    [cell.imageViewUsers setShowActivityIndicatorView:YES];
    [cell.imageViewUsers setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [cell.imageViewUsers sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"userPicBase"]] placeholderImage:[UIImage imageNamed:@"missing-profile-photo"]];
    
    cell.imageViewUsers.layer.cornerRadius =  cell.imageViewUsers.frame.size.width/2;
    [cell.imageViewUsers.layer setMasksToBounds:YES];
    [cell.imageViewUsers.layer setBorderColor:[UIColor clearColor].CGColor];
    
    NSString *userFullMode= [[AppDelegate sharedinstance] nullcheck:[obj.fields objectForKey:@"userFullMode"]];

    if([userFullMode isEqualToString:@"1"]) {
        [cell.imageViewBadge setHidden:NO];
        [cell.viewBG setHidden:NO];
    }
    else {
        [cell.imageViewBadge setHidden:YES];
        [cell.viewBG setHidden:YES];
    }
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    ViewProfileViewController *viewController;
//    viewController    = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
//    
//    QBCOCustomObject *obj = [arrData objectAtIndex:indexPath.row];
//    viewController.customShareObj=obj;
//    viewController.isMyMatch=NO;
//    [self.navigationController pushViewController:viewController animated:YES];
}

/*
 NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];
 [getRequest setObject:@"1" forKey:@"limit"];
 [getRequest setObject:@"0" forKey:@"skip"];
 
 [[AppDelegate sharedinstance] showLoader];
 
 [QBRequest objectsWithClassName:@"UserInfo" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
 // response processing
 
 [[AppDelegate sharedinstance] hideLoader];
 
 } errorBlock:^(QBResponse *response) {
 // error handling
 NSLog(@"Response error: %@", [response.error description]);
 }];
 
 */
@end
