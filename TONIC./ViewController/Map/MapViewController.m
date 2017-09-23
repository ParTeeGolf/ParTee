//
//  WelcomeViewController.m
//  Alarm
//
//  Copyright (c) 2015 WLc. All rights reserved.
//

#import "MapViewController.h"
#import "PurchaseSpecialsViewController.h"

#define kLimit @"100"

#define kScreenCoursesMain @"1"
#define kScreenCoursesSub @"2"
#define kScreenCoursesDetail @"3"
#define kScreenCoursesMy @"4"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize dictCourseMapData;
@synthesize strFromScreen;
@synthesize arrCourseData;
@synthesize status;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [indicatorLocImage setHidden:YES];
    path = [GMSMutablePath path];
    
    arrData = [[NSMutableArray alloc] init];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [[AppDelegate sharedinstance] showLoader];
    
    mapView.myLocationEnabled = NO;
    mapView.delegate = self;
    mapView.settings.myLocationButton = NO;
    
    [indicatorLocImage startAnimating];
    [indicatorLocImage setHidden:NO];
    
    if([strFromScreen isEqualToString:kScreenCoursesMain]) {
        
        [self gotLocationFromMain];
    }
    else {
        
        [self gotLocation];
    }
}

-(void) gotLocationFromMain {
    int n=arrCourseData.count;
    
    if([arrCourseData count]>50) {
        n=50;
    }
    
    for(int i=0;i<n;i++) {
        
        dictCourseMapData = [arrCourseData objectAtIndex:i];
        
        NSArray *arrCoord = [dictCourseMapData.fields objectForKey:@"coordinates"];
        
        if([arrCoord count]>0) {
            NSString *strPinType =[[AppDelegate sharedinstance] nullcheck: [dictCourseMapData.fields objectForKey:@"pin_type"]];
            
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
            
            CLLocationCoordinate2D myposition = {  placeCoord.latitude, placeCoord.longitude };
            scrplaceCoord = myposition;
            
            GMSMarker *mymarker = [GMSMarker markerWithPosition:myposition];
            
            mymarker.icon = [UIImage imageNamed:@"type-my"];
            
            mymarker.title = @"";//[NSString stringWithFormat:@"Marker %i", i];
            mymarker.appearAnimation = YES;
            mymarker.flat = YES;
            mymarker.snippet =  [NSString stringWithFormat:@"%i", 0];
            mymarker.map = mapView;
            
            [path addCoordinate: mymarker.position];
            
        }
    }
    
    if([arrCourseData count]>0) {
        dictCourseMapData = [arrCourseData objectAtIndex:0];
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
        [mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds]];
         [self gotLocation];
    }

}

-(void) gotLocation {
    
    NSArray *arrCoord = [dictCourseMapData.fields objectForKey:@"coordinates"];

    if([arrCoord count]>0) {
        NSString *strPinType =[[AppDelegate sharedinstance] nullcheck: [dictCourseMapData.fields objectForKey:@"pin_type"]];
        
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

        GMSMarker *mymarker = [GMSMarker markerWithPosition:myposition];
        
        mymarker.icon = [UIImage imageNamed:@"type-my"];
        
        mymarker.title = @"";//[NSString stringWithFormat:@"Marker %i", i];
        mymarker.appearAnimation = YES;
        mymarker.flat = YES;
        mymarker.snippet =  [NSString stringWithFormat:@"%i", 0];
        mymarker.map = mapView;
        
        [path addCoordinate: mymarker.position];
        
        
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
    
//    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:scrplaceCoord.latitude
//                                                            longitude:scrplaceCoord.longitude
//                                                                 zoom:mapView.camera.zoom];
//    [mapView animateToCameraPosition:camera];
    
}

- (BOOL) mapView: (GMSMapView *)mapView1 didTapMarker:(GMSMarker *)marker
{
    
    if([strFromScreen isEqualToString:kScreenCoursesMain]) {
        NSString *strIdx = marker.snippet;
        
        dictCourseMapData= [arrCourseData objectAtIndex:[strIdx integerValue]];
        
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
    NSString *directionsUrlString = [NSString stringWithFormat:@"%@&origin=%@&destination=%@&mode=driving", directionsAPI, originString, destinationString];
    
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
             
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             //show error
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
