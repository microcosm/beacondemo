//
//  DictionaryFactory.h
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryFactory : NSObject
+ (NSDictionary *)dictionaryFromBeacons:(NSUInteger)beaconResolution
                                     toTargets:(NSUInteger)targetResolution;
+ (NSDictionary *)dictionaryFromIdentifiersToTargetPointsX:(NSDictionary *)beaconsToTargetsX
                                                         Y:(NSDictionary *)beaconsToTargetsY;
@end
