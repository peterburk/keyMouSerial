//
//  ORSSerialPortDemoController.m
//  ORSSerialPortDemo
//
//  Created by Andrew R. Madsen on 6/27/12.
//	Copyright (c) 2012-2014 Andrew R. Madsen (andrew@openreelsoftware.com)
//
//	Permission is hereby granted, free of charge, to any person obtaining a
//	copy of this software and associated documentation files (the
//	"Software"), to deal in the Software without restriction, including
//	without limitation the rights to use, copy, modify, merge, publish,
//	distribute, sublicense, and/or sell copies of the Software, and to
//	permit persons to whom the Software is furnished to do so, subject to
//	the following conditions:
//
//	The above copyright notice and this permission notice shall be included
//	in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//	MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//	IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//	CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//	SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "ORSSerialPortDemoController.h"
#import "ORSSerialPortManager.h"
#import <AppKit/NSEvent.h>
#import <ApplicationServices/ApplicationServices.h>
#import <Carbon/Carbon.h>

@implementation ORSSerialPortDemoController

- (instancetype)init
{
    self = [super init];
    if (self)
	{
        self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
		self.availableBaudRates = @[@300, @1200, @2400, @4800, @9600, @14400, @19200, @28800, @38400, @57600, @115200, @230400];
		
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(serialPortsWereConnected:) name:ORSSerialPortsWereConnectedNotification object:nil];
		[nc addObserver:self selector:@selector(serialPortsWereDisconnected:) name:ORSSerialPortsWereDisconnectedNotification object:nil];

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
#endif
        
        
        [self beginEventMonitoring];

        
    }
    
    
    
    return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Actions

- (IBAction)send:(id)sender
{
	NSData *dataToSend = [self.sendTextField.stringValue dataUsingEncoding:NSUTF8StringEncoding];
	[self.serialPort sendData:dataToSend];
}

- (IBAction)openOrClosePort:(id)sender
{
	self.serialPort.isOpen ? [self.serialPort close] : [self.serialPort open];
}

#pragma mark - ORSSerialPortDelegate Methods

- (void)serialPortWasOpened:(ORSSerialPort *)serialPort
{
	self.openCloseButton.title = @"Close";
}

- (void)serialPortWasClosed:(ORSSerialPort *)serialPort
{
	self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
	NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if ([string length] == 0) return;
	[self.receivedDataTextView.textStorage.mutableString appendString:string];
	[self.receivedDataTextView setNeedsDisplay:YES];
}

- (void)serialPortWasRemovedFromSystem:(ORSSerialPort *)serialPort;
{
	// After a serial port is removed from the system, it is invalid and we must discard any references to it
	self.serialPort = nil;
	self.openCloseButton.title = @"Open";
}

- (void)serialPort:(ORSSerialPort *)serialPort didEncounterError:(NSError *)error
{
	NSLog(@"Serial port %@ encountered an error: %@", serialPort, error);
}

#pragma mark - NSUserNotificationCenterDelegate

#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification
{
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[center removeDeliveredNotification:notification];
	});
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
	return YES;
}

#endif

#pragma mark - Notifications

- (void)serialPortsWereConnected:(NSNotification *)notification
{
	NSArray *connectedPorts = [notification userInfo][ORSConnectedSerialPortsKey];
	NSLog(@"Ports were connected: %@", connectedPorts);
	[self postUserNotificationForConnectedPorts:connectedPorts];
}

- (void)serialPortsWereDisconnected:(NSNotification *)notification
{
	NSArray *disconnectedPorts = [notification userInfo][ORSDisconnectedSerialPortsKey];
	NSLog(@"Ports were disconnected: %@", disconnectedPorts);
	[self postUserNotificationForDisconnectedPorts:disconnectedPorts];
	
}

- (void)postUserNotificationForConnectedPorts:(NSArray *)connectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in connectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Connected", @"Serial Port Connected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was connected to your Mac.", @"Serial port connected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}

- (void)postUserNotificationForDisconnectedPorts:(NSArray *)disconnectedPorts
{
#if (MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_7)
	if (!NSClassFromString(@"NSUserNotificationCenter")) return;
	
	NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
	for (ORSSerialPort *port in disconnectedPorts)
	{
		NSUserNotification *userNote = [[NSUserNotification alloc] init];
		userNote.title = NSLocalizedString(@"Serial Port Disconnected", @"Serial Port Disconnected");
		NSString *informativeTextFormat = NSLocalizedString(@"Serial Port %@ was disconnected from your Mac.", @"Serial port disconnected user notification informative text");
		userNote.informativeText = [NSString stringWithFormat:informativeTextFormat, port.name];
		userNote.soundName = nil;
		[unc deliverNotification:userNote];
	}
#endif
}


#pragma mark - Properties

- (void)setSerialPort:(ORSSerialPort *)port
{
	if (port != _serialPort)
	{
		[_serialPort close];
		_serialPort.delegate = nil;
		
		_serialPort = port;
		
		_serialPort.delegate = self;
	}
}





- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.loggingEnabled = NO;
    
    //serialKeyboardPort = [ORSSerialPort serialPortWithPath:@"/dev/cu.usbserial"];
    
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

-(void)logMessageToLogView:(NSString*)message {
    
    //[logView setString: [[logView string] stringByAppendingFormat:@"%@: %@\n", [self.logDateFormatter stringFromDate:[NSDate date]],  message]];
    
    //[_receivedDataTextView setString: [[_receivedDataTextView string] stringByAppendingFormat:@"%@", message]];
    
    NSLog(@"%@", message);
    
}

- (IBAction)stopButtonPressed:(id)sender {
    if (!self.loggingEnabled) {
        return;
    }
    self.loggingEnabled = false;
    [NSEvent removeMonitor:monitorLeftMouseDown];
    [NSEvent removeMonitor:monitorRightMouseDown];
    [NSEvent removeMonitor:monitorKeyDown];
}

- (IBAction)startButtonPressed:(id)sender {
    
    if (checkAccessibility()) {
        NSLog(@"Accessibility Enabled");
    }
    else {
        NSLog(@"Accessibility Disabled");
    }
    
    if (self.loggingEnabled) {
        return;
    }
    self.loggingEnabled = true;
    monitorLeftMouseDown = [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *evt) {
        [self logMessageToLogView:[NSString stringWithFormat:@"Left mouse down!"]];
        //self.leftMouseCounter = [NSNumber numberWithInt:(1 + [self.leftMouseCounter intValue])];
    }];
    monitorRightMouseDown = [NSEvent addGlobalMonitorForEventsMatchingMask:NSRightMouseDownMask handler:^(NSEvent *evt) {
        [self logMessageToLogView:@"Right mouse down!"];
        //self.rightMouseCounter = [NSNumber numberWithInt:(1 + [self.rightMouseCounter intValue])];
    }];
    //monitorKeyDown = [NSEvent addGlobalMonitorForEventsMatchingMask:NSKeyDownMask handler:^(NSEvent *evt) {
    //    [self logMessageToLogView:[NSString stringWithFormat:@"Key down: %@ (key code %d)", [evt characters], [evt keyCode]]];
    //    self.keyPressCounter = [NSNumber numberWithInt:(1 + [self.keyPressCounter intValue])];
    //}];
    
    
    //monitorMouseMoved = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent *evt) {
    //    [self logMessageToLogView:@"Mouse moved!"];
        //self.rightMouseCounter = [NSNumber numberWithInt:(1 + [self.rightMouseCounter intValue])];
    //}];

    
    //monitorMouseMoved = [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMoved handler:^NSEvent* (NSEvent* event){
    //NSString *keyPressed = event.charactersIgnoringModifiers;
    //    unsigned short thisKeyCode = [event keyCode];
    
    //    NSString *keyPressed = [self keyCodeConversion:thisKeyCode];
    
    //    [self logMessageToLogView:[NSString stringWithFormat:@"%@", keyPressed]];
    //self.keyPressCounter = [NSNumber numberWithInt:(1 + [self.keyPressCounter intValue])];
    
    //    NSData *dataToSend = [keyPressed dataUsingEncoding:NSUTF8StringEncoding];
    //    [self.serialPort sendData:dataToSend];
    
    //    [self logMessageToLogView:@"Mouse moved!"];
        
    //    return event;
    //}];
    
    //monitorKeyDown = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent* (NSEvent* event){
        //NSString *keyPressed = event.charactersIgnoringModifiers;
    //    unsigned short thisKeyCode = [event keyCode];
        
    //    NSString *keyPressed = [self keyCodeConversion:thisKeyCode];
        
    //    [self logMessageToLogView:[NSString stringWithFormat:@"%@", keyPressed]];
        //self.keyPressCounter = [NSNumber numberWithInt:(1 + [self.keyPressCounter intValue])];
        
    //    NSData *dataToSend = [keyPressed dataUsingEncoding:NSUTF8StringEncoding];
    //    [self.serialPort sendData:dataToSend];
        
    //    return event;
    //}];
    
    
    
}

- (void) startEventTap {
    //eventTap is an ivar on this class of type CFMachPortRef
    monitorMouseMoved = (__bridge id)(CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionListenOnly, kCGEventMaskForAllEvents, myCGEventCallback, NULL));
    CGEventTapEnable((__bridge CFMachPortRef)(monitorMouseMoved), true);
}

CGEventRef myCGEventCallback(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon) {
    if (type == kCGEventMouseMoved) {
        NSLog(@"%@", NSStringFromPoint([NSEvent mouseLocation]));
    }
    
    return event;
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
    
    mouseMovementEventMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSMouseMovedMask) handler:^(NSEvent *event)
                                 {
                                     NSLog(@"mouse moved");
                                     
                                     [self simulateMouseEvent: kCGEventLeftMouseDragged];
                                 }];
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
}

-(void)simulateMouseEvent:(CGEventType)eventType
{
    // Get the current mouse position
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    // Create and post the event
    CGEventRef event = CGEventCreateMouseEvent(CGEventSourceCreate(kCGEventSourceStateHIDSystemState), eventType, mouseLocation, kCGMouseButtonLeft);
    CGEventPost(kCGHIDEventTap, event);
    CFRelease(event);
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
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



- (NSString*)keyCodeConversion:(unsigned short)keyCode {
    
    //Convert keyCode to string (no simple method around this)
    switch (keyCode) {
        case kVK_ANSI_A:                return @"a"; break;
        case kVK_ANSI_S:                return @"s"; break;
        case kVK_ANSI_D:                return @"d"; break;
        case kVK_ANSI_F:                return @"f"; break;
        case kVK_ANSI_H:                return @"h"; break;
        case kVK_ANSI_G:                return @"g"; break;
        case kVK_ANSI_Z:                return @"z"; break;
        case kVK_ANSI_X:                return @"x"; break;
        case kVK_ANSI_C:                return @"c"; break;
        case kVK_ANSI_V:                return @"v"; break;
        case kVK_ANSI_B:                return @"b"; break;
        case kVK_ANSI_Q:                return @"q"; break;
        case kVK_ANSI_W:                return @"w"; break;
        case kVK_ANSI_E:                return @"e"; break;
        case kVK_ANSI_R:                return @"r"; break;
        case kVK_ANSI_T:                return @"t"; break;
        case kVK_ANSI_Y:                return @"y"; break;
        case kVK_ANSI_1:                return @"1"; break;
        case kVK_ANSI_2:                return @"2"; break;
        case kVK_ANSI_3:                return @"3"; break;
        case kVK_ANSI_4:                return @"4"; break;
        case kVK_ANSI_6:                return @"6"; break;
        case kVK_ANSI_5:                return @"5"; break;
        case kVK_ANSI_Equal:            return @"="; break;
        case kVK_ANSI_9:                return @"9"; break;
        case kVK_ANSI_7:                return @"7"; break;
        case kVK_ANSI_Minus:            return @"-"; break;
        case kVK_ANSI_8:                return @"8"; break;
        case kVK_ANSI_0:                return @"0"; break;
        case kVK_ANSI_RightBracket:     return @"]"; break;
        case kVK_ANSI_O:                return @"o"; break;
        case kVK_ANSI_U:                return @"u"; break;
        case kVK_ANSI_LeftBracket:      return @"["; break;
        case kVK_ANSI_I:                return @"i"; break;
        case kVK_ANSI_P:                return @"p"; break;
        case kVK_ANSI_L:                return @"l"; break;
        case kVK_ANSI_J:                return @"j"; break;
        case kVK_ANSI_Quote:            return @"'"; break;
        case kVK_ANSI_K:                return @"k"; break;
        case kVK_ANSI_Semicolon:        return @"a"; break;
        case kVK_ANSI_Backslash:        return @"\\"; break;
        case kVK_ANSI_Comma:            return @","; break;
        case kVK_ANSI_Slash:            return @"/"; break;
        case kVK_ANSI_N:                return @"n"; break;
        case kVK_ANSI_M:                return @"m"; break;
        case kVK_ANSI_Period:           return @"."; break;
        case kVK_ANSI_Grave:            return @"`"; break;
        case kVK_ANSI_KeypadDecimal:    return @"."; break;
        case kVK_ANSI_KeypadMultiply:   return @"*"; break;
        case kVK_ANSI_KeypadPlus:       return @"+"; break;
        case kVK_ANSI_KeypadClear:      return @"<Clear>"; break;
        case kVK_ANSI_KeypadDivide:     return @"/"; break;
        case kVK_ANSI_KeypadEnter:      return @"<Enter>"; break;
        case kVK_ANSI_KeypadMinus:      return @"-"; break;
        case kVK_ANSI_KeypadEquals:     return @"="; break;
        case kVK_ANSI_Keypad0:          return @"0"; break;
        case kVK_ANSI_Keypad1:          return @"1"; break;
        case kVK_ANSI_Keypad2:          return @"2"; break;
        case kVK_ANSI_Keypad3:          return @"3"; break;
        case kVK_ANSI_Keypad4:          return @"4"; break;
        case kVK_ANSI_Keypad5:          return @"5"; break;
        case kVK_ANSI_Keypad6:          return @"6"; break;
        case kVK_ANSI_Keypad7:          return @"7"; break;
        case kVK_ANSI_Keypad8:          return @"8"; break;
        case kVK_ANSI_Keypad9:          return @"9"; break;
            
        case kVK_Return:                return @"\n"; break;
        case kVK_Tab:                   return @"   "; break;
        case kVK_Space:                 return @" "; break;
        case kVK_Delete:                return @"\x8"; break;
        case kVK_Escape:                return @"Escape"; break;
        case kVK_F1:                    return @"F1"; break;
        case kVK_F2:                    return @"F2"; break;
        case kVK_F3:                    return @"F3"; break;
        case kVK_F4:                    return @"F4"; break;
        case kVK_F5:                    return @"F5"; break;
        case kVK_F6:                    return @"F6"; break;
        case kVK_F7:                    return @"F7"; break;
        case kVK_F8:                    return @"F8"; break;
        case kVK_F9:                    return @"F9"; break;
        case kVK_F10:                   return @"F10"; break;
        case kVK_F11:                   return @"F11"; break;
        case kVK_F12:                   return @"F12"; break;
        case kVK_F13:                   return @"F13"; break;
        case kVK_F14:                   return @"F14"; break;
        case kVK_F15:                   return @"F15"; break;
        case kVK_F16:                   return @"F16"; break;
        case kVK_F17:                   return @"F17"; break;
        case kVK_F18:                   return @"F18"; break;
        case kVK_F19:                   return @"F19"; break;
        case kVK_F20:                   return @"F20"; break;
        case kVK_ForwardDelete:         return @"<Delete>"; break;
        case kVK_LeftArrow:             return @"<Left Arrow>"; break;
        case kVK_RightArrow:            return @"<Right Arrow>"; break;
        case kVK_DownArrow:             return @"<Down Arrow>"; break;
        case kVK_UpArrow:               return @"<Up Arrow>"; break;
            
        default:
            return @"<Unknown>";
            break;
    }
}

@end
