//
//  BeaconLayoutManager.m
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "BeaconLayoutManager.h"
#import "DictionaryFactory.h"
#import <CoreLocation/CoreLocation.h>

@interface BeaconLayoutManager ()

@property (nonatomic) NSUInteger beaconResolutionX;
@property (nonatomic) NSUInteger beaconResolutionY;
@property (nonatomic) NSUInteger targetResolutionX;
@property (nonatomic) NSUInteger targetResolutionY;
@property (strong, nonatomic) NSDictionary *beaconPointsToTargetPointsX;
@property (strong, nonatomic) NSDictionary *beaconPointsToTargetPointsY;
@property (strong, nonatomic) NSDictionary *identifiersToBeaconPoints;

//Temporary for testing without beacons
@property (nonatomic) NSInteger dictionaryIndex;

@end

@implementation BeaconLayoutManager

- (void)setNearestBeacon:(CLBeacon *)nearestBeacon
{
    self.hasNearestBeaconChanged = ![nearestBeacon isEqual: self.nearestBeacon];
    _nearestBeacon = nearestBeacon;
}

- (NSDictionary *)identifiersToBeaconPoints
{
    if (!_identifiersToBeaconPoints) {
        _identifiersToBeaconPoints = [DictionaryFactory dictionaryFromIdentifiersToTargetPointsX:self.beaconPointsToTargetPointsX
                                                                                               Y:self.beaconPointsToTargetPointsY];
    }
    return _identifiersToBeaconPoints;
}

- (NSDictionary *)beaconPointsToTargetPointsX
{
    if (!_beaconPointsToTargetPointsX) {
        _beaconPointsToTargetPointsX = [DictionaryFactory dictionaryFromBeacons:self.beaconResolutionX
                                                                      toTargets:self.targetResolutionX];
    }
    return _beaconPointsToTargetPointsX;
}

- (NSDictionary *)beaconPointsToTargetPointsY
{
    if (!_beaconPointsToTargetPointsY) {
        _beaconPointsToTargetPointsY = [DictionaryFactory dictionaryFromBeacons:self.beaconResolutionY
                                                                     toTargets:self.targetResolutionY];
    }
    return _beaconPointsToTargetPointsY;
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
    NSValue *pointValue = [self.identifiersToBeaconPoints objectForKey:identifier];
    return [pointValue CGPointValue];
}

- (NSString *)identifierOfNearestBeacon
{
    //Temporary for testing without beacons
    self.dictionaryIndex++;
    if(self.dictionaryIndex >= self.identifiersToBeaconPoints.count)
    {
        self.dictionaryIndex = 0;
    }
    return [[self.identifiersToBeaconPoints allKeys] objectAtIndex: self.dictionaryIndex];
    
    //Real implementation
    /*return [NSString stringWithFormat: @"%@%@%@",
     self.nearestBeacon.proximityUUID.UUIDString,
     self.nearestBeacon.major,
     self.nearestBeacon.minor];*/
}

@end