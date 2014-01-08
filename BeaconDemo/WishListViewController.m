//
//  WishListViewController.m
//  BeaconDemo
//
//  Created by dteng on 12/24/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "WishListViewController.h"

@interface WishListViewController ()

@end

@implementation WishListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:10];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = futureDate;
    localNotification.alertBody = @"Welcome to the ThoughtWorks Boots Store!";
    localNotification.alertAction = @"enter the experience!";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
    

}

//- (void) viewDidAppear:(BOOL)animated {
//    [self.navigationItem setHidesBackButton:YES animated:NO];
//}
//
//- (void) viewWillAppear:(BOOL)animated {
//    [self.navigationItem setHidesBackButton:YES animated:NO];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
