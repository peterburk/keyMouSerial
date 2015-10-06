//
//  KMSAppDelegate.h: Headers for the keyboard & mouse tracker
//
//  KeyMouSerial
//  Peter Burkimsher, 2015-06-25
//  peterburk@gmail.com
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPortDemoController.h"
#import "ORSSerialPortManager.h"

@interface KMSAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDataSource, NSTableViewDelegate> {

    // We only have 2 variables; the serial port for sending the data out, and the last mouse location
    @private
        ORSSerialPort *arduino;
        CGPoint lastMouseLocation;
    }

- (IBAction)serialPortSelected:(id)sender;

    // The front window
    @property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *serialPortPopup;
@property (nonatomic, strong) ORSSerialPortManager *serialPortManager;

@end
