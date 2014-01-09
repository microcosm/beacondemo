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
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
        _peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:@{CBPeripheralManagerOptionRestoreIdentifierKey: @"myPeripheralManager"}];
    }
    
}

-(void)peripheralManager:(CBPeripheralManager *)peripheral willRestoreState:(NSDictionary *)dict {
    
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
    [self.peripheralManager stopAdvertising];
    
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


- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    [self sendData];
}


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
        
        self.textView.text = [NSString stringWithFormat:@"COLORED BOOTS: %@ ", color];
        
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
        [self.peripheralManager startAdvertising:@{ CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]}];
    } else {
        [self.peripheralManager stopAdvertising];
    }

}

@end
