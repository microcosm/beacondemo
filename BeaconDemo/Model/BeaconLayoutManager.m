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

@property (nonatomic) CGSize beaconResolution;
@property (nonatomic) CGSize screenSize;
@property (nonatomic) CGSize pointerSize;
@property (strong, nonatomic) NSDictionary *beaconPositionXToScreenPositionX;
@property (strong, nonatomic) NSDictionary *beaconPositionYToScreenPositionY;
@property (strong, nonatomic) NSDictionary *identifiersToScreenPoints;

//Temporary for testing without beacons
@property (nonatomic) NSInteger dictionaryIndex;

@end

@implementation BeaconLayoutManager

- (void)setNearestBeacon:(CLBeacon *)nearestBeacon
{
    self.hasNearestBeaconChanged = ![nearestBeacon isEqual: self.nearestBeacon];
    _nearestBeacon = nearestBeacon;
}

- (NSDictionary *)beaconPositionXToScreenPositionX
{
    if (!_beaconPositionXToScreenPositionX) {
        _beaconPositionXToScreenPositionX = [DictionaryFactory dictionaryFrom1DBeaconPositions:self.beaconResolution.width
                                                                             toScreenPositions:self.screenSize.width
                                                                           offsetByPointerSize:self.pointerSize.width];
    }
    return _beaconPositionXToScreenPositionX;
}

- (NSDictionary *)beaconPositionYToScreenPositionY
{
    if (!_beaconPositionYToScreenPositionY) {
        _beaconPositionYToScreenPositionY = [DictionaryFactory dictionaryFrom1DBeaconPositions:self.beaconResolution.height
                                                                             toScreenPositions:self.screenSize.height
                                                                           offsetByPointerSize:self.pointerSize.height];
    }
    return _beaconPositionYToScreenPositionY;
}

- (NSDictionary *)identifiersToScreenPoints
{
    if (!_identifiersToScreenPoints) {
        _identifiersToScreenPoints = [DictionaryFactory dictionaryFromIdentifiersToScreenPointsX:self.beaconPositionXToScreenPositionX
                                                                                               Y:self.beaconPositionYToScreenPositionY];
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

- (NSString *)identifierOfNearestBeacon
{
    //Temporary for testing without beacons
    self.dictionaryIndex++;
    if(self.dictionaryIndex >= self.identifiersToScreenPoints.count)
    {
        self.dictionaryIndex = 0;
    }
    return [[self.identifiersToScreenPoints allKeys] objectAtIndex: self.dictionaryIndex];
    
    //Real implementation
    /*return [NSString stringWithFormat: @"%@%@%@",
     self.nearestBeacon.proximityUUID.UUIDString,
     self.nearestBeacon.major,
     self.nearestBeacon.minor];*/
}

@end