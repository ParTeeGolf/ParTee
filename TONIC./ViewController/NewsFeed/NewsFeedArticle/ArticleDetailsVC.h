//
//  ArticleDetailsVC.h
//  ParTee
//
//  Created by Admin on 08/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleDetailsVC : UIViewController<UIWebViewDelegate,RNGridMenuDelegate,UIPopoverControllerDelegate>
// Feed article details dict.
@property (nonatomic, strong) NSDictionary *articleDetailDict;
// Advertisement Feed Object.
@property (nonatomic, strong) QBCOCustomObject *AdFeedObj;
// Is from advertisement feed.
@property BOOL adFeedVal;

@end
