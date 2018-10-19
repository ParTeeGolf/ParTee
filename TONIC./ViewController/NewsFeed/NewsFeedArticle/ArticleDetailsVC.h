//
//  ArticleDetailsVC.h
//  ParTee
//
//  Created by Admin on 08/10/18.
//  Copyright © 2018 Hooda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArticleDetailsVC : UIViewController<UIWebViewDelegate,RNGridMenuDelegate,UIPopoverControllerDelegate>
@property (nonatomic, strong) NSDictionary *articleDetailDict;
@property (nonatomic, strong) QBCOCustomObject *AdFeedObj;
@property BOOL adFeedVal;

@end
