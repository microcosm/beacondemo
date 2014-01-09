//
//  LastViewController.m
//  nrfbeacondemo
//
//  Created by dteng on 1/9/14.
//  Copyright (c) 2014 dteng. All rights reserved.
//

#import "LastViewController.h"

@interface LastViewController ()

@end

@implementation LastViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (IBAction)nextExperience:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
