//
//  BeaconLayoutManager.h
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BeaconLayoutManager : NSObject

@property (strong, nonatomic) CLBeacon *nearestBeacon;
@property (nonatomic) BOOL hasNearestBeaconChanged;

- (instancetype)initWithBeaconResolutionX:(NSUInteger)beaconX
                        beaconResolutionY:(NSUInteger)beaconY
                        targetResolutionX:(NSUInteger)targetX
                        targetResolutionY:(NSUInteger)targetY;
- (CGPoint)targetPoint;

@end
