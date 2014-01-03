//
//  DictionaryFactory.h
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DictionaryFactory : NSObject
+ (NSDictionary *)dictionaryFrom1DBeaconPositions:(NSUInteger)beaconResolution
                                toScreenPositions:(NSUInteger)screenSize
                              offsetByPointerSize:(NSUInteger)pointerSize;
+ (NSDictionary *)dictionaryFromIdentifiersToScreenPointsX:(NSDictionary *)beaconPositionsToScreenPositionsX
                                                         Y:(NSDictionary *)beaconPositionsToScreenPositionsY;
@end
