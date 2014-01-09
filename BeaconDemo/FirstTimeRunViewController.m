//
//  FirstTimeRunViewController.m
//  nrfbeacondemo
//
//  Created by dteng on 1/7/14.
//  Copyright (c) 2014 dteng. All rights reserved.
//

#import "FirstTimeRunViewController.h"

@interface FirstTimeRunViewController ()

@end

@implementation FirstTimeRunViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults objectForKey:@"isAdmin"] != nil) {
        int isAdmin = [defaults integerForKey:@"isAdmin"];
        
        if (isAdmin == 1){
            [self performSegueWithIdentifier:@"isSalesAssociateSegue" sender:self];
        } else if (isAdmin == 2) {
            [self performSegueWithIdentifier:@"isCustomerSegue" sender:self];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)setAsSalesAssociate:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:1 forKey:@"isAdmin"];

    [defaults synchronize];

}

- (IBAction)setAsCustomer:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:2 forKey:@"isAdmin"];

    [defaults synchronize];

}

@end
