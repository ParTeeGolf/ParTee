//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#define klimit 100
// Get dialogs with custom params : Occupant ID : current logged in ID + Other user ID : Will give output for 1-1 chat
//http://quickblox.com/developers/SimpleSample-chat_users-ios#Connect_to_Chat
#import "DemoMessagesViewController.h"
#import "JSQMessagesViewAccessoryButtonDelegate.h"
#import "UIButton+WebCache.h"
#import "AppDelegate.h"

@interface DemoMessagesViewController () <JSQMessagesViewAccessoryButtonDelegate>
@end

@implementation DemoMessagesViewController
@synthesize otherUserObject;
@synthesize connObj;
@synthesize arrConnections;
@synthesize sharedChatDialog;

#pragma mark - View lifecycle

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */

-(BOOL) prefersStatusBarHidden {
    return NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIApplication sharedApplication]setStatusBarHidden:NO];

    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(gotmessage:) name:@"gotmessage" object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(hidethekeyboard) name:@"hidethekeyboard" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(customCode) name:@"customAmoCode" object:nil];

    [AppDelegate sharedinstance].currentScreen = kScreenChat;

    [QBSettings setStreamResumptionEnabled:YES];
    
    self.demoData.messages = [[NSMutableArray alloc] init];
    
   _currentPage = 0;
    
    arrCustomMessage = [[NSMutableArray alloc] init];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    NSString *str =[otherUserObject.fields objectForKey:@"userDisplayName"];
    self.title = str;
    
    UIColor *red = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.00];
    
    NSMutableDictionary *navBarTextAttributes = [NSMutableDictionary dictionaryWithCapacity:1];
    
    [navBarTextAttributes setObject:red forKey:NSForegroundColorAttributeName ];
    
    self.navigationController.navigationBar.titleTextAttributes = navBarTextAttributes;
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    
    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];

    /**
     *  Set up message accessory button delegate and configuration
     */
    self.collectionView.accessoryDelegate = self;

    /**
     *  You can set custom avatar sizes
     */
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    
    self.showLoadEarlierMessagesHeader = NO;

//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
//                                                                              style:UIBarButtonItemStylePlain
//                                                                             target:self
//                                                                             action:@selector(receiveMessagePressed:)];

    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];

	
    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];

    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */

    /**
     *  Set a maximum height for the input toolbar
     *
     *  self.inputToolbar.maximumHeight = 150;
     */


}

-(void) hidethekeyboard {
    [self.view endEditing:YES];
     [self.inputToolbar.contentView.textView resignFirstResponder];
    [self.inputToolbar setHidden:YES];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    self.menuContainerViewController.panMode =YES;
    [AppDelegate sharedinstance].currentScreen = kScreenOther;

}

-(void) customchanges {
    
    UIFont *font = [UIFont fontWithName:@"Montserrat-Regular" size:15];
    UIFont *font1 = [UIFont fontWithName:@"Oswald-Regular" size:22];

    self.collectionView.collectionViewLayout.messageBubbleFont =font;
    self.navigationController.navigationBarHidden=YES;
    self.view.backgroundColor=[UIColor clearColor];  //[UIColor colorWithRed:0.231 green:0.231 blue:0.239 alpha:1.00];
    self.collectionView.backgroundColor=[UIColor clearColor];//[UIColor colorWithRed:0.231 green:0.231 blue:0.239 alpha:1.00];
    //      self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"imageName.pnd"]];
    
    self.collectionView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listBackground"]];

    long screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    UINavigationBar *navbar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 60)];
    // [navbar setTranslucent:YES];
    
    //do something like background color, title, etc you self
    [navbar setBackgroundColor:[UIColor redColor]];
    [navbar setBarTintColor:[UIColor colorWithRed:0.000 green:0.655 blue:0.176 alpha:1.00]];
    
    UIButton * customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton setBackgroundImage:[UIImage imageNamed:@"ico-back"] forState:UIControlStateNormal];
    customButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:11.0f];
    [customButton.layer setMasksToBounds:YES];
    customButton.frame=CGRectMake(15, 30, 11, 20);
    [customButton addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
    [navbar addSubview:customButton];
    
    UIButton * customButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [customButton1.layer setMasksToBounds:YES];
    customButton1.frame=CGRectMake(0, 20, 49, 39);
    [customButton1 addTarget:self action:@selector(closePressed:) forControlEvents:UIControlEventTouchUpInside];
    [navbar addSubview:customButton1];
    
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth/4, 20, screenWidth/2, 40)];
    [lbl setFont:font1];
    [lbl setTextAlignment:NSTextAlignmentCenter];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setText:[otherUserObject.fields objectForKey:@"userDisplayName"]];
    [lbl setTextColor:[UIColor whiteColor]];
    [navbar addSubview:lbl];
    
    [self.view addSubview:navbar];
    
    [self.view bringSubviewToFront:navbar];
    
    self.additionalContentInset = UIEdgeInsetsMake(40, 0, 0, 0);

}

-(void) viewDidDisappear:(BOOL)animated {
    self.menuContainerViewController.panMode=YES;

    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.inputToolbar setHidden:NO];

    currentPageNum=0;
    
    [AppDelegate sharedinstance].currentScreen = kScreenChat;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.menuContainerViewController.panMode=NO;
    
    
    self.view.backgroundColor=[UIColor colorWithRed:0.231 green:0.231 blue:0.239 alpha:1.00];
    self.collectionView.backgroundColor=[UIColor colorWithRed:0.231 green:0.231 blue:0.239 alpha:1.00];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.000 green:0.675 blue:0.224 alpha:1.00];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
    
    strImgUrl  = [otherUserObject.fields objectForKey:@"userPicBase"];
    
    [self customchanges];
    
//    self.collectionView.layer.borderColor = [UIColor redColor].CGColor;
//    self.collectionView.layer.borderWidth=2.f;
//    
    
    [self initalAmoCode];

}


-(void) sendCustomMessage {
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
    
    
}

#pragma mark - Custom menu actions for cells

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    /**
     *  Display custom menu actions for cells.
     */
    UIMenuController *menu = [notification object];
    menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
    
    [super didReceiveMenuWillShowNotification:notification];
}



#pragma mark - Testing

- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}


#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                          displayName:kJSQDemoAvatarDisplayNameJobs
                                                 text:@"First received!"];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = NO;
                
                newMediaData = videoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                JSQAudioMediaItem *audioItemCopy = [((JSQAudioMediaItem *)copyMediaData) copy];
                audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [audioItemCopy.audioData copy];
                
                /**
                 *  Reset audio item to simulate "downloading" the audio
                 */
                audioItemCopy.audioData = nil;
                
                newMediaData = audioItemCopy;
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                   media:newMediaData];
        }
        else {
            /**
             *  Last message was a text message
             */
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:copyMessage.text];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */

        // [JSQSystemSoundPlayer jsq_playMessageReceivedSound];

        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                    ((JSQAudioMediaItem *)newMediaData).audioData = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}

- (void) keyboardPressed:(UIBarButtonItem *)sender {
    ViewProfileViewController *viewController;
    
    viewController    = [[ViewProfileViewController alloc] initWithNibName:@"ViewProfileViewController" bundle:nil];
    
    QBCOCustomObject *obj = otherUserObject;
    viewController.customShareObj=obj;
    viewController.isMyMatch=NO;
    [self.navigationController pushViewController:viewController animated:YES];

    
   // [self.inputToolbar.contentView.textView becomeFirstResponder];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)closePressed:(UIBarButtonItem *)sender
{
    //[self.navigationController popViewControllerAnimated:YES];
   // [self.delegateModal didDismissJSQDemoViewController:self];
    
    self.inputToolbar.contentView.hidden=YES;
    self.inputToolbar.hidden=YES;
    [AppDelegate sharedinstance].isBlocked=NO;
    [AppDelegate sharedinstance].currentScreen = kScreenOther;
    
    [self dismissViewControllerAnimated:YES completion:^{
        
        self.navigationController.navigationBarHidden=NO;
    }];
}


#pragma mark - JSQMessagesViewController method overrides

- (void) didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *) date
{
    
    if(![[AppDelegate sharedinstance] connected]) {
        [[AppDelegate sharedinstance] displayServerFailureMessage];
        return;
    }
    
    QBChatMessage *qmessage = [QBChatMessage message];
    [qmessage setText:text];
    qmessage.recipientID = customAmoDialog.recipientID;
    qmessage.markable = YES;
    
    int currentUserQuickbloxId = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    qmessage.senderID = currentUserQuickbloxId;
    qmessage.dialogID = customAmoDialog.ID;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    params[@"senderNick"] = [[AppDelegate sharedinstance] getCurrentName];

    [qmessage setCustomParameters:params];
    
    QBChatDialog *dialog = customAmoDialog;

        JSQMessage *message = [[JSQMessage alloc] initWithSenderId: [[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"]
                                                 senderDisplayName:senderDisplayName
                                                              date:date
                                                              text:text];
        
        [self.demoData.messages addObject:message];
        
        [self finishSendingMessageAnimated:YES];
        [self.collectionView reloadData];
        
        cntMessage++;
        [dialog sendMessage:qmessage completionBlock:^(NSError * _Nullable error) {
        
            if(error) {
            
            [[AppDelegate sharedinstance] displayMessage:@"Message could not be send."];
            return ;
            }
        }];

    
//        if(cntMessage%1==0) {
//            // Check in background, user block/remove from my match status
//            
//            [QBRequest objectWithClassName:@"UserConnections" ID:objToUpdate.ID successBlock:^(QBResponse *response, QBCOCustomObject *object) {
//                // do something with retrieved object
//                
//                NSString *strConnStatus = [object.fields objectForKey:@"connStatus"];
//                
//                if(![strConnStatus isEqualToString:@"2"]) {
//                    
//                    [AppDelegate sharedinstance].isBlocked=YES;
//                    
//                    NSString *strMessage = [NSString stringWithFormat:@"Message could not be send.\n%@ has removed you from MY MATCHES",self.title];
//                    [[AppDelegate sharedinstance] displayMessage:strMessage];
//                    
//                    [self dismissViewControllerAnimated:YES completion:^{
//                        
//                    }];
//                    return ;
//                }
//                
//                
//            } errorBlock:^(QBResponse *response) {
//                // error handling
//                NSLog(@"Response error: %@", [response.error description]);
//            }];
//        }

    
//    [dialog joinWithCompletionBlock:^(NSError * _Nullable error) {
//
//     
//    }];

  //  [self sendCustomMessage];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];

    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Media messages", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"Send photo", nil), NSLocalizedString(@"Send location", nil), NSLocalizedString(@"Send video", nil), NSLocalizedString(@"Send audio", nil), nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        [self.inputToolbar.contentView.textView becomeFirstResponder];
        return;
    }
    
    switch (buttonIndex) {
        case 0:
            [self.demoData addPhotoMediaMessage];
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
            
        case 2:
            [self.demoData addVideoMediaMessage];
            break;
            
        case 3:
            [self.demoData addAudioMediaMessage];
            break;
    }
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}


#pragma mark - JSQMessages CollectionView DataSource

- (NSString *)senderId {
    return [[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"];
}

- (NSString *)senderDisplayName {
    return kJSQDemoAvatarDisplayNameSquires;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    return nil;

    if (indexPath.item % 4 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor =[UIColor colorWithRed:0.400 green:0.400 blue:0.400 alpha:1.00];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    cell.accessoryButton.hidden = YES;// ![self shouldShowAccessoryButtonForMessage:msg];
    
    return cell;
}

- (BOOL)shouldShowAccessoryButtonForMessage:(id<JSQMessageData>)message
{
    return ([message isMediaMessage] && [NSUserDefaults accessoryButtonForMediaMessages]);
}


#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }

    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }

    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);

    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    return 0.0f;

    if (indexPath.item % 4 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault ;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 5.0f;

    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 5.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
    
    [self loadEarlierData];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.demoData.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

#pragma mark - JSQMessagesViewAccessoryDelegate methods

- (void)messageView:(JSQMessagesCollectionView *)view didTapAccessoryButtonAtIndexPath:(NSIndexPath *)path
{
    NSLog(@"Tapped accessory button!");
}

//-----------------------------------------------------------------------

#pragma mark - CHAT Methods

//-----------------------------------------------------------------------


-(void) initalAmoCode {
//    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
//    [self.view addSubview:self.HUD];
//    
//    self.HUD.labelText=@"Connecting ...";
//    [self.HUD show:YES];
    
    int currentUserQuickbloxId = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    NSString *strSessToken = [QBSession currentSession].sessionDetails.token;
    
    int otherUserId = otherUserObject.userID;
    
    int nameForChatRoom = [[[AppDelegate sharedinstance] getStringObjfromKey:@"userQuickbloxID"] integerValue];
    nameForChatRoom = nameForChatRoom + otherUserId;
    
    QBUUser *user = [QBUUser user];
    QBUUser *currentUser = [QBSession currentSession].currentUser;
    currentUser.password = [[AppDelegate sharedinstance] getStringObjfromKey:kuserPassword];
    

    user.password = strSessToken;
    user.ID = currentUserQuickbloxId;
    
    NSLog(@"%@",[[QBChat instance] delegates]);
    
    if([[AppDelegate sharedinstance].sharedChatInstance isConnected]) {
        
        NSMutableDictionary *filterRequest = [[NSMutableDictionary alloc] init];
        
        filterRequest[@"name"] = [NSString stringWithFormat:@"%d",nameForChatRoom];
        
//        self.HUD.labelText=@"Connecting ...";
        
        QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypePrivate];
        chatDialog.occupantIDs = @[@(otherUserId)];
        
            customAmoDialog = [AppDelegate sharedinstance].sharedchatDialog;
            [self openChat];
        
    }
    else {
        [[AppDelegate sharedinstance] showLoader];
        
        // connect to Chat
        [[AppDelegate sharedinstance].sharedChatInstance connectWithUser:currentUser completion:^(NSError * _Nullable error) {
            NSMutableDictionary *filterRequest = [[NSMutableDictionary alloc] init];
            
            filterRequest[@"name"] = [NSString stringWithFormat:@"%d",nameForChatRoom];
            
            //        self.HUD.labelText=@"Connecting ...";
            
            QBChatDialog *chatDialog = [[QBChatDialog alloc] initWithDialogID:@"null" type:QBChatDialogTypePrivate];
            chatDialog.occupantIDs = @[@(otherUserId)];
            
            customAmoDialog = [AppDelegate sharedinstance].sharedchatDialog;
            [self openChat];
            
        }];
        
    
    }
}
-(void) openChat
{

    [self customAmoCode];
}

-(void) customCode {
    self.demoData.messages=nil;
    
    [self customAmoCode];
    currentPageNum=0;
    
}

-(void) customAmoCode {
    
    if(!self.demoData.messages) {
        self.demoData.messages= [[ NSMutableArray alloc] init];
        arrCustomMessage= [[ NSMutableArray alloc] init];
        self.demoData.messages= [[ NSMutableArray alloc] init];
    }

        // self get messages for dialog id
        
        NSString *strDialogId = customAmoDialog.ID;

        QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:klimit skip:(klimit*currentPageNum)];
    
        NSLog(@"Dialog : %@",customAmoDialog);
    
    [[QBChat instance] delegates];
    [QBSettings setKeepAliveInterval:30];
    
            NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc]init];
            
            extendedRequest[@"sort_desc"] = @"date_sent";
    
            [[AppDelegate sharedinstance] showLoader];
    
            [QBRequest messagesWithDialogID:strDialogId extendedRequest:extendedRequest forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responsePage) {
                
                if(!arrCustomMessage) {
                    arrCustomMessage = [[NSMutableArray alloc] init];
                }
                
                [arrCustomMessage addObjectsFromArray:[messages mutableCopy]];
                
                if(messages.count >= klimit && currentPageNum<1) {
                    ++currentPageNum;
                    [self customAmoCode];
                    return;
                }
                
                for(QBChatMessage *messageObj in arrCustomMessage ) {
                    
                    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",messageObj.senderID]
                                                             senderDisplayName:@""
                                                                          date:messageObj.dateSent
                                                                          text:messageObj.text];
                    
                    [self.demoData.messages addObject:message];
                }
                
               self.demoData.messages =[[[self.demoData.messages reverseObjectEnumerator] allObjects] mutableCopy];

                [self.collectionView reloadData];
                [self scrollToBottomAnimated:NO];
          //      [self.HUD hide:YES];
            
                [[AppDelegate sharedinstance] hideLoader];
                
//                NSString *strSelectedEmail = [otherUserObject.fields objectForKey:@"userEmail"];
//                
//                for(QBCOCustomObject *connObj in arrConnections) {
//                    
//                    NSString *strEmail = [connObj.fields objectForKey:@"connReceiverID"];
//                    
//                    if([[[AppDelegate sharedinstance] getCurrentUserEmail] isEqualToString:strEmail]) {
//                        strEmail= [connObj.fields objectForKey:@"connSenderID"];
//                    }
//                    
//                    if([strSelectedEmail isEqualToString:strEmail]) {
//                        objToUpdate = connObj;
//                        break;
//                    }
//                }
                
            } errorBlock:^(QBResponse *response) {
                NSLog(@"error: %@", response.error);
            }];
            
}

-(void) loadEarlierData {
    _currentPage++;
    
    NSString *str =[otherUserObject.fields objectForKey:@"userDisplayName"];
    self.title = str;
    
    // self get messages for dialog id
    
    NSString *strDialogId = customAmoDialog.ID;
    
    QBResponsePage *resPage = [QBResponsePage responsePageWithLimit:klimit skip:klimit*_currentPage];
    
        NSMutableDictionary *extendedRequest = [[NSMutableDictionary alloc]init];
        
        extendedRequest[@"sort_desc"] = @"date_sent";
        
        [QBRequest messagesWithDialogID:strDialogId extendedRequest:extendedRequest forPage:resPage successBlock:^(QBResponse *response, NSArray *messages, QBResponsePage *responcePage) {
            
            arrCustomMessage = [messages mutableCopy];
            
            for(QBChatMessage *messageObj in arrCustomMessage ) {
                
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",messageObj.senderID]
                                                         senderDisplayName:@""
                                                                      date:messageObj.dateSent
                                                                      text:messageObj.text];
                
               [self.demoData.messages insertObject:message atIndex:0];
            }
            
            [self.collectionView reloadData];
            
        } errorBlock:^(QBResponse *response) {
            NSLog(@"error: %@", response.error);
        }];

}

- (void) chatRoomDidReceiveMessage:(QBChatMessage *)messageObj fromDialogId:(NSString *)dialogId{
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",messageObj.senderID]
                                             senderDisplayName:@""
                                                          date:messageObj.dateSent
                                                          text:messageObj.text];
    
    [self.demoData.messages addObject:message];
    
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];
}

-(void) gotmessage:(NSNotification*)notification{
    
    NSDictionary *dictObj = notification.userInfo;
    
    QBChatMessage *messageObj = [dictObj objectForKey:@"message"];
    NSString *strMessageText = messageObj.text;
    NSString *strSenderName = [messageObj.customParameters objectForKey:@"senderNick"];
    NSString *strDialogId = [messageObj.customParameters objectForKey:@"dialog_id"];
    
    if([customAmoDialog.ID isEqualToString:strDialogId]) {
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",messageObj.senderID]
                                                 senderDisplayName:@""
                                                              date:messageObj.dateSent
                                                              text:messageObj.text];
        
        [self.demoData.messages addObject:message];
        
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
        
    }
    else {
     //   [self.inputToolbar.contentView.textView resignFirstResponder];

        NSString *strOtherUserId =[NSString stringWithFormat:@"%d",otherUserObject.userID];
        
        NSString *strSenderId =[NSString stringWithFormat:@"%d",messageObj.senderID];
        
        if(![strSenderId isEqualToString:strOtherUserId]) {
            
            NSString *strMessage = [NSString stringWithFormat:@"Message from %@",strSenderName];
            [[AppDelegate sharedinstance] displayCustomNotificationWithTitle:strMessage andMessage:strMessageText];
        }
    }
    

}

- (void)chatDidReceiveMessage:(QB_NONNULL QBChatMessage *)messageObj {
    
    NSString *strMessageText = messageObj.text;
    NSString *strSenderName = [messageObj.customParameters objectForKey:@"senderNick"];
    NSString *strDialogId = [messageObj.customParameters objectForKey:@"dialog_id"];

    if([customAmoDialog.ID isEqualToString:strDialogId]) {
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%lu",messageObj.senderID]
                                                 senderDisplayName:@""
                                                              date:messageObj.dateSent
                                                              text:messageObj.text];
        
        [self.demoData.messages addObject:message];
        
        [self.collectionView reloadData];
        [self scrollToBottomAnimated:NO];
        
    }
    else {
        NSString *strOtherUserId =[NSString stringWithFormat:@"%lu",otherUserObject.userID];

        NSString *strSenderId =[NSString stringWithFormat:@"%lu",messageObj.senderID];
        
        if(![strSenderId isEqualToString:strOtherUserId]) {
            
            NSString *strMessage = [NSString stringWithFormat:@"Received message from %@ : %@ ",strSenderName,strMessageText];
            [[AppDelegate sharedinstance] displayMessage:strMessage];
        }
    }
}

- (void)chatDidReceiveSystemMessage:(QBChatMessage *)messageObj
{
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[NSString stringWithFormat:@"%d",messageObj.senderID]
                                                 senderDisplayName:@""
                                                              date:messageObj.dateSent
                                                              text:messageObj.text];
        
        [self.demoData.messages addObject:message];
    
    [self.collectionView reloadData];
    [self scrollToBottomAnimated:NO];

}

- (void) chatDidAccidentallyDisconnect{
    
}

- (void)chatDidNotConnectWithError:(QB_NULLABLE NSError *)error {
    
}

- (void)chatDidReconnect{
    
}

- (void)chatDidFailWithStreamError:(QB_NULLABLE NSError *)error {
    
}

- (void)chatDidConnect {
    
}

- (void) chatDidNotSendMessage:(QBChatMessage *)message error:(NSError *)error{

}

@end
