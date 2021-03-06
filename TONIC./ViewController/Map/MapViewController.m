//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//


#import "MapViewController.h"
#import "PurchaseSpecialsViewController.h"
#import <MapKit/MapKit.h>

#define kLimit @"100"

#define kScreenCoursesMain @"1"
#define kScreenCoursesSub @"2"
#define kScreenCoursesDetail @"3"
#define kScreenCoursesMy @"4"

@interface MapViewController ()
{
    GMSMarker *courseMarker;
    UIImage *newImage;
    NSMutableArray *arrCourseDetails;
    
}
@end

@implementation MapViewController

@synthesize dictCourseMapData;
@synthesize strFromScreen;
@synthesize arrCourseData;
@synthesize status;


- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    arrCourseDetails = [[NSMutableArray alloc]init];
    tempCourseMapData = [[QBCOCustomObject alloc]init];
    [self drawRouteOnMap];
    
}
-(void)drawRouteOnMap
{
    
    self.navigationController.navigationBarHidden = YES;
    imgviewLoc.layer.masksToBounds = YES;
    imgviewLoc.layer.cornerRadius = 25.0;
    imgviewLoc.layer.cornerRadius = 25.0;
    
    [indicatorLocImage setHidden:YES];
    path = [GMSMutablePath path];
    
    arrData = [[NSMutableArray alloc] init];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    mapView.myLocationEnabled = NO;
    mapView.delegate = self;
    mapView.settings.myLocationButton = NO;
    
    [indicatorLocImage startAnimating];
    [indicatorLocImage setHidden:NO];
    
    if([strFromScreen isEqualToString:kScreenCoursesMain]) {
        arrCourseDetails = [arrCourseData mutableCopy];
        dictCourseMapData = [arrCourseDetails objectAtIndex:0];
        [arrCourseDetails removeObjectAtIndex:0];
        [self gotLocationFromMain];
    }
    else {
        
        [self gotLocation];
    }
}

-(void) gotLocationFromMain {
    int n = arrCourseDetails.count;
    
    if([arrCourseDetails count]>50) {
        n=50;
    }
    
    for(int i=0;i<n;i++) {
        
        tempCourseMapData = [arrCourseDetails objectAtIndex:i];
        
        NSArray *arrCoord = [tempCourseMapData.fields objectForKey:@"coordinates"];
        // pin type is parameter available on golfcurse table on quickblox that we need to ask for.
        if([arrCoord count]>0) {
            
            NSString *strPinType = @"";
            if([strPinType length]==0) {
                strPinType = @"type-1";
            }
            
            strlat = [arrCoord objectAtIndex:1];
            strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
            
            strlong = [arrCoord objectAtIndex:0];
            strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
            
            //Create a special variable to hold this coordinate info.
            CLLocationCoordinate2D placeCoord;
            
            //Set the lat and long.
            placeCoord.latitude=[strlat doubleValue];
            placeCoord.longitude=[strlong doubleValue];
            
            desplaceCoord = placeCoord;
            
            CLLocationCoordinate2D position = {  placeCoord.latitude, placeCoord.longitude };
            
            GMSMarker *marker = [GMSMarker markerWithPosition:position];
            marker.icon = [UIImage imageNamed:strPinType];
            marker.title = @"";//[NSString stringWithFormat:@"Marker %i", i];
            marker.appearAnimation = YES;
            marker.flat = YES;
            marker.snippet =  [NSString stringWithFormat:@"%i", i];
            marker.map = mapView;
            
            [path addCoordinate: marker.position];
            
            strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
            strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
            
            strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
            strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
            
            //Set the lat and long.
            placeCoord.latitude=[strlat doubleValue];
            placeCoord.longitude=[strlong doubleValue];
            
        }
    }
    
    if([arrCourseDetails count]>0) {
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        [self gotLocation];
    }
    
}

-(void) gotLocation {
    
    NSArray *arrCoord = [dictCourseMapData.fields objectForKey:@"coordinates"];
    
    // pin type is parameter available on golfcurse table on quickblox that we need to ask for.
    if([arrCoord count]>0) {
        
        NSString *strPinType = @"";
        if([strPinType length]==0) {
            strPinType = @"type-1";
        }
        
        strlat = [arrCoord objectAtIndex:1];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [arrCoord objectAtIndex:0];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        desplaceCoord = placeCoord;
        
        CLLocationCoordinate2D position = {  placeCoord.latitude, placeCoord.longitude };
        
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.icon = [UIImage imageNamed:@"type-my"];
        marker.title = @"";
        marker.appearAnimation = YES;
        marker.flat = YES;
        marker.snippet =  [NSString stringWithFormat:@"%i", 0];
        marker.map = mapView;
        [path addCoordinate: marker.position];
        
        
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        
        CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
        scrplaceCoord = myposition;
        UIImage *newBottomImage = [UIImage imageNamed:@"userProfileDefaultImage"];
        UIImage *bottomImage = [self roundedRectImageFromImage:newBottomImage size:CGSizeMake(70.8, 70.8) withCornerRadius:70.8];
        UIImage *image   = [UIImage imageNamed:kUserMapProfileBackgrooundIcon]; //foreground image
        
        CGSize newSize = CGSizeMake(150, 150);
        UIGraphicsBeginImageContext( newSize );
        
        // Apply supplied opacity if applicable
        [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        [bottomImage drawInRect:CGRectMake(40.5,7.6,70.8,70.8)];
        UIImage *tempImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        
        courseMarker = [GMSMarker markerWithPosition:myposition];
        courseMarker.icon = tempImage;
        courseMarker.title = @"";
        courseMarker.appearAnimation = YES;
        courseMarker.flat = YES;
        courseMarker.snippet =  [NSString stringWithFormat:@"%i", 0];
        courseMarker.map = mapView;
        
        [path addCoordinate: courseMarker.position];
        
        
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
        
        NSString *strCourseName = [dictCourseMapData.fields objectForKey:@"Name"];
        NSString *strCourseImgUrl = [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"ImageUrl"]];
        
        [lblName setText:strCourseName];
        
        NSString *strCity= [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"City"]];
        NSString *strState= [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"State"]];
        NSString *strZipCode= [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"ZipCode"]];
        
        NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"Address"]];
        str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
        [lblAddress setText:str1];
        
        [self drawRoute];
        
        //   [self getUserProfileImage];
        
        if([strCourseImgUrl length]>0) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strCourseImgUrl]];
            
            [imgviewLoc setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           // do image resize here
                                           
                                           // then set image view
                                           
                                           imgviewLoc.image = image;
                                           [indicatorLocImage stopAnimating];
                                           [indicatorLocImage setHidden:YES];
                                           
                                           
                                       }
                                       failure:nil];
        }
        else {
            [indicatorLocImage stopAnimating];
            [indicatorLocImage setHidden:YES];
            
            [imgviewLoc setImage:[UIImage imageNamed:@"ic_thumbnail.png"]];
        }
        
    }
}

-(void)getUserProfileImage
{
    // Show user profile image at users current location according to requirement
    // only profile image only if map screen disply it will not display if user come from three dot popup map screen
    if([strFromScreen isEqualToString:kScreenCoursesSub]) {
        //    [[AppDelegate sharedinstance] showLoader];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           
                           NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];
                           NSString *strname = [dictUserDetails objectForKey:@"userPicBase"];
                           NSURL *urlImg = [NSURL URLWithString:strname];
                           NSData *imageData = [NSData dataWithContentsOfURL:urlImg];
                           
                           //This is your completion handler
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               
                               
                               UIImage *newBottomImage = [UIImage imageWithData:imageData];
                               UIImage *bottomImage = [self roundedRectImageFromImage:newBottomImage size:CGSizeMake(70.8, 70.8) withCornerRadius:70.8];
                               UIImage *image       = [UIImage imageNamed:kUserMapProfileBackgrooundIcon]; //foreground image
                               
                               CGSize newSize = CGSizeMake(150, 150);
                               UIGraphicsBeginImageContext( newSize );
                               
                               // Apply supplied opacity if applicable
                               [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                               [bottomImage drawInRect:CGRectMake(40.5,7.6,70.8,70.8)];
                               newImage = UIGraphicsGetImageFromCurrentImageContext();
                               
                               UIGraphicsEndImageContext();
                               courseMarker.icon = newImage;
                               
                           });
                       });
        
    }else {
        //  [[AppDelegate sharedinstance] showLoader];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           
                           
                           NSDictionary *dictUserDetails = [[NSUserDefaults standardUserDefaults] objectForKey:kuserData];
                           NSString *strname = [dictUserDetails objectForKey:@"userPicBase"];
                           NSURL *urlImg = [NSURL URLWithString:strname];
                           NSData *imageData = [NSData dataWithContentsOfURL:urlImg];
                           
                           //This is your completion handler
                           dispatch_sync(dispatch_get_main_queue(), ^{
                               
                               
                               UIImage *newBottomImage = [UIImage imageWithData:imageData];
                               UIImage *bottomImage = [self roundedRectImageFromImage:newBottomImage size:CGSizeMake(70.8, 70.8) withCornerRadius:72];
                               UIImage *image       = [UIImage imageNamed:kUserMapProfileBackgrooundIcon]; //foreground image
                               
                               CGSize newSize = CGSizeMake(150, 150);
                               UIGraphicsBeginImageContext( newSize );
                               
                               // Apply supplied opacity if applicable
                               [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
                               [bottomImage drawInRect:CGRectMake(40.5,7.6,70.8,70.8)];
                               newImage = UIGraphicsGetImageFromCurrentImageContext();
                               
                               UIGraphicsEndImageContext();
                               courseMarker.icon = newImage;
                               
                               
                           });
                       });
    }
    
}


-(UIImage*)roundedRectImageFromImage:(UIImage *)image
                                size:(CGSize)imageSize
                    withCornerRadius:(float)cornerRadius
{
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);   //  <= notice 0.0 as third scale parameter. It is important cause default draw scale ≠ 1.0. Try 1.0 - it will draw an ugly image..
    CGRect bounds=(CGRect){CGPointZero,imageSize};
    [[UIBezierPath bezierPathWithRoundedRect:bounds
                                cornerRadius:cornerRadius] addClip];
    [image drawInRect:bounds];
    UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return finalImage;
}


-(IBAction)navigate:(id)sender {
    
    if([strFromScreen isEqualToString:kScreenCoursesMain]) {
        
        PurchaseSpecialsViewController *viewController;
        viewController    = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
        viewController.status=1;
        viewController.courseObject=dictCourseMapData;
        [self.navigationController pushViewController:viewController animated:YES];
    }
    else      if([strFromScreen isEqualToString:kScreenCoursesSub])
    {
        PurchaseSpecialsViewController *viewController;
        viewController    = [[PurchaseSpecialsViewController alloc] initWithNibName:@"PurchaseSpecialsViewController" bundle:nil];
        
        viewController.status=1;
        
        viewController.courseObject=dictCourseMapData;
        [self.navigationController pushViewController:viewController animated:YES];
        
    }
    
}


-(IBAction)showcurrentlocation:(id)sender {
    
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
    [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
}

- (BOOL) mapView: (GMSMapView *)mapView1 didTapMarker:(GMSMarker *)marker
{
    
    if([strFromScreen isEqualToString:kScreenCoursesMain]) {
        NSString *strIdx = marker.snippet;
        
        dictCourseMapData= [arrCourseDetails objectAtIndex:[strIdx integerValue]];
        
        [indicatorLocImage startAnimating];
        [indicatorLocImage setHidden:NO];
        
        NSString *strCourseName = [dictCourseMapData.fields objectForKey:@"Name"];
        NSString *strCourseImgUrl = [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"ImageUrl"]];
        
        [lblName setText:strCourseName];
        
        NSString *strCity= [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"City"]];
        NSString *strState= [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"State"]];
        NSString *strZipCode= [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"ZipCode"]];
        
        NSString *str1 = [[AppDelegate sharedinstance] nullcheck:[dictCourseMapData.fields objectForKey:@"Address"]];
        str1 = [NSString stringWithFormat:@"%@, %@, %@ %@",str1,strCity,strState,strZipCode];
        [lblAddress setText:str1];
        
        [self drawRoute];
        
        if([strCourseImgUrl length]>0) {
            NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:strCourseImgUrl]];
            
            [imgviewLoc setImageWithURLRequest:request
                              placeholderImage:nil
                                       success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                           
                                           // do image resize here
                                           
                                           // then set image view
                                           
                                           imgviewLoc.image = image;
                                           [indicatorLocImage stopAnimating];
                                           [indicatorLocImage setHidden:YES];
                                           
                                           
                                       }
                                       failure:nil];
        }
        else {
            [indicatorLocImage stopAnimating];
            [indicatorLocImage setHidden:YES];
            
            [imgviewLoc setImage:[UIImage imageNamed:@"ic_thumbnail.png"]];
        }
        
    }
    
    return YES;
}


- (void)drawRoute
{
    
    if(singleLine) {
        singleLine.map = nil;
    }
    
    if([strFromScreen isEqualToString:kScreenCoursesMain]) {
        
        NSArray *arrCoord = [dictCourseMapData.fields objectForKey:@"coordinates"];
        strlat = [arrCoord objectAtIndex:1];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [arrCoord objectAtIndex:0];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Create a special variable to hold this coordinate info.
        CLLocationCoordinate2D placeCoord;
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        desplaceCoord = placeCoord;
        
        strlat = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlat];
        strlat = [[AppDelegate sharedinstance] nullcheck:strlat];
        
        strlong = [[AppDelegate sharedinstance] getStringObjfromKey:klocationlong];
        strlong = [[AppDelegate sharedinstance] nullcheck:strlong];
        
        //Set the lat and long.
        placeCoord.latitude=[strlat doubleValue];
        placeCoord.longitude=[strlong doubleValue];
        
        CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
        scrplaceCoord = myposition;
    }
    
    CLLocation *origin = [[CLLocation alloc] initWithLatitude:scrplaceCoord.latitude longitude:scrplaceCoord.longitude];
    
    CLLocation *destination =  [[CLLocation alloc] initWithLatitude:desplaceCoord.latitude longitude:desplaceCoord.longitude];
    
    NSString *originString = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString *destinationString = [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude];
    NSString *directionsAPI = @"https://maps.googleapis.com/maps/api/directions/json?";
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving&key=AIzaSyBGk3fDMZHoId5VQT-gvbMWYgZnaj8zyE0", directionsAPI, originString, destinationString];
    
    directionsUrlString=[directionsUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    
    [manager GET:directionsUrlString
      parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             //do stuff
             
             [[AppDelegate sharedinstance] hideLoader];
             NSDictionary *json = (NSDictionary * ) responseObject;
             
             NSArray *routesArray = [json objectForKey:@"routes"];
             
             if ([routesArray count] > 0)
             {
                 GMSPath *path1 =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
                 singleLine = [GMSPolyline polylineWithPath:path1];
                 singleLine.strokeWidth = 3;
                 singleLine.strokeColor = [UIColor colorWithRed:0.000 green:0.655 blue:0.247 alpha:1.00];
                 singleLine.map = mapView;
             }
             [self getUserProfileImage];
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //show error
             [self getUserProfileImage];
             [[AppDelegate sharedinstance] hideLoader];
             [[AppDelegate sharedinstance] displayMessage:@"Some error occured"];
         }];
    
}

//-----------------------------------------------------------------------

- (IBAction)action_Menu:(id)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    
    // when tapped, open in browser and pass url of direction from current location to selected marker.
    //Current Location to Latitude and Longitude
    
    //    [[UIApplication sharedApplication] ]
    //        https://www.google.com/maps?saddr=My+Location&daddr=43.12345,-76.12345
    
}


@end
