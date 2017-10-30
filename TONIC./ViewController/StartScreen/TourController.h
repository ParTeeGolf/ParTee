//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TourController : UIViewController <UITextFieldDelegate>
{
        NSArray *arrPageImages;
}

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIPageControl *page;
@property (strong, nonatomic) UIPageViewController *pageViewController;

@end
