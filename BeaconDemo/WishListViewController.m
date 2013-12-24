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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDate *futureDate = [NSDate dateWithTimeIntervalSinceNow:10];
    
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = futureDate;
    localNotification.alertBody = @"There are Timberland Boots in your area!";
    localNotification.alertAction = @"Show me the item";
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadData" object:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
