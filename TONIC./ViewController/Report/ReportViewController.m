//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "ReportViewController.h"
#import "HomeViewController.h"

@interface ReportViewController ()

@end

@implementation ReportViewController
@synthesize customShareObj;
@synthesize arrData;
@synthesize arrConnections;
@synthesize dictUserData;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden=YES;
    
    imgView1.layer.cornerRadius = imgView1.frame.size.width/2;
    [imgView1.layer setMasksToBounds:YES];
    [imgView1.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView2.layer.cornerRadius = imgView2.frame.size.width/2;
    [imgView2.layer setMasksToBounds:YES];
    [imgView2.layer setBorderColor:[UIColor clearColor].CGColor];
    
    imgView3.layer.cornerRadius = imgView3.frame.size.width/2;
    [imgView3.layer setMasksToBounds:YES];
    [imgView3.layer setBorderColor:[UIColor clearColor].CGColor];
}

-(void) viewWillAppear:(BOOL)animated {
    self.otherUserObject = dictUserData;
    
}

-(IBAction)btnadvertisementPressed:(id)sender  {
    
    if(isadvertisement==0) {
        [btnadvertisement setTitleColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.180 alpha:1.00] forState:UIControlStateNormal];
        isadvertisement = 1;
    }
    else {
        [btnadvertisement setTitleColor:[UIColor colorWithRed:0.408 green:0.408 blue:0.408 alpha:1.00] forState:UIControlStateNormal];
        isadvertisement = 0;
    }

}

-(IBAction)btnABUSIVEPressed:(id)sender {
    
    if(isAbusive==0) {
        [btnABUSIVE setTitleColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.180 alpha:1.00] forState:UIControlStateNormal];
        isAbusive = 1;
    }
    else {
        [btnABUSIVE setTitleColor:[UIColor colorWithRed:0.408 green:0.408 blue:0.408 alpha:1.00] forState:UIControlStateNormal];
        isAbusive = 0;
    }

}

-(IBAction)btnINAPPROPRIATEPressed:(id)sender {
    if(isINAPPROPRIATE==0) {
        [btnINAPPROPRIATE setTitleColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.180 alpha:1.00] forState:UIControlStateNormal];
        isINAPPROPRIATE = 1;
    }
    else {
        [btnINAPPROPRIATE setTitleColor:[UIColor colorWithRed:0.408 green:0.408 blue:0.408 alpha:1.00] forState:UIControlStateNormal];
        isINAPPROPRIATE = 0;
    }
}

-(IBAction)btnSTOLENPressed:(id)sender {
    if(isSTOLEN==0) {
        [btnSTOLEN setTitleColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.180 alpha:1.00] forState:UIControlStateNormal];
        isSTOLEN = 1;
    }
    else {
        [btnSTOLEN setTitleColor:[UIColor colorWithRed:0.408 green:0.408 blue:0.408 alpha:1.00] forState:UIControlStateNormal];
        isSTOLEN = 0;
    }
}

-(IBAction)btnSPAMPressed:(id)sender {
    if(isSPAM==0) {
        [btnSPAM setTitleColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.180 alpha:1.00] forState:UIControlStateNormal];
        isSPAM = 1;
    }
    else {
        [btnSPAM setTitleColor:[UIColor colorWithRed:0.408 green:0.408 blue:0.408 alpha:1.00] forState:UIControlStateNormal];
        isSPAM = 0;
    }
}

-(IBAction) reportPressed:(id)sender {
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }

    [[AppDelegate sharedinstance] showLoader];
    
    int otherUserId = self.otherUserObject.userID;

    NSMutableArray *arr = [[self.otherUserObject.fields objectForKey:@"blockedfrommail"] mutableCopy];
    
    if(!arr || [arr count]==0) {
        arr = [[NSMutableArray alloc] init];
    }
    
    NSString *strCurrentUsermail = [[AppDelegate sharedinstance] getCurrentUserEmail];
    
    if(![arr containsObject:strCurrentUsermail]) {
        [arr addObject:strCurrentUsermail];
    }
    

    NSInteger spamBlockCount = [[self.otherUserObject.fields objectForKey:@"spamBlockCount"] integerValue];
    NSInteger contentBlockCount = [[self.otherUserObject.fields objectForKey:@"contentBlockCount"] integerValue];
    NSInteger stolenBlockCount = [[self.otherUserObject.fields objectForKey:@"stolenBlockCount"] integerValue];
    NSInteger abusiveBlockCount = [[self.otherUserObject.fields objectForKey:@"abusiveBlockCount"] integerValue];
    NSInteger otherBlockCount = [[self.otherUserObject.fields objectForKey:@"otherBlockCount"] integerValue];
    NSInteger advertisingBlockCount = [[self.otherUserObject.fields objectForKey:@"advertisingBlockCount"] integerValue];


    if(isSPAM==1) {
        spamBlockCount = spamBlockCount + 1;
    }
    
    if(isadvertisement==1) {
        advertisingBlockCount = advertisingBlockCount + 1;
    }
    
    if(isINAPPROPRIATE==1) {
        contentBlockCount = contentBlockCount + 1;
    }
    
    if(isAbusive==1) {
        abusiveBlockCount = abusiveBlockCount + 1;
    }
    
    if(isSTOLEN==1) {
        stolenBlockCount = stolenBlockCount + 1;
    }
    
    [self.otherUserObject.fields setObject:arr forKey:@"blockedfrommail"];
    [self.otherUserObject.fields setObject:[NSNumber numberWithInteger:spamBlockCount] forKey:@"spamBlockCount"];
    [self.otherUserObject.fields setObject:[NSNumber numberWithInteger:contentBlockCount] forKey:@"contentBlockCount"];
    [self.otherUserObject.fields setObject:[NSNumber numberWithInteger:stolenBlockCount] forKey:@"stolenBlockCount"];
    [self.otherUserObject.fields setObject:[NSNumber numberWithInteger:abusiveBlockCount] forKey:@"abusiveBlockCount"];
    [self.otherUserObject.fields setObject:[NSNumber numberWithInteger:advertisingBlockCount] forKey:@"advertisingBlockCount"];
    
    [[AppDelegate sharedinstance] showLoader];

    [QBRequest updateObject:self.otherUserObject successBlock:^(QBResponse *response, QBCOCustomObject *object) {
        // object updated
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypePrivate];
        chatDialog.occupantIDs = @[@(otherUserId)];
        
        QBChatMessage *qmessage = [QBChatMessage message];
        NSString *strname = [[AppDelegate sharedinstance] getCurrentName];
        
        [qmessage setText:[NSString stringWithFormat:@"unfriended"]];
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"save_to_history"] = @YES;
        params[@"senderNick"] =strname;
        [qmessage setCustomParameters:params];
        
        QBChatDialog *dialog = [AppDelegate sharedinstance].sharedchatDialog;
        
        [dialog sendMessage:qmessage completionBlock:^(NSError * _Nullable error) {

            [[[AppDelegate sharedinstance] sharedChatInstance] removeUserFromContactList:self.otherUserObject.userID completion:^(NSError * _Nullable error) {
            
                [[AppDelegate sharedinstance] hideLoader];
                [[AppDelegate sharedinstance] displayMessage:@"Unfriended successfully"];


                [self.navigationController popToRootViewControllerAnimated:YES];
            }];
            
       }];
        
    } errorBlock:^(QBResponse *response) {
        // error handling
        NSLog(@"Response error: %@", [response.error description]);
        [[AppDelegate sharedinstance] hideLoader];
        
    }];
    
}

-(IBAction)backPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
