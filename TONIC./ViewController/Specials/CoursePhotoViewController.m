//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

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

    tblList1.tableFooterView = [UIView new];
    tblList1.separatorInset = UIEdgeInsetsZero;
    
    roleId = [[AppDelegate sharedinstance] getCurrentRole];
    
    [addButton setHidden:roleId != 3];
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 4.5, 0, 4.5);
    
}

-(void) viewWillAppear:(BOOL)animated {
    
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
    [arrData1 removeAllObjects];

    NSMutableDictionary *getRequest = [NSMutableDictionary dictionary];

    [getRequest setObject:kLimit1 forKey:@"limit"];

    [getRequest setObject: courseID forKey:@"_parent_id"];
    
    [getRequest setObject: @"Order" forKey:@"sort_asc"];

    
    [[AppDelegate sharedinstance] showLoader];
    
    [QBRequest objectsWithClassName:@"CoursePhoto" extendedRequest:getRequest successBlock:^(QBResponse *response, NSArray *objects, QBResponsePage *page) {
        
        NSLog(@"Entries %lu",(unsigned long)page.totalEntries);
        
        _sequence = (long)page.totalEntries;
        
        [[AppDelegate sharedinstance] hideLoader];
        
        [arrData1 addObjectsFromArray:[objects mutableCopy]];


        [tblList1 setHidden:[arrData1 count]==0];

        
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
    
    [cell.primary setHidden:![[obj.fields objectForKey:@"Primary"] boolValue]];
    
    [cell.imageUrl setShowActivityIndicatorView:YES];
    [cell.imageUrl setIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [cell.imageUrl sd_setImageWithURL:[NSURL URLWithString:[obj.fields objectForKey:@"Image"]] placeholderImage:[UIImage imageNamed:@"imgplaceholder.jpg"]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(roleId != 3)
    {
        return;
    }
    QBCOCustomObject *obj = [arrData1 objectAtIndex:indexPath.row];
    
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Course Options"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* deleteButton = [UIAlertAction
                                   actionWithTitle:@"Delete Photo"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       [self deletePhoto:obj.ID];
                                   }];
    
    UIAlertAction* primaryButton = [UIAlertAction
                                    actionWithTitle:@"Make Primary"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self setImagePrimary:obj.ID];
                                    }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                    actionWithTitle:@"Cancel"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        
                                    }];
    
    
    [alert addAction:deleteButton];
    [alert addAction:primaryButton];
    [alert addAction:cancelButton];

    alert.popoverPresentationController.sourceView = [tableView cellForRowAtIndexPath:indexPath];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) setImagePrimary: (NSString *) imageId
{
    for(QBCOCustomObject *obj in arrData1)
    {
        [obj.fields setObject:[obj.ID isEqualToString:imageId] ? @"true" : @"false" forKey:@"Primary"];
    }

    [QBRequest updateObjects:arrData1 className:@"CoursePhoto" successBlock:^(QBResponse * _Nonnull response, NSArray * _Nullable objects, NSArray * _Nullable notFoundObjectsIds) {
        [self getData1];
        } errorBlock:^(QBResponse *response) {
            // error handling
            NSLog(@"Response error: %@", [response.error description]);
            [[AppDelegate sharedinstance] hideLoader];
            
        }];
}

- (IBAction)action_Menu:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) addPhoto:(UIButton *)photoButton
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:@"Select image"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction* cameraButton = [UIAlertAction
                                   actionWithTitle:@"Camera"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
                                       {
                                           UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                           picker.delegate = self;
                                           picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                                           picker.allowsEditing = YES;
                                           
                                           [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                               [self presentViewController:picker animated:YES completion:nil];
                                           }];
                                           
                                       }
                                       else {
                                           UIAlertController * ac = [UIAlertController
                                                                     alertControllerWithTitle:kAppName
                                                                     message:@"Device does not supports camera"
                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                           UIAlertAction* okButton = [UIAlertAction
                                                                      actionWithTitle:@"OK"
                                                                      style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          
                                                                      }];
                                           [ac addAction:okButton];
                                           [self presentViewController:ac animated:YES completion:nil];
                                           return;
                                       }
                                   }];
    
    UIAlertAction* libraryButton = [UIAlertAction
                                    actionWithTitle:@"Select from Library"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        UIImagePickerController * picker = [[UIImagePickerController alloc] init];
                                        
                                        picker.delegate = self;
                                        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                                        picker.allowsEditing = YES;
                                        
                                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                            
                                            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                                                [self presentViewController:picker animated:YES completion:nil];
                                            }
                                            else {
                                                [self presentViewController:picker animated:YES completion:nil];
                                                
                                            }
                                        }];
                                    }];
    
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:@"Cancel"
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                       
                                   }];
    
    [alert addAction:cameraButton];
    [alert addAction:libraryButton];
    [alert addAction:cancelButton];
    
    alert.popoverPresentationController.sourceView = photoButton;
    [self presentViewController:alert animated:YES completion:nil];
}

//-----------------------------------------------------------------------

#pragma mark -
#pragma - mark Selecting Image from Camera and Library
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [[AppDelegate sharedinstance] showLoader];
    NSData *imageData = UIImagePNGRepresentation([info objectForKey:@"UIImagePickerControllerEditedImage"]);
    
    [QBRequest TUploadFile:imageData fileName:@"Photo.png" contentType:@"image/png" isPublic:YES successBlock:^(QBResponse *response, QBCBlob *blob) {
        
        
        NSString *url = [blob publicUrl];
        
        QBCOCustomObject *obj  = [[QBCOCustomObject alloc] init];
        obj.className = @"CoursePhoto";
        obj.parentID = courseID;
        [obj.fields setObject:[NSString stringWithFormat:@"%ld", _sequence + 1] forKey:@"Order"];
        [obj.fields setObject:url forKey:@"Image"];
        
            [QBRequest createObject:obj successBlock:^(QBResponse *response, QBCOCustomObject *object1) {
                // object updated
                
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Photo sucessfully saved."];
                
                [self viewWillAppear:NO];
                
                
            } errorBlock:^(QBResponse *response) {
                // error handling
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayServerErrorMessage];
                NSLog(@"Response error: %@", [response.error description]);
            }];
       
    } statusBlock:^(QBRequest *request, QBRequestStatus *status) {
        // handle progress
    } errorBlock:^(QBResponse *response) {
        [[AppDelegate sharedinstance] hideLoader];
        [[AppDelegate sharedinstance] displayServerErrorMessage];
        NSLog(@"error: %@", response.error);
    }];
   
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
}

//-----------------------------------------------------------------------

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
}


- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void) deletePhoto:(NSString *) id
{
    [QBRequest deleteObjectWithID:id className:@"CoursePhoto" successBlock:^(QBResponse * _Nonnull response) {
        [self viewWillAppear:NO];
    } errorBlock:^(QBResponse * _Nonnull response) {
        
    }
     ];
}


@end
