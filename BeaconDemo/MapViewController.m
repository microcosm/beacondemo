//
//  MapViewController.m
//  BeaconDemo
//
//  Created by dteng on 12/23/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "MapViewController.h"
#import "Model/BeaconLayoutManager.h"
#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

static const int BEACON_RES_X = 3;
static const int BEACON_RES_Y = 4;

@interface MapViewController () <CLLocationManagerDelegate>

    @property (strong, nonatomic) BeaconLayoutManager *beaconManager;

    @property (nonatomic) CLBeaconRegion *beaconRegion;
    @property (nonatomic) CLLocationManager *locationManager;
    @property (weak, nonatomic) IBOutlet UIImageView *user;
    @property (weak, nonatomic) IBOutlet UIImageView *map;

    //Temporary for testing without beacons
    @property (strong, nonatomic) NSTimer *timer;

@end

@implementation MapViewController

- (BeaconLayoutManager *)beaconManager
{
    if (!_beaconManager) {
        _beaconManager = [[BeaconLayoutManager alloc] initWithBeaconResolutionX: BEACON_RES_X
                                                              beaconResolutionY: BEACON_RES_Y
                                                              targetResolutionX: self.map.bounds.size.width
                                                              targetResolutionY: self.map.bounds.size.height];
    }
    return _beaconManager;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBeaconTracking];
    
    //Temporary for testing without beacons
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                  target:self
                                                selector:@selector(userDidMove)
                                                userInfo:nil
                                                 repeats:YES];
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

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray *)beacons
               inRegion:(CLBeaconRegion *)region
{
    self.beaconManager.nearestBeacon = [beacons objectAtIndex:0];
    if(self.beaconManager.hasNearestBeaconChanged){
        [self userDidMove];
    }
}

- (void)userDidMove
{
    CGPoint newPoint = self.beaconManager.targetPoint;
    NSLog([NSString stringWithFormat: @"User moved to [%f, %f]", newPoint.x, newPoint.y]);
    [self.user setCenter:newPoint];
}

@end
