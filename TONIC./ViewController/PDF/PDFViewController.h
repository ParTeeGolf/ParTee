//
//  MainViewController.h
//  SilverSpace
//
//  Created by Jagdish Prajapati on 11/03/15.
//  Copyright (c) 2015 SilverSpace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface PDFViewController : UIViewController <UIWebViewDelegate>{
    IBOutlet UITableView *tblRooms;
    NSArray *arrRoomInfo;
    
    IBOutlet UIWebView *webView;
    
    IBOutlet UIView *viewFooter;
    IBOutlet UIButton *btnBack;
    IBOutlet UILabel *lblTitle;
    
    NSInteger cameFromScreen;
    
}

@property(nonatomic,assign)  NSInteger cameFromScreen;

@property(nonatomic,assign) BOOL isForDocDir,isURL;

@property (nonatomic,strong) NSString *strFileName,*strDisplayFileName;



@end
