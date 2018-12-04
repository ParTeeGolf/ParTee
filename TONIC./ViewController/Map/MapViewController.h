//
//  WelcomeViewController.h
//  Alarm
//
//  Created by Amolaksingh on 11/02/15.
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController <GMSMapViewDelegate,UITextFieldDelegate> {
    NSMutableArray *arrData;
    NSString *strPageToken;

    IBOutlet UIView *viewInfo;
    GMSMutablePath *path;
    NSString *strGlobalLat;
    NSString *strGlobalLong;
    NSString *strlat;
    NSString *strlong;
    IBOutlet UILabel *lblName;
    IBOutlet UILabel *lblAddress;
    IBOutlet UILabel *lblRating;
    IBOutlet UILabel *lblDistance;
    IBOutlet UIImageView *imgviewLoc;
    IBOutlet  GMSMapView *mapView;
    
    IBOutlet UIActivityIndicatorView *indicatorLocImage;
    CLLocation *loc2;
    CLLocation *loc1;
    GMSPolyline *singleLine ;
    QBCOCustomObject *dictCourseMapData;
    QBCOCustomObject *tempCourseMapData;
    
    CLLocationCoordinate2D desplaceCoord;
    CLLocationCoordinate2D scrplaceCoord;

    NSString *strFromScreen;
    
    NSMutableArray *arrCourseData;
    int status;
}
@property (nonatomic,assign) int status;

@property (nonatomic,strong) QBCOCustomObject *dictCourseMapData;
@property (nonatomic,strong) NSMutableArray *arrCourseData;
@property (nonatomic,strong) NSString *strFromScreen;

@end
