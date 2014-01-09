//
//  WishListViewController.m
//  BeaconDemo
//
//  Created by dteng on 12/24/13.
//  Copyright (c) 2013 dteng. All rights reserved.
//

#import "OptInViewController.h"

@interface OptInViewController ()
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITextView *text;
@property (weak, nonatomic) IBOutlet UIView *background;

@end

@implementation OptInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.background.backgroundColor = [self colorWithHexString:@"efeff4"];
    
    self.label.font = [UIFont fontWithName:@"OpenSans-ExtraBold" size:25];
     self.label.textColor = [self colorWithHexString:@"2c3e50"];
     self.label.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
     self.label.textAlignment = NSTextAlignmentCenter;
    
    self.text.font = [UIFont fontWithName:@"OpenSans-Light" size:15];
     self.text.textColor = [self colorWithHexString:@"2c3e50"];
     self.text.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
     self.text.textAlignment = NSTextAlignmentCenter;

}

- (void) viewDidAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
