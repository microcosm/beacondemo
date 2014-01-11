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

@property (nonatomic) CGSize beaconResolution;
@property (nonatomic) CGSize screenSize;
@property (nonatomic) CGSize pointerSize;
@property (strong, nonatomic) NSDictionary *beaconPositionXToScreenPositionX;
@property (strong, nonatomic) NSDictionary *beaconPositionYToScreenPositionY;
@property (strong, nonatomic) NSDictionary *identifiersToScreenPoints;
@property (strong, nonatomic) NSDictionary *adjacencyList;

//Temporary for testing without beacons
@property (nonatomic) NSInteger dictionaryIndex;

@end

@implementation BeaconLayoutManager

- (void)setNearestBeacon:(CLBeacon *)nearestBeacon
{
    if (![nearestBeacon isEqual: self.nearestBeacon])
    {
        self.hasNearestBeaconChanged = TRUE;
        _nearestBeacon = nearestBeacon;
    }
}

static const int OFFSET_X = 65;

- (NSDictionary *)identifiersToScreenPoints
{
    if (!_identifiersToScreenPoints) {
        _identifiersToScreenPoints = [[NSDictionary alloc] init];
        _identifiersToScreenPoints = @{
                                       //Top left
                                       @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:53626:34111":
                                           [ NSValue valueWithCGPoint: CGPointMake(OFFSET_X + 50, 50)],
                                       //Top right
                                       @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:53626:34111":
                                           [ NSValue valueWithCGPoint: CGPointMake(OFFSET_X + 150, 50)],
                                       //Bottom left
                                       @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:53626:34111":
                                           [ NSValue valueWithCGPoint: CGPointMake(OFFSET_X + 50, 350)],
                                       //Bottom right
                                       @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:53626:34111":
                                           [ NSValue valueWithCGPoint: CGPointMake(OFFSET_X + 150, 350)]
                                       };
    }
    return _identifiersToScreenPoints;
}

- (instancetype)initWithBeaconResolution:(CGSize)beaconResolution
                              screenSize:(CGSize)screenSize
                             pointerSize:(CGSize)pointerSize
{
    self = [super init];
    self.beaconResolution = beaconResolution;
    self.screenSize = screenSize;
    self.pointerSize = pointerSize;
    return self;
}

- (CGPoint)pointerPosition
{
    NSString *identifier = self.identifierOfNearestBeacon;
    NSValue *pointValue = [self.identifiersToScreenPoints objectForKey:identifier];
    return [pointValue CGPointValue];
}

- (NSString *)beaconIdentifier:(CLBeacon *)beacon
{
    return [NSString stringWithFormat: @"%@:%@:%@",
    beacon.proximityUUID.UUIDString,
    beacon.major,
    beacon.minor];
}

- (NSString *)identifierOfNearestBeacon
{
    //Temporary for testing without beacons
    /* self.dictionaryIndex++;
    if(self.dictionaryIndex >= self.identifiersToScreenPoints.count)
    {
        self.dictionaryIndex = 0;
    }
    return [[self.identifiersToScreenPoints allKeys] objectAtIndex: self.dictionaryIndex];*/
    
    //Real implementation
    return [NSString stringWithFormat: @"%@:%@:%@",
     self.nearestBeacon.proximityUUID.UUIDString,
     self.nearestBeacon.major,
     self.nearestBeacon.minor];
}

@end