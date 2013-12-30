//
//  MapViewController.m
//  BeaconDemo
//
//  Created by dteng on 12/23/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "MapViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <CLLocationManagerDelegate>

    @property (nonatomic) CLBeaconRegion *beaconRegion;
    @property (nonatomic) CLLocationManager *locationManager;
    @property (strong, nonatomic) CLBeacon *nearestBeacon;
    @property (strong, nonatomic) NSDictionary *beaconPointsByIdentifier;
    @property (weak, nonatomic) IBOutlet UIImageView *user;

    //Temporary for testing without beacons
    @property (nonatomic) NSInteger dictionaryIndex;
    @property (strong, nonatomic) NSTimer *timer;

@end

@implementation MapViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBeaconTracking];
    
    //Temporary for testing without beacons
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(userDidMove) userInfo:nil repeats:YES];
}

- (void)setupBeaconTracking
{
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
	self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: uuid identifier: @"thoughtWorksNRF"];
    [self.locationManager startMonitoringForRegion: self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion: self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    CLBeacon *newNearestBeacon = [beacons objectAtIndex:0];
    if(![newNearestBeacon isEqual: self.nearestBeacon]){
        [self setNearestBeacon: newNearestBeacon];
        [self userDidMove];
    }
}

- (void)userDidMove
{
    CGPoint newPoint = [self pointForBeaconIdentifier: [self identifierOfNearestBeacon]];
    NSLog([NSString stringWithFormat: @"User moved to [%f, %f]", newPoint.x, newPoint.y]);
    [self.user setCenter: newPoint];
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

- (CGPoint)pointForBeaconIdentifier:(NSString *)identifier
{
    NSValue *pointValue = [self.beaconPointsByIdentifier objectForKey: identifier];
    return[pointValue CGPointValue];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
