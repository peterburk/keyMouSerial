//
//  MyDocument.h
//  CGEventPostingExample
//
//  Created by Jake Petroules on 6/22/11.
//

#import <Cocoa/Cocoa.h>
#import "ORSSerialPortDemoController.h"
#import "ORSSerialPortManager.h"

@interface MyDocument : NSDocument {
@private
    id capsLockEventMonitor;
    id mouseMovementEventMonitor;
    id monitorLeftMouseDown;
    id monitorRightMouseDown;
    bool wasCapsLockDown;
    ORSSerialPort *arduino;
    CGPoint lastMouseLocation;
}

-(void)beginEventMonitoring;
-(void)endEventMonitoring;

-(void)simulateMouseEvent:(CGEventType)eventType;

@end
