//
//  OBSlider.h
//
//  Created by Ole Begemann on 02.01.11.
//  Copyright 2011 Ole Begemann. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface OBSlider : UISlider{
    float scrubbingSpeed;
    float realPositionValue;

    NSArray *scrubbingSpeeds;
    NSArray *scrubbingSpeedChangePositions;

    CGPoint beganTrackingLocation;
}

@property (assign, readonly) float scrubbingSpeed;
@property (retain) NSArray *scrubbingSpeeds;
@property (retain) NSArray *scrubbingSpeedChangePositions;
@property (assign) float progress;
@end
