# KeyMouSerial
Keyboard and Mouse over Serial

<img class="aligncenter" alt="KeyMouSerial Logo" src="https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Icon/KeyMouSerial.png" width="128">


KeyMouSerial is an app to copy keystrokes and mouse events to a serial line, allowing an Arduino to send those to a second computer over USB.

This is particularly useful for people who need to use the Raspberry Pi but don’t want to carry a USB keyboard everywhere.

*** If you are a developer, please help improve the current code, and port the serial-to-USB part from Arduino to Rockbox so I can use my iPod as a keyboard! ***

##Download
Arduino source
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Arduino/KeyMouSerialArduinoSource.zip
Mac app
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Mac/KeyMouSerialMac.zip
Mac source
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Mac/KeyMouSerialMacSource.zip
Windows app
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Windows/keyMouSerialWindows.zip
Windows source
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Windows/keyMouSerialWindowsSource.zip
Linux app (compiled for Raspberry Pi)
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Linux/keyMouSerialLinux.zip
Linux source
https://raw.githubusercontent.com/peterburk/keyMouSerial/master/Linux/keyMouSerialLinuxSource.zip

##Block diagram

##Usage
1. Install the Arduino sketch onto a 32U4-capable Arduino board (tested with Leonardo and Micro)
2. Connect the Arduino’s serial Tx and Rx lines to a USB-serial adapter (e.g. FTDI, Prolific, etc). Remember to connect the grounds as well! Do not connect the Vdd.
3. Plug in the USB-serial adapter to your source computer
4. Plug in the Arduino’s USB to your target computer
5. Run the KeyMouSerial app for your operating system on the source computer
6. Watch the keystrokes and mouse movements being copied to the target computer


##FAQ
1. Why not use a physical USB keyboard and mouse?
I travel a lot. I carry my laptop and my Raspberry Pi. I don’t want to carry a bulky USB keyboard in my backpack if I can avoid it. 
2. Why not just use Teleport, SynergyKM, or SSH? (http://abyssoft.com/software/teleport/ or http://synergykm.com)
a. I can’t install software on the target computer.
There is some equipment in the factory downstairs that we want to monitor, but changing the system in any way will void the manufacturer’s warranty. Instead of buying a hardware USB keylogger, I decided to build one using an Arduino and Raspberry Pi.
b. The host and target computers are on different networks.
The network connection in the office is rather bad, but usually problems only happen on WiFi or Ethernet alone, not both at the same time. So I keep my personal laptop connected to the Ethernet network, and the company laptop connected to WiFi. I could use an external keyboard and KM switch, but I like my laptop’s built-in keyboard more, and I need the desk space.
c. If your Raspberry Pi’s SD card becomes corrupt and you need to reinstall, you need the arrow keys and return key in order to set up SSH.


##Completed
1. Arduino USB keyboard and mouse control
2. Source computer apps on Mac, Windows, and Linux
3. Logging to a file

##To Do
1. Make a video of how this works
2. Modifier keys
3. Drag and drop
4. Scroll wheel
5. iPhone app (and DIY dock-to-serial wire)
6. Rockbox serial Rx (please help with this one!)
7. Rockbox plugin for on-screen keyboard to USB HID
8. Rockbox plugin for serial Rx to USB HID



##What’s the deal with Rockbox?
Currently, an Arduino with a 32U4 chip is used to convert serial to USB. The Arduino sketch receives serial bytes, decodes them, and sends them as keystrokes or mouse movement.
Rockbox has a USB Keypad Mode, which means that it is already possible to use an iPod (or other MP3 player) as a USB volume control/track/presentation controller.
http://download.rockbox.org/manual/rockbox-sansafuze/rockbox-buildch8.html#x11-1500008.5.7
But Rockbox does not support serial receive in plugins.
http://www.rockbox.org/irc/log-20150610#11:34:22

Ideally, I want this to fit in my pocket.
I will write a mobile KeyMouSerial app for my iPhone to send text out over the dock connector’s serial port. I will build a serial crossover cable to connect my iPhone’s serial line to my iPod’s remote connector. The iPod then becomes a serial-to-USB keyboard + mouse adapter. So I could connect my iPhone to my iPod to my Raspberry Pi, and use my iPhone as a touchscreen and touch keyboard for the RPi.

That setup could even work to turn an iPad into a touch keyboard that uses USB.

*** If anybody who has experience with Rockbox development reads this, please get in touch! ***
Email me at peterburk@gmail.com, and we can make this work. I’ve got a 4G, Photo, and 5.5G iPod that I’m happy to use for testing new builds.
