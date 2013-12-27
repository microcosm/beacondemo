//
//  MapViewController.m
//  BeaconDemo
//
//  Created by dteng on 12/23/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "MapViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface MapViewController () <CLLocationManagerDelegate>

    @property (nonatomic) CLBeaconRegion *beaconRegion;
    @property (nonatomic) CLLocationManager *locationManager;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBeaconTracking];
}

- (void)setupBeaconTracking {
	self.locationManager = [[CLLocationManager alloc] init];
	self.locationManager.delegate = self;
	
	NSUUID *uuid = [[NSUUID alloc] initWithUUIDString: @"B9407F30-F5F8-466E-AFF9-25556B57FE6D"];
	self.beaconRegion = [[CLBeaconRegion alloc] initWithProximityUUID: uuid identifier: @"thoughtWorksNRF"];
    [self.locationManager startMonitoringForRegion: self.beaconRegion];
    [self.locationManager startRangingBeaconsInRegion: self.beaconRegion];
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region {
    
    NSMutableArray *distances = [[NSMutableArray alloc] initWithCapacity:3];
    NSMutableArray *identifiers = [[NSMutableArray alloc] initWithCapacity:3];
    NSString *identifier = [[NSString alloc] init];
    CLBeacon *beacon = [beacons objectAtIndex:0];
    
    identifier = [NSString stringWithFormat: @"%@%@%@", beacon.proximityUUID.UUIDString, beacon.major, beacon.minor];
    [UpdateMap identifier]
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
