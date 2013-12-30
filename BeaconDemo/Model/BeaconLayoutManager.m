//
//  BeaconLayoutManager.m
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "BeaconLayoutManager.h"
#import <CoreLocation/CoreLocation.h>

@interface BeaconLayoutManager ()

@property (nonatomic) NSUInteger beaconResolutionX;
@property (nonatomic) NSUInteger beaconResolutionY;
@property (nonatomic) NSUInteger targetResolutionX;
@property (nonatomic) NSUInteger targetResolutionY;
@property (strong, nonatomic) NSDictionary *beaconPointsByIdentifier;

//Temporary for testing without beacons
@property (nonatomic) NSInteger dictionaryIndex;

@end

@implementation BeaconLayoutManager

- (void)setNearestBeacon:(CLBeacon *)nearestBeacon
{
    self.hasNearestBeaconChanged = ![nearestBeacon isEqual: self.nearestBeacon];
    _nearestBeacon = nearestBeacon;
}

- (NSDictionary *)beaconPointsByIdentifier
{
    if (!_beaconPointsByIdentifier) {
        _beaconPointsByIdentifier = [[NSDictionary alloc] init];
        _beaconPointsByIdentifier = @{
                                      @"ID01" : [ NSValue valueWithCGPoint: CGPointMake(10,150) ],
                                      @"ID02" : [ NSValue valueWithCGPoint: CGPointMake(20,150) ],
                                      @"ID03" : [ NSValue valueWithCGPoint: CGPointMake(30,150) ],
                                      @"ID04" : [ NSValue valueWithCGPoint: CGPointMake(40,150) ],
                                      @"ID05" : [ NSValue valueWithCGPoint: CGPointMake(50,150) ],
                                      @"ID06" : [ NSValue valueWithCGPoint: CGPointMake(60,150) ],
                                      @"ID07" : [ NSValue valueWithCGPoint: CGPointMake(70,150) ],
                                      @"ID08" : [ NSValue valueWithCGPoint: CGPointMake(80,150) ],
                                      @"ID09" : [ NSValue valueWithCGPoint: CGPointMake(90,150) ],
                                      @"ID10" : [ NSValue valueWithCGPoint: CGPointMake(100,150) ],
                                      @"ID11" : [ NSValue valueWithCGPoint: CGPointMake(110,150) ],
                                      @"ID12" : [ NSValue valueWithCGPoint: CGPointMake(120,150) ]
                                      };
    }
    return _beaconPointsByIdentifier;
}

- (instancetype)initWithBeaconResolutionX:(NSUInteger)beaconX
                        beaconResolutionY:(NSUInteger)beaconY
                        targetResolutionX:(NSUInteger)targetX
                        targetResolutionY:(NSUInteger)targetY
{
    self = [super init];
    self.beaconResolutionX = beaconX;
    self.beaconResolutionY = beaconY;
    self.targetResolutionX = targetX;
    self.targetResolutionY = targetY;
    return self;
}

- (CGPoint)targetPoint
{
    NSString *identifier = self.identifierOfNearestBeacon;
    NSValue *pointValue = [self.beaconPointsByIdentifier objectForKey: identifier];
    return[pointValue CGPointValue];
}

- (NSString *)identifierOfNearestBeacon
{
    //Temporary for testing without beacons
    self.dictionaryIndex++;
    if(self.dictionaryIndex >= self.beaconPointsByIdentifier.count)
    {
        self.dictionaryIndex = 0;
    }
    return [[self.beaconPointsByIdentifier allKeys] objectAtIndex: self.dictionaryIndex];
    
    //Real implementation
    /*return [NSString stringWithFormat: @"%@%@%@",
     self.nearestBeacon.proximityUUID.UUIDString,
     self.nearestBeacon.major,
     self.nearestBeacon.minor];*/
}

@end