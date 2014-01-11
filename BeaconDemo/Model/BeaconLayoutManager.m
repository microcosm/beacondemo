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
@property (strong, nonatomic) NSDictionary *adjacencyList;

//Temporary for testing without beacons
@property (nonatomic) NSInteger dictionaryIndex;

@end

@implementation BeaconLayoutManager

- (void)setNearestBeacon:(CLBeacon *)nearestBeacon
{
//    if (!self.adjacencyList) {
//        self.adjacencyList = [DictionaryFactory dictionaryAdjacency];
//    }
    
    NSString *primaryIdentifier = [self beaconIdentifier:self.nearestBeacon];
    NSString *beacon2Identifier = [self beaconIdentifier:[self.beacons objectAtIndex:1]];
    NSString *beacon3Identifier = [self beaconIdentifier:[self.beacons objectAtIndex:2]];
//    NSArray *adjaceny = [self.adjacencyList objectForKey:primaryIdentifier];
//    NSLog(@"%@",adjaceny);
    //self.hasNearestBeaconChanged = ![nearestBeacon isEqual: self.nearestBeacon];
    NSLog(@"Primary: %@",primaryIdentifier);
    NSLog(@"2nd: %@",beacon2Identifier);
    NSLog(@"3rd: %@",beacon3Identifier);
    
    if (![nearestBeacon isEqual: self.nearestBeacon])
    {
//        if(!([adjaceny containsObject: beacon2Identifier.description] && [adjaceny containsObject:beacon3Identifier.description]))
//        {
//            self.hasNearestBeaconChanged = TRUE;
//            _nearestBeacon = nearestBeacon;
//            NSLog(@"Adjacent points changed, creating move.");
//        }
//        else{
//            NSLog(@"Determined false move, ignoring.");
//        }
//        
//    }
//    else{
//        NSLog(@"Did not move.");
        self.hasNearestBeaconChanged = TRUE;
        _nearestBeacon = nearestBeacon;
    }
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

- (CGPoint)weightedPointerPosition
{
    CLBeacon *beacon1 = [self.beacons objectAtIndex:0];
    NSString *p1identifier = [self beaconIdentifier:beacon1];
    NSValue *p1Value = [self.identifiersToScreenPoints objectForKey:p1identifier];
    CGPoint p1 = [p1Value CGPointValue];
    CGFloat p1Strength = beacon1.accuracy;
    
    
    CLBeacon *beacon2 = [self.beacons objectAtIndex:1];
    NSString *p2identifier = [self beaconIdentifier:beacon2];
    NSValue *p2Value = [self.identifiersToScreenPoints objectForKey:p2identifier];
    CGPoint p2 = [p2Value CGPointValue];
    CGFloat p2Strength = beacon2.accuracy;
    
    
    CLBeacon *beacon3 = [self.beacons objectAtIndex:2];
    NSString *p3identifier = [self beaconIdentifier:beacon3];
    NSValue *p3Value = [self.identifiersToScreenPoints objectForKey:p3identifier];
    CGPoint p3 = [p1Value CGPointValue];
    CGFloat p3Strength = beacon3.accuracy;
    
    return p1;
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
    self.dictionaryIndex++;
    if(self.dictionaryIndex >= self.identifiersToScreenPoints.count)
    {
        self.dictionaryIndex = 0;
    }
    return [[self.identifiersToScreenPoints allKeys] objectAtIndex: self.dictionaryIndex];
    
    //Real implementation
//    return [NSString stringWithFormat: @"%@:%@:%@",
//     self.nearestBeacon.proximityUUID.UUIDString,
//     self.nearestBeacon.major,
//     self.nearestBeacon.minor];
}

@end