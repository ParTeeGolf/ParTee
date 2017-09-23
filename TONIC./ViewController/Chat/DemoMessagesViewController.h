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


// Import all the things
#import "JSQMessages.h"

#import "DemoModelData.h"
#import "NSUserDefaults+DemoSettings.h"


@class DemoMessagesViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(DemoMessagesViewController *)vc;

@end

@interface DemoMessagesViewController : JSQMessagesViewController <QBChatDelegate,UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate> {
    QBCOCustomObject *otherUserObject;
    NSString *strImgUrl ;
    NSMutableArray *arrCustomMessage;
    int demoId;
    int _currentPage;
    QBChatDialog *customAmoDialog;
     QBCOCustomObject *connObj;
    BOOL isMessageBlocked;
    IBOutlet UIImageView *imgBg;

    int cntMessage;
    QBCOCustomObject *objToUpdate;
    int currentPageNum;
    
}

@property (nonatomic,strong) QBChatDialog *sharedChatDialog;
@property (nonatomic,strong) QBCOCustomObject *otherUserObject;

@property (nonatomic,strong)   NSArray *arrConnections;

@property (strong, nonatomic) MBProgressHUD *HUD;
@property (nonatomic,strong) QBCOCustomObject *connObj;

@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) DemoModelData *demoData;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

@end
