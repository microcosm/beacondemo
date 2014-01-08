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
@property (strong, nonatomic) NSArray *beacons;
@property (nonatomic) BOOL hasNearestBeaconChanged;

- (instancetype)initWithBeaconResolution:(CGSize)beaconResolution
                              screenSize:(CGSize)screenSize
                             pointerSize:(CGSize)pointerSize;
- (CGPoint)pointerPosition;

- (NSString *)beaconIdentifier:(CLBeacon *)beacon;

@end
