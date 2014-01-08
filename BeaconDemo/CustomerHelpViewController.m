#import "CustomerHelpViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TransferService.h"

@interface CustomerHelpViewController () <CBPeripheralManagerDelegate, UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UITextView       *textView;
@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic   *notifyCharacteristic;
@property (strong, nonatomic) NSData                    *dataToSend;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) IBOutlet UILabel *testLabel;

@property (nonatomic) BOOL buttonPressed;

@property (strong, nonatomic) IBOutlet UIButton *redBoot;
@property (strong, nonatomic) IBOutlet UIButton *blackBoot;
@property (strong, nonatomic) IBOutlet UIButton *greenBoot;

@end

#define NOTIFY_MTU      20

@implementation CustomerHelpViewController

#pragma mark - View Lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureButtons];
    
    // Start up the CBPeripheralManager

    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    }
    
}

- (void) configureButtons{
    self.redBoot.tag = 1;
    self.blackBoot.tag = 2;
    self.greenBoot.tag = 3;
    
    [self.redBoot addTarget:self
                     action:@selector(buttonDidChange:)
           forControlEvents:UIControlEventTouchUpInside];
    
    [self.blackBoot addTarget:self
                       action:@selector(buttonDidChange:)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.greenBoot addTarget:self
                       action:@selector(buttonDidChange:)
             forControlEvents:UIControlEventTouchUpInside];
    
    _buttonPressed = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.

    //[self.peripheralManager stopAdvertising];
    
    [super viewWillDisappear:animated];
}



#pragma mark - Peripheral Methods

/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    // We're in CBPeripheralManagerStatePoweredOn state...
    NSLog(@"self.peripheralManager powered on.");
    
    // ... so build our service.
    
    // Start with the CBMutableCharacteristic
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    
    self.notifyCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC_UUID]
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsWriteable];
    
    // Then the service
    CBMutableService *transferService = [[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]
                                                                       primary:YES];
    
    // Add the characteristic to the service
    transferService.characteristics = @[self.transferCharacteristic, self.notifyCharacteristic];
    
    // And add it to the peripheral manager
    [self.peripheralManager addService:transferService];
}


/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
        
    // Get the data
    self.dataToSend = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
    
    // Reset the index
    self.sendDataIndex = 0;
    
    // Start sending
    [self sendData];
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");
}


/** Sends the next amount of data to the connected central
 */
- (void)sendData
{
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: EOM");
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        
        // No data left.  Do nothing
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes+self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
            return;
        }
        
        NSString *stringFromData = [[NSString alloc] initWithData:chunk encoding:NSUTF8StringEncoding];
        NSLog(@"Sent: %@", stringFromData);
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[@"EOM" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Sent: EOM");
            }
            
            return;
        }
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests {
    NSLog(@"HELLO");
    self.testLabel.text = @"S U C C E S S";
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    // Start sending again
    [self sendData];
}


#pragma mark - Switch Methods



/** Start advertising
 */
- (IBAction)buttonDidChange:(id)sender {
    
    
    if (self.buttonPressed == NO) {
        NSString *color;
        
        if ([sender tag] == 1){
            color = @"Red";
        }
        
        if ([sender tag] == 2){
            color = @"Black";
        }
        
        if ([sender tag] == 3){
            color = @"Green";
        }
        
        self.textView.text = [NSString stringWithFormat:@"The customer needs help or is requesting the %@ Boots", color];
        
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]] }];
    } else {
        //[self.peripheralManager stopAdvertising];
    }

}

@end
