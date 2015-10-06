//
//  MyDocument.m
//  CGEventPostingExample
//
//  Created by Jake Petroules on 6/22/11.
//

#import "MyDocument.h"
#import <Carbon/Carbon.h>
#import "ORSSerialPortDemoController.h"
#import "ORSSerialPortManager.h"
#import <AppKit/NSEvent.h>
#import <ApplicationServices/ApplicationServices.h>

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
        [self beginEventMonitoring];
        
    }
    return self;
}

// Begin listening for caps lock key presses and mouse movements
- (void)beginEventMonitoring
{
    // Determines whether the caps lock key was initially down before we started listening for events
    wasCapsLockDown = CGEventSourceKeyState(kCGEventSourceStateHIDSystemState, kVK_CapsLock);

    capsLockEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSFlagsChangedMask) handler: ^(NSEvent *event)
    {
        // Determines whether the caps lock key was pressed and posts a mouse down or mouse up event depending on its state
        bool isCapsLockDown = [event modifierFlags] & NSAlphaShiftKeyMask;
        if (isCapsLockDown && !wasCapsLockDown)
        {
            [self simulateMouseEvent: kCGEventLeftMouseDown];
            wasCapsLockDown = true;
        }
        else if (wasCapsLockDown)
        {
            [self simulateMouseEvent: kCGEventLeftMouseUp];
            wasCapsLockDown = false;
        }
    }];

    mouseMovementEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSLeftMouseDownMask | NSRightMouseDownMask | NSMouseMovedMask) handler:^(NSEvent *event)
    {
        switch (event.type)
        {
            case NSLeftMouseDown: NSLog(@"Left mouse clicked");
                break ;
        }
        
        [self simulateMouseEvent: kCGEventLeftMouseDragged];
    }];
    
    monitorLeftMouseDown = [NSEvent addGlobalMonitorForEventsMatchingMask:(kCGEventLeftMouseDown) handler:^(NSEvent *evt) {
        NSLog(@"Left mouse down");
        //self.leftMouseCounter = [NSNumber numberWithInt:(1 + [self.leftMouseCounter intValue])];
    }];

    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        [self globalMouseDown:event];
    }];

    
    arduino = [ORSSerialPort serialPortWithPath:@"/dev/cu.usbserial-FT3MGFU8B"];
    
    arduino.baudRate = @(9600); //sets baud rate
    
    [arduino open]; //opens port

}


- (void)globalMouseDown:(NSEvent *)event {
    
    
    NSLog(@"mouse down");
    
}


// Cease listening for caps lock key presses and mouse movements
- (void)endEventMonitoring
{
    if (capsLockEventMonitor)
    {
        [NSEvent removeMonitor: capsLockEventMonitor];
        capsLockEventMonitor = nil;
    }

    if (mouseMovementEventMonitor)
    {
        [NSEvent removeMonitor: mouseMovementEventMonitor];
        mouseMovementEventMonitor = nil;
    }
    
    [arduino close]; //closes port

}

-(void)simulateMouseEvent:(CGEventType)eventType
{
    // Get the current mouse position
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    //NSLog(@"mouse moved to %f, %f", mouseLocation.x, mouseLocation.y);

    double trackingSpeed = 1;
    
    double xMoved = (lastMouseLocation.x - mouseLocation.x) * trackingSpeed;
    double yMoved = (lastMouseLocation.y - mouseLocation.y) * trackingSpeed;
    
    int characterOffset = 64;
    
    int xMovedInt = (int)xMoved + characterOffset;
    int yMovedInt = (int)yMoved + characterOffset;
    
    
    NSLog(@"mouse moved by %d, %d", xMovedInt, yMovedInt);
    
    NSString *thisCharacter = @"x";
    NSData *outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data

    thisCharacter = [NSString stringWithFormat:@"%c", xMovedInt];
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    thisCharacter = @"y";
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    thisCharacter = [NSString stringWithFormat:@"%c", yMovedInt];
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    
    if (eventType == kCGEventLeftMouseDown)
    {
        thisCharacter = @"l";
        outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
        [arduino sendData:outgoingdata]; //sends data
        
        NSLog(@"mouse clicked");
        
    }
    
    thisCharacter = @"\n";
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data

    
    // Create and post the event
    CGEventRef event = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), eventType, mouseLocation, kCGMouseButtonLeft);
    
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
    
    lastMouseLocation = mouseLocation;

}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError {
    /*
     Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError {
    /*
    Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    */
    if (outError) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}



BOOL checkAccessibility()
{
    // 10.9 and later
    const void * keys[] = { kAXTrustedCheckOptionPrompt };
    const void * values[] = { kCFBooleanTrue };
    
    CFDictionaryRef options = CFDictionaryCreate(
                                                 kCFAllocatorDefault,
                                                 keys,
                                                 values,
                                                 sizeof(keys) / sizeof(*keys),
                                                 &kCFCopyStringDictionaryKeyCallBacks,
                                                 &kCFTypeDictionaryValueCallBacks);
    
    return AXIsProcessTrustedWithOptions(options);
    
    
    //NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    //return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}


@end
