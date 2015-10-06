/*
* keyMouSerial
* Decode received serial bytes to a USB HID keyboard and mouse
* Copyleft Peter Burkimsher 2015-06-26
* peterburk@gmail.com
*
* Requires Arduino with 32U4. Tested on Leonardo and Micro. 
*/

// The previous mouse coordinates
int xValue;
int yValue;

// Track the current state to know what the next byte represents
boolean nextValueX = false;
boolean nextValueY = false;
boolean nextValueClick = false;
boolean nextValueKey = false;

// setup - Start listening to serial at 9600 baud. 
void setup() 
{
  // open the serial port:
  Serial1.begin(9600);
  //Serial.begin(9600);
  
  // initialize control over the mouse:
  Mouse.begin();
} // end setup

// loop - Continuously decode bytes until power is disconnected
void loop()
{
  // While the serial line has bytes coming in
  while (Serial1.available()) 
  {
    // Get the new byte
    char inChar = (char)Serial1.read();
    
    // If we are expecting a keystroke, not a mouse movement
    if (nextValueKey == true)
    {
      // Write the recieved character to the USB keyboard
      Keyboard.write(inChar);
      
      // Reset the state
      nextValueKey = false;
      
    } else {
      
      // If we are expecting a click of the left or right button
      if (nextValueClick == true) 
      {
        // Click the left mouse button when we receive an 'l'
        if (inChar == 'l') 
        {
          Mouse.click();
        }

        // Click the right mouse button when we receive an 'r'
        if (inChar == 'r') 
        {
          Mouse.click(MOUSE_RIGHT);
        }
      
        // Reset the state
        nextValueClick = false;
      } // end if we are expecting a mouse click
      
      // When the '?' delimiter is recieved, move the mouse
      if (inChar == '?') 
      {
        // Move the mouse
        Mouse.move(xValue, yValue, 0);
    
        //Serial.write(xValue);
        //Serial.write(yValue);
        
        // Reset the last value
        xValue = 0;
        yValue = 0;
        
        // Expect a coordinate next time the mouse moves
        nextValueX = true;
        
      } // end if the mouse moved
  
      // If we expect an x coordinate
      if (nextValueX == true) 
      {
        // Calculate the horizontal mouse movement
        xValue = 64 - (int)inChar;
        
        // Reset the state
        nextValueX = false;
      } // end if we are expecting an x coordinate

      // If we expect a y coordinate
      if (nextValueY == true) 
      {
        // Calculate the vertical mouse movement
        yValue = 64 - (int)inChar;
        
        // Reset the state
        nextValueY = false;
      }
      
      // If we receive an 'x', expect an x coordinate next time
      if (inChar == 'x') 
      {
        nextValueX = true;
      }  
      
      // If we receive a 'y', expect an y coordinate next time
      if (inChar == 'y') 
      {
        nextValueY = true;
      }
      
      // If we receive an 'b', expect a button click next time
      if (inChar == 'b') 
      {
        nextValueClick = true;
      }
      
      // If we receive a 'k', expect a keystroke next time
      if (inChar == 'k') 
      {
        nextValueKey = true;
      }
    
    } // end if expecting a keystroke
    
  } // end while serial is available
  
} // end loop

