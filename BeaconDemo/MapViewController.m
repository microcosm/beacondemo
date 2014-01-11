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
static const int MAP_OFFSET_X = 65;
static const CGFloat MOVE_TIME = 0.3;
static const CGFloat FADE_TIME = 0.3;

@interface MapViewController () <CLLocationManagerDelegate>

    @property (strong, nonatomic) BeaconLayoutManager *beaconManager;
    @property (nonatomic) CLBeaconRegion *beaconRegion;
    @property (nonatomic) CLLocationManager *locationManager;
    @property (weak, nonatomic) IBOutlet UIImageView *map;
    @property (weak, nonatomic) IBOutlet UIImageView *boots;
    @property (strong, nonatomic) UIImageView *user;
    @property (nonatomic) CGPoint userPosition;
    @property (nonatomic) BOOL userIsDetected;
    @property (nonatomic) CGSize mapSizeScaled;

    //Temporary for testing without beacons
    @property (strong, nonatomic) NSTimer *timer;

@end

@implementation MapViewController

- (BeaconLayoutManager *)beaconManager
{
    if (!_beaconManager) {
        _beaconManager = [[BeaconLayoutManager alloc] initWithBeaconResolution: CGSizeMake(BEACON_RES_X, BEACON_RES_Y)
                                                                    screenSize: self.mapSizeScaled
                                                                   pointerSize: self.user.bounds.size];
    }
    return _beaconManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupViews];
    [self setupBeaconTracking];
    
    //\[self setModalPresentationStyle:UIModalPresentationCurrentContext];
    
    //Temporary for testing without beacons
    /*self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                  target:self
                                                selector:@selector(userDidEnterZone)
                                                userInfo:nil
                                                 repeats:YES];*/
}

- (void)setupViews
{
    self.user = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user"]];
    [self.user setAlpha:0];
    [self.map addSubview:self.user];
    [self.map addSubview:self.boots];
    self.mapSizeScaled = CGSizeMake(self.map.bounds.size.width - 160, self.map.bounds.size.height);
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
    
    [self checkIfNearestBeaconIsAlert:self.beaconManager.nearestBeacon];
    
    self.beaconManager.beacons = beacons;
    
    if(self.beaconManager.hasNearestBeaconChanged){
        [self userDidEnterZone];
    }
}

- (void)checkIfNearestBeaconIsAlert:(CLBeacon *)beacon {
    if ([[self.beaconManager beaconIdentifier:beacon] isEqualToString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D:61612:59156"]) {

           // [self performSegueWithIdentifier:@"toProductDetails" sender:self];
 
    }
}

- (void)userDidEnterZone
{
    CGFloat xSize = self.mapSizeScaled.width/2.0;
    CGFloat ySize = self.mapSizeScaled.height/3.0;
    CGPoint oldPosition = self.userPosition;
    self.userPosition = [self.beaconManager pointerPosition];
    CGFloat xMove = self.userPosition.x - oldPosition.x;
    CGFloat yMove = self.userPosition.y - oldPosition.y;
    CGFloat newX = self.userPosition.x;
    CGFloat newY = self.userPosition.y;
    
    if(fabs(xMove) > xSize)
    {
        if(xMove >= 0)
        {
            newX = oldPosition.x + xSize;
        }
        else
        {
            newX = oldPosition.x - xSize;
        }
    }
    if(fabs(yMove) > ySize)
    {
        if(yMove >= 0)
        {
            newY = oldPosition.y + ySize;
        }
        else
        {
            newY = oldPosition.y - ySize;
        }
    }

    self.userPosition = CGPointMake(newX + MAP_OFFSET_X, newY);
    
    if(self.userIsDetected)
    {
        [self transformUserToMatchPositionInMoveTime:MOVE_TIME];
    }
    else
    {
        self.userIsDetected = YES;
        [self transformUserToMatchPositionInMoveTime:0];
        [self fadeUserToAlpha:1.0 inFadeTime:FADE_TIME];
    }
}

- (void)transformUserToMatchPositionInMoveTime:(CGFloat)moveTime
{
    [UIView animateWithDuration:moveTime
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         CGAffineTransform transform = CGAffineTransformTranslate(CGAffineTransformIdentity, self.userPosition.x, self.userPosition.y);
                         transform = CGAffineTransformRotate(transform, [self radiansToFaceUserTowardsBoots]);
                         [self.user setTransform:transform];
                     }
                     completion:^(BOOL finished){}];
}

- (void)fadeUserToAlpha:(CGFloat)alpha inFadeTime:(CGFloat)fadeTime
{
    [UIView animateWithDuration:fadeTime
                          delay:0
                        options:(UIViewAnimationOptionCurveEaseOut |
                                 UIViewAnimationOptionBeginFromCurrentState)
                     animations:^{
                         [self.user setAlpha:alpha];
                     }
                     completion:^(BOOL finished){}];
}

- (CGFloat)radiansToFaceUserTowardsBoots
{
    CGFloat distanceX = self.boots.center.x - self.userPosition.x - (self.user.image.size.width * 0.5);
    CGFloat distanceY = self.boots.center.y - self.userPosition.y - (self.user.image.size.height * 0.5);
    return atan2(distanceY, distanceX); //tan = opp / adj
}

@end