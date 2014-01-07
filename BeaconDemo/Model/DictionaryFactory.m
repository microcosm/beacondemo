//
//  DictionaryFactory.m
//  BeaconDemo
//
//  Created by Andy on 12/30/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "DictionaryFactory.h"

@implementation DictionaryFactory

+ (NSDictionary *)dictionaryFrom1DBeaconPositions:(NSUInteger)beaconResolution
                                toScreenPositions:(NSUInteger)screenSize
                              offsetByPointerSize:(NSUInteger)pointerSize
{
    CGFloat zoneFraction = 1.0 / beaconResolution;
    CGFloat zoneSize = zoneFraction * screenSize;
    CGFloat halfZoneSize = zoneSize * 0.5;
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:beaconResolution];
    
    for(NSUInteger i = 1; i <= beaconResolution; i++)
    {
        NSInteger screenPosition = lroundf((zoneSize * i) - halfZoneSize) - (pointerSize * 0.5);
        [dict setObject:[NSNumber numberWithInteger:screenPosition] forKey:[NSNumber numberWithInteger:i]];
    }
    
    return dict;
}

+ (NSDictionary *)dictionaryFromIdentifiersToScreenPointsX:(NSDictionary *)beaconPositionsToScreenPositionsX
                                                         Y:(NSDictionary *)beaconPositionsToScreenPositionsY
{        
    NSDictionary *dict = [[NSDictionary alloc] init];
    dict = @{
             //Blues
             /*@"B9407F30-F5F8-466E-AFF9-25556B57FE6D:53626:34111":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@1] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@1] intValue])],*/
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:36507:50355":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@1] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@2] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:59628:33950":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@1] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@3] intValue])],
             
             /*@"B9407F30-F5F8-466E-AFF9-25556B57FE6D:59820:47378":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@1] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@4] intValue])],*/
             //Greens
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:32002:57685":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@2] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@1] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:2178:60491":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@2] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@2] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:8157:58201":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@2] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@3] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:43188:62110":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@2] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@4] intValue])],
             //Purples
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:61612:59156":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@3] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@1] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:55284:5223":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@3] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@2] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:13272:41609":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@3] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@3] intValue])],
             
             @"B9407F30-F5F8-466E-AFF9-25556B57FE6D:25061:32695":
                    [ NSValue valueWithCGPoint: CGPointMake(
                    [[beaconPositionsToScreenPositionsX objectForKey:@3] intValue],
                    [[beaconPositionsToScreenPositionsY objectForKey:@4] intValue])]
         };
    return dict;
}
@end
