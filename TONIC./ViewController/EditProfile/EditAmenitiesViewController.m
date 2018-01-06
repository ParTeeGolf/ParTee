//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "cell_ViewAmenities.h"
#import "EditAmenitiesViewController.h"


@interface EditAmenitiesViewController ()

@end

@implementation EditAmenitiesViewController
@synthesize courseID;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshContent" object:nil];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4.5, 0, 4.5);

    tblList1.tableFooterView = [UIView new];
    tblList1.separatorInset = UIEdgeInsetsZero;
    
}

-(void) viewWillAppear:(BOOL)animated {
    
    [self getData1];
    
}


-(void) getData1
{
    arrAmenities = [[NSMutableArray alloc] init];
    arrCurrentAmenities = [[NSMutableArray alloc] init];
    [arrAmenities removeAllObjects];

    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"AmenitiesIcon" extendedRequest:nil successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        
        [arrAmenities addObjectsFromArray:[objects mutableCopy]];

        NSMutableDictionary *getRequest = [[NSMutableDictionary alloc] init];
        [getRequest setObject:courseID forKey:@"_parent_id"];
        
        [QBRequest objectsWithClassName:@"CourseAmenities" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
            
            NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
            
            [[AppDelegate sharedinstance] hideLoader];
            
            [arrCurrentAmenities addObjectsFromArray:[objects mutableCopy]];

            [tblList1 reloadData];
            
        } errorBlock:^(QBResponse *response) {
            // error handling
            [[AppDelegate sharedinstance] hideLoader];
            
            NSLog(@"Response error: %@", [response.error description]);
        }];
        
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
    return 60.5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return arrAmenities.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_ViewAmenities *cell = [tableView dequeueReusableCellWithIdentifier:@"cell_ViewAmenities"];
    NSArray *topLevelObjects;
    
    topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"cell_ViewAmenities" owner:self options:nil];
    // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
    
    cell = [topLevelObjects objectAtIndex:0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.backgroundColor=[UIColor clearColor];
    cell.contentView.backgroundColor=[UIColor clearColor];
    
    QBCOCustomObject *obj = [arrAmenities objectAtIndex:indexPath.row];
    
    cell.amenitiesName.text = [obj.fields objectForKey:@"Amenities"];
    cell.contentView.alpha = 0.5;
    NSString *amenity1 = [[obj.fields objectForKey:@"Amenities"] lowercaseString];
    for(QBCOCustomObject *amenities in arrCurrentAmenities)
    {
       
        NSString *amenity2 = [[amenities.fields objectForKey:@"Amenity"] lowercaseString];
        if([amenity1 isEqualToString:amenity2])
        {
            cell.contentView.alpha = 1.0;
            break;
        }
    }
    
    [cell.imageViewAmenities sd_setImageWithURL:[NSURL URLWithString:[[AppDelegate sharedinstance] getAmenitiesIcons:[obj.fields objectForKey:@"Amenities"]]] placeholderImage:[UIImage imageNamed:@"user"] options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [cell.imageViewAmenities setImage:image];
        [cell.imageViewAmenities setContentMode:UIViewContentModeScaleAspectFill];
        [cell.imageViewAmenities setShowActivityIndicatorView:NO];
        
    }];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell_ViewAmenities *selectedCell=[tableView cellForRowAtIndexPath:indexPath];
    QBCOCustomObject *selectAmenity = [arrAmenities objectAtIndex:indexPath.row];
    if(selectedCell.contentView.alpha == 0.5)
    {
        selectedCell.contentView.alpha = 1.0;
        
        QBCOCustomObject *newAmenity = [QBCOCustomObject alloc];
        newAmenity.className = @"CourseAmenities";
        [newAmenity.fields setObject:[selectAmenity.fields objectForKey:@"Amenities"] forKey:@"Amenity"];
        [newAmenity.fields setObject:courseID forKey:@"_parent_id"];
        
        [QBRequest createObject:newAmenity successBlock:^(QBResponse * _Nonnull response, QBCOCustomObject * _Nullable object) {
            
        } errorBlock:^(QBResponse * _Nonnull response) {
            
        }];
    }
    else
    {
        selectedCell.contentView.alpha = 0.5;
        NSString *id;
        NSString *amenity1 = [[selectAmenity.fields objectForKey:@"Amenities"] lowercaseString];
        for(QBCOCustomObject *obj in arrCurrentAmenities)
        {
            NSString *amenity2 = [[obj.fields objectForKey:@"Amenity"] lowercaseString];
            if([amenity1 isEqualToString:amenity2])
            {
                id = obj.ID;
                break;
            }
        }
        [QBRequest deleteObjectWithID:id className:@"CourseAmenities" successBlock:^(QBResponse * _Nonnull response) {

        } errorBlock:^(QBResponse * _Nonnull response) {
            
        }
         ];
    }
}



- (IBAction)action_Menu:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
