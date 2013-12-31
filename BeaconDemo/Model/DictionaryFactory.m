//
//  DictionaryFactory.m
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "DictionaryFactory.h"

@implementation DictionaryFactory

+ (NSDictionary *)dictionaryFromBeacons:(NSUInteger)beaconResolution
                              toTargets:(NSUInteger)targetResolution
{
    CGFloat zoneFraction = 1.0 / beaconResolution;
    CGFloat zoneSize = zoneFraction * targetResolution;
    CGFloat halfZoneSize = zoneSize * 0.5;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:beaconResolution];
    
    for(NSUInteger i = 1; i <= beaconResolution; i++)
    {
        NSInteger target = lroundf((zoneSize * i) - halfZoneSize);
        [dict setObject:[NSNumber numberWithInteger:target] forKey:[NSNumber numberWithInteger:i]];
    }
    
    return dict;
}

+ (NSDictionary *)dictionaryFromIdentifiersToTargetPointsX:(NSDictionary *)beaconsToTargetsX
                                                         Y:(NSDictionary *)beaconsToTargetsY
{        
    NSDictionary *dict = [[NSDictionary alloc] init];
    dict = @{
             @"ID01" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@1] intValue],
                    [[beaconsToTargetsY objectForKey:@1] intValue])],
             
             @"ID02" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@1] intValue],
                    [[beaconsToTargetsY objectForKey:@2] intValue])],
             
             @"ID03" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@1] intValue],
                    [[beaconsToTargetsY objectForKey:@3] intValue])],
             
             @"ID04" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@1] intValue],
                    [[beaconsToTargetsY objectForKey:@4] intValue])],
             
             @"ID05" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@2] intValue],
                    [[beaconsToTargetsY objectForKey:@1] intValue])],
             
             @"ID06" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@2] intValue],
                    [[beaconsToTargetsY objectForKey:@2] intValue])],
             
             @"ID07" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@2] intValue],
                    [[beaconsToTargetsY objectForKey:@3] intValue])],
             
             @"ID08" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@2] intValue],
                    [[beaconsToTargetsY objectForKey:@4] intValue])],
             
             @"ID09" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@3] intValue],
                    [[beaconsToTargetsY objectForKey:@1] intValue])],
             
             @"ID10" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@3] intValue],
                    [[beaconsToTargetsY objectForKey:@2] intValue])],
             
             @"ID11" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@3] intValue],
                    [[beaconsToTargetsY objectForKey:@3] intValue])],
             
             @"ID12" : [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconsToTargetsX objectForKey:@3] intValue],
                    [[beaconsToTargetsY objectForKey:@4] intValue])]
         };
    return dict;
}
@end
