//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "TourViewController.h"

@interface TourViewController ()<UIPageViewControllerDelegate, UIPageViewControllerDataSource>

@end

@implementation TourViewController

NSArray *views;


-(UIViewController *) VCInstance:(NSString *) name
{
   UIViewController *view = [[UIStoryboard storyboardWithName:@"TourViewController" bundle:nil] instantiateViewControllerWithIdentifier:name];
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad )
    {
        for(NSObject *obj in [view.view subviews])
        {
            if([obj isKindOfClass:[UIImageView class]])
            {
                if([name isEqualToString:@"slide1"])
                {
                    [(UIImageView *)obj setImage:[UIImage imageNamed:@"Copy of Slide 1"]];
                    break;
                }
                else if([name isEqualToString:@"slide2"])
                {
                    [(UIImageView *)obj setImage:[UIImage imageNamed:@"Copy of Slide 2"]];
                    break;
                }
                else if([name isEqualToString:@"slide3"])
                {
                    [(UIImageView *)obj setImage:[UIImage imageNamed:@"Copy of Slide 3"]];
                    break;
                }
                else if([name isEqualToString:@"slide4"])
                {
                    [(UIImageView *)obj setImage:[UIImage imageNamed:@"Copy of Slide 4"]];
                    break;
                }
                else if([name isEqualToString:@"slide5"])
                {
                    [(UIImageView *)obj setImage:[UIImage imageNamed:@"Copy of Silde 5"]];
                    break;
                }
            }
        }
    }
    
    
    return view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataSource = self;
    self.delegate = self;
    
    views = @[[self VCInstance:@"slide1"],
              [self VCInstance:@"slide2"],
              [self VCInstance:@"slide3"],
              [self VCInstance:@"slide4"],
              [self VCInstance:@"slide5"]];
    [self setViewControllers:@[[views firstObject]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    [[NSUserDefaults standardUserDefaults]  setBool:YES forKey:kIsFirstTime];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSInteger index = [views indexOfObject:viewController];

    --index;
    if(index < 0)
    {
        index = [views count] - 1;
    }
    
    return views[index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSInteger index = [views indexOfObject:viewController];
    ++index;
    if(index > 4)
    {
        index = 0;
    }
    return views[index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [views count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

-(IBAction)closeTour:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
