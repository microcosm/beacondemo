#import "SalesAssociateHelpViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>

#import "TransferService.h"

@interface SalesAssociateHelpViewController () <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral          *savedPeripheral;
@property (strong, nonatomic) NSMutableData         *data;
@property (strong, nonatomic) IBOutlet UITextView *textview;
@property (strong, nonatomic) IBOutlet UIView *background;
@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *bodyTextView;
@property (strong, nonatomic) IBOutlet UIImageView *bootSelected;

@end

@implementation SalesAssociateHelpViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.background.backgroundColor = [self colorWithHexString:@"efeff4"];
    
    self.titleLabel.font = [UIFont fontWithName:@"OpenSans-ExtraBold" size:25];
    self.titleLabel.textColor = [self colorWithHexString:@"2c3e50"];
    self.titleLabel.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.bodyTextView.font = [UIFont fontWithName:@"OpenSans-Light" size:15];
    self.bodyTextView.textColor = [self colorWithHexString:@"2c3e50"];
    self.bodyTextView.backgroundColor = [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
    self.bodyTextView.textAlignment = NSTextAlignmentCenter;
    
    
    UIDevice *currentDevice = [UIDevice currentDevice];
    if ([currentDevice.model rangeOfString:@"Simulator"].location == NSNotFound) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    
    _data = [[NSMutableData alloc] init];
}

- (void) viewDidAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    [super viewWillDisappear:animated];
}

#pragma mark - Central Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        return;
    }
    
    [self scan];
}

- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"Scanning started");
}

- (void)setImageOfBootForString:(NSString *)stringOfImage {
    if ([stringOfImage isEqualToString: @"black"]) {
        self.bootSelected.image = [UIImage imageNamed:@"boots_rotated_gray.png"];
    } else if ([stringOfImage isEqualToString: @"maroon"]) {
        self.bootSelected.image = [UIImage imageNamed:@"boots_rotated_red.png"];
    } else if ([stringOfImage isEqualToString: @"yellow"]) {
        self.bootSelected.image = [UIImage imageNamed:@"boots_rotated_yellow.png"];
    }else if ([stringOfImage isEqualToString: @"green"]) {
        self.bootSelected.image = [UIImage imageNamed:@"boots_rotated_green.png"];
    }else if ([stringOfImage isEqualToString: @"cyan"]) {
        self.bootSelected.image = [UIImage imageNamed:@"boots_rotated_cyan.png"];
    }else if ([stringOfImage isEqualToString: @"white"]) {
        self.bootSelected.image = [UIImage imageNamed:@"boots_rotated_white.png"];
    }
}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    if (RSSI.integerValue > -15) {
        return;
    }
    
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    if (self.discoveredPeripheral != peripheral) {
        
        self.discoveredPeripheral = peripheral;
        self.savedPeripheral = peripheral;
        
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnNotificationKey : @YES}];
    }
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    self.textview.text = @"";
    [self cleanup];
}


- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    [self.centralManager stopScan];
    NSLog(@"Scanning stopped");
    
    [self.data setLength:0];
    peripheral.delegate = self;
    
    [peripheral discoverServices:@[[CBUUID UUIDWithString:TRANSFER_SERVICE_UUID]]];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID], [CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC_UUID]] forService:service];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
            
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    if ([stringFromData isEqualToString:@"EOM"]) {
        
        self.textview.text = [[NSString alloc] initWithData:self.data encoding:NSUTF8StringEncoding];
        
        [self setImageOfBootForString:self.textview.text];
        
        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
    
    [self.data appendData:characteristic.value];
    
    NSLog(@"Received: %@", stringFromData);
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
        return;
    }
    
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    else {
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    self.discoveredPeripheral = nil;
    
    [self scan];
}

- (void)cleanup
{
    if (self.discoveredPeripheral.state != CBPeripheralStateConnected) {
        return;
    }
    
    if (self.discoveredPeripheral.services != nil) {
        for (CBService *service in self.discoveredPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
                        if (characteristic.isNotifying) {
                            [self.discoveredPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                            
                            return;
                        }
                    }
                }
            }
        }
    }
    
    [self.centralManager cancelPeripheralConnection:self.discoveredPeripheral];
}

- (IBAction)sendCustomerNotificationToStartApp:(id)sender {
    if (self.savedPeripheral != nil) {
        for (CBService *service in self.savedPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:NOTIFY_CHARACTERISTIC_UUID]]) {
                        NSData *data = [@"notifyStartup" dataUsingEncoding:NSUTF8StringEncoding];
                        for (int x = 0; x < 3; x++) {
                            [self.savedPeripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
                        }
                    }
                }
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Hello");
}

- (IBAction)resetApplication:(id)sender {
    [self.textview setText:@""];
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
