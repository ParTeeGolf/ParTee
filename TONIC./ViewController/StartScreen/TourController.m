//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "TourController.h"
#import "TourViewController.h"

@interface TourController ()

@end

@implementation TourController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    arrPageImages = @[@"Slide 1.png", @"Slide 2.png", @"Slide 3.png", @"Slide 4.png", @"Slide 5.png",];
    
    self.pageViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TourViewController"];
    
    TourController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 30);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (TourController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([arrPageImages count] == 0) || (index >= [arrPageImages count])) {
        return nil;
    }
    // Create a new view controller and pass suitable data.
    TourController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"TourController"];
    pageContentViewController.image = arrPageImages[index];
    pageContentViewController.page.currentPage = index;
    return pageContentViewController;
}



@end
