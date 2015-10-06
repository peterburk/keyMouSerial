//
//  KMSAppDelegate.m: Code for the keyboard & mouse tracker
//
//  KeyMouSerial
//  Peter Burkimsher, 2015-06-25
//  peterburk@gmail.com
//

#import "KMSAppDelegate.h"
#import <Carbon/Carbon.h>
#import "ORSSerialPortDemoController.h"
#import "ORSSerialPortManager.h"
#import <AppKit/NSEvent.h>
#import <ApplicationServices/ApplicationServices.h>

// Capture mouse movement events
@interface KMSAppDelegate()
- (void)globalMouseMoved:(NSEvent *)event;
- (void)globalMouseDown:(NSEvent *)event;
@end

@implementation KMSAppDelegate

// Create the window
@synthesize window = _window;

// We don't need to initialise anything yet, it's all in applicationDidFinishLaunching
+ (void)initialize {
    //NSLog(@"initialize");
}

// Close the port when quitting
- (void)dealloc
{
    // Close port - this is too slow
    //[arduino close];
}

/*
 * applicationDidFinishLaunching: When the application opens, start tracking the mouse and keyboard
 */
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

    // Mouse movement
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSMouseMovedMask handler:^(NSEvent *event) {
        [self globalMouseMoved:event]; 
    }];
    
    // Mouse left click global
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^(NSEvent *event) {
        [self globalMouseDown:event]; 
    }];

    // Mouse left click local
    [NSEvent addLocalMonitorForEventsMatchingMask:NSLeftMouseDownMask handler:^NSEvent* (NSEvent* event){
        [self globalMouseDown:event];
        return event;
    }];

    
    // Mouse right click global
    [NSEvent addGlobalMonitorForEventsMatchingMask:NSRightMouseDownMask handler:^(NSEvent *event) {
        [self globalRightMouseDown:event];
    }];
    
    // Mouse right click local
    [NSEvent addLocalMonitorForEventsMatchingMask:NSRightMouseDownMask handler:^NSEvent* (NSEvent* event){
        [self globalRightMouseDown:event];
        return event;
    }];

    
    // Keystroke local
    [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent* (NSEvent* event)
    {
        // Filter out characters here if necessary
        //NSString *keyPressed = event.charactersIgnoringModifiers;
        
        // Capture the key code
        unsigned short thisKeyCode = [event keyCode];
        
        // Convert the key code to a string to pass to the serial port
        NSString *keyPressed = [self keyCodeConversion:thisKeyCode];
        
        // Send a "k" first to tell the Arduino to expect a keystroke
        NSString *thisCharacter = @"k";
        
        // Send the "k" character
        NSData *outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
        [arduino sendData:outgoingdata];
        
        // Send the actual key character
        outgoingdata = [keyPressed dataUsingEncoding:NSASCIIStringEncoding];
        [arduino sendData:outgoingdata]; //sends data
        
        return event;
    }];

    // Find the serial port
    //_serialPortManager = [ORSSerialPortManager sharedSerialPortManager];
    self.serialPortManager = [ORSSerialPortManager sharedSerialPortManager];

    //availablePorts = serialPortManager.availablePorts;
    
    //NSLog(@"serialPorts: %@", availablePorts);
    
    
    // Connect to the serial port
    //arduino = [ORSSerialPort serialPortWithPath:@"/dev/cu.usbserial-FT3MGFU8B"];
    arduino = [ORSSerialPort serialPortWithPath:@"/dev/cu.usbserial"];
    
    // Set baud rate
    arduino.baudRate = @(9600);
    
    // Open port
    [arduino open];
    
} // end applicationDidFinishLaunching

/*
 * serialPortSelected: When a new serial port is selected on the list, reconnect to the new port.
 */

- (IBAction)serialPortSelected:(id)sender
{
    // Close the current port
    [arduino close];
    
    // Read the new port name
    NSString *portName = self.serialPortManager.availablePorts[[_serialPortPopup indexOfSelectedItem]];
    
    // Log the port name
    //NSLog(@"portName: %@", portName);
    
    portName = [NSString stringWithFormat:@"/dev/cu.%@", portName];
    
    // Set the new serial port
    arduino = [ORSSerialPort serialPortWithPath:portName];

    // Open port
    [arduino open];
} // end serialPortSelected



/*
 * globalMouseMoved: When the mouse moves, compare the new position to the old one and tell the serial port. 
 * @param (NSEvent*) event: The mouse movement event
 */
- (void)globalMouseMoved:(NSEvent *)event
{
    // Get the current mouse position
    CGEventRef ourEvent = CGEventCreate(NULL);
    CGPoint mouseLocation = CGEventGetLocation(ourEvent);
    
    //NSLog(@"mouse moved to %f, %f", mouseLocation.x, mouseLocation.y);
    
    // Tweak this to speed up the mouse movement via serial
    double trackingSpeed = 1;
    
    // Calculate the distance the mouse has moved
    double xMoved = (lastMouseLocation.x - mouseLocation.x) * trackingSpeed;
    double yMoved = (lastMouseLocation.y - mouseLocation.y) * trackingSpeed;
    
    // Shift the characters into an unusual range for typing.
    int characterOffset = 64;
    
    // Calculate the character code to send
    int xMovedInt = (int)xMoved + characterOffset;
    int yMovedInt = (int)yMoved + characterOffset;
    
    // Send these characters to move the mouse by x and y
    NSString* xCharacter = [NSString stringWithFormat:@"%c", xMovedInt];
    NSString* yCharacter = [NSString stringWithFormat:@"%c", yMovedInt];
    
    // Log the location.
    // NSLog(@"mouse moved by %d %@ %d %@", xMovedInt, xCharacter, yMovedInt, yCharacter);
    
    // Send an "x" to tell the mouse to move horizontally
    NSString *thisCharacter = @"x";
    NSData *outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    // Send the "x" value to move left or right
    outgoingdata = [xCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    // Send a "y" to tell the mouse to move verticaly.
    thisCharacter = @"y";
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    // Send the y value to move up or down
    outgoingdata = [yCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    // Send a "?" character as a terminator.
    thisCharacter = @"?";
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata]; //sends data
    
    // Update the tracking variable.
    lastMouseLocation = mouseLocation;
    
} // end globalMouseMoved

/*
 * globalMouseDown: When the left mouse button is clicked, tell the serial port.
 * @param (NSEvent*) event: The mouse click event
 */
- (void)globalMouseDown:(NSEvent *)event
{
    // Log the event
    //NSLog(@"mouse down");
    
    // Send a "b" character before a mouse button event
    NSString *thisCharacter = @"b";
    NSData *outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata];
    
    // Send the "l" character to say that it's a left click
    thisCharacter = @"l";
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata];
    
} // end globalMouseDown

/*
 * globalMouseDown: When the right mouse button is clicked, tell the serial port.
 * @param (NSEvent*) event: The mouse click event
 */
- (void)globalRightMouseDown:(NSEvent *)event
{
    //NSLog(@"mouse down");
    
    // Send a "b" character before a mouse button event
    NSString *thisCharacter = @"b";
    NSData *outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata];
    
    // Send the "r" character to say that it's a right click
    thisCharacter = @"r";
    outgoingdata = [thisCharacter dataUsingEncoding:NSASCIIStringEncoding];
    [arduino sendData:outgoingdata];
    
} // end globalRightMouseDown

/*
 * keyCodeConversion: Convert key code events to strings. This needs the Carbon library, to my surprise.
 * @param (unsigned short) keyCode: The mouse click event
 */
- (NSString*)keyCodeConversion:(unsigned short)keyCode
{
    // Convert keyCode to string (no simple method around this)
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
} // end keyCodeConversion




/*
 * checkAccessibility: Allows the app to use accessibility features in Mac OS 10.9 and above.
 * @return BOOL True if the app is trusted, false if not.
 */

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
} // end checkAccessibility


@end
