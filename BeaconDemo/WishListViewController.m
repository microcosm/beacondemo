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

}

- (void) viewDidDisappear:(BOOL)animated {

}

- (void) viewDidAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
