#import "CustomerHelpViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface CustomerHelpViewController () <CBPeripheralManagerDelegate, UITextViewDelegate>


@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *notifyCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;

@property (nonatomic) BOOL buttonPressed;

@property (strong, nonatomic) IBOutlet UIImageView *currentBoot;

@property (strong, nonatomic) IBOutlet UITextView *textView;


@property (weak, nonatomic) IBOutlet UIView *background;

@property (weak, nonatomic) IBOutlet UIButton *color1;
@property (weak, nonatomic) IBOutlet UIButton *color2;
@property (weak, nonatomic) IBOutlet UIButton *color3;
@property (weak, nonatomic) IBOutlet UIButton *color4;
@property (weak, nonatomic) IBOutlet UIButton *color5;
@property (weak, nonatomic) IBOutlet UIButton *color6;
@property (strong, nonatomic) IBOutlet UIImageView *blackHighlighted;
@property (strong, nonatomic) IBOutlet UIImageView *maroonHighlighted;
@property (strong, nonatomic) IBOutlet UIImageView *whiteHighlighted;
@property (strong, nonatomic) IBOutlet UIImageView *cyanHighlighted;
@property (strong, nonatomic) IBOutlet UIImageView *greenHighlighted;
@property (strong, nonatomic) IBOutlet UIImageView *yellowHighlighted;

@property (strong, nonatomic) NSString* color;
@property (weak, nonatomic) IBOutlet UIButton *callAssistant;

@end

#define NOTIFY_MTU      20

@implementation CustomerHelpViewController

#pragma mark - View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureButtons];
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    
    self.background.backgroundColor = [self colorWithHexString:@"efeff4"];
    
    self.textView.text = [NSString stringWithFormat:@"-"];

    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    
}

- (void) configureButtons{
    self.color1.tag = 1;
    self.color2.tag = 2;
    self.color3.tag = 3;
    self.color4.tag = 4;
    self.color5.tag = 5;
    self.color6.tag = 6;
    
    self.maroonHighlighted.hidden = YES;
    self.blackHighlighted.hidden = YES;
    self.whiteHighlighted.hidden = YES;
    self.cyanHighlighted.hidden = YES;
    self.greenHighlighted.hidden = YES;
    self.yellowHighlighted.hidden = YES;
    
    [self.color1 addTarget:self
                    action:@selector(buttonDidChange:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.color2 addTarget:self
                    action:@selector(buttonDidChange:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.color3 addTarget:self
                    action:@selector(buttonDidChange:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.color4 addTarget:self
                    action:@selector(buttonDidChange:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.color5 addTarget:self
                    action:@selector(buttonDidChange:)
          forControlEvents:UIControlEventTouchUpInside];
    
    [self.color6 addTarget:self
                    action:@selector(buttonDidChange:)
          forControlEvents:UIControlEventTouchUpInside];
    
    _buttonPressed = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}


- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    NSLog(@"self.peripheralManager powered on.");
    
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    self.notifyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyWrite
                                                                          value:nil
                                                                  permissions:CBAttributePermissionsWriteable];
    
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    transferService.characteristics = @[self.transferCharacteristic, self.notifyCharacteristic];
    [self.peripheralManager addService:transferService];
}


- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
        
    self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    self.sendDataIndex = 0;
    
    [self sendData];
}



- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


- (void)sendData
{
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if (didSend) {
            
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        return;
    }
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        return;
    }
    
    
    BOOL didSend = YES;
    
    while (didSend) {
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        self.sendDataIndex += amountToSend;
        
        [self.peripheralManager stopAdvertising];

        if (self.sendDataIndex >= self.dataToSend.length) {
            
            sendingEOM = YES;
            
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                sendingEOM = NO;

                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    self.textView.text = @"";
    
    [self sendData];
}

- (IBAction)didCallAssistant:(id)sender {
    
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
    [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];

}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self sendData];
}

- (IBAction)buttonDidChange:(id)sender {
        if ([sender tag] == 1){
            self.color = @"dark gray";
            self.maroonHighlighted.hidden = YES;
            self.blackHighlighted.hidden = NO;
            self.whiteHighlighted.hidden = YES;
            self.cyanHighlighted.hidden = YES;
            self.greenHighlighted.hidden = YES;
            self.yellowHighlighted.hidden = YES;
            
            self.currentBoot.image = [UIImage imageNamed:@"boots_rotated_gray.png"];
        }
        
        if ([sender tag] == 2){
            self.color = @"maroon";
            
            self.maroonHighlighted.hidden = NO;
            self.blackHighlighted.hidden = YES;
            self.whiteHighlighted.hidden = YES;
            self.cyanHighlighted.hidden = YES;
            self.greenHighlighted.hidden = YES;
            self.yellowHighlighted.hidden = YES;
            
            self.currentBoot.image = [UIImage imageNamed:@"boots_rotated_red.png"];

        }
    
        if ([sender tag] == 3){
            self.color = @"white";
            
            self.maroonHighlighted.hidden = YES;
            self.blackHighlighted.hidden = YES;
            self.whiteHighlighted.hidden = NO;
            self.cyanHighlighted.hidden = YES;
            self.greenHighlighted.hidden = YES;
            self.yellowHighlighted.hidden = YES;
            
            self.currentBoot.image = [UIImage imageNamed:@"boots_rotated_white.png"];

        }
    
        if ([sender tag] == 4){
            self.color = @"cyan";
            
            self.maroonHighlighted.hidden = YES;
            self.blackHighlighted.hidden = YES;
            self.whiteHighlighted.hidden = YES;
            self.cyanHighlighted.hidden = NO;
            self.greenHighlighted.hidden = YES;
            self.yellowHighlighted.hidden = YES;
            
            self.currentBoot.image = [UIImage imageNamed:@"boots_rotated_cyan.png"];

        }
    
        if ([sender tag] == 5){
            self.color = @"green";
            
            self.maroonHighlighted.hidden = YES;
            self.blackHighlighted.hidden = YES;
            self.whiteHighlighted.hidden = YES;
            self.cyanHighlighted.hidden = YES;
            self.greenHighlighted.hidden = NO;
            self.yellowHighlighted.hidden = YES;
            
            self.currentBoot.image = [UIImage imageNamed:@"boots_rotated_green.png"];

        }
    
        if ([sender tag] == 6){
            self.color = @"yellow";
            
            self.maroonHighlighted.hidden = YES;
            self.blackHighlighted.hidden = YES;
            self.whiteHighlighted.hidden = YES;
            self.cyanHighlighted.hidden = YES;
            self.greenHighlighted.hidden = YES;
            self.yellowHighlighted.hidden = NO;
            
            self.currentBoot.image = [UIImage imageNamed:@"boots_rotated_yellow.png"];

        }
    
        self.textView.text = [NSString stringWithFormat:@"%@", self.color];
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
