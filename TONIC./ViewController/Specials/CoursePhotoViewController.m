//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "HomeViewController.h"
#import "cell_ViewPhoto.h"
#import "CoursePhotoViewController.h"

#define kLimit1 @"100"


@interface CoursePhotoViewController ()

@end

@implementation CoursePhotoViewController
@synthesize courseID;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    
    if(isiPhone4) {
        
        [tblList1 setFrame:CGRectMake(tblList1.frame.origin.x, tblList1.frame.origin.y, tblList1.frame.size.width, tblList1.frame.size.height-88)];
    }
    
}

-(void) viewWillAppear:(BOOL)animated {
    arrData1 = [[NSMutableArray alloc] init];
    [tblList1 reloadData];
    [self getData1];
    
}

-(void) presentAd {
    BOOL isFullVersion = [[NSUserDefaults standardUserDefaults] boolForKey:kIAPFULLVERSION];

    if(!isFullVersion) {

    }
}


-(void) getData1
{
    arrData1 = [[NSMutableArray alloc] init];

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];

    [getRequest setObject:kLimit1 forKey:@"limit"];

    [getRequest setObject: courseID forKey:@"_parent_id"];

    [getRequest setObject: @"Order" forKey:@"sort_asc"];
    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"CoursePhoto" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        
        [[AppDelegate sharedinstance] hideLoader];
        
        [arrData1 addObjectsFromArray:[objects mutableCopy]];

        if([arrData1 count]==0) {
        
            [tblList1 setHidden:YES];
        }
        else {
            [tblList1 setHidden:NO];
            
        }
        
         [tblList1 reloadData];
        
        } errorBlock:^(QBResponse *response) {
        // error handling
        [[AppDelegate sharedinstance] hideLoader];
        
        NSLog(@"Response error: %@", [response.error description]);
    }];

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
    
    return arrData1.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_ViewPhoto *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewPhoto"];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewPhoto" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    
    QBCOCustomObject *obj = [arrData1 objectAtIndex:indexPath.row];
    
    [cell.imageUrl setShowActivityIndicatorView:YES];
    [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"Image"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
    
    return cell;
    
}

- (IBAction)action_Menu:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}






- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



@end
