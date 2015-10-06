/*
 * keyMouSerial.c
 * Copyleft Peter Burkimsher 2015-06-25
 * peterburk@gmail.com
 * 
 * Use ncurses to capture keyboard and mouse input and output the results over a serial port
 * Compile using:
cc -lm keyMouSerial.c -o keyMouSerial -lncurses
 *
 */

// Import libraries. Most importantly, curses is the keyboard and mouse tracker. 
#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <ctype.h>
#include <curses.h>

// Change this to set the output serial port
#define SERIAL1 "/dev/ttyUSB0"

// Function prototype. This would be in a .h file, but it's much easier to keep this short program in one file. 
char * keyCodeToString(int keyCode);

/*
* main: Start listening to keyboard and mouse events, and copying them to the serial port
*/
int main(void) 
{
	// The terminal window. Note that mouse tracking only works if the terminal is running inside a GUI (e.g. LXDE)
    WINDOW * terminalWindow;
    
    // The key code as an integer
    int keyCode;
    
    // The previous mouse coordinates
    int lastXValue = 0;
    int lastYValue = 0;

	// The current mouse coordinates
    int xValue = 0;
    int yValue = 0;

	// The character used is calculated from the difference of values
    int xChar = 0;
    int yChar = 0;
	
	// Change this to make the mouse move faster or slower
    int trackingSpeed = 10;
    
    // This is part of the mouse tracking protocol, which currently uses characters
    int characterOffset = 64;

	// Mouse mask
    mmask_t old;

	// The character to send to the serial port
    char* thisCharacter;

	// Open the serial port
    int serialPort = open(SERIAL1, O_RDWR | O_NOCTTY | O_NDELAY);

	// The serial port file reference that we write characters to
    FILE *serialPortFile;

	// The log file for saving a local keystroke log
    FILE *logFile;

	// Open the serial port file for writing
    serialPortFile = fopen(SERIAL1, "w");
	
	// Open the log file for writing
    logFile = fopen("log.txt", "w");

    //  Initialize ncurses
    if ( (terminalWindow = initscr()) == NULL ) 
    {
		fprintf(stderr, "Error initializing ncurses.\n");
		exit(EXIT_FAILURE);
    } // end if ncurses can't be initalised

	// Turn off key echoing
    noecho();
    // Enable the keypad for non-char keys
    keypad(terminalWindow, TRUE);
    cbreak();
    
    // Capture mouse events too
    mousemask (ALL_MOUSE_EVENTS | REPORT_MOUSE_POSITION, &old);

    //  Print a prompt and refresh() the screen
    mvaddstr(5, 10, "Press a key ('q' to quit)...");
    mvprintw(7, 10, "You pressed: ");
    refresh();


    //  Capture new inputs from the keyboard or mouse until user presses 'q'
    while ( (keyCode = getch()) != 'q' ) 
    {
		// If it was a mouse event
		if (keyCode == KEY_MOUSE)
		{
			// The mouse event
			MEVENT event;
			//assert (getmouse(&event) == OK);
			//mvprintw (0,0,"Mouse Event!\n");
			
			// If the mouse event can be read
			if( getmouse( &event ) == OK )
			{
				// Left mouse click
				if (event.bstate & BUTTON1_CLICKED)
				{
					// Show visual feedback about the left mouse click
					mvprintw(7, 10, "You clicked the mouse");

					// Send 'b' (button) to the serial port
					fprintf(serialPortFile, "%s", "b");
					fflush(serialPortFile);
					
					// Send 'l' (left click) to the serial port
					fprintf(serialPortFile, "%s", "l");
					fflush(serialPortFile);
				} else {
				
					// Right mouse click
					if (event.bstate & BUTTON3_CLICKED)
					{
						// Show visual feedback about the right mouse click
						mvprintw(7, 10, "You right clicked the mouse");

						// Send 'b' (button) to the serial port
						fprintf(serialPortFile, "%s", "b");
						fflush(serialPortFile);

						// Send 'r' (right click) to the serial port
						fprintf(serialPortFile, "%s", "r");
						fflush(serialPortFile);

					} else {
						
						// Read the mouse location and scale by the tracking speed
						xValue = event.x * trackingSpeed;
						yValue = event.y * trackingSpeed;
						
						// Calculate the difference from the last value
						xChar = lastXValue - xValue + characterOffset;
						yChar = lastYValue - yValue + characterOffset;
						
						// Show visual feedback about the mouse movement
						mvprintw(7, 10, "You moved the mouse %d %d", xChar, yChar);

						// Send 'x' (horizontal) to the serial port
						fprintf(serialPortFile, "%s", "x");
						fflush(serialPortFile);

						// Send the x coordinate character to the serial port 
						fprintf(serialPortFile, "%c", xChar);
						fflush(serialPortFile);

						// Send 'y' (vertical) to the serial port
						fprintf(serialPortFile, "%s", "y");
						fflush(serialPortFile);

						// Send the y coordinate character to the serial port 
						fprintf(serialPortFile, "%c", yChar);
						fflush(serialPortFile);

						// Send '?' (terminator) to the serial port
						fprintf(serialPortFile, "%s", "?");
						fflush(serialPortFile);
						
						// Update the last value variable
						lastXValue = xValue;
						lastYValue = yValue;
						
					} // end if right click or movement
				} // end if left click
			} // end if mouse event
		} else {

			/*  Delete the old response line, and print a new one  */

			deleteln();
			thisCharacter = keyCodeToString(keyCode);

			//write(serialPort, thisCharacter, 2);

			fprintf(serialPortFile, "%s", "k");
			fflush(serialPortFile);

			fprintf(serialPortFile, "%s", thisCharacter);
			fflush(serialPortFile);

			fprintf(logFile, "%s", thisCharacter);
			fflush(logFile);

			mvprintw(7, 10, "You pressed: 0x%x (%s)", keyCode, thisCharacter);
			refresh();
		} // end if mouse or keyboard
    } // end while key pressed isn't 'q'


    //  Clean up the GUI
    delwin(terminalWindow);
    endwin();
    refresh();
	
	// Close the serial port
    close (serialPort);

	// Quit
    return EXIT_SUCCESS;
} // end function main


/*  Struct to hold keycode/keyname information  */

struct keydesc 
{
    int  code;
    char name[20];
};


/*
 * keyCodeToString - Returns a string describing a character passed to it
 * @param int keyCode: The integer value of the key pressed
 * @return char*: The string value of the key pressed
 */
char* keyCodeToString(int keyCode) 
{
    //  Define a selection of non-printable keys we will handle
    static struct keydesc keys[] = 
    { 
		{ KEY_UP,        "Up arrow"        },
		{ KEY_DOWN,      "Down arrow"      },
		{ KEY_LEFT,      "Left arrow"      },
		{ KEY_RIGHT,     "Right arrow"     },
		{ KEY_HOME,      "Home"            },
		{ KEY_END,       "End"             },
		{ KEY_BACKSPACE, "\x8"       },
		{ KEY_IC,        "Insert"          },
		{ KEY_DC,        "Delete"          },
		{ KEY_NPAGE,     "Page down"       },
		{ KEY_PPAGE,     "Page up"         },
		{ KEY_F(1),      "Function key 1"  },
		{ KEY_F(2),      "Function key 2"  },
		{ KEY_F(3),      "Function key 3"  },
		{ KEY_F(4),      "Function key 4"  },
		{ KEY_F(5),      "Function key 5"  },
		{ KEY_F(6),      "Function key 6"  },
		{ KEY_F(7),      "Function key 7"  },
		{ KEY_F(8),      "Function key 8"  },
		{ KEY_F(9),      "Function key 9"  },
		{ KEY_F(10),     "Function key 10" },
		{ KEY_F(11),     "Function key 11" },
		{ KEY_F(12),     "Function key 12" },
		{ 0xa, "\n"},
		{ -1,            "<unsupported>"   }
    };
    
    // The key pressed as a character array
    static char keych[2] = {0};
    
    // If the key is printable, and not in our list
    if ( isprint(keyCode) && !(keyCode & KEY_CODE_YES)) 
    {
    	// Return the printable character
		keych[0] = keyCode;
		return keych;
    } else {

		// If the character is not printable, loop through our array of structs
		int thisCode = 0;
		do {
			
			// If the key code is found in the non-printable array
			if ( keys[thisCode].code == keyCode )
			{
				return keys[thisCode].name;
			} // end if the non-printable key is found
			
			thisCode++;
		} while ( keys[thisCode].code != -1 );
		
		// Return the name of the found code
		return keys[thisCode].name;
    } // end if the key is printable
    
    // We shouldn't get here
    return NULL;
} // end function keyCodeToString
